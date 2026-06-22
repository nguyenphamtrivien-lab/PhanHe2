namespace PhanHe2.Forms;

partial class LoginForm
{
    private System.ComponentModel.IContainer components = null;

    // Controls
    private Panel pnlBackground;
    private Panel pnlCenter;
    private Label lblIcon;
    private Label lblTitle;
    private Label lblSubTitle;
    private Label lblUsername;
    private TextBox txtUsername;
    private Label lblPassword;
    private TextBox txtPassword;
    private Label lblServerLabel;
    private ComboBox cmbServer;
    private Label lblPort;
    private TextBox txtPort;
    private Label lblService;
    private TextBox txtService;
    private Button btnLogin;
    private Label lblStatus;
    private Panel pnlSeparator;
    private Label lblVersion;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
            components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        components = new System.ComponentModel.Container();

        // === Form chính ===
        this.Text = "Đăng nhập - Hệ thống Quản lý Y tế Bệnh viện";
        this.Size = new Size(520, 680);
        this.StartPosition = FormStartPosition.CenterScreen;
        this.FormBorderStyle = FormBorderStyle.FixedSingle;
        this.MaximizeBox = false;
        this.BackColor = Color.FromArgb(18, 18, 30);
        this.Font = new Font("Segoe UI", 9f);

        // === Panel nền chính (toàn bộ form) ===
        pnlBackground = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = Color.FromArgb(18, 18, 30),
            Padding = new Padding(40)
        };

        // === Panel trung tâm bo tròn ===
        pnlCenter = new Panel
        {
            BackColor = Color.FromArgb(30, 30, 58),
            Padding = new Padding(40),
            Width = 420,
            Height = 580,
            Left = 10,
            Top = 30
        };

        // === Icon bệnh viện ===
        lblIcon = new Label
        {
            Text = "🏥",
            Font = new Font("Segoe UI", 32f),
            ForeColor = Color.FromArgb(100, 181, 246),
            AutoSize = false,
            Width = 340,
            Height = 50,
            Left = 40,
            Top = 30,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // === Tiêu đề chính ===
        lblTitle = new Label
        {
            Text = "QUẢN LÝ Y TẾ",
            Font = new Font("Segoe UI", 20f, FontStyle.Bold),
            ForeColor = Color.FromArgb(100, 181, 246),
            AutoSize = false,
            Width = 340,
            Height = 40,
            Left = 40,
            Top = 85,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // === Tiêu đề phụ ===
        lblSubTitle = new Label
        {
            Text = "Hệ thống quản lý dữ liệu bệnh viện",
            Font = new Font("Segoe UI", 10f),
            ForeColor = Color.FromArgb(150, 150, 180),
            AutoSize = false,
            Width = 340,
            Height = 25,
            Left = 40,
            Top = 128,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // === Separator ===
        pnlSeparator = new Panel
        {
            BackColor = Color.FromArgb(60, 60, 100),
            Width = 300,
            Height = 1,
            Left = 60,
            Top = 163
        };

        // === Label Username ===
        lblUsername = new Label
        {
            Text = "TÊN ĐĂNG NHẬP",
            Font = new Font("Segoe UI", 8f, FontStyle.Bold),
            ForeColor = Color.FromArgb(120, 180, 250),
            AutoSize = false,
            Width = 340,
            Height = 20,
            Left = 40,
            Top = 180
        };

        // === TextBox Username ===
        txtUsername = new TextBox
        {
            Width = 340,
            Height = 38,
            Left = 40,
            Top = 202,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Font = new Font("Segoe UI", 11f),
            Padding = new Padding(5)
        };
        txtUsername.KeyDown += new KeyEventHandler(txtUsername_KeyDown);

        // === Label Password ===
        lblPassword = new Label
        {
            Text = "MẬT KHẨU",
            Font = new Font("Segoe UI", 8f, FontStyle.Bold),
            ForeColor = Color.FromArgb(120, 180, 250),
            AutoSize = false,
            Width = 340,
            Height = 20,
            Left = 40,
            Top = 255
        };

        // === TextBox Password ===
        txtPassword = new TextBox
        {
            Width = 340,
            Height = 38,
            Left = 40,
            Top = 277,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Font = new Font("Segoe UI", 11f),
            PasswordChar = '●'
        };
        txtPassword.KeyDown += new KeyEventHandler(txtPassword_KeyDown);

        // === Label Server ===
        lblServerLabel = new Label
        {
            Text = "MÁY CHỦ",
            Font = new Font("Segoe UI", 8f, FontStyle.Bold),
            ForeColor = Color.FromArgb(120, 180, 250),
            AutoSize = false,
            Width = 160,
            Height = 20,
            Left = 40,
            Top = 330
        };

        // === ComboBox Server ===
        cmbServer = new ComboBox
        {
            Width = 160,
            Height = 32,
            Left = 40,
            Top = 352,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 10f),
            DropDownStyle = ComboBoxStyle.DropDown
        };
        cmbServer.Items.AddRange(new[] { "localhost", "127.0.0.1" });
        cmbServer.Text = "localhost";

        // === Label Port ===
        lblPort = new Label
        {
            Text = "CỔNG",
            Font = new Font("Segoe UI", 8f, FontStyle.Bold),
            ForeColor = Color.FromArgb(120, 180, 250),
            AutoSize = false,
            Width = 80,
            Height = 20,
            Left = 215,
            Top = 330
        };

        // === TextBox Port ===
        txtPort = new TextBox
        {
            Width = 80,
            Height = 32,
            Left = 215,
            Top = 352,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Font = new Font("Segoe UI", 10f),
            Text = "1521",
            TextAlign = HorizontalAlignment.Center
        };

        // === Label Service ===
        lblService = new Label
        {
            Text = "SERVICE",
            Font = new Font("Segoe UI", 8f, FontStyle.Bold),
            ForeColor = Color.FromArgb(120, 180, 250),
            AutoSize = false,
            Width = 80,
            Height = 20,
            Left = 308,
            Top = 330
        };

        // === TextBox Service ===
        txtService = new TextBox
        {
            Width = 72,
            Height = 32,
            Left = 308,
            Top = 352,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Font = new Font("Segoe UI", 10f),
            Text = "XE",
            TextAlign = HorizontalAlignment.Center
        };

        // === Button Đăng nhập ===
        btnLogin = new Button
        {
            Text = "ĐĂNG NHẬP",
            Width = 340,
            Height = 45,
            Left = 40,
            Top = 410,
            BackColor = Color.FromArgb(21, 101, 192),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 11f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnLogin.FlatAppearance.BorderSize = 0;
        btnLogin.Click += new EventHandler(btnLogin_Click);

        // === Label Status (lỗi) ===
        lblStatus = new Label
        {
            Text = "",
            Font = new Font("Segoe UI", 9f),
            ForeColor = Color.FromArgb(239, 83, 80),
            AutoSize = false,
            Width = 340,
            Height = 40,
            Left = 40,
            Top = 465,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // === Label Version ===
        lblVersion = new Label
        {
            Text = "PhanHe2 v1.0 | Oracle 21c XE | .NET 8",
            Font = new Font("Segoe UI", 8f),
            ForeColor = Color.FromArgb(80, 80, 110),
            AutoSize = false,
            Width = 340,
            Height = 20,
            Left = 40,
            Top = 510,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // Thêm controls vào pnlCenter
        pnlCenter.Controls.AddRange(new Control[]
        {
            lblIcon, lblTitle, lblSubTitle, pnlSeparator,
            lblUsername, txtUsername,
            lblPassword, txtPassword,
            lblServerLabel, cmbServer,
            lblPort, txtPort,
            lblService, txtService,
            btnLogin, lblStatus, lblVersion
        });

        // Thêm pnlCenter vào pnlBackground
        pnlBackground.Controls.Add(pnlCenter);

        // Thêm pnlBackground vào Form
        this.Controls.Add(pnlBackground);
    }
}
