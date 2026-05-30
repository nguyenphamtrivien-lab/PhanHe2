using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface ILoginDAL
    {
        UserSessionDTO DangNhap(string username, string password);
        void DangXuat();
        bool DoiMatKhau(string matKhauCu, string matKhauMoi);
    }
}
