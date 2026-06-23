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
    /// <summary>Username Oracle (uppercase)</summary>
    public string OraUser { get; set; } = "";
}

/// <summary>
/// Dịch vụ xác thực và phân quyền.
/// Toàn bộ xác thực dựa trên cơ chế Oracle Database:
/// - Kết nối Oracle = xác thực tài khoản (không cần bảng user riêng)
/// - SYS_CONTEXT('USERENV','SESSION_USER') = xác định danh tính người dùng
/// </summary>
public static class AuthService
{
    /// <summary>Phiên đăng nhập hiện tại</summary>
    public static UserSession? CurrentSession { get; private set; }

    /// <summary>
    /// Sau khi đăng nhập Oracle thành công, xác định vai trò người dùng.
    /// Truy vấn bảng NHÂNVIÊN trước, nếu không có thì thử bảng BỆNHNHÂN.
    /// Dùng quoted identifiers vì tên cột tiếng Việt.
    /// </summary>
    /// <returns>UserSession hoặc null nếu không tìm thấy trong CSDL</returns>
    public static UserSession? GetCurrentUser()
    {
        try
        {
            var conn = OracleHelper.GetConnection();

            // Bước 1: Tìm trong bảng NHÂNVIÊN (dùng quoted identifiers)
            using (var cmd = new OracleCommand(
                "SELECT \"VAITRÒ\", \"MÃNV\", \"HỌTÊN\" FROM \"NHÂNVIÊN\" " +
                "WHERE \"ORAUSER\" = SYS_CONTEXT('USERENV','SESSION_USER')", conn))
            {
                using var reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    var vaiTro = reader["VAITRÒ"]?.ToString() ?? "";
                    var session = new UserSession
                    {
                        UserId      = reader["MÃNV"]?.ToString() ?? "",
                        DisplayName = reader["HỌTÊN"]?.ToString() ?? "",
                        OraUser     = OracleHelper.CurrentUser ?? "",
                        Role        = ParseNhanVienRole(vaiTro)
                    };
                    CurrentSession = session;
                    return session;
                }
            }

            // Bước 2: Không có trong NHÂNVIÊN → thử bảng BỆNHNHÂN
            using (var cmd2 = new OracleCommand(
                "SELECT \"MÃBN\", \"TÊNBN\" FROM \"BỆNHNHÂN\" " +
                "WHERE \"ORAUSER\" = SYS_CONTEXT('USERENV','SESSION_USER')", conn))
            {
                using var reader2 = cmd2.ExecuteReader();
                if (reader2.Read())
                {
                    var session = new UserSession
                    {
                        UserId      = reader2["MÃBN"]?.ToString() ?? "",
                        DisplayName = reader2["TÊNBN"]?.ToString() ?? "",
                        OraUser     = OracleHelper.CurrentUser ?? "",
                        Role        = UserRole.BenhNhan
                    };
                    CurrentSession = session;
                    return session;
                }
            }

            // Bước 3: Có thể là DBA (SYS/SYSTEM - không có trong bảng nghiệp vụ)
            var currentUser = OracleHelper.CurrentUser?.ToUpper() ?? "";
            if (currentUser == "SYS" || currentUser == "SYSTEM")
            {
                var dbaSession = new UserSession
                {
                    UserId      = currentUser,
                    DisplayName = "Quản trị hệ thống (DBA)",
                    OraUser     = currentUser,
                    Role        = UserRole.DBA
                };
                CurrentSession = dbaSession;
                return dbaSession;
            }

            // Không tìm thấy vai trò nào
            CurrentSession = null;
            return null;
        }
        catch (OracleException ex)
        {
            System.Diagnostics.Debug.WriteLine($"[AuthService] Lỗi Oracle: {ex.Number} - {ex.Message}");
            throw new Exception($"Lỗi xác thực người dùng: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Chuyển đổi chuỗi VaiTrò từ CSDL sang enum UserRole.
    /// So sánh không phân biệt hoa thường với các giá trị có dấu tiếng Việt.
    /// </summary>
    private static UserRole ParseNhanVienRole(string vaiTro)
    {
        // So sánh trực tiếp (không dùng ToUpper vì tiếng Việt có thể bị mất dấu)
        if (string.IsNullOrEmpty(vaiTro)) return UserRole.BacSi;

        if (vaiTro.Contains("Điều phối", StringComparison.OrdinalIgnoreCase))
            return UserRole.CoVienDieuPhoi;

        if (vaiTro.Contains("Bác sĩ", StringComparison.OrdinalIgnoreCase) ||
            vaiTro.Contains("Y sĩ", StringComparison.OrdinalIgnoreCase))
            return UserRole.BacSi;

        if (vaiTro.Contains("Kỹ thuật", StringComparison.OrdinalIgnoreCase))
            return UserRole.KyThuatVien;

        return UserRole.BacSi; // Mặc định an toàn
    }

    /// <summary>Xóa phiên đăng nhập hiện tại và ngắt kết nối Oracle</summary>
    public static void Logout()
    {
        CurrentSession = null;
        OracleHelper.Disconnect();
    }
}
