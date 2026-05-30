using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IDonThuocDAL
    {
        List<DonThuocDTO> LayTheoHSBA(string maHSBA);
        bool ThemMoi(DonThuocDTO dt);
        bool CapNhat(DonThuocDTO dt);
    }
}
