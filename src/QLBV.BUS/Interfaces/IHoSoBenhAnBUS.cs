using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    /// <summary>
    /// Hợp ước tầng nghiệp vụ cho quản lý Hồ sơ bệnh án.
    /// </summary>
    public interface IHoSoBenhAnBUS
    {
        List<HoSoBenhAnDTO> LayDanhSach();
        HoSoBenhAnDTO TimTheoMa(string maHSBA);
        List<HoSoBenhAnDTO> LayTheoMaBN(string maBN);
        (bool ThanhCong, string ThongBao) ThemMoi(HoSoBenhAnDTO hsba);
        (bool ThanhCong, string ThongBao) CapNhat(HoSoBenhAnDTO hsba);
        List<HoSoBenhAnDTO> LocTheoNgay(DateTime tuNgay, DateTime denNgay);
    }
}
