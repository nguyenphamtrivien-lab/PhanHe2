using PhanHe2.DAL;

namespace PhanHe2.Forms.Notification;

/// <summary>Form hiển thị thông báo (Oracle Label Security tự lọc)</summary>
public partial class NotificationForm : UserControl
{
    public NotificationForm()
    {
        InitializeComponent();
        LoadNotifications();
    }

    private void LoadNotifications()
    {
        try
        {
            var list = NotificationDAL.GetNotifications();
            dgvNotifications.DataSource = list;
            lblCount.Text = $"Thông báo hiển thị: {list.Count}";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Lỗi tải thông báo: {ex.Message}", "Lỗi",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadNotifications();
    }
}
