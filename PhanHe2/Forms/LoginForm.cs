using PhanHe2.BLL;
using PhanHe2.DAL;

namespace PhanHe2.Forms;

/// <summary>
/// Form đăng nhập hệ thống quản lý y tế
/// </summary>
public partial class LoginForm : Form
{
    // Màu sắc hover cho nút đăng nhập
    private readonly Color _btnNormalColor = Color.FromArgb(21, 101, 192);
    private readonly Color _btnHoverColor = Color.FromArgb(25, 118, 210);

    public LoginForm()
    {
        InitializeComponent();
        SetupAnimations();
    }

    private void SetupAnimations()
    {
        // Thiết lập hiệu ứng hover cho nút đăng nhập
        btnLogin.MouseEnter += (s, e) =>
        {
            btnLogin.BackColor = _btnHoverColor;
            btnLogin.Cursor = Cursors.Hand;
        };
        btnLogin.MouseLeave += (s, e) =>
        {
            btnLogin.BackColor = _btnNormalColor;
        };
    }

    private async void btnLogin_Click(object sender, EventArgs e)
    {
        lblStatus.Text = "";
        btnLogin.Enabled = false;
        btnLogin.Text = "Đang kết nối...";

        try
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;
            string host = cmbServer.Text.Trim();
            string portText = txtPort.Text.Trim();
            string service = txtService.Text.Trim();

            // Kiểm tra dữ liệu nhập
            if (string.IsNullOrEmpty(username))
            {
                ShowError("Vui lòng nhập tên đăng nhập.");
                return;
            }
            if (string.IsNullOrEmpty(password))
            {
                ShowError("Vui lòng nhập mật khẩu.");
                return;
            }
            if (!int.TryParse(portText, out int port) || port <= 0 || port > 65535)
            {
                ShowError("Cổng kết nối không hợp lệ (1-65535).");
                return;
            }

            // Thực hiện kết nối trong thread khác để không block UI
            bool connected = await Task.Run(() =>
                OracleHelper.Connect(username, password, host, port, service));

            if (!connected)
            {
                ShowError("Đăng nhập thất bại. Kiểm tra thông tin kết nối.");
                return;
            }

            // Xác định vai trò người dùng
            UserSession? session = await Task.Run(() => AuthService.GetCurrentUser());

            if (session == null)
            {
                OracleHelper.Disconnect();
                ShowError("Tài khoản không được đăng ký trong hệ thống.");
                return;
            }

            // Mở dashboard tương ứng vai trò
            this.Hide();
            OpenDashboard(session);
        }
        catch (Exception ex)
        {
            ShowError($"Lỗi: {ex.Message}");
        }
        finally
        {
            btnLogin.Enabled = true;
            btnLogin.Text = "ĐĂNG NHẬP";
        }
    }

    private void OpenDashboard(UserSession session)
    {
        Form dashboard = session.Role switch
        {
            UserRole.CoVienDieuPhoi => new MainForm(session),
            UserRole.BacSi => new MainForm(session),
            UserRole.KyThuatVien => new MainForm(session),
            UserRole.BenhNhan => new MainForm(session),
            UserRole.DBA => new MainForm(session),
            _ => new MainForm(session)
        };

        dashboard.FormClosed += (s, e) => this.Close();
        dashboard.Show();
    }

    private void ShowError(string message)
    {
        lblStatus.Text = message;
        lblStatus.ForeColor = Color.FromArgb(239, 83, 80);
    }

    private void txtPassword_KeyDown(object sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Enter)
            btnLogin_Click(sender, e);
    }

    private void txtUsername_KeyDown(object sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Enter)
            txtPassword.Focus();
    }
}
