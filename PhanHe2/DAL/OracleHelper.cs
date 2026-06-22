using Oracle.ManagedDataAccess.Client;
using System.Data;

namespace PhanHe2.DAL;

/// <summary>
/// Lớp tiện ích quản lý kết nối Oracle - Singleton pattern per session
/// </summary>
public static class OracleHelper
{
    private static OracleConnection? _connection;
    private static string? _currentUser;

    /// <summary>Xây dựng chuỗi kết nối Oracle</summary>
    public static string BuildConnectionString(string username, string password,
        string host = "localhost", int port = 1521, string service = "XE")
    {
        return $"User Id={username};Password={password};Data Source={host}:{port}/{service};";
    }

    /// <summary>
    /// Kết nối đến Oracle với thông tin đăng nhập.
    /// Trả về true nếu kết nối thành công, false nếu thất bại.
    /// </summary>
    public static bool Connect(string username, string password,
        string host = "localhost", int port = 1521, string service = "XE")
    {
        try
        {
            // Đóng kết nối cũ nếu còn
            Disconnect();

            var cs = BuildConnectionString(username, password, host, port, service);
            _connection = new OracleConnection(cs);
            _connection.Open();
            _currentUser = username.ToUpper();
            return true;
        }
        catch (OracleException ex)
        {
            // Ghi log lỗi Oracle cụ thể
            System.Diagnostics.Debug.WriteLine($"[OracleHelper] Lỗi kết nối Oracle: {ex.Number} - {ex.Message}");
            _connection = null;
            _currentUser = null;
            return false;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[OracleHelper] Lỗi không xác định: {ex.Message}");
            _connection = null;
            _currentUser = null;
            return false;
        }
    }

    /// <summary>
    /// Lấy kết nối hiện tại. Ném ngoại lệ nếu chưa kết nối.
    /// </summary>
    public static OracleConnection GetConnection()
    {
        if (_connection == null || _connection.State != ConnectionState.Open)
            throw new InvalidOperationException("Chưa kết nối đến Oracle. Hãy đăng nhập trước.");
        return _connection;
    }

    /// <summary>Tên user Oracle hiện tại (uppercase)</summary>
    public static string? CurrentUser => _currentUser;

    /// <summary>Kiểm tra đã kết nối chưa</summary>
    public static bool IsConnected =>
        _connection != null && _connection.State == ConnectionState.Open;

    /// <summary>Ngắt kết nối và giải phóng tài nguyên</summary>
    public static void Disconnect()
    {
        try
        {
            _connection?.Close();
            _connection?.Dispose();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[OracleHelper] Lỗi khi ngắt kết nối: {ex.Message}");
        }
        finally
        {
            _connection = null;
            _currentUser = null;
        }
    }
}
