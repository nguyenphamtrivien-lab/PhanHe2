using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng NHANVIEN
    /// </summary>
    public class NhanVienDTO
    {
        public string MaNV { get; set; }
        public string HoTen { get; set; }
        public string Phai { get; set; }
        public DateTime? NgaySinh { get; set; }
        public string CMND { get; set; }
        public string QueQuan { get; set; }
        public string SoDT { get; set; }
        public string VaiTro { get; set; }
        public string ChuyenKhoa { get; set; }
        public string TaiKhoan { get; set; }
    }
}
