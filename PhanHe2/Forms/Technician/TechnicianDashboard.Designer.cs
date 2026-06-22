namespace PhanHe2.Forms.Technician;

partial class TechnicianDashboard
{
    private System.ComponentModel.IContainer components = null;
    private DataGridView dgvServices;
    private Panel pnlToolbar;
    private Button btnUpdateResult;
    private Button btnRefresh;
    private Label lblTitle;
    private Label lblCount;
    private Label lblInfo;

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

        // Tiêu đề
        lblTitle = new Label
        {
            Text = "🔬 DỊCH VỤ ĐƯỢC GIAO",
            Font = new Font("Segoe UI", 16f, FontStyle.Bold),
            ForeColor = Color.FromArgb(100, 181, 246),
            Dock = DockStyle.Top,
            Height = 55,
            TextAlign = ContentAlignment.MiddleCenter,
            BackColor = Color.FromArgb(20, 20, 40)
        };

        // Toolbar
        pnlToolbar = new Panel
        {
            Dock = DockStyle.Top,
            Height = 50,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(10, 8, 10, 8)
        };

        btnUpdateResult = new Button
        {
            Text = "✏️  Cập nhật kết quả",
            Width = 165,
            Height = 32,
            Left = 10,
            Top = 9,
            BackColor = Color.FromArgb(46, 125, 50),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnUpdateResult.FlatAppearance.BorderSize = 0;
        btnUpdateResult.Click += new EventHandler(btnUpdateResult_Click);

        btnRefresh = new Button
        {
            Text = "🔄  Làm mới",
            Width = 110,
            Height = 32,
            Left = 185,
            Top = 9,
            BackColor = Color.FromArgb(70, 70, 120),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9.5f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnRefresh.FlatAppearance.BorderSize = 0;
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

        pnlToolbar.Controls.AddRange(new Control[] { btnUpdateResult, btnRefresh, lblCount });

        // Thông tin
        lblInfo = new Label
        {
            Text = "📌 Hiển thị các dịch vụ được phân công cho bạn (qua view VW_HSBA_DV_KTV)",
            Font = new Font("Segoe UI", 8.5f, FontStyle.Italic),
            ForeColor = Color.FromArgb(120, 150, 200),
            Dock = DockStyle.Bottom,
            Height = 28,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(10, 0, 0, 0),
            BackColor = Color.FromArgb(20, 20, 40)
        };

        // DataGridView
        dgvServices = new DataGridView
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
        dgvServices.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(22, 33, 62);
        dgvServices.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(100, 181, 246);
        dgvServices.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9f, FontStyle.Bold);
        dgvServices.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(22, 33, 62);
        dgvServices.ColumnHeadersHeight = 35;
        dgvServices.DefaultCellStyle.BackColor = Color.FromArgb(18, 18, 35);
        dgvServices.DefaultCellStyle.ForeColor = Color.White;
        dgvServices.DefaultCellStyle.SelectionBackColor = Color.FromArgb(30, 80, 160);
        dgvServices.DefaultCellStyle.SelectionForeColor = Color.White;
        dgvServices.DefaultCellStyle.Padding = new Padding(3);
        dgvServices.AlternatingRowsDefaultCellStyle.BackColor = Color.FromArgb(22, 22, 42);
        dgvServices.AlternatingRowsDefaultCellStyle.ForeColor = Color.White;
        dgvServices.RowTemplate.Height = 30;
        dgvServices.EnableHeadersVisualStyles = false;

        this.Controls.Add(dgvServices);
        this.Controls.Add(pnlToolbar);
        this.Controls.Add(lblTitle);
        this.Controls.Add(lblInfo);
    }
}
