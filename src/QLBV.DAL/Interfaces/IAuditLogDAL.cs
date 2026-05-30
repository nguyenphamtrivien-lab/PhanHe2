using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    /// <summary>
    /// Hợp ước truy cập dữ liệu bảng AUDIT_LOG.
    /// Dùng cho chức năng xem lịch sử thay đổi.
    /// </summary>
    public interface IAuditLogDAL
    {
        List<AuditLogDTO> LayDanhSach();
        List<AuditLogDTO> LocTheoNgay(DateTime tuNgay, DateTime denNgay);
        List<AuditLogDTO> LocTheoUser(string taiKhoan);
        List<AuditLogDTO> LocTheoBang(string tenBang);
    }
}
