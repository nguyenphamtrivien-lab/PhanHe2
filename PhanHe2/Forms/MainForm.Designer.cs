namespace PhanHe2.Forms;

partial class MainForm
{
    private System.ComponentModel.IContainer components = null;

    // Controls
    private Panel pnlSidebar;
    private Panel pnlHeader;
    private Panel pnlContent;
    private Label lblUserName;
    private Label lblUserRole;
    private Button btnLogout;
    private Panel pnlHeaderLeft;
    private Label lblAppTitle;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
            components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        components = new System.ComponentModel.Container();

        // === Form ===
        this.Text = "PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện";
        this.Size = new Size(1200, 750);
        this.StartPosition = FormStartPosition.CenterScreen;
        this.BackColor = Color.FromArgb(15, 15, 26);
        this.Font = new Font("Segoe UI", 9f);
        this.MinimumSize = new Size(900, 600);

        // === Panel Header (trên cùng) ===
        pnlHeader = new Panel
        {
            Dock = DockStyle.Top,
            Height = 60,
            BackColor = Color.FromArgb(22, 33, 62),
            Padding = new Padding(10)
        };

        // App title trong header
        lblAppTitle = new Label
        {
            Text = "🏥 HỆ THỐNG QUẢN LÝ Y TẾ BỆNH VIỆN",
            Font = new Font("Segoe UI", 12f, FontStyle.Bold),
            ForeColor = Color.FromArgb(100, 181, 246),
            Dock = DockStyle.Left,
            Width = 450,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(10, 0, 0, 0)
        };

        // Panel bên phải header (thông tin user)
        pnlHeaderLeft = new Panel
        {
            Dock = DockStyle.Right,
            Width = 350,
            BackColor = Color.Transparent
        };

        lblUserName = new Label
        {
            Text = "Người dùng",
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            ForeColor = Color.White,
            AutoSize = false,
            Width = 200,
            Height = 30,
            Left = 10,
            Top = 5,
            TextAlign = ContentAlignment.BottomLeft
        };

        lblUserRole = new Label
        {
            Text = "Vai trò",
            Font = new Font("Segoe UI", 8.5f),
            ForeColor = Color.FromArgb(150, 200, 250),
            AutoSize = false,
            Width = 200,
            Height = 25,
            Left = 10,
            Top = 35,
            TextAlign = ContentAlignment.TopLeft
        };

        btnLogout = new Button
        {
            Text = "⏻  Đăng xuất",
            Width = 120,
            Height = 36,
            Left = 215,
            Top = 12,
            BackColor = Color.FromArgb(180, 50, 50),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnLogout.FlatAppearance.BorderSize = 0;
        btnLogout.FlatAppearance.MouseOverBackColor = Color.FromArgb(200, 60, 60);
        btnLogout.Click += new EventHandler(btnLogout_Click);

        pnlHeaderLeft.Controls.AddRange(new Control[] { lblUserName, lblUserRole, btnLogout });
        pnlHeader.Controls.AddRange(new Control[] { lblAppTitle, pnlHeaderLeft });

        // === Panel Sidebar (bên trái) ===
        pnlSidebar = new Panel
        {
            Dock = DockStyle.Left,
            Width = 220,
            BackColor = Color.FromArgb(26, 26, 46)
        };

        // === Panel Content (vùng nội dung chính) ===
        pnlContent = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = Color.FromArgb(15, 15, 26),
            Padding = new Padding(10)
        };

        // Thêm controls theo thứ tự (DockStyle.Fill phải thêm sau)
        this.Controls.Add(pnlContent);
        this.Controls.Add(pnlSidebar);
        this.Controls.Add(pnlHeader);
    }
}
