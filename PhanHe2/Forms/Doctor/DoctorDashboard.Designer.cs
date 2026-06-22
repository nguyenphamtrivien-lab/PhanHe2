namespace PhanHe2.Forms.Doctor;

partial class DoctorDashboard
{
    private System.ComponentModel.IContainer components = null;

    private TabControl tabControl;
    private TabPage tabHsba;
    private TabPage tabServices;
    private TabPage tabPrescriptions;

    private DataGridView dgvHsba;
    private DataGridView dgvServices;
    private DataGridView dgvPrescriptions;

    private Panel pnlHsbaToolbar;
    private Button btnViewDetail;
    private Button btnUpdateDiagnosis;
    private Label lblHsbaCount;

    private Panel pnlPresToolbar;
    private Button btnAddPrescription;

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

        tabControl = new TabControl
        {
            Dock = DockStyle.Fill,
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            Padding = new Point(15, 8),
            DrawMode = TabDrawMode.OwnerDrawFixed
        };
        tabControl.DrawItem += (sender, e) =>
        {
            var g = e.Graphics;
            var tab = tabControl.TabPages[e.Index];
            var bounds = tabControl.GetTabRect(e.Index);
            bool selected = e.Index == tabControl.SelectedIndex;
            using var bgBrush = new System.Drawing.SolidBrush(selected
                ? Color.FromArgb(21, 101, 192)
                : Color.FromArgb(30, 30, 58));
            g.FillRectangle(bgBrush, bounds);
            TextRenderer.DrawText(g, tab.Text, e.Font ?? tabControl.Font, bounds,
                selected ? Color.White : Color.FromArgb(160, 160, 200),
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter);
        };

        // Tab 1: HSBA của tôi
        tabHsba = new TabPage { Text = "  📁  HSBA của tôi  ", BackColor = Color.FromArgb(15, 15, 26) };
        pnlHsbaToolbar = new Panel { Dock = DockStyle.Top, Height = 50, BackColor = Color.FromArgb(20, 20, 40), Padding = new Padding(10, 8, 10, 8) };

        btnViewDetail = CreateBtn("🔍  Xem chi tiết", Color.FromArgb(21, 101, 192), 10);
        btnViewDetail.Click += new EventHandler(btnViewDetail_Click);

        btnUpdateDiagnosis = CreateBtn("✏️  Cập nhật CĐ", Color.FromArgb(46, 125, 50), 140);
        btnUpdateDiagnosis.Click += new EventHandler(btnUpdateDiagnosis_Click);

        lblHsbaCount = new Label { Text = "Đang tải...", ForeColor = Color.FromArgb(150, 200, 255), AutoSize = false, Width = 200, Height = 32, Left = 680, Top = 9, TextAlign = ContentAlignment.MiddleRight, Font = new Font("Segoe UI", 9f) };
        pnlHsbaToolbar.Controls.AddRange(new Control[] { btnViewDetail, btnUpdateDiagnosis, lblHsbaCount });

        dgvHsba = CreateDGV();
        dgvHsba.Dock = DockStyle.Fill;
        dgvHsba.SelectionChanged += new EventHandler(dgvHsba_SelectionChanged);

        tabHsba.Controls.Add(dgvHsba);
        tabHsba.Controls.Add(pnlHsbaToolbar);

        // Tab 2: Dịch vụ
        tabServices = new TabPage { Text = "  🔬  Dịch vụ chẩn đoán  ", BackColor = Color.FromArgb(15, 15, 26) };
        dgvServices = CreateDGV();
        dgvServices.Dock = DockStyle.Fill;
        tabServices.Controls.Add(dgvServices);

        // Tab 3: Đơn thuốc
        tabPrescriptions = new TabPage { Text = "  💊  Đơn thuốc  ", BackColor = Color.FromArgb(15, 15, 26) };
        pnlPresToolbar = new Panel { Dock = DockStyle.Top, Height = 50, BackColor = Color.FromArgb(20, 20, 40), Padding = new Padding(10, 8, 10, 8) };
        btnAddPrescription = CreateBtn("➕  Thêm thuốc", Color.FromArgb(21, 101, 192), 10);
        btnAddPrescription.Click += new EventHandler(btnAddPrescription_Click);
        pnlPresToolbar.Controls.Add(btnAddPrescription);
        dgvPrescriptions = CreateDGV();
        dgvPrescriptions.Dock = DockStyle.Fill;
        tabPrescriptions.Controls.Add(dgvPrescriptions);
        tabPrescriptions.Controls.Add(pnlPresToolbar);

        tabControl.TabPages.AddRange(new[] { tabHsba, tabServices, tabPrescriptions });
        this.Controls.Add(tabControl);
    }

    private static Button CreateBtn(string text, Color color, int left)
    {
        var btn = new Button { Text = text, Width = 120, Height = 32, Top = 9, Left = left, BackColor = color, ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 9f, FontStyle.Bold), Cursor = Cursors.Hand };
        btn.FlatAppearance.BorderSize = 0;
        return btn;
    }

    private static DataGridView CreateDGV()
    {
        var dgv = new DataGridView
        {
            BackgroundColor = Color.FromArgb(18, 18, 35), ForeColor = Color.White, GridColor = Color.FromArgb(50, 50, 80),
            BorderStyle = BorderStyle.None, SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            MultiSelect = false, ReadOnly = true, AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
            RowHeadersVisible = false, AllowUserToAddRows = false, AllowUserToDeleteRows = false
        };
        dgv.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(22, 33, 62);
        dgv.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(100, 181, 246);
        dgv.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9f, FontStyle.Bold);
        dgv.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(22, 33, 62);
        dgv.ColumnHeadersHeight = 35;
        dgv.DefaultCellStyle.BackColor = Color.FromArgb(18, 18, 35);
        dgv.DefaultCellStyle.ForeColor = Color.White;
        dgv.DefaultCellStyle.SelectionBackColor = Color.FromArgb(30, 80, 160);
        dgv.DefaultCellStyle.SelectionForeColor = Color.White;
        dgv.DefaultCellStyle.Padding = new Padding(3);
        dgv.AlternatingRowsDefaultCellStyle.BackColor = Color.FromArgb(22, 22, 42);
        dgv.AlternatingRowsDefaultCellStyle.ForeColor = Color.White;
        dgv.RowTemplate.Height = 30;
        dgv.EnableHeadersVisualStyles = false;
        return dgv;
    }
}
