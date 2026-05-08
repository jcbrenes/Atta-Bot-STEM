const BlockType = require('../../extension-support/block-type');
const ArgumentType = require('../../extension-support/argument-type');
const TargetType = require('../../extension-support/target-type');
//import 'regenerator-runtime/runtime';
//Robados de los oficiales
const Cast = require('../../util/cast');
const MathUtil = require('../../util/math-util');
const Timer = require('../../util/timer');
//const util = require('../../engine/block-utility');
class Scratch3YourExtension {

    


    constructor (runtime) {
        // put any setup for your extension here
    }

    /**
     * Returns the metadata about your extension.
     */
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
                }, // Fin LapizActivado

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


                {
                    // name of the function where your block code lives
                    opcode: 'AttaAvanzar',
                    blockType: BlockType.COMMAND,

                    // label to display on the block
                    text: 'Avanzar [distancia_cm]',

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
                    text: 'Retroceder [distancia_cm]',

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
                    opcode: 'AttaIfInicio',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 2,

                    // label to display on the block
                    text: ['Si sensores [condicionSensorIzq] y [condicionSensorDer]', 'si no'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        }
                    } 
                }, // Fin IF

                {    // name of the function where your block code lives
                    opcode: 'ElseIfInicio',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 2,

                    // label to display on the block
                    text: ['Si no, si [condicionSensorIzq] y [condicionSensorDer]', 'si no'],

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        }
                    } 
                }, // Fin ElseIf


                {  
                    opcode: 'AttaWhileInicio',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 1,

                    // label to display on the block
                    text: 'Mientras sensores [condicionSensorIzq] y [condicionSensorDer]',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        }
                    } 
                }, // Fin While

                {  
                    opcode: 'AttaWhileNotInicio',
                    blockType: BlockType.CONDITIONAL,
                    branchCount: 1,

                    // label to display on the block
                    text: 'Mientras sensores no [condicionSensorIzq] y [condicionSensorDer]',

                    // true if this block should end a stack
                    terminal: false,
                    filter: [ TargetType.SPRITE],

                    // arguments used in the block
                    arguments: {
                        condicionSensorIzq: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
                        },
                        condicionSensorDer: {
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuCondiciones'
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
                            defaultValue:'Ninguna',
                            type: ArgumentType.NUMBER,
                            menu: 'menuHerramientaAcciones'
                        }
                    } 
                }, // Fin Herramienta




          
            
            ],
            // Menús de selección
            menus: {
                menuHerramientaAcciones: { 
                            acceptReporters: true,
                            items:[//Valores placeholder, poner los resultantes de la calibración del motor
                            {text: 'Garra abrir', value: 1},
                            {text: 'Garra cerrar', value: 2},
                            {text: 'Grúa subir', value: 3},
                            {text: 'Grúa bajar', value: 4},
                            {text: 'Ninguna', value: 0}
                            ]
                        },

                menuCondiciones: {
                    items:
                    [
                    {text: 'blanco' , value: 1},
                    {text: 'negro' , value: 0}
                    ]
                }
                

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
            const steps = distancia_cm*10;
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
            const steps = -distancia_cm*10;
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
            util.target.setDirection(util.target.direction - angulo);//comportamiento gráfico
        }  

    };

    AttaGirarDerecha({angulo},util){
        if(this.varModoTransmision){
            this.FormatearComando('GD', angulo);
        }  else{
            util.target.setDirection(util.target.direction + angulo);//comportamiento gráfico
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



    AttaDeteccionIniciada(util){};
    AttaDeteccionFinalizada(util){};
    AttaLapizActivado(util){};
    AttaIfInicio ({condicionSensorIzq}, {condicionSensorDer},util){};
    AttaWhileInicio ({condicionSensorIzq}, {condicionSensorDer},util){};
    AttaWhileNotInicio ({condicionSensorIzq}, {condicionSensorDer},util){};
    AttaHerramienta ({herramientaAccion},util){};

    AttaComandoBLE(args,util){ 
        if (typeof util.stackFrame.loopCounter === 'undefined') {
                util.stackFrame.loopCounter = -1; //Primera ejecucion del bloque
                this.varModoTransmision= true;      
                this.varMensajeBle='ATINI';
                util.startBranch(1, true);
            }else{ // segunda iteracion
                this.varMensajeBle += 'OBFIN';
                //codigo de comunicacion BLE de Web BLUETOOTH
            }

    };

    AttaSimulacion(){
        this.varModoTransmision= false;
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

module.exports = Scratch3YourExtension;
