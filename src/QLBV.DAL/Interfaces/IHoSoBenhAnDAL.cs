using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IHoSoBenhAnDAL
    {
        List<HoSoBenhAnDTO> LayDanhSach();
        HoSoBenhAnDTO TimTheoMa(string maHSBA);
        List<HoSoBenhAnDTO> LayTheoMaBN(string maBN);
        bool ThemMoi(HoSoBenhAnDTO hsba);
        bool CapNhat(HoSoBenhAnDTO hsba);
    }
}
