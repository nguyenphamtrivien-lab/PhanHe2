using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Patient;

/// <summary>Dashboard cho Bệnh nhân - xem và cập nhật thông tin cá nhân</summary>
public partial class PatientDashboard : UserControl
{
    private BenhNhan? _currentPatient;

    public PatientDashboard()
    {
        InitializeComponent();
        LoadMyInfo();
    }

    private void LoadMyInfo()
    {
        try
        {
            _currentPatient = PatientDAL.GetMyInfo();
            if (_currentPatient == null)
            {
                MessageBox.Show("Không tìm thấy thông tin bệnh nhân.", "Thông báo",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            DisplayInfo(_currentPatient);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải thông tin: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void DisplayInfo(BenhNhan bn)
    {
        // Thông tin chỉ đọc
        lblMaBNValue.Text = bn.MaBN;
        lblTenBNValue.Text = bn.TenBN;
        lblNgaySinhValue.Text = bn.NgaySinh?.ToString("dd/MM/yyyy") ?? "";
        lblCCCDValue.Text = bn.CCCD;
        lblPhaiValue.Text = bn.Phai;

        // Thông tin có thể chỉnh sửa
        txtSoNha.Text = bn.SoNha;
        txtTenDuong.Text = bn.TenDuong;
        txtQuanHuyen.Text = bn.QuanHuyen;
        txtTinhTP.Text = bn.TinhTP;
        txtTienSuBenh.Text = bn.TienSuBenh;
        txtTienSuBenhGD.Text = bn.TienSuBenhGD;
        txtDiUngThuoc.Text = bn.DiUngThuoc;
    }

    private void btnSave_Click(object sender, EventArgs e)
    {
        if (_currentPatient == null) return;

        try
        {
            // Cập nhật các trường được phép
            _currentPatient.SoNha = txtSoNha.Text.Trim();
            _currentPatient.TenDuong = txtTenDuong.Text.Trim();
            _currentPatient.QuanHuyen = txtQuanHuyen.Text.Trim();
            _currentPatient.TinhTP = txtTinhTP.Text.Trim();
            _currentPatient.TienSuBenh = txtTienSuBenh.Text.Trim();
            _currentPatient.TienSuBenhGD = txtTienSuBenhGD.Text.Trim();
            _currentPatient.DiUngThuoc = txtDiUngThuoc.Text.Trim();

            PatientDAL.UpdateMyProfile(_currentPatient);
            MessageBox.Show("Cập nhật thông tin thành công!", "Thành công",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi khi lưu: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
