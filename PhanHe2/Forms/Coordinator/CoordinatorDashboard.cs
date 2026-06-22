using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Coordinator;

/// <summary>
/// Dashboard cho Cô viên Điều phối
/// </summary>
public partial class CoordinatorDashboard : UserControl
{
    public CoordinatorDashboard()
    {
        InitializeComponent();
        LoadData();
    }

    /// <summary>Chọn tab theo index</summary>
    public void SelectTab(int index)
    {
        if (index >= 0 && index < tabControl.TabCount)
            tabControl.SelectedIndex = index;
    }

    private void LoadData()
    {
        LoadPatients();
        LoadHsba();
        LoadHsbaDv();
    }

    // ==================== TAB BỆNH NHÂN ====================

    private void LoadPatients()
    {
        try
        {
            var list = PatientDAL.GetAllPatients();
            dgvPatients.DataSource = list;
            lblPatientCount.Text = $"Tổng số: {list.Count} bệnh nhân";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải dữ liệu bệnh nhân: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnAddPatient_Click(object sender, EventArgs e)
    {
        // Mở dialog thêm bệnh nhân
        using var dlg = new PatientEditDialog();
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadPatients();
    }

    private void btnEditPatient_Click(object sender, EventArgs e)
    {
        if (dgvPatients.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một bệnh nhân để sửa.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var bn = (BenhNhan)dgvPatients.SelectedRows[0].DataBoundItem;
        using var dlg = new PatientEditDialog(bn);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadPatients();
    }

    private void btnSearchPatient_Click(object sender, EventArgs e)
    {
        string keyword = txtSearchPatient.Text.Trim().ToLower();
        if (string.IsNullOrEmpty(keyword))
        {
            LoadPatients();
            return;
        }
        try
        {
            var all = PatientDAL.GetAllPatients();
            var filtered = all.Where(p =>
                p.MaBN.ToLower().Contains(keyword) ||
                p.TenBN.ToLower().Contains(keyword) ||
                p.CCCD.ToLower().Contains(keyword)).ToList();
            dgvPatients.DataSource = filtered;
            lblPatientCount.Text = $"Tìm thấy: {filtered.Count} bệnh nhân";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tìm kiếm: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    // ==================== TAB HỒ SƠ BỆNH ÁN ====================

    private void LoadHsba()
    {
        try
        {
            var list = HsbaDAL.GetAllHsba();
            dgvHsba.DataSource = list;
            lblHsbaCount.Text = $"Tổng số: {list.Count} hồ sơ";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải HSBA: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnCreateHsba_Click(object sender, EventArgs e)
    {
        using var dlg = new HsbaEditDialog();
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadHsba();
    }

    private void btnAssignDoctor_Click(object sender, EventArgs e)
    {
        if (dgvHsba.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một hồ sơ bệnh án.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var hsba = (Hsba)dgvHsba.SelectedRows[0].DataBoundItem;
        using var dlg = new AssignDoctorDialog(hsba.MaHSBA);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadHsba();
    }

    // ==================== TAB PHÂN CÔNG KTV ====================

    private void LoadHsbaDv()
    {
        try
        {
            // Hiển thị tất cả dịch vụ chưa có KTV
            var list = new List<HsbaDv>();
            var allHsba = HsbaDAL.GetAllHsba();
            foreach (var h in allHsba)
            {
                var dvs = HsbaDvDAL.GetServicesByHsba(h.MaHSBA);
                list.AddRange(dvs);
            }
            dgvHsbaDv.DataSource = list;
            lblDvCount.Text = $"Tổng số: {list.Count} dịch vụ";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải dịch vụ: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnAssignKTV_Click(object sender, EventArgs e)
    {
        if (dgvHsbaDv.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một dịch vụ để phân công.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var dv = (HsbaDv)dgvHsbaDv.SelectedRows[0].DataBoundItem;
        using var dlg = new AssignTechnicianDialog(dv);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadHsbaDv();
    }
}
