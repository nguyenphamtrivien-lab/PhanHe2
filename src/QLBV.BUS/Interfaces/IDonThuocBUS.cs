using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    public interface IDonThuocBUS
    {
        List<DonThuocDTO> LayTheoHSBA(string maHSBA);
        (bool ThanhCong, string ThongBao) ThemMoi(DonThuocDTO dt);
        (bool ThanhCong, string ThongBao) CapNhat(DonThuocDTO dt);
        (bool ThanhCong, string ThongBao) Xoa(string maHSBA, DateTime ngayDT, string tenThuoc);
    }
}
