namespace PhanHe2.Forms.Notification;

partial class NotificationForm
{
    private System.ComponentModel.IContainer components = null;
    private DataGridView dgvNotifications;
    private Panel pnlToolbar;
    private Button btnRefresh;
    private Label lblTitle;
    private Label lblCount;
    private Label lblOlsInfo;

    protected override void Dispose(bool disposing)
    {
        if (disposing && components != null) components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        components = new System.ComponentModel.Container();
        this.BackColor = Color.FromArgb(15, 15, 26);
        this.Font = new Font("Segoe UI", 9f);
        this.Dock = DockStyle.Fill;

        lblTitle = new Label
        {
            Text = "🔔 THÔNG BÁO HỆ THỐNG",
            Font = new Font("Segoe UI", 16f, FontStyle.Bold),
            ForeColor = Color.FromArgb(100, 181, 246),
            Dock = DockStyle.Top,
            Height = 55,
            TextAlign = ContentAlignment.MiddleCenter,
            BackColor = Color.FromArgb(20, 20, 40)
        };

        lblOlsInfo = new Label
        {
            Text = "🔒 Bạn chỉ thấy các thông báo phù hợp với quyền hạn của mình (Oracle Label Security - OLS)",
            Font = new Font("Segoe UI", 9f, FontStyle.Italic),
            ForeColor = Color.FromArgb(120, 180, 120),
            Dock = DockStyle.Top,
            Height = 32,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = Color.FromArgb(15, 30, 15),
            Padding = new Padding(15, 0, 0, 0)
        };

        pnlToolbar = new Panel
        {
            Dock = DockStyle.Top,
            Height = 50,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(10, 8, 10, 8)
        };

        btnRefresh = new Button
        {
            Text = "🔄  Làm mới",
            Width = 120,
            Height = 32,
            Left = 10,
            Top = 9,
            BackColor = Color.FromArgb(21, 101, 192),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnRefresh.FlatAppearance.BorderSize = 0;
        btnRefresh.FlatAppearance.MouseOverBackColor = Color.FromArgb(25, 118, 210);
        btnRefresh.Click += new EventHandler(btnRefresh_Click);

        lblCount = new Label
        {
            Text = "Đang tải...",
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 250,
            Height = 32,
            Left = 650,
            Top = 9,
            TextAlign = ContentAlignment.MiddleRight,
            Font = new Font("Segoe UI", 9f)
        };

        pnlToolbar.Controls.AddRange(new Control[] { btnRefresh, lblCount });

        // DataGridView
        dgvNotifications = new DataGridView
        {
            Dock = DockStyle.Fill,
            BackgroundColor = Color.FromArgb(18, 18, 35),
            ForeColor = Color.White,
            GridColor = Color.FromArgb(50, 50, 80),
            BorderStyle = BorderStyle.None,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            MultiSelect = false,
            ReadOnly = true,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
            RowHeadersVisible = false,
            AllowUserToAddRows = false
        };
        dgvNotifications.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(22, 33, 62);
        dgvNotifications.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(100, 181, 246);
        dgvNotifications.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9f, FontStyle.Bold);
        dgvNotifications.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(22, 33, 62);
        dgvNotifications.ColumnHeadersHeight = 35;
        dgvNotifications.DefaultCellStyle.BackColor = Color.FromArgb(18, 18, 35);
        dgvNotifications.DefaultCellStyle.ForeColor = Color.White;
        dgvNotifications.DefaultCellStyle.SelectionBackColor = Color.FromArgb(30, 80, 160);
        dgvNotifications.DefaultCellStyle.SelectionForeColor = Color.White;
        dgvNotifications.DefaultCellStyle.Padding = new Padding(3);
        dgvNotifications.AlternatingRowsDefaultCellStyle.BackColor = Color.FromArgb(22, 22, 42);
        dgvNotifications.AlternatingRowsDefaultCellStyle.ForeColor = Color.White;
        dgvNotifications.RowTemplate.Height = 30;
        dgvNotifications.EnableHeadersVisualStyles = false;

        this.Controls.Add(dgvNotifications);
        this.Controls.Add(pnlToolbar);
        this.Controls.Add(lblOlsInfo);
        this.Controls.Add(lblTitle);
    }
}
