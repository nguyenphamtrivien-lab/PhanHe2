using QLBV.BUS.Interfaces;
using QLBV.DAL.Interfaces;
using QLBV.DAL.Implementations;
using QLBV.DTO;

namespace QLBV.BUS.Implementations
{
    public class LoginBUS : ILoginBUS
    {
        private readonly ILoginDAL _loginDAL;
        public LoginBUS() { _loginDAL = new LoginDAL(); }
        public UserSessionDTO DangNhap(string username, string password) { return _loginDAL.DangNhap(username, password); }
        public void DangXuat() { _loginDAL.DangXuat(); }
        public (bool ThanhCong, string ThongBao) DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhan) { return (false, "Not implemented"); }
    }
}
