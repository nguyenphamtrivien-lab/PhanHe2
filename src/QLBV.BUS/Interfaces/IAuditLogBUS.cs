using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    public interface IAuditLogBUS
    {
        List<AuditLogDTO> LayDanhSach();
        List<AuditLogDTO> LocTheoNgay(DateTime tuNgay, DateTime denNgay);
        List<AuditLogDTO> LocTheoUser(string taiKhoan);
        List<AuditLogDTO> LocTheoBang(string tenBang);
    }
}
