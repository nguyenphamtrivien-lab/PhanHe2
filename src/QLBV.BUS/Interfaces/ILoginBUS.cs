using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    public interface ILoginBUS
    {
        UserSessionDTO DangNhap(string username, string password);
        void DangXuat();
        (bool ThanhCong, string ThongBao) DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhan);
    }
}
