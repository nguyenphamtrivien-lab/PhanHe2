using System.Windows.Forms;
using PhanHe2.Models;
using PhanHe2.DAL;

namespace PhanHe2.Forms.Technician
{
    public class UpdateResultDialog : Form
    {
        private HsbaDv _dv;
        private TextBox txtKetQua;
        private Button btnOK, btnCancel;

        public UpdateResultDialog(HsbaDv dv)
        {
            _dv = dv;
            Text = "Cập nhật Kết quả - " + dv.LoaiDV;
            Size = new System.Drawing.Size(400, 200);
            StartPosition = FormStartPosition.CenterParent;

            txtKetQua = new TextBox { Top = 20, Left = 120, Width = 200, Text = dv.KetQua };
            
            btnOK = new Button { Text = "Lưu", Top = 100, Left = 120, DialogResult = DialogResult.OK };
            btnCancel = new Button { Text = "Hủy", Top = 100, Left = 220, DialogResult = DialogResult.Cancel };

            btnOK.Click += (s, e) => {
                _dv.KetQua = txtKetQua.Text;
                if(HsbaDvDAL.UpdateResult(_dv)) {
                    MessageBox.Show("Cập nhật thành công!");
                } else {
                    MessageBox.Show("Cập nhật thất bại!");
                }
            };

            Controls.Add(new Label { Text = "Kết quả:", Top = 20, Left = 20 });
            Controls.Add(txtKetQua);
            Controls.Add(btnOK);
            Controls.Add(btnCancel);
        }
    }
}
