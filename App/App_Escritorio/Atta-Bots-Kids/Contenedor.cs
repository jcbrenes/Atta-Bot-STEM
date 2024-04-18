using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using System.Windows.Forms;
using static Globals;

namespace Atta_Bots_Kids
{
    internal class Contenedor
    {
        private PictureBox imagenInstruccion;
        private Button boton;
        private Panel historial;
        private string codigo;
        private string valor;
        private List<Contenedor> instrucciones;
        /// <summary>
        /// Constructor de la clase Contenedor pensado para la instrucción "ciclo"
        /// </summary>
        /// <param name="funcion"></param>
        /// <param name="valor"></param>
        public Contenedor(Funciones funcion, string valor)
        {
            this.valor = valor;
            codigo = codigos[(int)funcion];
            boton = null;
            imagenInstruccion = null;
        }
        /// <summary>
        /// Constructor de la clase Contenedor, utilizado para las instrucciones relacionadas con el movimiento del robot
        /// </summary>
        /// <param name="historial"></param>
        /// <param name="instrucciones"></param>
        /// <param name="funcion"></param>
        /// <param name="valor"></param>
        public Contenedor(Panel historial, List<Contenedor> instrucciones, Funciones funcion, string valor)
        {
            this.instrucciones = instrucciones;
            this.historial = historial; 
            this.valor = valor;
            InitializeComponent(); // inicializar componentes
            codigo = codigos[(int)funcion];
            switch (funcion) // seleccionar imagen del boton
            {
                case Funciones.Avanzar:
                    imagenInstruccion.BackgroundImage = Properties.Resources.Avanzar_Boton;
                    break;
                case Funciones.Retroceder:
                    imagenInstruccion.BackgroundImage = Properties.Resources.Atras_Boton;
                    break;
                case Funciones.Izquierda:
                    imagenInstruccion.BackgroundImage = Properties.Resources.Izquierda_Boton;
                    break;
                case Funciones.Derecha:
                    imagenInstruccion.BackgroundImage = Properties.Resources.Derecha_Boton;
                    break;
                default: //play
                    break;
            }
        }
        /// <summary>
        /// Ubica los elementos graficos del Contenedor en el historial de la aplación
        /// </summary>
        private void InitializeComponent()
        {
            int ejeX = PosicionInstrucciones;
            int ejeY = tamanioInstrucciones * CantInstrucciones + espacioEntreInstrucciones * CantInstrucciones;
            boton = new Button();
            imagenInstruccion = new PictureBox();
            ((System.ComponentModel.ISupportInitialize)(imagenInstruccion)).BeginInit();

            historial.Controls.Add(imagenInstruccion);
            historial.Controls.Add(boton);
            // 
            // imagenInstruccion
            // 
            imagenInstruccion.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            imagenInstruccion.Location = new System.Drawing.Point(ejeX, ejeY+historial.AutoScrollPosition.Y);
            imagenInstruccion.Name = "imagenInstruccion";
            imagenInstruccion.Size = new System.Drawing.Size(tamanioInstrucciones, tamanioInstrucciones);
            imagenInstruccion.TabIndex = 1;
            imagenInstruccion.TabStop = false;
            // 
            // boton
            // 
            boton.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(128)))));
            boton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            boton.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F, System.Drawing.FontStyle.Bold);
            boton.Location = new System.Drawing.Point(ejeX+tamanioInstrucciones, ejeY + historial.AutoScrollPosition.Y);
            boton.Name = "boton";
            boton.Size = new System.Drawing.Size(tamanioInstrucciones, tamanioInstrucciones);
            boton.TabIndex = 0;
            boton.Text = "X";
            boton.UseVisualStyleBackColor = false;
            boton.Click += new System.EventHandler(Boton_Click);
        }
        /// <summary>
        /// elimina la instruccion deseada, no se pregunta por confirmación
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Boton_Click(object sender, EventArgs e)
        {
            historial.Controls.Remove(boton); // quitar del panel
            historial.Controls.Remove(imagenInstruccion);
            boton.Dispose(); // eliminar
            imagenInstruccion.Dispose();
            // acomodar el resto de instrucciones
            if (instrucciones.Last() == this)
            {
                instrucciones.Remove(this);
            }
            else
            {
                int pos, instruccion;
                pos = instruccion = instrucciones.IndexOf(this);
                instrucciones.Remove(this);
                int ejeY;
                if(posicionCiclo != -1 && posicionCiclo < pos) 
                {
                    instruccion--;
                }else if(posicionCiclo != -1 && pos < posicionCiclo)
                {
                    posicionCiclo--;
                }
                for (int i = pos; i < instrucciones.Count; i++)
                {
                    ejeY = tamanioInstrucciones * instruccion + espacioEntreInstrucciones * instruccion;
                    if (!instrucciones[i].isCiclo())
                    {
                        instrucciones[i].actualizarPosicion(instrucciones[i].GetEjeX(), ejeY);
                        instruccion++;
                    }
                }
                Console.WriteLine("borrado");
            }
            eliminarInstruccion();
        }
        /// <summary>
        /// libera los elementos graficos del Contenedor
        /// </summary>
        public void Clear()
        {
            if (boton != null)
            {
                boton.Dispose();
                imagenInstruccion.Dispose();
            }
        }
        /// <summary>
        /// Se modifica la posición altual de los componentes del Contenedor
        /// </summary>
        /// <param name="ejeX"></param>
        /// <param name="ejeY"></param>
        public void actualizarPosicion(int ejeX, int ejeY)
        {
            imagenInstruccion.Location = new System.Drawing.Point(ejeX, ejeY + historial.AutoScrollPosition.Y);
            boton.Location = new System.Drawing.Point(ejeX + tamanioInstrucciones, ejeY + historial.AutoScrollPosition.Y);
        }
        /// <summary>
        /// Se modifica unicamente el eje X de los componentes del Contenedor
        /// </summary>
        /// <param name="ajuste"></param>
        public void ajustarEjeX(int ajuste)
        {
            imagenInstruccion.Left += ajuste;
            boton.Left += ajuste;
        }
        /// <summary>
        /// Convierte el contenido del contenedor en un string
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return codigo + "-" + valor;
        }
        /// <summary>
        /// Para conseguir el eje X de los componentes del Contenedor
        /// </summary>
        /// <returns>Retorna la posición del eje X del PictureBox</returns>
        public int GetEjeX()
        {
            return imagenInstruccion.Left;
        }
        /// <summary>
        /// Se pregunta si la instrucción actual es la de ciclo
        /// </summary>
        /// <returns>Retorna true si es el ciclo y false si es cualquier otra instrucción.</returns>
        private bool isCiclo()
        {
            return boton == null;
        }
    }
}
