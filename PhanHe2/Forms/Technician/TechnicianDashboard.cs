using PhanHe2.DAL;
using PhanHe2.Models;

namespace PhanHe2.Forms.Technician;

/// <summary>Dashboard cho Kỹ thuật viên</summary>
public partial class TechnicianDashboard : UserControl
{
    public TechnicianDashboard()
    {
        InitializeComponent();
        LoadMyServices();
    }

    private void LoadMyServices()
    {
        try
        {
            var list = HsbaDvDAL.GetMyServices();
            dgvServices.DataSource = list;
            lblCount.Text = $"Dịch vụ được giao: {list.Count}";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải dữ liệu: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnUpdateResult_Click(object sender, EventArgs e)
    {
        if (dgvServices.SelectedRows.Count == 0)
        {
            MessageBox.Show("Vui lòng chọn một dịch vụ để cập nhật kết quả.", "Thông báo",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        var dv = (HsbaDv)dgvServices.SelectedRows[0].DataBoundItem;
        using var dlg = new UpdateResultDialog(dv);
        if (dlg.ShowDialog() == DialogResult.OK)
            LoadMyServices();
    }

    private void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadMyServices();
    }
}
