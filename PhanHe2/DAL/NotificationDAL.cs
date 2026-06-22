using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>
/// Lớp truy cập dữ liệu Thông báo.
/// Oracle Label Security (OLS) tự động lọc theo nhãn bảo mật của user hiện tại.
/// </summary>
public static class NotificationDAL
{
    /// <summary>
    /// Lấy danh sách thông báo. OLS tự lọc theo nhãn bảo mật của user.
    /// </summary>
    public static List<ThongBao> GetNotifications()
    {
        var list = new List<ThongBao>();
        try
        {
            var conn = OracleHelper.GetConnection();
            // OLS tự lọc dòng theo nhãn - không cần WHERE clause
            using var cmd = new OracleCommand(
                "SELECT MÃTB, NỘIDUNG, NGÀYGIỜ, ĐỊAĐIỂM FROM THÔNGBÁO ORDER BY NGÀYGIỜ DESC", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                list.Add(new ThongBao
                {
                    MaTB = reader["MÃTB"] == DBNull.Value ? 0 : Convert.ToInt32(reader["MÃTB"]),
                    NoiDung = reader["NỘIDUNG"]?.ToString() ?? "",
                    NgayGio = reader["NGÀYGIỜ"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀYGIỜ"]),
                    DiaDiem = reader["ĐỊAĐIỂM"]?.ToString() ?? ""
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
