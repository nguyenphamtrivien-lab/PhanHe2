using Oracle.ManagedDataAccess.Client;
using PhanHe2.Models;

namespace PhanHe2.DAL;

/// <summary>
/// Lớp truy cập dữ liệu cho bảng BỆNHNHÂN
/// </summary>
public static class PatientDAL
{
    private const string TABLE = "\"BỆNHNHÂN\"";

    /// <summary>
    /// Lấy toàn bộ danh sách bệnh nhân (dành cho Điều phối viên).
    /// VPD Oracle tự lọc nếu user không phải DPV.
    /// </summary>
    public static List<BenhNhan> GetAllPatients()
    {
        var list = new List<BenhNhan>();
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"SELECT \"MÃBN\", \"TÊNBN\", \"PHÁI\", \"NGÀYSINH\", \"CCCD\", \"SỐNHÀ\", \"TÊNĐƯỜNG\", " +
                $"\"QUẬNHUYỆN\", \"TỈNHTP\", \"TIỀNSỬBỆNH\", \"TIỀNSỬBỆNHGĐ\", \"DỊỨNGTHUỐC\", \"ORAUSER\" " +
                $"FROM {TABLE} ORDER BY \"MÃBN\"", conn);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
                list.Add(MapReader(reader));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] GetAllPatients: {ex.Message}");
            throw;
        }
        return list;
    }

    /// <summary>Lấy thông tin bệnh nhân theo mã</summary>
    public static BenhNhan? GetPatientById(string maBN)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"SELECT \"MÃBN\", \"TÊNBN\", \"PHÁI\", \"NGÀYSINH\", \"CCCD\", \"SỐNHÀ\", \"TÊNĐƯỜNG\", " +
                $"\"QUẬNHUYỆN\", \"TỈNHTP\", \"TIỀNSỬBỆNH\", \"TIỀNSỬBỆNHGĐ\", \"DỊỨNGTHUỐC\", \"ORAUSER\" " +
                $"FROM {TABLE} WHERE \"MÃBN\" = :maBN", conn);
            cmd.Parameters.Add(new OracleParameter("maBN", maBN));
            using var reader = cmd.ExecuteReader();
            if (reader.Read()) return MapReader(reader);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] GetPatientById: {ex.Message}");
            throw;
        }
        return null;
    }

    /// <summary>Bệnh nhân xem thông tin của chính mình (dùng SESSION_USER, bảo mật ở tầng Oracle)</summary>
    public static BenhNhan? GetMyInfo()
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"SELECT \"MÃBN\", \"TÊNBN\", \"PHÁI\", \"NGÀYSINH\", \"CCCD\", \"SỐNHÀ\", \"TÊNĐƯỜNG\", " +
                $"\"QUẬNHUYỆN\", \"TỈNHTP\", \"TIỀNSỬBỆNH\", \"TIỀNSỬBỆNHGĐ\", \"DỊỨNGTHUỐC\", \"ORAUSER\" " +
                $"FROM {TABLE} WHERE \"ORAUSER\" = SYS_CONTEXT('USERENV','SESSION_USER')", conn);
            using var reader = cmd.ExecuteReader();
            if (reader.Read()) return MapReader(reader);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] GetMyInfo: {ex.Message}");
            throw;
        }
        return null;
    }

    /// <summary>Thêm bệnh nhân mới (Điều phối viên)</summary>
    public static bool InsertPatient(BenhNhan bn)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"INSERT INTO {TABLE} (\"MÃBN\", \"TÊNBN\", \"PHÁI\", \"NGÀYSINH\", \"CCCD\", \"SỐNHÀ\", \"TÊNĐƯỜNG\", " +
                "\"QUẬNHUYỆN\", \"TỈNHTP\", \"TIỀNSỬBỆNH\", \"TIỀNSỬBỆNHGĐ\", \"DỊỨNGTHUỐC\", \"ORAUSER\") " +
                "VALUES (:maBN, :tenBN, :phai, :ngaySinh, :cccd, :soNha, :tenDuong, " +
                ":quanHuyen, :tinhTP, :tienSuBenh, :tienSuBenhGD, :diUngThuoc, :oraUser)", conn);
            AddParams(cmd, bn);
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] InsertPatient: {ex.Message}");
            throw;
        }
    }

    /// <summary>Cập nhật toàn bộ thông tin bệnh nhân (Điều phối viên)</summary>
    public static bool UpdatePatient(BenhNhan bn)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            using var cmd = new OracleCommand(
                $"UPDATE {TABLE} SET \"TÊNBN\"=:tenBN, \"PHÁI\"=:phai, \"NGÀYSINH\"=:ngaySinh, " +
                "\"CCCD\"=:cccd, \"SỐNHÀ\"=:soNha, \"TÊNĐƯỜNG\"=:tenDuong, \"QUẬNHUYỆN\"=:quanHuyen, " +
                "\"TỈNHTP\"=:tinhTP, \"TIỀNSỬBỆNH\"=:tienSuBenh, \"TIỀNSỬBỆNHGĐ\"=:tienSuBenhGD, " +
                "\"DỊỨNGTHUỐC\"=:diUngThuoc WHERE \"MÃBN\"=:maBN", conn);
            cmd.Parameters.Add(new OracleParameter("tenBN", bn.TenBN));
            cmd.Parameters.Add(new OracleParameter("phai", (object?)bn.Phai ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("ngaySinh", (object?)bn.NgaySinh ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("cccd", (object?)bn.CCCD ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("soNha", (object?)bn.SoNha ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tenDuong", (object?)bn.TenDuong ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("quanHuyen", (object?)bn.QuanHuyen ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tinhTP", (object?)bn.TinhTP ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tienSuBenh", (object?)bn.TienSuBenh ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tienSuBenhGD", (object?)bn.TienSuBenhGD ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("diUngThuoc", (object?)bn.DiUngThuoc ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("maBN", bn.MaBN));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] UpdatePatient: {ex.Message}");
            throw;
        }
    }

    /// <summary>
    /// Bệnh nhân tự cập nhật thông tin cá nhân được phép chỉnh sửa.
    /// Row-level security: Oracle VPD tự lọc đúng bệnh nhân qua ORAUSER.
    /// Không có WHERE MÃBN - hoàn toàn dựa vào Oracle SESSION_USER (không thể giả mạo).
    /// </summary>
    public static bool UpdateMyProfile(BenhNhan bn)
    {
        try
        {
            var conn = OracleHelper.GetConnection();
            // Chỉ cập nhật các trường được phép: địa chỉ, tiền sử bệnh, dị ứng thuốc
            using var cmd = new OracleCommand(
                $"UPDATE {TABLE} SET \"SỐNHÀ\"=:soNha, \"TÊNĐƯỜNG\"=:tenDuong, " +
                "\"QUẬNHUYỆN\"=:quanHuyen, \"TỈNHTP\"=:tinhTP, " +
                "\"TIỀNSỬBỆNH\"=:tienSuBenh, \"TIỀNSỬBỆNHGĐ\"=:tienSuBenhGD, " +
                "\"DỊỨNGTHUỐC\"=:diUngThuoc " +
                "WHERE \"ORAUSER\" = SYS_CONTEXT('USERENV','SESSION_USER')", conn);
            cmd.Parameters.Add(new OracleParameter("soNha", (object?)bn.SoNha ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tenDuong", (object?)bn.TenDuong ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("quanHuyen", (object?)bn.QuanHuyen ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tinhTP", (object?)bn.TinhTP ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tienSuBenh", (object?)bn.TienSuBenh ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("tienSuBenhGD", (object?)bn.TienSuBenhGD ?? DBNull.Value));
            cmd.Parameters.Add(new OracleParameter("diUngThuoc", (object?)bn.DiUngThuoc ?? DBNull.Value));
            cmd.ExecuteNonQuery();
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[PatientDAL] UpdateMyProfile: {ex.Message}");
            throw;
        }
    }

    /// <summary>Map OracleDataReader → BenhNhan object</summary>
    private static BenhNhan MapReader(OracleDataReader reader)
    {
        return new BenhNhan
        {
            MaBN         = reader["MÃBN"]?.ToString() ?? "",
            TenBN        = reader["TÊNBN"]?.ToString() ?? "",
            Phai         = reader["PHÁI"]?.ToString() ?? "",
            NgaySinh     = reader["NGÀYSINH"] == DBNull.Value ? null : Convert.ToDateTime(reader["NGÀYSINH"]),
            CCCD         = reader["CCCD"]?.ToString() ?? "",
            SoNha        = reader["SỐNHÀ"]?.ToString() ?? "",
            TenDuong     = reader["TÊNĐƯỜNG"]?.ToString() ?? "",
            QuanHuyen    = reader["QUẬNHUYỆN"]?.ToString() ?? "",
            TinhTP       = reader["TỈNHTP"]?.ToString() ?? "",
            TienSuBenh   = reader["TIỀNSỬBỆNH"]?.ToString() ?? "",
            TienSuBenhGD = reader["TIỀNSỬBỆNHGĐ"]?.ToString() ?? "",
            DiUngThuoc   = reader["DỊỨNGTHUỐC"]?.ToString() ?? "",
            OraUser      = reader["ORAUSER"]?.ToString() ?? ""
        };
    }

    private static void AddParams(OracleCommand cmd, BenhNhan bn)
    {
        cmd.Parameters.Add(new OracleParameter("maBN", bn.MaBN));
        cmd.Parameters.Add(new OracleParameter("tenBN", bn.TenBN));
        cmd.Parameters.Add(new OracleParameter("phai", (object?)bn.Phai ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("ngaySinh", (object?)bn.NgaySinh ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("cccd", (object?)bn.CCCD ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("soNha", (object?)bn.SoNha ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("tenDuong", (object?)bn.TenDuong ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("quanHuyen", (object?)bn.QuanHuyen ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("tinhTP", (object?)bn.TinhTP ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("tienSuBenh", (object?)bn.TienSuBenh ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("tienSuBenhGD", (object?)bn.TienSuBenhGD ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("diUngThuoc", (object?)bn.DiUngThuoc ?? DBNull.Value));
        cmd.Parameters.Add(new OracleParameter("oraUser", (object?)bn.OraUser ?? DBNull.Value));
    }
}
