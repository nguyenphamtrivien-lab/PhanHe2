using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>Lớp truy cập dữ liệu Thông báo (OLS tự lọc nhãn bảo mật)</summary>
public static class NotificationDAL
{
    private const string TABLE = "\"THÔNGBÁO\"";

    /// <summary>
    /// Lấy danh sách thông báo mà người dùng hiện tại được phép xem.
    /// Oracle Label Security (OLS) tự động lọc theo nhãn bảo mật của user.
    /// </summary>
    public static List<ThongBao> GetNotifications()
    {
        var list = new List<ThongBao>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"SELECT \"MÃTB\", \"NỘIDUNG\", \"NGÀYGIỜ\", \"ĐỊAĐIỂM\" " +
                $"FROM {TABLE} ORDER BY \"NGÀYGIỜ\" DESC", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                list.Add(new ThongBao
                {
                    MaTB     = reader["MÃTB"] == DBNull.Value ? 0 : Convert.ToInt32(reader["MÃTB"]),
                    NoiDung  = reader["NỘIDUNG"]?.ToString() ?? "",
                    NgayGio  = reader["NGÀYGIỜ"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀYGIỜ"]),
                    DiaDiem  = reader["ĐỊAĐIỂM"]?.ToString() ?? ""
                });
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[NotificationDAL] GetNotifications: {ex.Message}");
            throw;
        }
        return list;
    }
}
