using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    public interface IDichVuBUS
    {
        List<DichVuDTO> LayDanhSach();
        List<DichVuDTO> LayTheoHSBA(string maHSBA);
        (bool ThanhCong, string ThongBao) ThemMoi(DichVuDTO dv);
        (bool ThanhCong, string ThongBao) CapNhatKetQua(DichVuDTO dv);
        (bool ThanhCong, string ThongBao) Xoa(string maHSBA, string loaiDV, DateTime ngayDV);
    }
}
