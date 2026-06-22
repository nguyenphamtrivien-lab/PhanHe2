using System.Windows.Forms;
using PhanHe2.DAL;

namespace PhanHe2.Forms.Coordinator
{
    public class AssignDoctorDialog : Form
    {
        private string _maHSBA;
        private TextBox txtMaBS, txtMaKhoa;
        private Button btnOK, btnCancel;

        public AssignDoctorDialog(string maHSBA)
        {
            _maHSBA = maHSBA;
            Text = "Phân công Bác sĩ - " + maHSBA;
            Size = new System.Drawing.Size(400, 200);
            StartPosition = FormStartPosition.CenterParent;

            txtMaBS = new TextBox { Top = 20, Left = 120, Width = 200 };
            txtMaKhoa = new TextBox { Top = 60, Left = 120, Width = 200 };
            
            btnOK = new Button { Text = "Lưu", Top = 100, Left = 120, DialogResult = DialogResult.OK };
            btnCancel = new Button { Text = "Hủy", Top = 100, Left = 220, DialogResult = DialogResult.Cancel };

            btnOK.Click += (s, e) => {
                if(HsbaDAL.UpdateHsbaAssign(_maHSBA, txtMaBS.Text, txtMaKhoa.Text)) {
                    MessageBox.Show("Phân công thành công!");
                } else {
                    MessageBox.Show("Phân công thất bại!");
                }
            };

            Controls.Add(new Label { Text = "Mã Bác Sĩ:", Top = 20, Left = 20 });
            Controls.Add(txtMaBS);
            Controls.Add(new Label { Text = "Mã Khoa:", Top = 60, Left = 20 });
            Controls.Add(txtMaKhoa);
            Controls.Add(btnOK);
            Controls.Add(btnCancel);
        }
    }
}
