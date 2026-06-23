using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>Lớp truy cập dữ liệu Đơn thuốc</summary>
public static class PrescriptionDAL
{
    private const string TABLE = "\"ĐƠNTHUỐC\"";

    /// <summary>Lấy đơn thuốc theo HSBA</summary>
    public static List<DonThuoc> GetByHsba(string maHSBA)
    {
        var list = new List<DonThuoc>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"SELECT \"MÃHSBA\", \"NGÀYĐT\", \"TÊNTHUỐC\", \"LIỀUDÙNG\" FROM {TABLE} " +
                "WHERE \"MÃHSBA\"=:maHSBA ORDER BY \"NGÀYĐT\"", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            using var reader = cmd.ExecuteReader();
            while (reader.Read()) list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PrescriptionDAL] GetByHsba: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>Thêm đơn thuốc mới</summary>
    public static bool Insert(DonThuoc dt)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"INSERT INTO {TABLE} (\"MÃHSBA\", \"NGÀYĐT\", \"TÊNTHUỐC\", \"LIỀUDÙNG\") " +
                "VALUES (:maHSBA, :ngayDT, :tenThuoc, :lieuDung)", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", dt.MaHSBA));
            cmd.Parameters.Add(new OracleParameter("ngayDT", (object?)dt.NgayDT ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tenThuoc", dt.TenThuoc));
            cmd.Parameters.Add(new OracleParameter("lieuDung", (object?)dt.LieuDung ?? DBNull.Value));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PrescriptionDAL] Insert: {ex.Message}");
            throw;
        }
    }

    /// <summary>Cập nhật liều dùng đơn thuốc</summary>
    public static bool Update(DonThuoc dt)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"UPDATE {TABLE} SET \"LIỀUDÙNG\"=:lieuDung " +
                "WHERE \"MÃHSBA\"=:maHSBA AND \"NGÀYĐT\"=:ngayDT AND \"TÊNTHUỐC\"=:tenThuoc", conn);
            cmd.Parameters.Add(new OracleParameter("lieuDung", (object?)dt.LieuDung ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("maHSBA", dt.MaHSBA));
            cmd.Parameters.Add(new OracleParameter("ngayDT", (object?)dt.NgayDT ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tenThuoc", dt.TenThuoc));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PrescriptionDAL] Update: {ex.Message}");
            throw;
        }
    }

    /// <summary>Xóa đơn thuốc</summary>
    public static bool Delete(string maHSBA, DateTime ngayDT, string tenThuoc)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"DELETE FROM {TABLE} WHERE \"MÃHSBA\"=:maHSBA AND \"NGÀYĐT\"=:ngayDT AND \"TÊNTHUỐC\"=:tenThuoc", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            cmd.Parameters.Add(new OracleParameter("ngayDT", ngayDT));
            cmd.Parameters.Add(new OracleParameter("tenThuoc", tenThuoc));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PrescriptionDAL] Delete: {ex.Message}");
            throw;
        }
    }

    private static DonThuoc MapReader(OracleDataReader reader)
    {
        return new DonThuoc
        {
            MaHSBA   = reader["MÃHSBA"]?.ToString() ?? "",
            NgayDT   = reader["NGÀYĐT"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀYĐT"]),
            TenThuoc = reader["TÊNTHUỐC"]?.ToString() ?? "",
            LieuDung = reader["LIỀUDÙNG"]?.ToString() ?? ""
        };
    }
}
