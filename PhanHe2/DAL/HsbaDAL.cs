using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>
/// Lớp truy cập dữ liệu Hồ sơ bệnh án
/// </summary>
public static class HsbaDAL
{
    /// <summary>Bác sĩ lấy danh sách HSBA của mình (VPD tự lọc)</summary>
    public static List<Hsba> GetMyHsba()
    {
        var list = new List<Hsba>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "SELECT MÃHSBA, MÃBN, NGÀY, CHẨNĐOÁN, ĐIỀUTRỊ, MÃBS, MÃKHOA, KẾTLUẬN " +
                "FROM HỒSƠBỆNÁN ORDER BY NGÀY DESC", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDAL] GetMyHsba: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>Điều phối viên lấy toàn bộ HSBA</summary>
    public static List<Hsba> GetAllHsba()
    {
        var list = new List<Hsba>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "SELECT MÃHSBA, MÃBN, NGÀY, CHẨNĐOÁN, ĐIỀUTRỊ, MÃBS, MÃKHOA, KẾTLUẬN " +
                "FROM HỒSƠBỆNÁN ORDER BY NGÀY DESC", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDAL] GetAllHsba: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>Điều phối viên tạo HSBA mới</summary>
    public static bool InsertHsba(Hsba h)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "INSERT INTO HỒSƠBỆNÁN (MÃHSBA, MÃBN, NGÀY, CHẨNĐOÁN, ĐIỀUTRỊ, MÃBS, MÃKHOA, KẾTLUẬN) " +
                "VALUES (:maHSBA, :maBN, :ngay, :chanDoan, :dieuTri, :maBS, :maKhoa, :ketLuan)", conn);
            cmd.Parameters.Add(new OracleParameter("maHSBA", h.MaHSBA));
            cmd.Parameters.Add(new OracleParameter("maBN", h.MaBN));
            cmd.Parameters.Add(new OracleParameter("ngay", (object?)h.Ngay ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("chanDoan", h.ChanDoan));
            cmd.Parameters.Add(new OracleParameter("dieuTri", h.DieuTri));
            cmd.Parameters.Add(new OracleParameter("maBS", h.MaBS));
            cmd.Parameters.Add(new OracleParameter("maKhoa", h.MaKhoa));
            cmd.Parameters.Add(new OracleParameter("ketLuan", h.KetLuan));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDAL] InsertHsba: {ex.Message}");
            throw;
        }
    }

    /// <summary>Điều phối viên phân công bác sĩ và khoa</summary>
    public static bool UpdateHsbaAssign(string maHSBA, string maBS, string maKhoa)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "UPDATE HỒSƠBỆNÁN SET MÃBS=:maBS, MÃKHOA=:maKhoa WHERE MÃHSBA=:maHSBA", conn);
            cmd.Parameters.Add(new OracleParameter("maBS", maBS));
            cmd.Parameters.Add(new OracleParameter("maKhoa", maKhoa));
            cmd.Parameters.Add(new OracleParameter("maHSBA", maHSBA));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDAL] UpdateHsbaAssign: {ex.Message}");
            throw;
        }
    }

    /// <summary>Bác sĩ cập nhật chẩn đoán, điều trị, kết luận</summary>
    public static bool UpdateDiagnosis(Hsba h)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                "UPDATE HỒSƠBỆNÁN SET CHẨNĐOÁN=:chanDoan, ĐIỀUTRỊ=:dieuTri, KẾTLUẬN=:ketLuan " +
                "WHERE MÃHSBA=:maHSBA", conn);
            cmd.Parameters.Add(new OracleParameter("chanDoan", h.ChanDoan));
            cmd.Parameters.Add(new OracleParameter("dieuTri", h.DieuTri));
            cmd.Parameters.Add(new OracleParameter("ketLuan", h.KetLuan));
            cmd.Parameters.Add(new OracleParameter("maHSBA", h.MaHSBA));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[HsbaDAL] UpdateDiagnosis: {ex.Message}");
            throw;
        }
    }

    private static Hsba MapReader(OracleDataReader reader)
    {
        return new Hsba
        {
            MaHSBA = reader["MÃHSBA"]?.ToString() ?? "",
            MaBN = reader["MÃBN"]?.ToString() ?? "",
            Ngay = reader["NGÀY"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀY"]),
            ChanDoan = reader["CHẨNĐOÁN"]?.ToString() ?? "",
            DieuTri = reader["ĐIỀUTRỊ"]?.ToString() ?? "",
            MaBS = reader["MÃBS"]?.ToString() ?? "",
            MaKhoa = reader["MÃKHOA"]?.ToString() ?? "",
            KetLuan = reader["KẾTLUẬN"]?.ToString() ?? ""
        };
    }
}
