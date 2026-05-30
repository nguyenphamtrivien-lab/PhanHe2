using System;
using System.Windows.Forms;
using QLBV.BUS;
using QLBV.BUS.Implementations;
using QLBV.BUS.Interfaces;

namespace QLBV.UI.Forms
{
    public partial class frmLogin : Form
    {
        private readonly ILoginBUS _loginBUS;
        public frmLogin() { InitializeComponent(); _loginBUS = new LoginBUS(); }

        private void btnDangNhap_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;
            var session = _loginBUS.DangNhap(username, password);
            if (session != null) {
                SessionManager.SetSession(session);
                this.Hide();
                Form frmMain = MoFormTheoVaiTro(session.VaiTro);
                if (frmMain != null) {
                    frmMain.FormClosed += (s, args) => { _loginBUS.DangXuat(); SessionManager.ClearSession(); this.Show(); };
                    frmMain.Show();
                }
            } else { MessageBox.Show("Sai tÃ i khoáº£n/máº­t kháº©u."); }
        }

        private Form MoFormTheoVaiTro(string vaiTro)
        {
            switch (vaiTro) {
                case SessionManager.ROLE_DPV: return new frmDieuPhoiVien();
                case SessionManager.ROLE_BS: return new frmBacSi();
                case SessionManager.ROLE_KTV: return new frmKyThuatVien();
                case SessionManager.ROLE_BN: return new frmBenhNhan();
                default: return null;
            }
        }
    }
}
