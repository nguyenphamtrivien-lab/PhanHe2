using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Coordinator;

/// <summary>Dialog tạo HSBA mới (Điều phối viên)</summary>
public class HsbaEditDialog : Form
{
    private TextBox txtMaHSBA, txtMaBN, txtMaBS, txtMaKhoa;
    private DateTimePicker dtpNgay;
    private Button btnOK, btnCancel;

    public HsbaEditDialog()
    {
        SetupUI();
    }

    private void SetupUI()
    {
        this.Text = "Tạo Hồ sơ bệnh án mới";
        this.Size = new Size(450, 340);
        this.StartPosition = FormStartPosition.CenterParent;
        this.BackColor = Color.FromArgb(20, 20, 40);
        this.Font = new Font("Segoe UI", 9f);
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.MaximizeBox = false;

        var lblTitle = new Label { Text = "➕ TẠO HỒ SƠ BỆNH ÁN", Font = new Font("Segoe UI", 13f, FontStyle.Bold), ForeColor = Color.FromArgb(100, 181, 246), Width = 410, Height = 35, Left = 15, Top = 10, TextAlign = ContentAlignment.MiddleLeft };
        this.Controls.Add(lblTitle);

        int y = 55, x = 150, lblX = 15, w = 260, h = 28;
        void AddField(string label, ref int yy, out TextBox txt)
        {
            this.Controls.Add(new Label { Text = label, ForeColor = Color.FromArgb(180, 200, 240), Width = 130, Height = h, Left = lblX, Top = yy, TextAlign = ContentAlignment.MiddleRight, Font = new Font("Segoe UI", 9f, FontStyle.Bold) });
            txt = new TextBox { Width = w, Height = h, Left = x, Top = yy, BackColor = Color.FromArgb(35, 35, 60), ForeColor = Color.White, BorderStyle = BorderStyle.FixedSingle, Font = new Font("Segoe UI", 10f) };
            this.Controls.Add(txt);
            yy += 38;
        }

        AddField("Mã HSBA:", ref y, out txtMaHSBA);
        AddField("Mã BN:", ref y, out txtMaBN);
        this.Controls.Add(new Label { Text = "Ngày:", ForeColor = Color.FromArgb(180, 200, 240), Width = 130, Height = h, Left = lblX, Top = y, TextAlign = ContentAlignment.MiddleRight, Font = new Font("Segoe UI", 9f, FontStyle.Bold) });
        dtpNgay = new DateTimePicker { Width = w, Height = h, Left = x, Top = y, Format = DateTimePickerFormat.Short };
        this.Controls.Add(dtpNgay);
        y += 38;
        AddField("Mã BS:", ref y, out txtMaBS);
        AddField("Mã Khoa:", ref y, out txtMaKhoa);

        btnOK = new Button { Text = "✔  Tạo", Width = 100, Height = 36, Left = 220, Top = y + 8, BackColor = Color.FromArgb(21, 101, 192), ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 10f, FontStyle.Bold), Cursor = Cursors.Hand };
        btnOK.FlatAppearance.BorderSize = 0;
        btnOK.Click += BtnOK_Click;
        btnCancel = new Button { Text = "✖  Hủy", Width = 100, Height = 36, Left = 330, Top = y + 8, BackColor = Color.FromArgb(80, 30, 30), ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Font = new Font("Segoe UI", 10f, FontStyle.Bold), Cursor = Cursors.Hand, DialogResult = DialogResult.Cancel };
        btnCancel.FlatAppearance.BorderSize = 0;
        this.Controls.AddRange(new Control[] { btnOK, btnCancel });
    }

    private void BtnOK_Click(object? sender, EventArgs e)
    {
        try
        {
            var hsba = new Hsba
            {
                MaHSBA = txtMaHSBA.Text.Trim(),
                MaBN = txtMaBN.Text.Trim(),
                Ngay = dtpNgay.Value.Date,
                MaBS = txtMaBS.Text.Trim(),
                MaKhoa = txtMaKhoa.Text.Trim()
            };
            HsbaDAL.InsertHsba(hsba);
            this.DialogResult = DialogResult.OK;
            this.Close();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi: {ex.Message}", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
