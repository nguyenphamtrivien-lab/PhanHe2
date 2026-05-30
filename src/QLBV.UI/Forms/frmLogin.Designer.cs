namespace QLBV.UI.Forms
{
    partial class frmLogin
    {
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing) { if (disposing && (components != null)) components.Dispose(); base.Dispose(disposing); }
        private void InitializeComponent()
        {
            this.txtUsername = new System.Windows.Forms.TextBox();
            this.txtPassword = new System.Windows.Forms.TextBox();
            this.btnDangNhap = new System.Windows.Forms.Button();
            this.SuspendLayout();
            
            this.txtUsername.Location = new System.Drawing.Point(50, 50);
            this.txtUsername.Name = "txtUsername";
            
            this.txtPassword.Location = new System.Drawing.Point(50, 100);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.UseSystemPasswordChar = true;
            
            this.btnDangNhap.Location = new System.Drawing.Point(50, 150);
            this.btnDangNhap.Name = "btnDangNhap";
            this.btnDangNhap.Text = "ÄÄƒng nháº­p";
            this.btnDangNhap.Click += new System.EventHandler(this.btnDangNhap_Click);
            
            this.ClientSize = new System.Drawing.Size(300, 250);
            this.Controls.Add(this.txtUsername);
            this.Controls.Add(this.txtPassword);
            this.Controls.Add(this.btnDangNhap);
            this.Name = "frmLogin";
            this.Text = "ÄÄƒng nháº­p";
            this.ResumeLayout(false);
            this.PerformLayout();
        }
        private System.Windows.Forms.TextBox txtUsername;
        private System.Windows.Forms.TextBox txtPassword;
        private System.Windows.Forms.Button btnDangNhap;
    }
}
