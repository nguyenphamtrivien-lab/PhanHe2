using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    /// <summary>
    /// Hợp ước truy cập dữ liệu bảng THONGBAO.
    /// OLS kiểm soát mức độ hiển thị thông báo theo nhãn bảo mật.
    /// </summary>
    public interface IThongBaoDAL
    {
        List<ThongBaoDTO> LayDanhSach();
        bool ThemMoi(ThongBaoDTO tb);
    }
}
