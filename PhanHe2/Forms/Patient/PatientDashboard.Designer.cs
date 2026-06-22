namespace PhanHe2.Forms.Patient;

partial class PatientDashboard
{
    private System.ComponentModel.IContainer components = null;

    // Read-only info labels
    private Label lblTitle;
    private Label lblMaBN, lblMaBNValue;
    private Label lblTenBN, lblTenBNValue;
    private Label lblNgaySinh, lblNgaySinhValue;
    private Label lblCCCD, lblCCCDValue;
    private Label lblPhai, lblPhaiValue;

    // Editable fields
    private Label lblSoNha;
    private TextBox txtSoNha;
    private Label lblTenDuong;
    private TextBox txtTenDuong;
    private Label lblQuanHuyen;
    private TextBox txtQuanHuyen;
    private Label lblTinhTP;
    private TextBox txtTinhTP;
    private Label lblTienSuBenh;
    private TextBox txtTienSuBenh;
    private Label lblTienSuBenhGD;
    private TextBox txtTienSuBenhGD;
    private Label lblDiUngThuoc;
    private TextBox txtDiUngThuoc;

    private Button btnSave;
    private Panel pnlReadOnly;
    private Panel pnlEditable;
    private Label lblSectionInfo;
    private Label lblSectionEdit;

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

        // ===== Tiêu đề =====
        lblTitle = new Label
        {
            Text = "👤 THÔNG TIN CÁ NHÂN",
            Font = new Font("Segoe UI", 16f, FontStyle.Bold),
            ForeColor = Color.FromArgb(100, 181, 246),
            Dock = DockStyle.Top,
            Height = 55,
            TextAlign = ContentAlignment.MiddleCenter,
            BackColor = Color.FromArgb(20, 20, 40)
        };

        // ===== Panel Thông tin chỉ đọc =====
        pnlReadOnly = new Panel
        {
            Dock = DockStyle.Top,
            Height = 200,
            BackColor = Color.FromArgb(20, 20, 40),
            Padding = new Padding(30, 15, 30, 15)
        };

        lblSectionInfo = new Label
        {
            Text = "📋 THÔNG TIN CƠ BẢN (Chỉ xem)",
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 700,
            Height = 28,
            Left = 0,
            Top = 5
        };

        // Khởi tạo các label
        lblMaBN = CreateLabel("Mã BN:", 0, 38, bold: true);
        lblMaBNValue = CreateValueLabel("", 100, 38);
        lblTenBN = CreateLabel("Họ tên:", 250, 38, bold: true);
        lblTenBNValue = CreateValueLabel("", 330, 38);
        lblNgaySinh = CreateLabel("Ngày sinh:", 0, 75, bold: true);
        lblNgaySinhValue = CreateValueLabel("", 100, 75);
        lblCCCD = CreateLabel("CCCD:", 250, 75, bold: true);
        lblCCCDValue = CreateValueLabel("", 330, 75);
        lblPhai = CreateLabel("Phái:", 0, 112, bold: true);
        lblPhaiValue = CreateValueLabel("", 100, 112);

        pnlReadOnly.Controls.Add(lblSectionInfo);
        pnlReadOnly.Controls.AddRange(new Control[]
        {
            lblMaBN, lblMaBNValue,
            lblTenBN, lblTenBNValue,
            lblNgaySinh, lblNgaySinhValue,
            lblCCCD, lblCCCDValue,
            lblPhai, lblPhaiValue
        });

        // ===== Panel Thông tin có thể chỉnh sửa =====
        pnlEditable = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = Color.FromArgb(15, 15, 26),
            Padding = new Padding(30, 10, 30, 10),
            AutoScroll = true
        };

        lblSectionEdit = new Label
        {
            Text = "✏️ THÔNG TIN CÓ THỂ CẬP NHẬT",
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            ForeColor = Color.FromArgb(150, 200, 255),
            AutoSize = false,
            Width = 700,
            Height = 28,
            Left = 0,
            Top = 10
        };

        // Tạo các trường có thể chỉnh sửa
        int yStart = 45;
        int rowH = 60;

        lblSoNha = CreateFieldLabel("Số nhà:", 0, yStart);
        txtSoNha = CreateEditField(120, yStart);

        lblTenDuong = CreateFieldLabel("Tên đường:", 400, yStart);
        txtTenDuong = CreateEditField(520, yStart);

        lblQuanHuyen = CreateFieldLabel("Quận/Huyện:", 0, yStart + rowH);
        txtQuanHuyen = CreateEditField(120, yStart + rowH);

        lblTinhTP = CreateFieldLabel("Tỉnh/TP:", 400, yStart + rowH);
        txtTinhTP = CreateEditField(520, yStart + rowH);

        lblTienSuBenh = CreateFieldLabel("Tiền sử bệnh:", 0, yStart + rowH * 2);
        txtTienSuBenh = CreateMultilineField(120, yStart + rowH * 2, 820);

        lblTienSuBenhGD = CreateFieldLabel("Tiền sử bệnh GĐ:", 0, yStart + rowH * 2 + 75);
        txtTienSuBenhGD = CreateMultilineField(120, yStart + rowH * 2 + 75, 820);

        lblDiUngThuoc = CreateFieldLabel("Dị ứng thuốc:", 0, yStart + rowH * 2 + 150);
        txtDiUngThuoc = CreateMultilineField(120, yStart + rowH * 2 + 150, 820);

        btnSave = new Button
        {
            Text = "💾  LƯU THAY ĐỔI",
            Width = 200,
            Height = 42,
            Left = 0,
            Top = yStart + rowH * 2 + 230,
            BackColor = Color.FromArgb(21, 101, 192),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
            Font = new Font("Segoe UI", 10f, FontStyle.Bold),
            Cursor = Cursors.Hand
        };
        btnSave.FlatAppearance.BorderSize = 0;
        btnSave.FlatAppearance.MouseOverBackColor = Color.FromArgb(25, 118, 210);
        btnSave.Click += new EventHandler(btnSave_Click);

        pnlEditable.Controls.AddRange(new Control[]
        {
            lblSectionEdit,
            lblSoNha, txtSoNha, lblTenDuong, txtTenDuong,
            lblQuanHuyen, txtQuanHuyen, lblTinhTP, txtTinhTP,
            lblTienSuBenh, txtTienSuBenh,
            lblTienSuBenhGD, txtTienSuBenhGD,
            lblDiUngThuoc, txtDiUngThuoc,
            btnSave
        });

        this.Controls.Add(pnlEditable);
        this.Controls.Add(pnlReadOnly);
        this.Controls.Add(lblTitle);
    }

    private static Label CreateLabel(string text, int left, int top, bool bold = false)
        => new Label { Text = text, Font = new Font("Segoe UI", 9f, bold ? FontStyle.Bold : FontStyle.Regular), ForeColor = Color.FromArgb(150, 180, 220), AutoSize = false, Width = 95, Height = 25, Left = left, Top = top, TextAlign = ContentAlignment.MiddleRight };

    private static Label CreateValueLabel(string text, int left, int top)
        => new Label { Text = text, Font = new Font("Segoe UI", 9f, FontStyle.Bold), ForeColor = Color.White, AutoSize = false, Width = 200, Height = 25, Left = left, Top = top, TextAlign = ContentAlignment.MiddleLeft };

    private static Label CreateFieldLabel(string text, int left, int top)
        => new Label { Text = text, Font = new Font("Segoe UI", 9f, FontStyle.Bold), ForeColor = Color.FromArgb(120, 180, 250), AutoSize = false, Width = 115, Height = 28, Left = left, Top = top, TextAlign = ContentAlignment.MiddleLeft };

    private static TextBox CreateEditField(int left, int top)
        => new TextBox { Width = 260, Height = 30, Left = left, Top = top, BackColor = Color.FromArgb(30, 30, 55), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle, Font = new Font("Segoe UI", 10f) };

    private static TextBox CreateMultilineField(int left, int top, int width)
        => new TextBox { Width = width, Height = 60, Left = left, Top = top, BackColor = Color.FromArgb(30, 30, 55), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle, Font = new Font("Segoe UI", 10f), Multiline = true, ScrollBars = ScrollBars.Vertical };
}
