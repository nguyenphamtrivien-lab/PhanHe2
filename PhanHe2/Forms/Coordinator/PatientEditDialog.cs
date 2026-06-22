using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Coordinator;

/// <summary>Dialog thêm/sửa thông tin bệnh nhân (Điều phối viên)</summary>
public class PatientEditDialog : Form
{
    private readonly BenhNhan? _existing;
    private TextBox txtMaBN, txtTenBN, txtPhai, txtCCCD, txtSoNha, txtTenDuong, txtQuanHuyen, txtTinhTP;
    private DateTimePicker dtpNgaySinh;
    private Button btnOK, btnCancel;
    private Label lblTitle;

    public PatientEditDialog(BenhNhan? existing = null)
    {
        _existing = existing;
        SetupUI();
        if (existing != null) PopulateFields(existing);
    }

    private void SetupUI()
    {
        this.Text = _existing == null ? "Thêm bệnh nhân mới" : "Sửa thông tin bệnh nhân";
        this.Size = new Size(500, 480);
        this.StartPosition = FormStartPosition.CenterParent;
        this.BackColor = Color.FromArgb(20, 20, 40);
        this.Font = new Font("Segoe UI", 9f);
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.MaximizeBox = false;

        int y = 15, x = 150, lblX = 15, w = 300, h = 28;
        lblTitle = new Label { Text = _existing == null ? "➕ THÊM BỆNH NHÂN" : "✏️ SỬA BỆNH NHÂN", Font = new Font("Segoe UI", 13f, FontStyle.Bold), ForeColor = Color.FromArgb(100, 181, 246), Width = 460, Height = 35, Left = 15, Top = y, TextAlign = ContentAlignment.MiddleLeft };
        y += 45;

        this.Controls.Add(lblTitle);

        void AddField(string label, ref int yy, out TextBox txt, bool readOnly = false)
        {
            this.Controls.Add(new Label { Text = label, ForeColor = Color.FromArgb(180, 200, 240), Width = 130, Height = h, Left = lblX, Top = yy, TextAlign = ContentAlignment.MiddleRight, Font = new Font("Segoe UI", 9f, FontStyle.Bold) });
            txt = new TextBox { Width = w, Height = h, Left = x, Top = yy, BackColor = Color.FromArgb(35, 35, 60), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle, Font = new Font("Segoe UI", 10f), ReadOnly = readOnly };
            this.Controls.Add(txt);
            yy += 38;
        }

        AddField("Mã BN:", ref y, out txtMaBN, readOnly: _existing != null);
        AddField("Họ tên:", ref y, out txtTenBN);
        AddField("Phái:", ref y, out txtPhai);

        this.Controls.Add(new Label { Text = "Ngày sinh:", ForeColor = Color.FromArgb(180, 200, 240), Width = 130, Height = h, Left = lblX, Top = y, TextAlign = ContentAlignment.MiddleRight, Font = new Font("Segoe UI", 9f, FontStyle.Bold) });
        dtpNgaySinh = new DateTimePicker { Width = w, Height = h, Left = x, Top = y, Format = DateTimePickerFormat.Short };
        dtpNgaySinh.CalendarForeColor = Color.White;
        this.Controls.Add(dtpNgaySinh);
        y += 38;

        AddField("CCCD:", ref y, out txtCCCD);
        AddField("Số nhà:", ref y, out txtSoNha);
        AddField("Tên đường:", ref y, out txtTenDuong);
        AddField("Quận/Huyện:", ref y, out txtQuanHuyen);
        AddField("Tỉnh/TP:", ref y, out txtTinhTP);

        btnOK = new Button { Text = "✔  Lưu", Width = 100, Height = 36, Left = 270, Top = y + 5, BackColor = Color.FromArgb(21, 101, 192), ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 10f, FontStyle.Bold), Cursor = Cursors.Hand, DialogResult = DialogResult.None };
        btnOK.FlatAppearance.BorderSize = 0;
        btnOK.Click += BtnOK_Click;
        btnCancel = new Button { Text = "✖  Hủy", Width = 100, Height = 36, Left = 380, Top = y + 5, BackColor = Color.FromArgb(80, 30, 30), ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 10f, FontStyle.Bold), Cursor = Cursors.Hand, DialogResult = DialogResult.Cancel };
        btnCancel.FlatAppearance.BorderSize = 0;
        this.Controls.AddRange(new Control[] { btnOK, btnCancel });
    }

    private void PopulateFields(BenhNhan bn)
    {
        txtMaBN.Text = bn.MaBN;
        txtTenBN.Text = bn.TenBN;
        txtPhai.Text = bn.Phai;
        if (bn.NgaySinh.HasValue) dtpNgaySinh.Value = bn.NgaySinh.Value;
        txtCCCD.Text = bn.CCCD;
        txtSoNha.Text = bn.SoNha;
        txtTenDuong.Text = bn.TenDuong;
        txtQuanHuyen.Text = bn.QuanHuyen;
        txtTinhTP.Text = bn.TinhTP;
    }

    private void BtnOK_Click(object? sender, EventArgs e)
    {
        try
        {
            var bn = new BenhNhan
            {
                MaBN = txtMaBN.Text.Trim(),
                TenBN = txtTenBN.Text.Trim(),
                Phai = txtPhai.Text.Trim(),
                NgaySinh = dtpNgaySinh.Value.Date,
                CCCD = txtCCCD.Text.Trim(),
                SoNha = txtSoNha.Text.Trim(),
                TenDuong = txtTenDuong.Text.Trim(),
                QuanHuyen = txtQuanHuyen.Text.Trim(),
                TinhTP = txtTinhTP.Text.Trim()
            };

            if (_existing == null)
                PatientDAL.InsertPatient(bn);
            else
                PatientDAL.UpdatePatient(bn);

            this.DialogResult = DialogResult.OK;
            this.Close();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
