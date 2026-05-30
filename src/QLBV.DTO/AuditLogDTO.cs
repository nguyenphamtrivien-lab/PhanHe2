using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng AUDIT_LOG
    /// </summary>
    public class AuditLogDTO
    {
        public int MaLog { get; set; }
        public string TaiKhoan { get; set; }
        public string Bang { get; set; }
        public string HanhVi { get; set; }
        public string Truong { get; set; }
        public string GiaTriCu { get; set; }
        public string GiaTriMoi { get; set; }
        public DateTime? ThoiGian { get; set; }
    }
}
