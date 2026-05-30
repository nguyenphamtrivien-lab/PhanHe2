using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface INhanVienDAL
    {
        List<NhanVienDTO> LayDanhSach();
        NhanVienDTO TimTheoMa(string maNV);
        bool CapNhatThongTinCaNhan(NhanVienDTO nv);
    }
}
