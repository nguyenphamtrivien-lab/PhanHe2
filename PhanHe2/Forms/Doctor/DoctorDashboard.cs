using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Doctor;

/// <summary>Dashboard cho Bác sĩ</summary>
public partial class DoctorDashboard : UserControl
{
    public DoctorDashboard()
    {
        InitializeComponent();
        LoadData();
    }

    public void SelectTab(int index)
    {
        if (index >= 0 && index < tabControl.TabCount)
            tabControl.SelectedIndex = index;
    }

    private void LoadData()
    {
        LoadMyHsba();
        LoadMyServices();
    }

    private void LoadMyHsba()
    {
        try
        {
            var list = HsbaDAL.GetMyHsba();
            dgvHsba.DataSource = list;
            lblHsbaCount.Text = $"Hồ sơ của tôi: {list.Count}";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải HSBA: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void LoadMyServices()
    {
        try
        {
            if (dgvHsba.SelectedRows.Count > 0)
            {
                var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
                var services = HsbaDvDAL.GetServicesByHsba(hsba.MaHSBA);
                dgvServices.DataSource = services;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải dịch vụ: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void LoadPrescriptions()
    {
        try
        {
            if (dgvHsba.SelectedRows.Count > 0)
            {
                var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
                var presc = PrescriptionDAL.GetByHsba(hsba.MaHSBA);
                dgvPrescriptions.DataSource = presc;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải đơn thuốc: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnViewDetail_Click(object sender, EventArgs e)
    {
        if (dgvHsba.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một hồ sơ.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
        LoadMyServices();
        LoadPrescriptions();
        tabControl.SelectedIndex = 1;
    }

    private void btnUpdateDiagnosis_Click(object sender, EventArgs e)
    {
        if (dgvHsba.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một hồ sơ để cập nhật.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
        using var dlg = new DiagnosisEditDialog(hsba);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadMyHsba();
    }

    private void btnAddPrescription_Click(object sender, EventArgs e)
    {
        if (dgvHsba.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một hồ sơ bệnh án trước.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
        using var dlg = new PrescriptionEditDialog(hsba.MaHSBA);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadPrescriptions();
    }

    private void dgvHsba_SelectionChanged(object sender, EventArgs e)
    {
        LoadMyServices();
        LoadPrescriptions();
    }
}
