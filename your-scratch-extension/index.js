const BlockType = require('../../extension-support/block-type');
const ArgumentType = require('../../extension-support/argument-type');
const TargetType = require('../../extension-support/target-type');
//import 'regenerator-runtime/runtime';
//Robados de los oficiales
const Cast = require('../../util/cast');
const MathUtil = require('../../util/math-util');
const Timer = require('../../util/timer');
//const util = require('../../engine/block-utility');+
// Chanchada con el lapiz INICIO
const Clone = require('../../util/clone');
const Color = require('../../util/color');
const formatMessage = require('format-message');
const RenderedTarget = require('../../sprites/rendered-target');
const log = require('../../util/log');
const StageLayering = require('../../engine/stage-layering');
//BLE
const SERVICIO_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const CARACTERISTICA_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
require('regenerator-runtime/runtime'); 
// Variable para guardar la referencia al dispositivo ya emparejado
let dispositivoBLE = null;
//BLE


const ColorParam = {
    COLOR: 'color',
    SATURATION: 'saturation',
    BRIGHTNESS: 'brightness',
    TRANSPARENCY: 'transparency'
};

/**
 * @typedef {object} PenState - the pen state associated with a particular target.
 * @property {Boolean} penDown - tracks whether the pen should draw for this target.
 * @property {number} color - the current color (hue) of the pen.
 * @property {PenAttributes} penAttributes - cached pen attributes for the renderer. This is the authoritative value for
 *   diameter but not for pen color.
 */

/**
 * Host for the Pen-related blocks in Scratch 3.0
 * @param {Runtime} runtime - the runtime instantiating this block package.
 * @constructor
 */

// Chanchada con el lapiz FINAL
class Scratch3YourExtension {
    
    static get EXTENSION_ID () {  
        return 'AttaBotSTEM';  
    }  
    


    constructor (runtime) {
        // put any setup for your extension here

// Chanchada con el lapiz INICIO /////////////////////////////////////
/**
         * The runtime instantiating this block package.
         * @type {Runtime}
         */
        this.runtime = runtime;

        /**
         * The ID of the renderer Drawable corresponding to the pen layer.
         * @type {int}
         * @private
         */
        this._penDrawableId = -1;

        /**
         * The ID of the renderer Skin corresponding to the pen layer.
         * @type {int}
         * @private
         */
        this._penSkinId = -1;

        this._onTargetCreated = this._onTargetCreated.bind(this);
        this._onTargetMoved = this._onTargetMoved.bind(this);

        runtime.on('targetWasCreated', this._onTargetCreated);
        runtime.on('RUNTIME_DISPOSED', this.clear.bind(this));

    
// Chanchada con el lapiz FINAL ///////////////////////////////////////

    }// fin constructor

    //Chanchada con lapiz inicio
    static get DEFAULT_PEN_STATE () {
        return {
            penDown: false,
            color: 66.66,
            saturation: 100,
            brightness: 100,
            transparency: 0,
            _shade: 50, // Used only for legacy `change shade by` blocks
            penAttributes: {
                color4f: [0, 0, 1, 1],
                diameter: 1
            }
        };
    }

   /**
     * The minimum and maximum allowed pen size.
     * The maximum is twice the diagonal of the stage, so that even an
     * off-stage sprite can fill it.
     * @type {{min: number, max: number}}
     */
    static get PEN_SIZE_RANGE () {
        return {min: 1, max: 1200};
    }

    /**
     * The key to load & store a target's pen-related state.
     * @type {string}
     */
    static get STATE_KEY () {
        return 'Scratch.pen';
    }

    /**
     * Clamp a pen size value to the range allowed by the pen.
     * @param {number} requestedSize - the requested pen size.
     * @returns {number} the clamped size.
     * @private
     */
    _clampPenSize (requestedSize) {
        return MathUtil.clamp(
            requestedSize,
            Scratch3YourExtension.PEN_SIZE_RANGE.min,
            Scratch3YourExtension.PEN_SIZE_RANGE.max
        );
    }

    /**
     * Retrieve the ID of the renderer "Skin" corresponding to the pen layer. If
     * the pen Skin doesn't yet exist, create it.
     * @returns {int} the Skin ID of the pen layer, or -1 on failure.
     * @private
     */
    _getPenLayerID () {
        if (this._penSkinId < 0 && this.runtime.renderer) {
            this._penSkinId = this.runtime.renderer.createPenSkin();
            this._penDrawableId = this.runtime.renderer.createDrawable(StageLayering.PEN_LAYER);
            this.runtime.renderer.updateDrawableSkinId(this._penDrawableId, this._penSkinId);
        }
        return this._penSkinId;
    }

    /**
     * @param {Target} target - collect pen state for this target. Probably, but not necessarily, a RenderedTarget.
     * @returns {PenState} the mutable pen state associated with that target. This will be created if necessary.
     * @private
     */
    _getPenState (target) {
        let penState = target.getCustomState(Scratch3YourExtension.STATE_KEY);
        if (!penState) {
            penState = Clone.simple(Scratch3YourExtension.DEFAULT_PEN_STATE);
            target.setCustomState(Scratch3YourExtension.STATE_KEY, penState);
        }
        return penState;
    }

    /**
     * When a pen-using Target is cloned, clone the pen state.
     * @param {Target} newTarget - the newly created target.
     * @param {Target} [sourceTarget] - the target used as a source for the new clone, if any.
     * @listens Runtime#event:targetWasCreated
     * @private
     */
    _onTargetCreated (newTarget, sourceTarget) {
        if (sourceTarget) {
            const penState = sourceTarget.getCustomState(Scratch3YourExtension.STATE_KEY);
            if (penState) {
                newTarget.setCustomState(Scratch3YourExtension.STATE_KEY, Clone.simple(penState));
                if (penState.penDown) {
                    newTarget.addListener(RenderedTarget.EVENT_TARGET_MOVED, this._onTargetMoved);
                }
            }
        }
    }

    /**
     * Handle a target which has moved. This only fires when the pen is down.
     * @param {RenderedTarget} target - the target which has moved.
     * @param {number} oldX - the previous X position.
     * @param {number} oldY - the previous Y position.
     * @param {boolean} isForce - whether the movement was forced.
     * @private
     */
    _onTargetMoved (target, oldX, oldY, isForce) {
        // Only move the pen if the movement isn't forced (ie. dragged).
        if (!isForce) {
            const penSkinId = this._getPenLayerID();
            if (penSkinId >= 0) {
                const penState = this._getPenState(target);
                this.runtime.renderer.penLine(penSkinId, penState.penAttributes, oldX, oldY, target.x, target.y);
                this.runtime.requestRedraw();
            }
        }
    }

    /**
     * Wrap a color input into the range (0,100).
     * @param {number} value - the value to be wrapped.
     * @returns {number} the wrapped value.
     * @private
     */
    _wrapColor (value) {
        return MathUtil.wrapClamp(value, 0, 100);
    }

    /**
     * Initialize color parameters menu with localized strings
     * @returns {array} of the localized text and values for each menu element
     * @private
     */
    _initColorParam () {
        return [
            {
                text: formatMessage({
                    id: 'pen.colorMenu.color',
                    default: 'color',
                    description: 'label for color element in color picker for pen extension'
                }),
                value: ColorParam.COLOR
            },
            {
                text: formatMessage({
                    id: 'pen.colorMenu.saturation',
                    default: 'saturation',
                    description: 'label for saturation element in color picker for pen extension'
                }),
                value: ColorParam.SATURATION
            },
            {
                text: formatMessage({
                    id: 'pen.colorMenu.brightness',
                    default: 'brightness',
                    description: 'label for brightness element in color picker for pen extension'
                }),
                value: ColorParam.BRIGHTNESS
            },
            {
                text: formatMessage({
                    id: 'pen.colorMenu.transparency',
                    default: 'transparency',
                    description: 'label for transparency element in color picker for pen extension'
                }),
                value: ColorParam.TRANSPARENCY

            }
        ];
    }

    /**
     * Clamp a pen color parameter to the range (0,100).
     * @param {number} value - the value to be clamped.
     * @returns {number} the clamped value.
     * @private
     */
    _clampColorParam (value) {
        return MathUtil.clamp(value, 0, 100);
    }

    /**
     * Convert an alpha value to a pen transparency value.
     * Alpha ranges from 0 to 1, where 0 is transparent and 1 is opaque.
     * Transparency ranges from 0 to 100, where 0 is opaque and 100 is transparent.
     * @param {number} alpha - the input alpha value.
     * @returns {number} the transparency value.
     * @private
     */
    _alphaToTransparency (alpha) {
        return (1.0 - alpha) * 100.0;
    }

    /**
     * Convert a pen transparency value to an alpha value.
     * Alpha ranges from 0 to 1, where 0 is transparent and 1 is opaque.
     * Transparency ranges from 0 to 100, where 0 is opaque and 100 is transparent.
     * @param {number} transparency - the input transparency value.
     * @returns {number} the alpha value.
     * @private
     */
    _transparencyToAlpha (transparency) {
        return 1.0 - (transparency / 100.0);
    }

    /**
     * @returns {object} metadata for this extension and its blocks.
     */



    //chachada con lapiz final

    getInfo () {
        return {
            // unique ID for your extension
            // Must not contain a '.' character.
            id: 'AttaBotSTEM',

            // name that will be displayed in the Scratch UI
            name: 'AttaBot',

            // colours to use for your extension blocks
            color1: '#000099',
            color2: '#660066',
            color3: '#a0a0a0',

            // icons to display
            blockIconURI: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAFCAAAAACyOJm3AAAAFklEQVQYV2P4DwMMEMgAI/+DEUIMBgAEWB7i7uidhAAAAABJRU5ErkJggg==',
            menuIconURI: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAFCAAAAACyOJm3AAAAFklEQVQYV2P4DwMMEMgAI/+DEUIMBgAEWB7i7uidhAAAAABJRU5ErkJggg==',

            // link to documentation content for this extension.
            docsURI: 'https://github.com/dalelane/scratch-extension-development',

            // your Scratch blocks, in the order they will be displayed
            blocks: [

// Bloques para Debug/desarrollo//******************************** 
// */
                {    // name of the function where your block code lives
                    opcode: 'AttaMensajeBLE',
                    blockType: BlockType.REPORTER,

                    // label to display on the block
                    text: 'string de comandos',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin MensajeBLE

                {    // name of the function where your block code lives
                    opcode: 'AttaReconectar',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Reconectar AttaBot',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin Reconectar

  // fin blosque de debug/desarrollo***************************************                    

                {    // name of the function where your block code lives
                    opcode: 'AttaComandoBLE',
                    blockType: BlockType.LOOP,

                    // label to display on the block
                    text: 'Modo de transmisión de comandos al AttaBot',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin envioBle

                {    // name of the function where your block code lives
                    opcode: 'AttaSimulacion',
                    blockType: BlockType.LOOP,

                    // label to display on the block
                    text: 'Modo de simular comandos del AttaBot',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin envioBle


                { // name of the function where your block code lives
                    opcode: 'AttaEnvioBLE',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Transmitir por BLE [mensajeBle]',

                    // true if this block should end a stack
                    terminal: true,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        mensajeBle: {
                            defaultValue: ' ',
                            type: ArgumentType.STRING
                        }
                    }
                }, // Fin envioBle  


                {
                    // name of the function where your block code lives
                    opcode: 'AttaAvanzar',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Avanzar [distancia_cm] cm',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        distancia_cm: {
                            defaultValue: 10,
                            type: ArgumentType.NUMBER
                        }
                    } 
                }, // Fin AttaAvanzar
                {
                    // name of the function where your block code lives
                    opcode: 'AttaRetroceder',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Retroceder [distancia_cm] cm',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        distancia_cm: {
                            defaultValue: 10,
                            type: ArgumentType.NUMBER
                        }
                    } 
                }, // Fin AttaRetroceder         
                
                
                {
                    // name of the function where your block code lives
                    opcode: 'AttaGirarIzquierda',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Girar izquierda [angulo]°',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        angulo: {
                            defaultValue: 90,
                            type: ArgumentType.NUMBER
                        }
                    } 
                }, // Fin AttaGirarIzquierda    


                {
                    // name of the function where your block code lives
                    opcode: 'AttaGirarDerecha',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Girar derecha [angulo]°',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        angulo: {
                            defaultValue: 90,
                            type: ArgumentType.NUMBER
                        }
                    } 
                }, // Fin AttaGirarDerecha+

                {// name of the function where your block code lives
                    opcode: 'AttaFor',
                    blockType: BlockType.LOOP,

                    // label to display on the block
                    text: 'Repetir [repeticiones] veces',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        repeticiones: {
                            defaultValue: 1,
                            type: ArgumentType.NUMBER
                        }
                    } 
                }, // Fin For

                               
                {    // name of the function where your block code lives
                    opcode: 'AttaDeteccionIniciada',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Iniciar detección de obstáculos',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin DeteccionIniciada

                {    // name of the function where your block code lives
                    opcode: 'AttaDeteccionFinalizada',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Finalizar detección de obstáculos',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin DeteccionFinalizada

                {    // name of the function where your block code lives
                    opcode: 'AttaLapizActivado',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Activar lápiz',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin LapizActivado

                {    // name of the function where your block code lives
                    opcode: 'AttaLapizDesactivado',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Desactivar lápiz',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],
                    // arguments used in the block} 
                }, // Fin LapizDesactivado
                
                {    // name of the function where your block code lives
                    opcode: 'AttaIf',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 1,

                    // label to display on the block
                    text: ['Si sensores [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }
                        
                        
                    } 
                }, // Fin IF

                {    // name of the function where your block code lives
                    opcode: 'AttaIfElse',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 2,

                    // label to display on the block
                    text: ['Si sensores [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]', 
                        'si no'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }                        
                    } 
                }, // Fin IFElse

                {    // name of the function where your block code lives
                    opcode: 'AttaIfElseIf',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 2,

                    // label to display on the block
                    text: ['Si sensores [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]',
                        'Si no, si sensores [condicionSensorIzqElse] y [condicionSensorDerElse]'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
               arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                         condicionSensorIzqElse: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDerElse: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }                        
                    } 
                }, // Fin IfElseIf


 {    // name of the function where your block code lives
                    opcode: 'AttaIfElseIfElse',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 3,

                    // label to display on the block
                    text: ['Si sensores [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]',
                        'Si no, si sensores [condicionSensorIzqElse] y [condicionSensorDerElse]',
                        'Si no'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
               arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                         condicionSensorIzqElse: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDerElse: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }                        
                    } 
                }, // Fin IfElseIfElse               


                {  
                    opcode: 'AttaWhile',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 1,

                    // label to display on the block
                    text: ['Mientras sensores [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }                         
                    } 
                }, // Fin While

                {  
                    opcode: 'AttaWhileNot',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 1,

                    // label to display on the block
                    text: 'Mientras sensores no [colorSensorIzquierdo] [condicionSensorIzq] y [colorSensorDerecho][condicionSensorDer][colorBlanco][colorNegro]',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        colorSensorIzquierdo: {
                            defaultValue:'#80FF00',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorSensorDerecho: {
                            defaultValue:'#FF0000',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorBlanco: {
                            defaultValue:'#FFFFFF',
                            type: ArgumentType.COLOR,
                            
                        },
                        colorNegro: {
                            defaultValue:'#000000',
                            type: ArgumentType.COLOR,
                            
                        }     
                    } 
                }, // Fin While

                {    // name of the function where your block code lives
                    opcode: 'AttaHerramienta',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Herramienta [herramientaAccion]',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        herramientaAccion: {
                            defaultValue:'0',
                            type: ArgumentType.NUMBER,
                            menu: 'menuHerramientaAcciones'
                        }
                    } 
                }, // Fin Herramienta


// Chanchada con el lapiz Inicio////////////////////
{
                    opcode: 'clear',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.clear',
                        default: 'erase all',
                        description: 'erase all pen trails and stamps'
                    })
                },
                {
                    opcode: 'stamp',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.stamp',
                        default: 'stamp',
                        description: 'render current costume on the background'
                    }),
                    filter: [TargetType.SPRITE]
                },
                /*
                {
                    opcode: 'penDown',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.penDown',
                        default: 'pen down',
                        description: 'start leaving a trail when the sprite moves'
                    }),
                    filter: [TargetType.SPRITE]
                },
                {
                    opcode: 'penUp',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.penUp',
                        default: 'pen up',
                        description: 'stop leaving a trail behind the sprite'
                    }),
                    filter: [TargetType.SPRITE]
                }, */
                {
                    opcode: 'setPenColorToColor',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.setColor',
                        default: 'set pen color to [COLOR]',
                        description: 'set the pen color to a particular (RGB) value'
                    }),
                    arguments: {
                        COLOR: {
                            type: ArgumentType.COLOR
                        }
                    },
                    filter: [TargetType.SPRITE]
                },
                {
                    opcode: 'changePenColorParamBy',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.changeColorParam',
                        default: 'change pen [COLOR_PARAM] by [VALUE]',
                        description: 'change the state of a pen color parameter'
                    }),
                    arguments: {
                        COLOR_PARAM: {
                            type: ArgumentType.STRING,
                            menu: 'colorParam',
                            defaultValue: ColorParam.COLOR
                        },
                        VALUE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 10
                        }
                    },
                    filter: [TargetType.SPRITE]
                },
                {
                    opcode: 'setPenColorParamTo',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.setColorParam',
                        default: 'set pen [COLOR_PARAM] to [VALUE]',
                        description: 'set the state for a pen color parameter e.g. saturation'
                    }),
                    arguments: {
                        COLOR_PARAM: {
                            type: ArgumentType.STRING,
                            menu: 'colorParam',
                            defaultValue: ColorParam.COLOR
                        },
                        VALUE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 50
                        }
                    },
                    filter: [TargetType.SPRITE]
                },
                {
                    opcode: 'changePenSizeBy',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.changeSize',
                        default: 'change pen size by [SIZE]',
                        description: 'change the diameter of the trail left by a sprite'
                    }),
                    arguments: {
                        SIZE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    filter: [TargetType.SPRITE]
                },
                {
                    opcode: 'setPenSizeTo',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.setSize',
                        default: 'set pen size to [SIZE]',
                        description: 'set the diameter of a trail left by a sprite'
                    }),
                    arguments: {
                        SIZE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    filter: [TargetType.SPRITE]
                },
                /* Legacy blocks, should not be shown in flyout */
                {
                    opcode: 'setPenShadeToNumber',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.setShade',
                        default: 'set pen shade to [SHADE]',
                        description: 'legacy pen blocks - set pen shade'
                    }),
                    arguments: {
                        SHADE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    hideFromPalette: true
                },
                {
                    opcode: 'changePenShadeBy',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.changeShade',
                        default: 'change pen shade by [SHADE]',
                        description: 'legacy pen blocks - change pen shade'
                    }),
                    arguments: {
                        SHADE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    hideFromPalette: true
                },
                {
                    opcode: 'setPenHueToNumber',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.setHue',
                        default: 'set pen color to [HUE]',
                        description: 'legacy pen blocks - set pen color to number'
                    }),
                    arguments: {
                        HUE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    hideFromPalette: true
                },
                {
                    opcode: 'changePenHueBy',
                    blockType: BlockType.COMMAND,
                    text: formatMessage({
                        id: 'pen.changeHue',
                        default: 'change pen color by [HUE]',
                        description: 'legacy pen blocks - change pen color'
                    }),
                    arguments: {
                        HUE: {
                            type: ArgumentType.NUMBER,
                            defaultValue: 1
                        }
                    },
                    hideFromPalette: true
                }



// Chanchada con el lapiz Fin////////////////////




          
            
            ],
            // Menús de selección
            menus: {
                menuHerramientaAcciones: { 
                            acceptReporters: true,
                            items:[//Valores 1xx accion rotacion positiva, 0xx accion rotacion negativa
                            {text: 'Garra abrir', value: 101},
                            {text: 'Garra cerrar', value: 1},
                            {text: 'Grúa subir', value: 102},
                            {text: 'Grúa bajar', value: 2},
                            {text: 'Ninguna', value: 0}
                            ]
                        },

                menuCondiciones: {
                    items:
                    [
                    {text: 'blanco' , value: 1},
                    {text: 'negro' , value: 0}
                    ]
                },
// Chanchada con el lapiz Inicio////////////////////

                colorParam: {
                    acceptReporters: true,
                    items: this._initColorParam()
                }

// Chanchada con el lapiz Fin////////////////////

                }
        };
    }
// Lógica de la funciones que los botones llaman y la funcionalidad de la extensión

    varModoTransmision = false;
    varMensajeBle = 'ATINI'; 

    /**
     * implementation of the block with the opcode that matches this name
     *  this will be called when the block is used
     */
    AttaAvanzar ({distancia_cm},util) {
        if(this.varModoTransmision){
            this.FormatearComando('AV', distancia_cm);
        }  else{
            const steps = distancia_cm;
            const radians = MathUtil.degToRad(90 - util.target.direction);
            const dx = steps * Math.cos(radians);
            const dy = steps * Math.sin(radians);
            util.target.setXY(util.target.x + dx, util.target.y + dy);    //comportamiento gráfico
        }           

    };

    AttaRetroceder({distancia_cm},util){
        if(this.varModoTransmision){
            this.FormatearComando('RE', distancia_cm);
        }  else{
            const steps = -distancia_cm;
            const radians = MathUtil.degToRad(90 - util.target.direction);
            const dx = steps * Math.cos(radians);
            const dy = steps * Math.sin(radians);
            util.target.setXY(util.target.x + dx, util.target.y + dy);    //comportamiento gráfico
        }  

    };

    AttaGirarIzquierda({angulo},util){
        if(this.varModoTransmision){
            this.FormatearComando('GI', angulo);
        }  else{
            util.target.setDirection(util.target.direction - Cast.toNumber(angulo));//comportamiento gráfico
        }  

    };

    AttaGirarDerecha({angulo},util){
        if(this.varModoTransmision){
            this.FormatearComando('GD', angulo);
        }  else{
            util.target.setDirection(util.target.direction + Cast.toNumber(angulo));//comportamiento gráfico
        } 

    };

    AttaFor ({repeticiones}, util){
        if(this.varModoTransmision){
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque
                this.FormatearComando('CI', repeticiones);
                util.startBranch(1, true);
            }else{ // segunda iteracion
                this.varMensajeBle += 'CIFIN';
            }            
            
        }  else{
            //comportamiento gráfico
            // Initialize loop
        if (typeof util.stackFrame.loopCounter === 'undefined') {
            util.stackFrame.loopCounter = repeticiones;
        }
        // Only execute once per frame.
        // When the branch finishes, `repeat` will be executed again and
        // the second branch will be taken, yielding for the rest of the frame.
        // Decrease counter
        util.stackFrame.loopCounter--;
        // If we still have some left, start the branch.
        if (util.stackFrame.loopCounter >= 0) {
            util.startBranch(1, true);
        }
        } //fin comportamiento gráfico      

    };

//Con bloques C .LOOP puedo hacer obligatorio que si se activa algo tambien deba apagarse. Necesario?
    AttaDeteccionIniciada(args, util){
        if (this.varModoTransmision){
            this.varMensajeBle += 'OBINI'
        } else { // comportamiento gráfico

        } 
    };
    AttaDeteccionFinalizada(args,util){
        if (this.varModoTransmision){
            this.varMensajeBle += 'OBFIN'
        } else { // comportamiento gráfico

        } 

    };
    AttaLapizActivado(args,util){
        if (this.varModoTransmision){
            this.varMensajeBle += 'HEINI'
        } else { // comportamiento gráfico
            this.penDown (args, util)
    
        } 
    };

       AttaLapizDesactivado(args,util){
        if (this.varModoTransmision){
            this.varMensajeBle += 'HEFIN'
        } else { // comportamiento gráfico
            this.penUp (args, util)
        } 
    };
////////////////////////// Inicio Chanchada con el lapiz

 clear () {
        const penSkinId = this._getPenLayerID();
        if (penSkinId >= 0) {
            this.runtime.renderer.penClear(penSkinId);
            this.runtime.requestRedraw();
        }
    }

    /**
     * The pen "stamp" block stamps the current drawable's image onto the pen layer.
     * @param {object} args - the block arguments.
     * @param {object} util - utility object provided by the runtime.
     */
    stamp (args, util) {
        const penSkinId = this._getPenLayerID();
        if (penSkinId >= 0) {
            const target = util.target;
            this.runtime.renderer.penStamp(penSkinId, target.drawableID);
            this.runtime.requestRedraw();
        }
    }

    /**
     * The pen "pen down" block causes the target to leave pen trails on future motion.
     * @param {object} args - the block arguments.
     * @param {object} util - utility object provided by the runtime.
     */
    penDown (args, util) {
        const target = util.target;
        const penState = this._getPenState(target);

        if (!penState.penDown) {
            penState.penDown = true;
            target.addListener(RenderedTarget.EVENT_TARGET_MOVED, this._onTargetMoved);
        }

        const penSkinId = this._getPenLayerID();
        if (penSkinId >= 0) {
            this.runtime.renderer.penPoint(penSkinId, penState.penAttributes, target.x, target.y);
            this.runtime.requestRedraw();
        }
    }

    /**
     * The pen "pen up" block stops the target from leaving pen trails.
     * @param {object} args - the block arguments.
     * @param {object} util - utility object provided by the runtime.
     */
    penUp (args, util) {
        const target = util.target;
        const penState = this._getPenState(target);

        if (penState.penDown) {
            penState.penDown = false;
            target.removeListener(RenderedTarget.EVENT_TARGET_MOVED, this._onTargetMoved);
        }
    }

    /**
     * The pen "set pen color to {color}" block sets the pen to a particular RGB color.
     * The transparency is reset to 0.
     * @param {object} args - the block arguments.
     *  @property {int} COLOR - the color to set, expressed as a 24-bit RGB value (0xRRGGBB).
     * @param {object} util - utility object provided by the runtime.
     */
    setPenColorToColor (args, util) {
        const penState = this._getPenState(util.target);
        const rgb = Cast.toRgbColorObject(args.COLOR);
        const hsv = Color.rgbToHsv(rgb);
        penState.color = (hsv.h / 360) * 100;
        penState.saturation = hsv.s * 100;
        penState.brightness = hsv.v * 100;
        if (Object.prototype.hasOwnProperty.call(rgb, 'a')) {
            penState.transparency = 100 * (1 - (rgb.a / 255.0));
        } else {
            penState.transparency = 0;
        }

        // Set the legacy "shade" value the same way scratch 2 did.
        penState._shade = penState.brightness / 2;

        this._updatePenColor(penState);
    }

    /**
     * Update the cached color from the color, saturation, brightness and transparency values
     * in the provided PenState object.
     * @param {PenState} penState - the pen state to update.
     * @private
     */
    _updatePenColor (penState) {
        const rgb = Color.hsvToRgb({
            h: penState.color * 360 / 100,
            s: penState.saturation / 100,
            v: penState.brightness / 100
        });
        penState.penAttributes.color4f[0] = rgb.r / 255.0;
        penState.penAttributes.color4f[1] = rgb.g / 255.0;
        penState.penAttributes.color4f[2] = rgb.b / 255.0;
        penState.penAttributes.color4f[3] = this._transparencyToAlpha(penState.transparency);
    }

    /**
     * Set or change a single color parameter on the pen state, and update the pen color.
     * @param {ColorParam} param - the name of the color parameter to set or change.
     * @param {number} value - the value to set or change the param by.
     * @param {PenState} penState - the pen state to update.
     * @param {boolean} change - if true change param by value, if false set param to value.
     * @private
     */
    _setOrChangeColorParam (param, value, penState, change) {
        switch (param) {
        case ColorParam.COLOR:
            penState.color = this._wrapColor(value + (change ? penState.color : 0));
            break;
        case ColorParam.SATURATION:
            penState.saturation = this._clampColorParam(value + (change ? penState.saturation : 0));
            break;
        case ColorParam.BRIGHTNESS:
            penState.brightness = this._clampColorParam(value + (change ? penState.brightness : 0));
            break;
        case ColorParam.TRANSPARENCY:
            penState.transparency = this._clampColorParam(value + (change ? penState.transparency : 0));
            break;
        default:
            log.warn(`Tried to set or change unknown color parameter: ${param}`);
        }
        this._updatePenColor(penState);
    }

    /**
     * The "change pen {ColorParam} by {number}" block changes one of the pen's color parameters
     * by a given amound.
     * @param {object} args - the block arguments.
     *  @property {ColorParam} COLOR_PARAM - the name of the selected color parameter.
     *  @property {number} VALUE - the amount to change the selected parameter by.
     * @param {object} util - utility object provided by the runtime.
     */
    changePenColorParamBy (args, util) {
        const penState = this._getPenState(util.target);
        this._setOrChangeColorParam(args.COLOR_PARAM, Cast.toNumber(args.VALUE), penState, true);
    }

    /**
     * The "set pen {ColorParam} to {number}" block sets one of the pen's color parameters
     * to a given amound.
     * @param {object} args - the block arguments.
     *  @property {ColorParam} COLOR_PARAM - the name of the selected color parameter.
     *  @property {number} VALUE - the amount to set the selected parameter to.
     * @param {object} util - utility object provided by the runtime.
     */
    setPenColorParamTo (args, util) {
        const penState = this._getPenState(util.target);
        this._setOrChangeColorParam(args.COLOR_PARAM, Cast.toNumber(args.VALUE), penState, false);
    }

    /**
     * The pen "change pen size by {number}" block changes the pen size by the given amount.
     * @param {object} args - the block arguments.
     *  @property {number} SIZE - the amount of desired size change.
     * @param {object} util - utility object provided by the runtime.
     */
    changePenSizeBy (args, util) {
        const penAttributes = this._getPenState(util.target).penAttributes;
        penAttributes.diameter = this._clampPenSize(penAttributes.diameter + Cast.toNumber(args.SIZE));
    }

    /**
     * The pen "set pen size to {number}" block sets the pen size to the given amount.
     * @param {object} args - the block arguments.
     *  @property {number} SIZE - the amount of desired size change.
     * @param {object} util - utility object provided by the runtime.
     */
    setPenSizeTo (args, util) {
        const penAttributes = this._getPenState(util.target).penAttributes;
        penAttributes.diameter = this._clampPenSize(Cast.toNumber(args.SIZE));
    }

    /* LEGACY OPCODES */
    /**
     * Scratch 2 "hue" param is equivelant to twice the new "color" param.
     * @param {object} args - the block arguments.
     *  @property {number} HUE - the amount to set the hue to.
     * @param {object} util - utility object provided by the runtime.
     */
    setPenHueToNumber (args, util) {
        const penState = this._getPenState(util.target);
        const hueValue = Cast.toNumber(args.HUE);
        const colorValue = hueValue / 2;
        this._setOrChangeColorParam(ColorParam.COLOR, colorValue, penState, false);
        this._setOrChangeColorParam(ColorParam.TRANSPARENCY, 0, penState, false);
        this._legacyUpdatePenColor(penState);
    }

    /**
     * Scratch 2 "hue" param is equivelant to twice the new "color" param.
     * @param {object} args - the block arguments.
     *  @property {number} HUE - the amount of desired hue change.
     * @param {object} util - utility object provided by the runtime.
     */
    changePenHueBy (args, util) {
        const penState = this._getPenState(util.target);
        const hueChange = Cast.toNumber(args.HUE);
        const colorChange = hueChange / 2;
        this._setOrChangeColorParam(ColorParam.COLOR, colorChange, penState, true);

        this._legacyUpdatePenColor(penState);
    }

    /**
     * Use legacy "set shade" code to calculate RGB value for shade,
     * then convert back to HSV and store those components.
     * It is important to also track the given shade in penState._shade
     * because it cannot be accurately backed out of the new HSV later.
     * @param {object} args - the block arguments.
     *  @property {number} SHADE - the amount to set the shade to.
     * @param {object} util - utility object provided by the runtime.
     */
    setPenShadeToNumber (args, util) {
        const penState = this._getPenState(util.target);
        let newShade = Cast.toNumber(args.SHADE);

        // Wrap clamp the new shade value the way scratch 2 did.
        newShade = newShade % 200;
        if (newShade < 0) newShade += 200;

        // And store the shade that was used to compute this new color for later use.
        penState._shade = newShade;

        this._legacyUpdatePenColor(penState);
    }

    /**
     * Because "shade" cannot be backed out of hsv consistently, use the previously
     * stored penState._shade to make the shade change.
     * @param {object} args - the block arguments.
     *  @property {number} SHADE - the amount of desired shade change.
     * @param {object} util - utility object provided by the runtime.
     */
    changePenShadeBy (args, util) {
        const penState = this._getPenState(util.target);
        const shadeChange = Cast.toNumber(args.SHADE);
        this.setPenShadeToNumber({SHADE: penState._shade + shadeChange}, util);
    }

    /**
     * Update the pen state's color from its hue & shade values, Scratch 2.0 style.
     * @param {object} penState - update the HSV & RGB values in this pen state from its hue & shade values.
     * @private
     */
    _legacyUpdatePenColor (penState) {
        // Create the new color in RGB using the scratch 2 "shade" model
        let rgb = Color.hsvToRgb({h: penState.color * 360 / 100, s: 1, v: 1});
        const shade = (penState._shade > 100) ? 200 - penState._shade : penState._shade;
        if (shade < 50) {
            rgb = Color.mixRgb(Color.RGB_BLACK, rgb, (10 + shade) / 60);
        } else {
            rgb = Color.mixRgb(rgb, Color.RGB_WHITE, (shade - 50) / 60);
        }

        // Update the pen state according to new color
        const hsv = Color.rgbToHsv(rgb);
        penState.color = 100 * hsv.h / 360;
        penState.saturation = 100 * hsv.s;
        penState.brightness = 100 * hsv.v;

        this._updatePenColor(penState);
    }
////////////////////////// Fin Chanchada con el lapiz


    AttaIf(args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'IF'+ '0' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);                  
                } else { //segunda iteracion> If fin
                    this.varMensajeBle += 'IFFIN';
                }

        } else { // comportamiento gráfico
            
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;              
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;
            
            console.log('colorSensorIzquierdo')
            console.log(colorSensorIzquierdo)
            console.log('colorSensorDerecho')
            console.log(colorSensorDerecho)
            /*
            En la GUI al dibujar Scratch usa escala HSV normalizada para los colores. Normaliza cada valor entre 0-100
            por lo tanto estos colores para deteccion de los sensores simples en hexadecimal equivalen en la escala de Scratch en:
                    VerdeIzq RojoeDer blanco  negro
            Color:      25  0           0       0
            Saturacion: 100 100         0       0
            Brillo:     100 100         100     0

            ******Esta es la formula matematica de HSV normal a HSV de scratch. De RBG/hexadecimal a HSV normal hay calculadoras en linea
                color = (hsv.h / 360) * 100;  
                saturation = hsv.s * 100;  
                brightness = hsv.v * 100;
            */
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;
                 console.log('selección: Blanco')
            }else{
                 colorFondoIzquierdo = colorNegro;
                 console.log('if selección: Negro')
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };

            console.log('colorFondoIzquierdo')
            console.log(colorFondoIzquierdo)
            console.log('colorFondoDerecho')
            console.log(colorFondoDerecho)

            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);
            //let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorSensorIzquierdo, colorFondoIzquierdo);  
            //let boolSensorDerecho = util.target.colorIsTouchingColor(colorSensorDerecho, colorFondoDerecho);

            console.log('boolSensorIzquierdo')
            console.log(boolSensorIzquierdo)
            console.log('boolSensorDerecho')
            console.log(boolSensorDerecho)
            
            if (boolSensorIzquierdo && boolSensorDerecho ) {
                util.startBranch(1, false);
            }
            
        } 
    };



    AttaIfElseIf(args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = 1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'IF'+ '0' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);
                }else if(util.stackFrame.loopCounter === 1){ // segunda iteracion: else
                    this.varMensajeBle += 'EL0' + args.condicionSensorIzqElse + args.condicionSensorDerElse;
                    util.stackFrame.loopCounter = -1;
                    util.startBranch(2, true);                    
                }else{ //tercera iteracion> If fin
                    this.varMensajeBle += 'IFFIN';
                }

        } else { // comportamiento gráfico
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;                         
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;
            let colorFondoIzquierdoElse;
            let colorFondoDerechoElse;
            //Asignar selecion de lógica de usuario IF
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;   
            }else{
                 colorFondoIzquierdo = colorNegro;    
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };

            //Asignar selecion de lógica de usuario ELSEIF
            if(args.condicionSensorIzqElse === esBlanco){
                 colorFondoIzquierdoElse = colorBlanco;
                 
            }else{
                 colorFondoIzquierdoElse = colorNegro;
            };

            if(args.condicionSensorDerElse === esBlanco){
                 colorFondoDerechoElse = colorBlanco;
            }else{
                 colorFondoDerechoElse = colorNegro;
            };

        // Bifurcaión
            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);
            let boolSensorIzquierdoElse = util.target.colorIsTouchingColor(colorFondoIzquierdoElse, colorSensorIzquierdo);
            let boolSensorDerechoElse = util.target.colorIsTouchingColor(colorFondoDerechoElse, colorSensorDerecho);

            if (boolSensorIzquierdo && boolSensorDerecho ) {
                util.startBranch(1, false);
            }else if (boolSensorIzquierdoElse && boolSensorDerechoElse ){
                util.startBranch(2, false);
            }

        } 
    };

 AttaIfElseIfElse(args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = 1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'IF'+ '0' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);
                } else if(util.stackFrame.loopCounter === 1){ // segunda iteracion: else
                    this.varMensajeBle += 'EL0' + args.condicionSensorIzqElse + args.condicionSensorDerElse;
                    util.stackFrame.loopCounter = 2;
                    util.startBranch(2, true);        
                 } else if(util.stackFrame.loopCounter === 2){ // tercera iteracion: else
                    this.varMensajeBle += 'EL999';
                    util.stackFrame.loopCounter = -1;
                    util.startBranch(3, true);                                       
                } else { //cuarta iteracion> If fin
                    this.varMensajeBle += 'IFFIN';
                }

        } else { // comportamiento gráfico
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;                         
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;
            let colorFondoIzquierdoElse;
            let colorFondoDerechoElse;
            //Asignar selecion de lógica de usuario IF
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;   
            }else{
                 colorFondoIzquierdo = colorNegro;    
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };

            //Asignar selecion de lógica de usuario ELSEIF
            if(args.condicionSensorIzqElse === esBlanco){
                 colorFondoIzquierdoElse = colorBlanco;
                 
            }else{
                 colorFondoIzquierdoElse = colorNegro;
            };

            if(args.condicionSensorDerElse === esBlanco){
                 colorFondoDerechoElse = colorBlanco;
            }else{
                 colorFondoDerechoElse = colorNegro;
            };

        // Bifurcaión
            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);
            let boolSensorIzquierdoElse = util.target.colorIsTouchingColor(colorFondoIzquierdoElse, colorSensorIzquierdo);
            let boolSensorDerechoElse = util.target.colorIsTouchingColor(colorFondoDerechoElse, colorSensorDerecho);

            if (boolSensorIzquierdo && boolSensorDerecho ) {
                util.startBranch(1, false);
            }else if (boolSensorIzquierdoElse && boolSensorDerechoElse ){
                util.startBranch(2, false);
            } else {
                util.startBranch(3, false);
            }

        } 
    };

    AttaIfElse (args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = 1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'IF'+ '0' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);
                }else if(util.stackFrame.loopCounter === 1){ // segunda iteracion: else
                    this.varMensajeBle += 'EL999';
                    util.stackFrame.loopCounter = -1;
                    util.startBranch(2, true);                    
                }else{ //tercera iteracion> If fin
                    this.varMensajeBle += 'IFFIN';
                }                

        } else { // comportamiento gráfico
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;              
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;            
             //Asignar selecion de lógica de usuario IF
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;   
            }else{
                 colorFondoIzquierdo = colorNegro;    
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };
            // bifurcación
            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);  
            if (boolSensorIzquierdo && boolSensorDerecho ) {
                util.startBranch(1, false);
            } else {
                util.startBranch(2, false);
            }                                
        } 
    };
    AttaWhile (args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'WH'+ '0' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);                  
                }else{ //segunda iteracion> If fin
                    this.varMensajeBle += 'WHFIN';
                }

        } else { // comportamiento gráfico
            
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;              
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;
            /*
            En la GUI al dibujar Scratch usa escala HSV normalizada para los colores. Normaliza cada valor entre 0-100
            por lo tanto estos colores para deteccion de los sensores simples en hexadecimal equivalen en la escala de Scratch en:
                    VerdeIzq RojoeDer blanco  negro
            Color:      25  0           0       0
            Saturacion: 100 100         0       0
            Brillo:     100 100         100     0

            ******Esta es la formula matematica de HSV normal a HSV de scratch. De RBG/hexadecimal a HSV normal hay calculadoras en linea
                color = (hsv.h / 360) * 100;  
                saturation = hsv.s * 100;  
                brightness = hsv.v * 100;
            */
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;
                 console.log('if true')
            }else{
                 colorFondoIzquierdo = colorNegro;
                 console.log('if false')
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };

            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);
            //let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorSensorIzquierdo, colorFondoIzquierdo);  
            //let boolSensorDerecho = util.target.colorIsTouchingColor(colorSensorDerecho, colorFondoDerecho);

            if (boolSensorIzquierdo && boolSensorDerecho ) {
                util.startBranch(1, true);
            }
            
        } 
    };
    AttaWhileNot (args,util){
        if (this.varModoTransmision){         
            if (typeof util.stackFrame.loopCounter === 'undefined') {
                    util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque   
                    this.varMensajeBle += 'WH'+ '1' + args.condicionSensorIzq + args.condicionSensorDer;
                    util.startBranch(1, true);                  
                }else{ //segunda iteracion> If fin
                    this.varMensajeBle += 'WHFIN';
                }

        } else { // comportamiento gráfico
            
            // Convertir a RGB arrays  
            const colorSensorIzquierdo = Cast.toRgbColorList(args.colorSensorIzquierdo) ;              
            const colorSensorDerecho = Cast.toRgbColorList(args.colorSensorDerecho) ;              
            const colorBlanco = Cast.toRgbColorList(args.colorBlanco);              
            const colorNegro = Cast.toRgbColorList(args.colorNegro); 
            const esBlanco=1;
            let colorFondoIzquierdo;
            let colorFondoDerecho;
          
            /*
            En la GUI al dibujar Scratch usa escala HSV normalizada para los colores. Normaliza cada valor entre 0-100
            por lo tanto estos colores para deteccion de los sensores simples en hexadecimal equivalen en la escala de Scratch en:
                    VerdeIzq RojoeDer blanco  negro
            Color:      25  0           0       0
            Saturacion: 100 100         0       0
            Brillo:     100 100         100     0

            ******Esta es la formula matematica de HSV normal a HSV de scratch. De RBG/hexadecimal a HSV normal hay calculadoras en linea
                color = (hsv.h / 360) * 100;  
                saturation = hsv.s * 100;  
                brightness = hsv.v * 100;
            */
            if(args.condicionSensorIzq === esBlanco){
                 colorFondoIzquierdo = colorBlanco;
            }else{
                 colorFondoIzquierdo = colorNegro;
            };

            if(args.condicionSensorDer === esBlanco){
                 colorFondoDerecho = colorBlanco;
            }else{
                 colorFondoDerecho = colorNegro;
            };

            let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorFondoIzquierdo, colorSensorIzquierdo);
            let boolSensorDerecho = util.target.colorIsTouchingColor(colorFondoDerecho, colorSensorDerecho);
            //let boolSensorIzquierdo = util.target.colorIsTouchingColor(colorSensorIzquierdo, colorFondoIzquierdo);  
            //let boolSensorDerecho = util.target.colorIsTouchingColor(colorSensorDerecho, colorFondoDerecho);
            
            if (!(boolSensorIzquierdo && boolSensorDerecho )) {
                util.startBranch(1, true);
            }
            
        } 
    };
    AttaHerramienta (args,util){
        if (this.varModoTransmision){
            this.FormatearComando('HE',args.herramientaAccion)
        } else {
            // asignacion de traje según menú de selección y orden esperado en el Sprite
            const trajeGarraAbierta=1;
            const trajeGarraCerrada=2;
            const trajeGruaArriba=3;
            const trajeGruaAbajo=4;
            const trajeBase=0;
            let traje;
            const garraAbrir=101;
            const garraCerrar=1;
            const gruaSubir=102;
            const gruaBajar=2;
            const ninguna=0;
            //Valor de case es el asignado por el menú/comandos
            switch(args.herramientaAccion) {
                case garraAbrir:                  
                    traje=trajeGarraAbierta;
                    break;
                case garraCerrar:
                    traje=trajeGarraCerrada;
                    break;
                case gruaSubir:
                    traje=trajeGruaArriba;
                    break;
                case gruaBajar:
                    traje=trajeGruaAbajo;
                    break;
                case ninguna:
                    traje=trajeBase;
                    break;                    
                default:
                    traje=trajeBase;
        // código a ejecutar si ningún caso coincide
}
            //Cambio de Sprite a trajes con herramientas
            util.target.setCostume(traje);
            // Algun tipo de interaccion con los otros sprites?

        } // Fin modo grafico
    };

    AttaComandoBLE(args,util){ 
        if (typeof util.stackFrame.loopCounter === 'undefined') {
                util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque
                this.varModoTransmision= true;      
                this.varMensajeBle='ATINI';
                util.startBranch(1, true);
            }else{ // segunda iteracion
                this.varMensajeBle += 'ATFIN';                
            }

    };

    AttaEnvioBLE(args,util){
        if (this.varModoTransmision){
        //codigo de comunicacion BLE de Web BLUETOOTH
          escribirMensajeBLE(args.mensajeBle)
        }
    };

    AttaReconectar(args,util){
        obtenerDispositivo();
    };

    AttaSimulacion(){
        this.varModoTransmision= false;
        util.startBranch(1, false); //eliminar y pasar a command luego
    };



    AttaMensajeBLE (){
        return this.varMensajeBle;
    };

    FormatearComando(strComando, intValor){
        if (intValor>0){
                if (intValor < 10) {
                    this.varMensajeBle = this.varMensajeBle + strComando + '00' + intValor;
                } else if (intValor < 100) {
                    this.varMensajeBle = this.varMensajeBle + strComando + '0' + intValor;
                } else if (intValor < 1000){
                    this.varMensajeBle = this.varMensajeBle + strComando + intValor;
                }    

            } 

    };


}


    // FuncionBLE Inicio 

async function obtenerDispositivo() {
  if (dispositivoBLE) {
    // Ya tenemos el objeto de una conexión anterior (en esta sesión)
    return dispositivoBLE;
  }
  // Primera vez: mostrar diálogo y guardar referencia
  dispositivoBLE = await navigator.bluetooth.requestDevice({
    filters: [{ services: [SERVICIO_UUID] }],
  });
  return dispositivoBLE;
}
    async function escribirMensajeBLE(varMensajeBLE) {
if (!navigator.bluetooth) {
    alert("Web Bluetooth no está soportado en este navegador.");
    return;
  }

  try {
    // 1. Solicitar el dispositivo (con filtro para evitar el diálogo si ya tiene permiso)
    const dispositivo = await obtenerDispositivo();

    // 2. Conectar al servidor GATT
    const servidor = await dispositivo.gatt.connect();

    // 3. Obtener el servicio y la característica
    const servicio = await servidor.getPrimaryService(SERVICIO_UUID);
    const caracteristica = await servicio.getCharacteristic(CARACTERISTICA_UUID);

    // 4. Codificar y escribir el mensaje
    const codificador = new TextEncoder();
    const datos = codificador.encode(varMensajeBLE);
    await caracteristica.writeValue(datos);
    
    console.log("Mensaje escrito correctamente:", varMensajeBLE);
  } catch (error) {
    console.error("Error en la comunicación BLE:", error);
  }
        
    };

    //FuncionBLE FInal  

module.exports = Scratch3YourExtension;
