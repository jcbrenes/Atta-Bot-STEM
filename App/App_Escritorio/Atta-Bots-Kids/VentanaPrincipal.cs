using Syncfusion.Windows.Forms.Tools;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.IO.Ports;
using System.Linq;
using System.Security.Policy;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace Atta_Bots_Kids
{
    public partial class Main : Form
    {
        private bool cicloActivo;
        private bool detectarObstaculo;
        private List<Contenedor> instrucciones;
        private Contenedor ciclo;
        public Main()
        {
            Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense("MTc5NDk3M0AzMjMxMmUzMTJlMzMzNUZLTGw0RG5rRDVYUGVTMHJSamlIaEM2MWpHWWxEdkJKMEtMd21LSi9ybzQ9"); // llave de acceso de Syncfusion
            InitializeComponent();
            cicloActivo = false;
            detectarObstaculo = false;
            instrucciones = new List<Contenedor>();
            Globals.posicionCiclo = -1;
        }

        // 
        // acciones al hacer click
        //
        /// <summary>
        /// Si se acepta el dialog box que se genera, agrega una instrucción de retroceder la cantidad de milimetros escogida por el usuario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Avanzar_Click(object sender, EventArgs e)
        {
            // se revisa si se alcanzó el limite de instrcciones
            if (Globals.CantInstrucciones != Globals.limiteInstrucciones)
            {
                string value = "";
                // se llama al Form2 (Movimiento), para solicitar los datos o cancelar la acción
                using (Movimiento movimiento = new Movimiento("Movimiento", "¿Cuanto quieres avanzar?"))
                {
                    // si se confirma se agrega la instruccion a la lista
                    if (movimiento.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        instrucciones.Add(new Contenedor(DisplayHistorial, instrucciones, Globals.Funciones.Avanzar, movimiento.TrackbarValue));
                        value = movimiento.TrackbarValue;
                        Console.WriteLine(value);
                        Globals.agregarInstruccion();
                    }
                }
            }
            else
            {
                if (InputBoxLimiteAlcanzado() == DialogResult.OK)
                {
                    return;
                }
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, agrega una instrucción de retroceder la cantidad de milimetros escogida por el usuario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Atras_Click(object sender, EventArgs e)
        {
            // se revisa si se alcanzó el limite de instrcciones
            if (Globals.CantInstrucciones != Globals.limiteInstrucciones)
            {
                string value = "";
                // se llama al Form2 (Movimiento), para solicitar los datos o cancelar la acción
                using (Movimiento movimiento = new Movimiento("Movimiento", "¿Cuanto quieres retroceder?"))
                {
                    // si se confirma se agrega la instruccion a la lista
                    if (movimiento.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        instrucciones.Add(new Contenedor(DisplayHistorial, instrucciones, Globals.Funciones.Retroceder, movimiento.TrackbarValue));
                        value = movimiento.TrackbarValue;
                        Console.WriteLine(value);
                        Globals.agregarInstruccion();
                    }
                }
            }
            else
            {
                if (InputBoxLimiteAlcanzado() == DialogResult.OK)
                {
                    return;
                }
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, agrega una instrucción de giro a la izquierda con la cantidad de grados seleccionada por el usuario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Izquierda_Click(object sender, EventArgs e)
        {
            // se revisa si se alcanzó el limite de instrcciones
            if (Globals.CantInstrucciones != Globals.limiteInstrucciones)
            {
                // se llama al Form3 (Giro), para solicitar los datos o cancelar la acción
                using (Giro giro = new Giro("¿Cuanto quieres girar?", false))
                {
                    // si se confirma se agrega la instruccion a la lista
                    if (giro.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        instrucciones.Add(new Contenedor(DisplayHistorial, instrucciones, Globals.Funciones.Izquierda, giro.TrackbarValue));
                        Console.WriteLine(giro.TrackbarValue);
                        Globals.agregarInstruccion();
                    }
                }
            }
            else
            {
                if (InputBoxLimiteAlcanzado() == DialogResult.OK)
                {
                    return;
                }
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, agrega una instrucción de giro a la derecha con la cantidad de grados seleccionada por el usuario
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Derecha_Click(object sender, EventArgs e)
        {
            // se revisa si se alcanzó el limite de instrcciones
            if (Globals.CantInstrucciones != Globals.limiteInstrucciones)
            {
                // se llama al Form3 (Giro), para solicitar los datos o cancelar la acción
                using (Giro giro = new Giro("¿Cuanto quieres girar?", true))
                {
                    // si se confirma se agrega la instruccion a la lista
                    if (giro.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        instrucciones.Add(new Contenedor(DisplayHistorial, instrucciones, Globals.Funciones.Derecha, giro.TrackbarValue));
                        Globals.agregarInstruccion();
                        Console.WriteLine(giro.TrackbarValue);
                    }
                }
            }
            else
            {
                if (InputBoxLimiteAlcanzado() == DialogResult.OK)
                {
                    return;
                }
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, se agrega la instrucción de ciclo y se modifica la posición de las instrucciones posteriores
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Ciclo_Click(object sender, EventArgs e)
        {
            // preguntar si se desea activar/desactivar el ciclo
            if (!cicloActivo)
            {
                if (InputBoxConfirmacion("Confirmar", "¿Desea agregar un ciclo?") == DialogResult.OK)
                {
                    Console.WriteLine("OK");
                    Ciclo.BackgroundImage = Properties.Resources.Repetir_Boton_Apagado; //cambiar imagen del boton
                    cicloActivo = !cicloActivo; // activar ciclo
                    Globals.PosicionInstrucciones = 55; // cambiar ejeX de las nuevas instrucciones
                    ciclo = new Contenedor(Globals.Funciones.Ciclo, "111"); // crear instruccion
                    instrucciones.Add(ciclo); // agregar instruccion
                    Globals.posicionCiclo = instrucciones.IndexOf(ciclo); // posición del ciclo
                }
            }
            else
            {
                if (InputBoxConfirmacion("Confirmar", "¿Desea quitar el ciclo?") == DialogResult.OK)
                {
                    Console.WriteLine("OK");
                    Ciclo.BackgroundImage = Properties.Resources.Repetir_Boton; //cambiar imagen del boton
                    cicloActivo = !cicloActivo; // desactivar ciclo
                    Globals.PosicionInstrucciones = 5; // cambiar ejeX de las nuevas instrucciones
                    ajustarInstrucciones();
                    Globals.posicionCiclo = -1; // indicar que no hay ciclo
                }
            }
        }
        /// <summary>
        /// Le indica al programa si se debe o no agregar la instrucción de detectar obstaculos.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Obstaculo_Click(object sender, EventArgs e)
        {
            // preguntar si se desea activar/desactivar la detección de objetos
            if (!detectarObstaculo)
            {
                if (InputBoxConfirmacion("Confirmar", "¿Desea detectar obstáculos?") == DialogResult.OK)
                {
                    Console.WriteLine("OK");
                    Obstaculo.BackgroundImage = Properties.Resources.Obstaculo_Boton_Apagado;//cambiar imagen del boton
                    detectarObstaculo = !detectarObstaculo; // detectar obstaculos
                }
            }
            else
            {
                if (InputBoxConfirmacion("Confirmar", "¿Desea no detectar obstáculos?") == DialogResult.OK)
                {
                    Console.WriteLine("OK");
                    Obstaculo.BackgroundImage = Properties.Resources.Obstaculo_Boton;//cambiar imagen del boton
                    detectarObstaculo = !detectarObstaculo; // dejar de detactar obstaculos
                }
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, intenta buscar un Atta-Bot al cual cargar las instrucciones
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// <remarks>Las instrucciones que se cargan al robót, si es que se logra encontrar, son las que se encuentran en el historial</remarks>
        private void Play_Click(object sender, EventArgs e)
        {
            if (InputBoxConfirmacion("Confirmar", "¿Desea cargar el código?") == DialogResult.OK)
            {
                Console.WriteLine("OK");
                autodetectarPuertoCOM();
                if (!serialPort1.IsOpen)
                {
                    InputBoxInformación("Error", "Dispositivo compatible no encontrado");
                    return;
                }
                string str = "";
                foreach (Contenedor instruccion in instrucciones)
                {
                    str += instruccion.ToString() + ",";
                }
                if (detectarObstaculo)
                {
                    str += Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-1,";
                }
                else
                {
                    str += Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-0,";
                }
                str += Globals.codigos[(int)Globals.Funciones.Play] + "-0";
                Console.WriteLine(str);
                serialPort1.WriteLine(str);
                Thread.Sleep(200);
                serialPort1.Close();
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, intenta indicarle al robot que se detenga
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Stop_Click(object sender, EventArgs e)
        {
            if (InputBoxConfirmacion("Confirmar", "¿Desea detener el robot?") == DialogResult.OK)
            {
                Console.WriteLine("OK");
                autodetectarPuertoCOM();
                if (!serialPort1.IsOpen)
                {
                    InputBoxInformación("Error", "Dispositivo compatible no encontrado");
                    return;
                }
                string str = Globals.codigos[(int)Globals.Funciones.Pausa]  + "-0,";
                str += Globals.codigos[(int)Globals.Funciones.Play] + "-0";
                Console.WriteLine(str);
                serialPort1.WriteLine(str);
                Thread.Sleep(200);
                serialPort1.Close();
            }
        }
        /// <summary>
        /// Si se acepta el dialog box que se genera, llama a la función auxiliar "limpiarHistorial"
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Limpiar_Click(object sender, EventArgs e)
        {
            if (InputBoxConfirmacion("Confirmar", "¿Desea borrar el historial?") == DialogResult.OK)
            {
                limpiarHistorial();
            }
        }   
        /// <summary>
        /// Si se acepta el dialog box que se genera, llama a la función auxiliar "limpiarHistorial"
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void limpiarHistorialToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (InputBoxConfirmacion("Confirmar", "¿Desea borrar el historial?") == DialogResult.OK)
            {
                limpiarHistorial();
            }
        }
        /// <summary>
        /// Llama un dialog box donde se muestra la versión alcual de la aplicación.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void versionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (InputBoxInformación("Versión", "Atta-Bots Kids versión: " + Globals.version) == DialogResult.OK)
            {
                
            }
        }

        private void desarrolladoresToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (InputBoxInformación("Desarrolladores", Globals.desarrolladores[0]) == DialogResult.OK)
            {

            }
        }
        /// <summary>
        /// Redirige al usuario al manual de usuario, el cual se encuentra en una paina web
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ayudaToolStripMenuItem_Click(object sender, EventArgs e)
        {
            try
            {
                System.Diagnostics.Process.Start(Globals.urlManualUsuario);
            }
            catch (Exception exc1)
            {
                // System.ComponentModel.Win32Exception es una excepción que ocurrecuando se tiene a Firefox como navegador por defecto.
                // si esa no es la exepción se abre la URL en IE en su lugar.
                if (exc1.GetType().ToString() != "System.ComponentModel.Win32Exception")
                {
                    // se tiene en caso de que se arroje alguna excepción
                    try
                    {
                        System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo("IExplore.exe", Globals.urlManualUsuario);
                        System.Diagnostics.Process.Start(startInfo);
                        startInfo = null;
                    }
                    catch (Exception exc2)
                    {
                        // still nothing we can do so just show the error to the user here.
                    }
                }
            }
        }
        /// <summary>
        /// Genera un documento de texto cuendo se interactua con el botón "Generar documento"
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void generarDocumentoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string path;
            saveFileDialog1.Filter = "Documentos de texto|*.txt";
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                if(File.Exists(saveFileDialog1.FileName))
                {
                    path = saveFileDialog1.FileName;
                    StreamWriter textoAGuardar = File.CreateText(path);
                    if(instrucciones.Count > 0)
                    {
                        textoAGuardar.WriteLine(instrucciones[0].ToString());
                        for(int i = 1; i < instrucciones.Count; i++)
                        {
                            textoAGuardar.WriteLine(instrucciones[i].ToString());
                        }
                        if (detectarObstaculo)
                        {
                            textoAGuardar.WriteLine(Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-1");
                        }
                        else
                        {
                            textoAGuardar.WriteLine(Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-0");
                        }
                        textoAGuardar.Flush();
                        textoAGuardar.Close();
                    }
                }
                else
                {
                    path = saveFileDialog1.FileName;
                    StreamWriter textoAGuardar = File.CreateText(path);
                    if (instrucciones.Count > 0)
                    {
                        textoAGuardar.WriteLine(instrucciones[0].ToString());
                        for (int i = 1; i < instrucciones.Count; i++)
                        {
                            textoAGuardar.WriteLine(instrucciones[i].ToString());
                        }
                        if (detectarObstaculo)
                        {
                            textoAGuardar.WriteLine(Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-1,");
                        }
                        else
                        {
                            textoAGuardar.WriteLine(Globals.codigos[(int)Globals.Funciones.Obstaculo] + "-0,");
                        }
                        textoAGuardar.Flush();
                        textoAGuardar.Close();
                    }
                }
            }
        }
        private void Main_FormClosing(object sender, FormClosingEventArgs e)
        {
            if(InputBoxConfirmacion("Confirmar", "¿Seguro de cerrar la aplicación?") != DialogResult.OK)
            {
                e.Cancel = true;
            }
        }
        // 
        // funciones auxiliares
        //
        /// <summary>
        /// Elimina todos los elemtnos precentes en el historial
        /// </summary>
        /// <remarks>Devuelve a la aplicación a un estado similar al estado base</remarks>
        private void limpiarHistorial()
        {
            Console.WriteLine("OK");
            DisplayHistorial.Controls.Clear(); // eliminar todos los controles del panel
            DisplayHistorial.Controls.Add(Limpiar); // agregamos el boton "Limpiar"
            foreach (Contenedor instruccion in instrucciones)
            {
                instruccion.Clear(); // nos desacemos de las instrucciones para que no haya un memory leak
            }
            instrucciones.Clear(); // limpiamos la lista
            Globals.CantInstrucciones = 0; // hacemos un reset al numeo de instrucciones
            cicloActivo = false; // no tenemos un ciclo
            detectarObstaculo = false; // no detectamos obstaculos
            Obstaculo.BackgroundImage = Properties.Resources.Obstaculo_Boton; // cambiamos la imagen en caso de que sea la deseada
            Ciclo.BackgroundImage = Properties.Resources.Repetir_Boton; // cambiamos la imagen en caso de que sea la deseada
            Globals.PosicionInstrucciones = 5; // nuevo ejeX de las instrucciones en el historial
        }

        /// <summary>
        /// Ajusta a la posición correspondiente todas las instrucciones que se agregaron tras haber activado el ciclo
        /// </summary>
        /// <remarks>Se llama cuando el ciclo es desactivado</remarks>
        private void ajustarInstrucciones()
        {
            // si el ciclo era la ultima instruccion solo se borra
            if (instrucciones.Last() == ciclo)
            {
                instrucciones.Remove(ciclo);
            }
            else
            {
                int posCiclo = instrucciones.IndexOf(ciclo); // conseguimos la posición del ciclo
                instrucciones.Remove(ciclo); // eliminamos el ciclo del historial
                for (int i = posCiclo; i < instrucciones.Count; i++)
                {
                    // ajustamos la el ejeX de las instrucciones que se agregaron despues del ciclo
                    instrucciones[i].ajustarEjeX(-50);
                    //instrucciones[i].actualizarPosicion(Globals.PosicionInstrucciones, ejeY);
                }
            }
            
        }
        /// <summary>
        /// llama un dialog box que indica que se alcanzó el limite de instrucciones
        /// </summary>
        /// <returns>Retorna el dialog box a ser mostrado</returns>
        private static DialogResult InputBoxLimiteAlcanzado()
        {
            return InputBoxInformación("Alerta", "Limite de instrucciones alcanzado");
        }
        /// <summary>
        /// buscar el puerto serial donde se encuentra el Arduino
        /// </summary>
        private void autodetectarPuertoCOM()
        {
            //serialPort1.BaudRate = Globals.velocidadPuerto;
            foreach (string s in SerialPort.GetPortNames())
            {
                serialPort1.Close();
                serialPort1.Dispose();
                bool portfound = false;
                serialPort1 = new SerialPort(s,Globals.velocidadPuerto);
                serialPort1.Parity = Parity.None;
                Console.WriteLine(s);
                try
                {
                    serialPort1.Open();
                }
                catch (IOException c)
                {
                    return;
                }
                catch (InvalidOperationException c1)
                {                    
                    return;
                }
                catch (ArgumentNullException c2)
                {                   
                    return;
                }
                catch (TimeoutException c3)
                {                    
                    return;
                }
                catch (UnauthorizedAccessException c4)
                {
                    return;
                }
                catch (ArgumentOutOfRangeException c5)
                {
                    return;
                }
                catch (ArgumentException c2)
                {
                    return;
                }
                if (!portfound)
                {
                    if (serialPort1.IsOpen) // el puerto se habrió correctamente
                    {
                        serialPort1.ReadTimeout = 1000; // 1 segundo de espera
                        serialPort1.WriteTimeout = 1000;
                        serialPort1.RtsEnable = true;
                        try
                        {
                            string comms = serialPort1.ReadLine();
                            if (comms.Substring(0, 1) == "A") // Se encontró un dispositivo compatible
                            {
                                serialPort1.WriteLine("a"); // le indicamos al dispositivo que lo encontramos
                                Console.WriteLine("Hubo respuesta");
                                portfound = !portfound;
                                break;

                            }
                            else
                            {
                                serialPort1.Close();
                            }
                        }
                        catch (Exception e1)
                        {
                            serialPort1.Close();
                        }
                    }
                }
            }
        }
        private void pruebaPuerto()
        {
            serialPort1 = new SerialPort("COM8", 9600);
            if (serialPort1.IsOpen)
            {
                serialPort1.Close();
            }
            serialPort1.ReadTimeout = 1000;
            serialPort1.RtsEnable = true;
            serialPort1.Open();
            while (true)
            {
                string a = serialPort1.ReadLine();
                if (a.Substring(0, 1) == "A")
                {
                    serialPort1.WriteLine("a");
                }
                Console.WriteLine(a);
                //Thread.Sleep(200);
            }
        }
        // 
        // dialog boxes
        //
        /// <summary>
        /// Dialog box de confirmación, aparece al momento de realizar alguna acción que requiera ser confirmada o rechazada
        /// </summary>
        /// <param name="title"></param>
        /// <param name="promptText"></param>
        /// <returns>Retorna el dialog box con una pregunta relacionada a lo que debe aceptar o cancelar</returns>
        public static DialogResult InputBoxConfirmacion(string title, string promptText)
        {
            // elementos del dialog box
            Form form = new Form();
            Label label = new Label();
            System.Windows.Forms.Button buttonOk = new System.Windows.Forms.Button();
            System.Windows.Forms.Button buttonCancel = new System.Windows.Forms.Button();


            form.Text = title; //titulo del dialog box
            label.Text = promptText; //texto del dialog box

            // funcionalidad de los botones del dialog box
            buttonOk.Text = "OK";
            buttonCancel.Text = "Cancelar";
            buttonOk.DialogResult = DialogResult.OK;
            buttonCancel.DialogResult = DialogResult.Cancel;

            // posicionamiento y diseño de los elementos
            label.SetBounds(36, 36, 372, 13);
            label.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);

            buttonOk.SetBounds(40, 100, 130, 50);
            buttonOk.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            buttonOk.Name = "BotonOk";
            buttonOk.TabIndex = 2;
            buttonOk.UseVisualStyleBackColor = true;

            buttonCancel.SetBounds(190, 100, 130, 50);
            buttonCancel.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            buttonCancel.Name = "BotonCancelar";
            buttonCancel.TabIndex = 2;
            buttonCancel.UseVisualStyleBackColor = true;

            // configuración del dialog box
            label.AutoSize = true;
            form.ClientSize = new Size(361, 218);
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            form.MinimizeBox = false;
            form.MaximizeBox = false;
            form.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(131)))), ((int)(((byte)(196)))), ((int)(((byte)(235)))));

            // agregar elementos al dialog box
            form.Controls.AddRange(new Control[] { label, buttonOk, buttonCancel });
            form.AcceptButton = buttonOk;
            form.CancelButton = buttonCancel;

            DialogResult dialogResult = form.ShowDialog(); //mostrar el dialog box

            return dialogResult;
        }
        /// <summary>
        /// Dialog box para indicar al usuario algun tipo de información en concreto
        /// </summary>
        /// <param name="titulo"></param>
        /// <param name="mensaje"></param>
        /// <returns>Reorna el dialog box con la información pertinente</returns>
        public static DialogResult InputBoxInformación(string titulo, string mensaje)
        {
            // elementos del dialog box
            Form form = new Form();
            Label label = new Label();
            System.Windows.Forms.Button buttonOk = new System.Windows.Forms.Button();


            form.Text = titulo; //titulo del dialog box
            label.Text = mensaje; //texto del dialog box

            // funcionalidad de los botones del dialog box
            buttonOk.Text = "OK";
            buttonOk.DialogResult = DialogResult.OK;

            // posicionamiento y diseño de los elementos
            label.SetBounds(36, 36, 372, 13);
            label.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);

            buttonOk.SetBounds(40, 100, 130, 50);
            buttonOk.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            buttonOk.Name = "BotonOk";
            buttonOk.TabIndex = 2;
            buttonOk.UseVisualStyleBackColor = true;

            // configuración del dialog box
            label.AutoSize = true;
            form.ClientSize = new Size(361, 218);
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            form.MinimizeBox = false;
            form.MaximizeBox = false;
            form.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(131)))), ((int)(((byte)(196)))), ((int)(((byte)(235)))));

            // agregar elementos al dialog box
            form.Controls.AddRange(new Control[] { label, buttonOk });
            form.AcceptButton = buttonOk;

            DialogResult dialogResult = form.ShowDialog(); //mostrar el dialog box

            return dialogResult;
        }
    }
}
