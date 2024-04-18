using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Atta_Bots_Kids
{
    public partial class Movimiento : Form
    {
        public string TrackbarValue { get; set; }
        public Movimiento(string title, string promptText)
        {
            InitializeComponent();
            this.Text = title; //titulo del dialog box
            texto.Text = promptText; //texto del dialog box
            TrackbarValue = trackbar_Label.Text = trackBar1.Value.ToString();
        }

        //mostrar valor actual del slider
        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            TrackbarValue = trackbar_Label.Text = trackBar1.Value.ToString();
        }
    }
}
