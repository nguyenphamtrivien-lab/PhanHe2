using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IDichVuDAL
    {
        List<DichVuDTO> LayDanhSach();
        List<DichVuDTO> LayTheoHSBA(string maHSBA);
        bool ThemMoi(DichVuDTO dv);
        bool CapNhatKetQua(DichVuDTO dv);
    }
}
