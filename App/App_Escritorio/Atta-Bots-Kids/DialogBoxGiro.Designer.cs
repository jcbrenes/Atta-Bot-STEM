namespace Atta_Bots_Kids
{
    partial class Giro
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.BotonCancelar = new System.Windows.Forms.Button();
            this.BotonOk = new System.Windows.Forms.Button();
            this.texto = new System.Windows.Forms.Label();
            this.radialSlider1 = new Syncfusion.Windows.Forms.Tools.RadialSlider();
            this.SuspendLayout();
            // 
            // BotonCancelar
            // 
            this.BotonCancelar.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.BotonCancelar.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.BotonCancelar.Location = new System.Drawing.Point(250, 357);
            this.BotonCancelar.Name = "BotonCancelar";
            this.BotonCancelar.Size = new System.Drawing.Size(160, 60);
            this.BotonCancelar.TabIndex = 3;
            this.BotonCancelar.Text = "Cancelar";
            this.BotonCancelar.UseVisualStyleBackColor = true;
            // 
            // BotonOk
            // 
            this.BotonOk.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.BotonOk.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.BotonOk.Location = new System.Drawing.Point(70, 357);
            this.BotonOk.Name = "BotonOk";
            this.BotonOk.Size = new System.Drawing.Size(160, 60);
            this.BotonOk.TabIndex = 2;
            this.BotonOk.Text = "Ok";
            this.BotonOk.UseVisualStyleBackColor = true;
            // 
            // texto
            // 
            this.texto.AutoSize = true;
            this.texto.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.texto.Location = new System.Drawing.Point(111, 9);
            this.texto.Name = "texto";
            this.texto.Size = new System.Drawing.Size(74, 29);
            this.texto.TabIndex = 4;
            this.texto.Text = "label1";
            // 
            // radialSlider1
            // 
            this.radialSlider1.BeforeTouchSize = new System.Drawing.Size(287, 287);
            this.radialSlider1.EndAngle = 360D;
            this.radialSlider1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(89)))), ((int)(((byte)(151)))), ((int)(((byte)(55)))));
            this.radialSlider1.Location = new System.Drawing.Point(92, 54);
            this.radialSlider1.MaximumValue = 360D;
            this.radialSlider1.Name = "radialSlider1";
            this.radialSlider1.RadialDirection = Syncfusion.Windows.Forms.Tools.RadialDirection.Clockwise;
            this.radialSlider1.Size = new System.Drawing.Size(287, 287);
            this.radialSlider1.SliderDivision = 8;
            this.radialSlider1.StartAngle = 0D;
            this.radialSlider1.TabIndex = 5;
            this.radialSlider1.Text = "radialSlider1";
            this.radialSlider1.Click += new System.EventHandler(this.radialSlider1_Click);
            // 
            // Giro
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(131)))), ((int)(((byte)(196)))), ((int)(((byte)(235)))));
            this.ClientSize = new System.Drawing.Size(482, 430);
            this.Controls.Add(this.radialSlider1);
            this.Controls.Add(this.texto);
            this.Controls.Add(this.BotonCancelar);
            this.Controls.Add(this.BotonOk);
            this.Name = "Giro";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Giro";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button BotonCancelar;
        private System.Windows.Forms.Button BotonOk;
        private System.Windows.Forms.Label texto;
        private Syncfusion.Windows.Forms.Tools.RadialSlider radialSlider1;
    }
}