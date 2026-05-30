using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IBenhNhanDAL
    {
        List<BenhNhanDTO> LayDanhSach();
        BenhNhanDTO TimTheoMa(string maBN);
        bool ThemMoi(BenhNhanDTO bn);
        bool CapNhat(BenhNhanDTO bn);
        List<BenhNhanDTO> TimKiem(string tuKhoa);
    }
}
