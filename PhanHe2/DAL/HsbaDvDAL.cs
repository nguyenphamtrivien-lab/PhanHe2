using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>Lớp truy cập dữ liệu Dịch vụ Hồ sơ bệnh án</summary>
public static class HsbaDvDAL
{
    /// <summary>Lấy danh sách dịch vụ theo HSBA</summary>
    public static List<HsbaDv> GetServicesByHsba(string maHSBA)
    {
        var list = new List<HsbaDv>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "SELECT MÃHSBA, LOẠIDV, NGÀYDV, MÃKTV, KẾTQUẢ " +
                "FROM HỒSƠBỆNÁN_DV WHERE MÃHSBA=:maHSBA ORDER BY NGÀYDV", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            using var reader = cmd.ExecuteReader();
            while (reader.Read()) list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] GetServicesByHsba: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>KTV xem các dịch vụ được giao (qua view VW_HSBA_DV_KTV)</summary>
    public static List<HsbaDv> GetMyServices()
    {
        var list = new List<HsbaDv>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "SELECT MÃHSBA, LOẠIDV, NGÀYDV, MÃKTV, KẾTQUẢ " +
                "FROM VW_HSBA_DV_KTV ORDER BY NGÀYDV DESC", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read()) list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] GetMyServices: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>Thêm dịch vụ mới vào HSBA</summary>
    public static bool InsertService(HsbaDv dv)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "INSERT INTO HỒSƠBỆNÁN_DV (MÃHSBA, LOẠIDV, NGÀYDV, MÃKTV, KẾTQUẢ) " +
                "VALUES (:maHSBA, :loaiDV, :ngayDV, :maKTV, :ketQua)", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", dv.MaHSBA));
            cmd.Parameters.Add(new OracleParameter("loaiDV", dv.LoaiDV));
            cmd.Parameters.Add(new OracleParameter("ngayDV", (object?)dv.NgayDV ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("maKTV", dv.MaKTV));
            cmd.Parameters.Add(new OracleParameter("ketQua", dv.KetQua));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] InsertService: {ex.Message}");
            throw;
        }
    }

    /// <summary>Xóa dịch vụ</summary>
    public static bool DeleteService(string maHSBA, string loaiDV, DateTime ngayDV)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "DELETE FROM HỒSƠBỆNÁN_DV WHERE MÃHSBA=:maHSBA AND LOẠIDV=:loaiDV AND NGÀYDV=:ngayDV", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            cmd.Parameters.Add(new OracleParameter("loaiDV", loaiDV));
            cmd.Parameters.Add(new OracleParameter("ngayDV", ngayDV));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] DeleteService: {ex.Message}");
            throw;
        }
    }

    /// <summary>KTV cập nhật kết quả dịch vụ</summary>
    public static bool UpdateResult(HsbaDv dv)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "UPDATE HỒSƠBỆNÁN_DV SET KẾTQUẢ=:ketQua " +
                "WHERE MÃHSBA=:maHSBA AND LOẠIDV=:loaiDV AND NGÀYDV=:ngayDV", conn);
            cmd.Parameters.Add(new OracleParameter("ketQua", dv.KetQua));
            cmd.Parameters.Add(new OracleParameter("maHSBA", dv.MaHSBA));
            cmd.Parameters.Add(new OracleParameter("loaiDV", dv.LoaiDV));
            cmd.Parameters.Add(new OracleParameter("ngayDV", (object?)dv.NgayDV ?? DBNull.Value));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] UpdateResult: {ex.Message}");
            throw;
        }
    }

    /// <summary>Điều phối viên phân công KTV cho dịch vụ</summary>
    public static bool AssignTechnician(string maHSBA, string loaiDV, DateTime ngayDV, string maKTV)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "UPDATE HỒSƠBỆNÁN_DV SET MÃKTV=:maKTV " +
                "WHERE MÃHSBA=:maHSBA AND LOẠIDV=:loaiDV AND NGÀYDV=:ngayDV", conn);
            cmd.Parameters.Add(new OracleParameter("maKTV", maKTV));
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            cmd.Parameters.Add(new OracleParameter("loaiDV", loaiDV));
            cmd.Parameters.Add(new OracleParameter("ngayDV", ngayDV));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDvDAL] AssignTechnician: {ex.Message}");
            throw;
        }
    }

    private static HsbaDv MapReader(OracleDataReader reader)
    {
        return new HsbaDv
        {
            MaHSBA = reader["MÃHSBA"]?.ToString() ?? "",
            LoaiDV = reader["LOẠIDV"]?.ToString() ?? "",
            NgayDV = reader["NGÀYDV"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀYDV"]),
            MaKTV = reader["MÃKTV"]?.ToString() ?? "",
            KetQua = reader["KẾTQUẢ"]?.ToString() ?? ""
        };
    }
}
