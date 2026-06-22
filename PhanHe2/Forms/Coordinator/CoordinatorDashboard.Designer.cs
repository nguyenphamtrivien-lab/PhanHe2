namespace PhanHe2.Forms.Coordinator;

partial class CoordinatorDashboard
{
    private System.ComponentModel.IContainer components = null;

    // Tab control
    private TabControl tabControl;
    private TabPage tabPatients;
    private TabPage tabHsba;
    private TabPage tabHsbaDv;

    // Tab Bệnh nhân
    private DataGridView dgvPatients;
    private Button btnAddPatient;
    private Button btnEditPatient;
    private Button btnSearchPatient;
    private TextBox txtSearchPatient;
    private Label lblPatientCount;
    private Panel pnlPatientToolbar;

    // Tab HSBA
    private DataGridView dgvHsba;
    private Button btnCreateHsba;
    private Button btnAssignDoctor;
    private Label lblHsbaCount;
    private Panel pnlHsbaToolbar;

    // Tab phân công KTV
    private DataGridView dgvHsbaDv;
    private Button btnAssignKTV;
    private Label lblDvCount;
    private Panel pnlDvToolbar;

    protected override void Dispose(bool disposing)
    {
        if (disposing && components != null) components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        components = new System.ComponentModel.Container();

        // UserControl settings
        this.BackColor = Color.FromArgb(15, 15, 26);
        this.Font = new Font("Segoe UI", 9f);
        this.Dock = DockStyle.Fill;

        // ================== TabControl ====================
        tabControl = new TabControl
        {
            Dock = DockStyle.Fill,
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            Padding = new Point(15, 8)
        };

        // Đặt màu tab (thông qua override Paint event)
        tabControl.DrawMode = TabDrawMode.OwnerDrawFixed;
        tabControl.DrawItem += (sender, e) =>
        {
            var g = e.Graphics;
            var tab = tabControl.TabPages[e.Index];
            var bounds = tabControl.GetTabRect(e.Index);
            bool selected = e.Index == tabControl.SelectedIndex;
            var bgBrush = new System.Drawing.SolidBrush(selected
                ? Color.FromArgb(21, 101, 192)
                : Color.FromArgb(30, 30, 58));
            g.FillRectangle(bgBrush, bounds);
            var textColor = selected ? Color.White : Color.FromArgb(160, 160, 200);
            TextRenderer.DrawText(g, tab.Text, e.Font ?? tabControl.Font, bounds,
                textColor, TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter);
            bgBrush.Dispose();
        };

        // ================== Tab 1: Bệnh nhân ====================
        tabPatients = new TabPage
        {
            Text = "  👤  Bệnh nhân  ",
            BackColor = Color.FromArgb(15, 15, 26)
        };

        pnlPatientToolbar = new Panel
        {
            Dock = DockStyle.Top,
            Height = 50,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(10, 8, 10, 8)
        };

        btnAddPatient = CreateToolbarButton("➕  Thêm mới", Color.FromArgb(21, 101, 192));
        btnAddPatient.Left = 10;
        btnAddPatient.Click += new EventHandler(btnAddPatient_Click);

        btnEditPatient = CreateToolbarButton("✏️  Sửa", Color.FromArgb(46, 125, 50));
        btnEditPatient.Left = 130;
        btnEditPatient.Click += new EventHandler(btnEditPatient_Click);

        txtSearchPatient = new TextBox
        {
            Width = 200,
            Height = 32,
            Left = 300,
            Top = 9,
            BackColor = Color.FromArgb(40, 40, 70),
            ForeColor = Color.White,
            BorderStyle = BorderStyle.FixedSingle,
            Font = new Font("Segoe UI", 9.5f),
            PlaceholderText = "Tìm theo tên, mã, CCCD..."
        };

        btnSearchPatient = CreateToolbarButton("🔍  Tìm", Color.FromArgb(100, 100, 150));
        btnSearchPatient.Left = 510;
        btnSearchPatient.Click += new EventHandler(btnSearchPatient_Click);

        lblPatientCount = new Label
        {
            Text = "Đang tải...",
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 200,
            Height = 32,
            Left = 680,
            Top = 9,
            TextAlign = ContentAlignment.MiddleRight,
            Font = new Font("Segoe UI", 9f)
        };

        pnlPatientToolbar.Controls.AddRange(new Control[]
            { btnAddPatient, btnEditPatient, txtSearchPatient, btnSearchPatient, lblPatientCount });

        dgvPatients = CreateDarkDataGridView();
        dgvPatients.Dock = DockStyle.Fill;

        tabPatients.Controls.Add(dgvPatients);
        tabPatients.Controls.Add(pnlPatientToolbar);

        // ================== Tab 2: Hồ sơ bệnh án ====================
        tabHsba = new TabPage
        {
            Text = "  📁  Hồ sơ bệnh án  ",
            BackColor = Color.FromArgb(15, 15, 26)
        };

        pnlHsbaToolbar = new Panel
        {
            Dock = DockStyle.Top,
            Height = 50,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(10, 8, 10, 8)
        };

        btnCreateHsba = CreateToolbarButton("➕  Tạo HSBA mới", Color.FromArgb(21, 101, 192));
        btnCreateHsba.Left = 10;
        btnCreateHsba.Width = 150;
        btnCreateHsba.Click += new EventHandler(btnCreateHsba_Click);

        btnAssignDoctor = CreateToolbarButton("👨⚕️  Phân công Bác sĩ", Color.FromArgb(46, 125, 50));
        btnAssignDoctor.Left = 170;
        btnAssignDoctor.Width = 180;
        btnAssignDoctor.Click += new EventHandler(btnAssignDoctor_Click);

        lblHsbaCount = new Label
        {
            Text = "Đang tải...",
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 200,
            Height = 32,
            Left = 680,
            Top = 9,
            TextAlign = ContentAlignment.MiddleRight,
            Font = new Font("Segoe UI", 9f)
        };

        pnlHsbaToolbar.Controls.AddRange(new Control[] { btnCreateHsba, btnAssignDoctor, lblHsbaCount });

        dgvHsba = CreateDarkDataGridView();
        dgvHsba.Dock = DockStyle.Fill;

        tabHsba.Controls.Add(dgvHsba);
        tabHsba.Controls.Add(pnlHsbaToolbar);

        // ================== Tab 3: Phân công KTV ====================
        tabHsbaDv = new TabPage
        {
            Text = "  🔧  Phân công KTV  ",
            BackColor = Color.FromArgb(15, 15, 26)
        };

        pnlDvToolbar = new Panel
        {
            Dock = DockStyle.Top,
            Height = 50,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(10, 8, 10, 8)
        };

        btnAssignKTV = CreateToolbarButton("🔧  Phân công KTV", Color.FromArgb(21, 101, 192));
        btnAssignKTV.Left = 10;
        btnAssignKTV.Width = 160;
        btnAssignKTV.Click += new EventHandler(btnAssignKTV_Click);

        lblDvCount = new Label
        {
            Text = "Đang tải...",
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 200,
            Height = 32,
            Left = 680,
            Top = 9,
            TextAlign = ContentAlignment.MiddleRight,
            Font = new Font("Segoe UI", 9f)
        };

        pnlDvToolbar.Controls.AddRange(new Control[] { btnAssignKTV, lblDvCount });

        dgvHsbaDv = CreateDarkDataGridView();
        dgvHsbaDv.Dock = DockStyle.Fill;

        tabHsbaDv.Controls.Add(dgvHsbaDv);
        tabHsbaDv.Controls.Add(pnlDvToolbar);

        // Thêm tabs vào tabControl
        tabControl.TabPages.AddRange(new[] { tabPatients, tabHsba, tabHsbaDv });

        // Thêm tabControl vào UserControl
        this.Controls.Add(tabControl);
    }

    /// <summary>Tạo button chuẩn cho toolbar</summary>
    private static Button CreateToolbarButton(string text, Color backColor)
    {
        var btn = new Button
        {
            Text = text,
            Width = 110,
            Height = 32,
            Top = 9,
            BackColor = backColor,
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 9f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btn.FlatAppearance.BorderSize = 0;
        return btn;
    }

    /// <summary>Tạo DataGridView với dark theme chuẩn</summary>
    private static DataGridView CreateDarkDataGridView()
    {
        var dgv = new DataGridView
        {
            BackgroundColor = Color.FromArgb(18, 18, 35),
            ForeColor = Color.White,
            GridColor = Color.FromArgb(50, 50, 80),
            BorderStyle = BorderStyle.None,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            MultiSelect = false,
            ReadOnly = true,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
            RowHeadersVisible = false,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false
        };
        // Header style
        dgv.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(22, 33, 62);
        dgv.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(100, 181, 246);
        dgv.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9f, FontStyle.Bold);
        dgv.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(22, 33, 62);
        dgv.ColumnHeadersHeight = 35;
        // Row style
        dgv.DefaultCellStyle.BackColor = Color.FromArgb(18, 18, 35);
        dgv.DefaultCellStyle.ForeColor = Color.White;
        dgv.DefaultCellStyle.SelectionBackColor = Color.FromArgb(30, 80, 160);
        dgv.DefaultCellStyle.SelectionForeColor = Color.White;
        dgv.DefaultCellStyle.Padding = new Padding(3);
        // Alternating row style
        dgv.AlternatingRowsDefaultCellStyle.BackColor = Color.FromArgb(22, 22, 42);
        dgv.AlternatingRowsDefaultCellStyle.ForeColor = Color.White;
        dgv.RowTemplate.Height = 30;
        dgv.EnableHeadersVisualStyles = false;
        return dgv;
    }
}
