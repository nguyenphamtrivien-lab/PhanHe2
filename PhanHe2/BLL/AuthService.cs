using Oracle.ManagedDataAccess.Client;
using PhanHe2.DAL;

namespace PhanHe2.BLL;

/// <summary>Vai trò người dùng trong hệ thống</summary>
public enum UserRole
{
    /// <summary>Cô viên điều phối (quản lý toàn bộ)</summary>
    CoVienDieuPhoi,
    /// <summary>Bác sĩ điều trị</summary>
    BacSi,
    /// <summary>Kỹ thuật viên xét nghiệm/chẩn đoán</summary>
    KyThuatVien,
    /// <summary>Bệnh nhân</summary>
    BenhNhan,
    /// <summary>DBA / Quản trị hệ thống</summary>
    DBA
}

/// <summary>Thông tin phiên đăng nhập của người dùng</summary>
public class UserSession
{
    /// <summary>Mã định danh (MaNV hoặc MaBN)</summary>
    public string UserId { get; set; } = "";
    /// <summary>Tên hiển thị</summary>
    public string DisplayName { get; set; } = "";
    /// <summary>Vai trò trong hệ thống</summary>
    public UserRole Role { get; set; }
    /// <summary>Username Oracle</summary>
    public string OraUser { get; set; } = "";
}

/// <summary>
/// Dịch vụ xác thực và phân quyền
/// </summary>
public static class AuthService
{
    /// <summary>Phiên đăng nhập hiện tại</summary>
    public static UserSession? CurrentSession { get; private set; }

    /// <summary>
    /// Sau khi đăng nhập Oracle thành công, xác định vai trò người dùng.
    /// Truy vấn bảng NHÂNVIÊN trước, nếu không có thì thử bảng BỆNHNHÂN.
    /// </summary>
    /// <returns>UserSession hoặc null nếu không tìm thấy trong CSDL</returns>
    public static UserSession? GetCurrentUser()
    {
        try
        {
            var conn = OracleHelper.GetConnection();

            // Bước 1: Tìm trong bảng NHÂNVIÊN
            using (var cmd = new OracleCommand(
                "SELECT VAITRÒ, MÃNV, HỌTÊN FROM NHÂNVIÊN " +
                "WHERE ORAUSER = SYS_CONTEXT('USERENV','SESSION_USER')", conn))
            {
                using var reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    var vaiTro = reader["VAITRÒ"].ToString() ?? "";
                    var session = new UserSession
                    {
                        UserId = reader["MÃNV"].ToString() ?? "",
                        DisplayName = reader["HỌTÊN"].ToString() ?? "",
                        OraUser = OracleHelper.CurrentUser ?? "",
                        Role = ParseNhanVienRole(vaiTro)
                    };
                    CurrentSession = session;
                    return session;
                }
            }

            // Bước 2: Không có trong NHÂNVIÊN → thử bảng BỆNHNHÂN
            using (var cmd2 = new OracleCommand(
                "SELECT MÃBN, TÊNBN FROM BỆNHNHÂN " +
                "WHERE ORAUSER = SYS_CONTEXT('USERENV','SESSION_USER')", conn))
            {
                using var reader2 = cmd2.ExecuteReader();
                if (reader2.Read())
                {
                    var session = new UserSession
                    {
                        UserId = reader2["MÃBN"].ToString() ?? "",
                        DisplayName = reader2["TÊNBN"].ToString() ?? "",
                        OraUser = OracleHelper.CurrentUser ?? "",
                        Role = UserRole.BenhNhan
                    };
                    CurrentSession = session;
                    return session;
                }
            }

            // Bước 3: Có thể là DBA (không có trong bảng nghiệp vụ)
            if (OracleHelper.CurrentUser?.ToUpper() == "SYS" ||
                OracleHelper.CurrentUser?.ToUpper() == "SYSTEM" ||
                OracleHelper.CurrentUser?.StartsWith("DBA") == true)
            {
                var dbaSession = new UserSession
                {
                    UserId = OracleHelper.CurrentUser ?? "DBA",
                    DisplayName = "Quản trị hệ thống",
                    OraUser = OracleHelper.CurrentUser ?? "",
                    Role = UserRole.DBA
                };
                CurrentSession = dbaSession;
                return dbaSession;
            }

            // Không tìm thấy vai trò
            CurrentSession = null;
            return null;
        }
        catch (OracleException ex)
        {
            System.Diagnostics.Debug.WriteLine($"[AuthService] Lỗi Oracle: {ex.Number} - {ex.Message}");
            throw new Exception($"Lỗi xác thực người dùng: {ex.Message}", ex);
        }
    }

    /// <summary>Chuyển đổi chuỗi VaiTrò sang enum UserRole</summary>
    private static UserRole ParseNhanVienRole(string vaiTro)
    {
        return vaiTro.ToUpper() switch
        {
            "CÔ VIÊN ĐIỀU PHỐI" or "COVIENDIEUPHOI" or "ĐIỀU PHỐI" => UserRole.CoVienDieuPhoi,
            "BÁC SĨ" or "BACSI" or "BS" => UserRole.BacSi,
            "KỸ THUẬT VIÊN" or "KYTHUATVIEN" or "KTV" => UserRole.KyThuatVien,
            "DBA" or "ADMIN" => UserRole.DBA,
            _ => UserRole.BacSi // Mặc định
        };
    }

    /// <summary>Xóa phiên đăng nhập hiện tại</summary>
    public static void Logout()
    {
        CurrentSession = null;
        OracleHelper.Disconnect();
    }
}
