using System.Windows.Forms;
using PhanHe2.Models;
using PhanHe2.DAL;

namespace PhanHe2.Forms.Doctor
{
    public class DiagnosisEditDialog : Form
    {
        private Hsba _hsba;
        private TextBox txtChanDoan, txtDieuTri, txtKetLuan;
        private Button btnOK, btnCancel;

        public DiagnosisEditDialog(Hsba hsba)
        {
            _hsba = hsba;
            Text = "Cập nhật Chẩn đoán - " + hsba.MaHSBA;
            Size = new System.Drawing.Size(400, 300);
            StartPosition = FormStartPosition.CenterParent;

            txtChanDoan = new TextBox { Top = 20, Left = 120, Width = 200, Text = hsba.ChanDoan };
            txtDieuTri = new TextBox { Top = 60, Left = 120, Width = 200, Text = hsba.DieuTri };
            txtKetLuan = new TextBox { Top = 100, Left = 120, Width = 200, Text = hsba.KetLuan };
            
            btnOK = new Button { Text = "Lưu", Top = 150, Left = 120, DialogResult = DialogResult.OK };
            btnCancel = new Button { Text = "Hủy", Top = 150, Left = 220, DialogResult = DialogResult.Cancel };

            btnOK.Click += (s, e) => {
                _hsba.ChanDoan = txtChanDoan.Text;
                _hsba.DieuTri = txtDieuTri.Text;
                _hsba.KetLuan = txtKetLuan.Text;
                if(HsbaDAL.UpdateDiagnosis(_hsba)) {
                    MessageBox.Show("Cập nhật thành công!");
                } else {
                    MessageBox.Show("Cập nhật thất bại!");
                }
            };

            Controls.Add(new Label { Text = "Chẩn đoán:", Top = 20, Left = 20 });
            Controls.Add(txtChanDoan);
            Controls.Add(new Label { Text = "Điều trị:", Top = 60, Left = 20 });
            Controls.Add(txtDieuTri);
            Controls.Add(new Label { Text = "Kết luận:", Top = 100, Left = 20 });
            Controls.Add(txtKetLuan);
            Controls.Add(btnOK);
            Controls.Add(btnCancel);
        }
    }
}
