using System;
using Oracle.ManagedDataAccess.Client;
using QLBV.DAL.Interfaces;
using QLBV.DTO;

namespace QLBV.DAL.Implementations
{
    public class LoginDAL : ILoginDAL
    {
        public UserSessionDTO DangNhap(string username, string password)
        {
            try
            {
                var provider = OracleDataProvider.CreateSession(username, password);
                if (!provider.TestConnection()) { OracleDataProvider.DestroySession(); return null; }

                var session = new UserSessionDTO { Username = username };
                var dt = provider.ExecuteQuery(
                    @"SELECT SYS_CONTEXT('CTX_QLBV', 'VAITRO') AS VAITRO, SYS_CONTEXT('CTX_QLBV', 'MANV') AS MANV, SYS_CONTEXT('CTX_QLBV', 'MABN') AS MABN, SYS_CONTEXT('CTX_QLBV', 'LOAI_USER') AS LOAI_USER FROM DUAL");

                if (dt.Rows.Count > 0)
                {
                    var row = dt.Rows[0];
                    session.VaiTro = row["VAITRO"]?.ToString();
                    session.LoaiUser = row["LOAI_USER"]?.ToString();

                    if (session.LoaiUser == "NHANVIEN") {
                        session.MaNguoiDung = row["MANV"]?.ToString();
                        var dtNV = provider.ExecuteQuery("SELECT HOTEN, CHUYENKHOA FROM QLBV.NHANVIEN WHERE TAIKHOAN = :user", new[] { new OracleParameter("user", username) });
                        if (dtNV.Rows.Count > 0) { session.HoTen = dtNV.Rows[0]["HOTEN"]?.ToString(); session.ChuyenKhoa = dtNV.Rows[0]["CHUYENKHOA"]?.ToString(); }
                    }
                    else if (session.LoaiUser == "BENHNHAN") {
                        session.MaNguoiDung = row["MABN"]?.ToString();
                        var dtBN = provider.ExecuteQuery("SELECT TENBN FROM QLBV.BENHNHAN WHERE TAIKHOAN = :user", new[] { new OracleParameter("user", username) });
                        if (dtBN.Rows.Count > 0) session.HoTen = dtBN.Rows[0]["TENBN"]?.ToString();
                    }
                }
                return session;
            }
            catch { OracleDataProvider.DestroySession(); return null; }
        }
        public void DangXuat() { OracleDataProvider.DestroySession(); }
        public bool DoiMatKhau(string matKhauCu, string matKhauMoi) { return false; }
    }
}
