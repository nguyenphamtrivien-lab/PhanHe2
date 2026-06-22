using PhanHe2.BLL;
using PhanHe2.DAL;
using PhanHe2.Forms.Coordinator;
using PhanHe2.Forms.Doctor;
using PhanHe2.Forms.Technician;
using PhanHe2.Forms.Patient;
using PhanHe2.Forms.Notification;

namespace PhanHe2.Forms;

/// <summary>
/// Form chính (Shell) - Chứa sidebar, header và vùng nội dung
/// </summary>
public partial class MainForm : Form
{
    private readonly UserSession _session;
    private readonly Color _sidebarBg = Color.FromArgb(26, 26, 46);
    private readonly Color _headerBg = Color.FromArgb(22, 33, 62);
    private readonly Color _btnActive = Color.FromArgb(21, 101, 192);
    private readonly Color _btnNormal = Color.FromArgb(26, 26, 46);

    public MainForm(UserSession session)
    {
        _session = session;
        InitializeComponent();
        SetupUser();
        SetupMenuByRole();
        LoadDefaultContent();
    }

    private void SetupUser()
    {
        lblUserName.Text = _session.DisplayName;
        lblUserRole.Text = GetRoleDisplay(_session.Role);
    }

    private string GetRoleDisplay(UserRole role) => role switch
    {
        UserRole.CoVienDieuPhoi => "Cô viên Điều phối",
        UserRole.BacSi => "Bác sĩ",
        UserRole.KyThuatVien => "Kỹ thuật viên",
        UserRole.BenhNhan => "Bệnh nhân",
        UserRole.DBA => "Quản trị hệ thống",
        _ => "Người dùng"
    };

    private void SetupMenuByRole()
    {
        pnlSidebar.Controls.Clear();
        // Logo
        var lblLogo = CreateSidebarLabel("🏥 PhanHe2", 18, true, Color.FromArgb(100, 181, 246));
        lblLogo.Height = 60;
        pnlSidebar.Controls.Add(lblLogo);

        // Thêm nút menu tùy theo vai trò
        switch (_session.Role)
        {
            case UserRole.CoVienDieuPhoi:
                AddMenuButton("📋  Tổng quan", () => LoadCoordinator());
                AddMenuButton("👤  Bệnh nhân", () => LoadCoordinator(0));
                AddMenuButton("📁  Hồ sơ bệnh án", () => LoadCoordinator(1));
                AddMenuButton("🔧  Phân công KTV", () => LoadCoordinator(2));
                break;
            case UserRole.BacSi:
                AddMenuButton("📋  Dashboard", () => LoadDoctor());
                AddMenuButton("📁  HSBA của tôi", () => LoadDoctor(0));
                AddMenuButton("🔬  Dịch vụ chẩn đoán", () => LoadDoctor(1));
                AddMenuButton("💊  Đơn thuốc", () => LoadDoctor(2));
                break;
            case UserRole.KyThuatVien:
                AddMenuButton("📋  Dashboard", () => LoadTechnician());
                AddMenuButton("🔬  Dịch vụ của tôi", () => LoadTechnician());
                break;
            case UserRole.BenhNhan:
                AddMenuButton("👤  Thông tin của tôi", () => LoadPatient());
                break;
            case UserRole.DBA:
                AddMenuButton("⚙️  Quản trị", () => { });
                break;
        }

        // Nút thông báo (chung cho tất cả)
        AddMenuButton("🔔  Thông báo", () => LoadNotification());
    }

    private Label CreateSidebarLabel(string text, float size, bool bold, Color color)
    {
        return new Label
        {
            Text = text,
            Font = new Font("Segoe UI", size, bold ? FontStyle.Bold : FontStyle.Regular),
            ForeColor = color,
            Dock = DockStyle.Top,
            Height = 50,
            TextAlign = ContentAlignment.MiddleCenter,
            BackColor = _sidebarBg,
            Padding = new Padding(10, 0, 0, 0)
        };
    }

    private void AddMenuButton(string text, Action onClick)
    {
        var btn = new Button
        {
            Text = text,
            Dock = DockStyle.Top,
            Height = 45,
            BackColor = _btnNormal,
            ForeColor = Color.FromArgb(200, 200, 230),
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9.5f),
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(20, 0, 0, 0),
            Cursor = Cursors.Hand
        };
        btn.FlatAppearance.BorderSize = 0;
        btn.FlatAppearance.MouseOverBackColor = Color.FromArgb(40, 40, 80);
        btn.Click += (s, e) => onClick();
        pnlSidebar.Controls.Add(btn);
        btn.BringToFront();
    }

    private void LoadContent(Control content)
    {
        pnlContent.Controls.Clear();
        content.Dock = DockStyle.Fill;
        pnlContent.Controls.Add(content);
    }

    private void LoadDefaultContent()
    {
        switch (_session.Role)
        {
            case UserRole.CoVienDieuPhoi: LoadCoordinator(); break;
            case UserRole.BacSi: LoadDoctor(); break;
            case UserRole.KyThuatVien: LoadTechnician(); break;
            case UserRole.BenhNhan: LoadPatient(); break;
            default: break;
        }
    }

    private void LoadCoordinator(int tabIndex = 0)
    {
        var dash = new CoordinatorDashboard();
        dash.SelectTab(tabIndex);
        LoadContent(dash);
    }

    private void LoadDoctor(int tabIndex = 0)
    {
        var dash = new DoctorDashboard();
        dash.SelectTab(tabIndex);
        LoadContent(dash);
    }

    private void LoadTechnician()
    {
        LoadContent(new TechnicianDashboard());
    }

    private void LoadPatient()
    {
        LoadContent(new PatientDashboard());
    }

    private void LoadNotification()
    {
        LoadContent(new NotificationForm());
    }

    private void btnLogout_Click(object sender, EventArgs e)
    {
        var result = MessageBox.Show(
            "Bạn có chắc chắn muốn đăng xuất?",
            "Xác nhận đăng xuất",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question);

        if (result == DialogResult.Yes)
        {
            AuthService.Logout();
            this.Hide();
            var loginForm = new LoginForm();
            loginForm.FormClosed += (s, e2) => this.Close();
            loginForm.Show();
        }
    }
}
