namespace Atta_Bots_Kids
{
    partial class Movimiento
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
            this.BotonOk = new System.Windows.Forms.Button();
            this.BotonCancelar = new System.Windows.Forms.Button();
            this.texto = new System.Windows.Forms.Label();
            this.trackBar1 = new System.Windows.Forms.TrackBar();
            this.trackbar_Label = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.trackBar1)).BeginInit();
            this.SuspendLayout();
            // 
            // BotonOk
            // 
            this.BotonOk.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.BotonOk.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.BotonOk.Location = new System.Drawing.Point(70, 160);
            this.BotonOk.Name = "BotonOk";
            this.BotonOk.Size = new System.Drawing.Size(160, 60);
            this.BotonOk.TabIndex = 0;
            this.BotonOk.Text = "Ok";
            this.BotonOk.UseVisualStyleBackColor = true;
            // 
            // BotonCancelar
            // 
            this.BotonCancelar.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.BotonCancelar.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.BotonCancelar.Location = new System.Drawing.Point(250, 160);
            this.BotonCancelar.Name = "BotonCancelar";
            this.BotonCancelar.Size = new System.Drawing.Size(160, 60);
            this.BotonCancelar.TabIndex = 1;
            this.BotonCancelar.Text = "Cancelar";
            this.BotonCancelar.UseVisualStyleBackColor = true;
            // 
            // texto
            // 
            this.texto.AutoSize = true;
            this.texto.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.texto.Location = new System.Drawing.Point(66, 36);
            this.texto.Name = "texto";
            this.texto.Size = new System.Drawing.Size(74, 29);
            this.texto.TabIndex = 2;
            this.texto.Text = "label1";
            // 
            // trackBar1
            // 
            this.trackBar1.AllowDrop = true;
            this.trackBar1.LargeChange = 50;
            this.trackBar1.Location = new System.Drawing.Point(58, 90);
            this.trackBar1.Maximum = 999;
            this.trackBar1.Minimum = 50;
            this.trackBar1.Name = "trackBar1";
            this.trackBar1.Size = new System.Drawing.Size(300, 56);
            this.trackBar1.SmallChange = 5;
            this.trackBar1.TabIndex = 3;
            this.trackBar1.Value = 50;
            this.trackBar1.Scroll += new System.EventHandler(this.trackBar1_Scroll);
            // 
            // trackbar_Label
            // 
            this.trackbar_Label.AutoSize = true;
            this.trackbar_Label.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.trackbar_Label.Location = new System.Drawing.Point(373, 90);
            this.trackbar_Label.Name = "trackbar_Label";
            this.trackbar_Label.Size = new System.Drawing.Size(26, 29);
            this.trackbar_Label.TabIndex = 4;
            this.trackbar_Label.Text = "0";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Bahnschrift SemiLight", 14F);
            this.label1.Location = new System.Drawing.Point(418, 90);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(55, 29);
            this.label1.TabIndex = 5;
            this.label1.Text = "mm";
            // 
            // Movimiento
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(131)))), ((int)(((byte)(196)))), ((int)(((byte)(235)))));
            this.ClientSize = new System.Drawing.Size(482, 263);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.trackbar_Label);
            this.Controls.Add(this.trackBar1);
            this.Controls.Add(this.texto);
            this.Controls.Add(this.BotonCancelar);
            this.Controls.Add(this.BotonOk);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Movimiento";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Form2";
            ((System.ComponentModel.ISupportInitialize)(this.trackBar1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button BotonOk;
        private System.Windows.Forms.Button BotonCancelar;
        private System.Windows.Forms.Label texto;
        private System.Windows.Forms.TrackBar trackBar1;
        private System.Windows.Forms.Label trackbar_Label;
        private System.Windows.Forms.Label label1;
    }
}