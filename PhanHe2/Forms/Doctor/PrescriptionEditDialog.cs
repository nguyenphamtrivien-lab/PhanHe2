using System.Windows.Forms;
using PhanHe2.Models;
using PhanHe2.DAL;
using System;

namespace PhanHe2.Forms.Doctor
{
    public class PrescriptionEditDialog : Form
    {
        private string _maHSBA;
        private TextBox txtTenThuoc, txtLieuDung;
        private Button btnOK, btnCancel;

        public PrescriptionEditDialog(string maHSBA)
        {
            _maHSBA = maHSBA;
            Text = "Thêm đơn thuốc - " + maHSBA;
            Size = new System.Drawing.Size(400, 200);
            StartPosition = FormStartPosition.CenterParent;

            txtTenThuoc = new TextBox { Top = 20, Left = 120, Width = 200 };
            txtLieuDung = new TextBox { Top = 60, Left = 120, Width = 200 };
            
            btnOK = new Button { Text = "Lưu", Top = 100, Left = 120, DialogResult = DialogResult.OK };
            btnCancel = new Button { Text = "Hủy", Top = 100, Left = 220, DialogResult = DialogResult.Cancel };

            btnOK.Click += (s, e) => {
                var dt = new DonThuoc {
                    MaHSBA = _maHSBA,
                    NgayDT = DateTime.Now,
                    TenThuoc = txtTenThuoc.Text,
                    LieuDung = txtLieuDung.Text
                };
                if(PrescriptionDAL.Insert(dt)) {
                    MessageBox.Show("Thêm thành công!");
                } else {
                    MessageBox.Show("Thêm thất bại!");
                }
            };

            Controls.Add(new Label { Text = "Tên thuốc:", Top = 20, Left = 20 });
            Controls.Add(txtTenThuoc);
            Controls.Add(new Label { Text = "Liều dùng:", Top = 60, Left = 20 });
            Controls.Add(txtLieuDung);
            Controls.Add(btnOK);
            Controls.Add(btnCancel);
        }
    }
}
