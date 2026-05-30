using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    /// <summary>
    /// Hợp ước tầng nghiệp vụ cho quản lý Bệnh nhân.
    /// </summary>
    public interface IBenhNhanBUS
    {
        List<BenhNhanDTO> LayDanhSach();
        BenhNhanDTO TimTheoMa(string maBN);
        (bool ThanhCong, string ThongBao) ThemMoi(BenhNhanDTO bn);
        (bool ThanhCong, string ThongBao) CapNhat(BenhNhanDTO bn);
        List<BenhNhanDTO> TimKiem(string tuKhoa);
    }
}
