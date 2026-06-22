using System;
using System.Windows.Forms;
using PhanHe2.DAL;

namespace PhanHe2.Forms.Coordinator
{
    public class AssignTechnicianDialog : Form
    {
        private string _maHSBA;
        private TextBox txtLoaiDV, txtMaKTV;
        private DateTimePicker dtpNgayDV;
        private Button btnOK, btnCancel;

        public AssignTechnicianDialog(string maHSBA)
        {
            _maHSBA = maHSBA;
            Text = "Phân công KTV - " + maHSBA;
            Size = new System.Drawing.Size(400, 250);
            StartPosition = FormStartPosition.CenterParent;

            txtLoaiDV = new TextBox { Top = 20, Left = 120, Width = 200 };
            dtpNgayDV = new DateTimePicker { Top = 60, Left = 120, Width = 200 };
            txtMaKTV = new TextBox { Top = 100, Left = 120, Width = 200 };
            
            btnOK = new Button { Text = "Lưu", Top = 150, Left = 120, DialogResult = DialogResult.OK };
            btnCancel = new Button { Text = "Hủy", Top = 150, Left = 220, DialogResult = DialogResult.Cancel };

            btnOK.Click += (s, e) => {
                if(HsbaDvDAL.AssignTechnician(_maHSBA, txtLoaiDV.Text, dtpNgayDV.Value, txtMaKTV.Text)) {
                    MessageBox.Show("Phân công thành công!");
                } else {
                    MessageBox.Show("Phân công thất bại!");
                }
            };

            Controls.Add(new Label { Text = "Loại DV:", Top = 20, Left = 20 });
            Controls.Add(txtLoaiDV);
            Controls.Add(new Label { Text = "Ngày DV:", Top = 60, Left = 20 });
            Controls.Add(dtpNgayDV);
            Controls.Add(new Label { Text = "Mã KTV:", Top = 100, Left = 20 });
            Controls.Add(txtMaKTV);
            Controls.Add(btnOK);
            Controls.Add(btnCancel);
        }
    }
}
