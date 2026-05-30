using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng BENHNHAN
    /// </summary>
    public class BenhNhanDTO
    {
        public string MaBN { get; set; }
        public string TenBN { get; set; }
        public string Phai { get; set; }
        public DateTime? NgaySinh { get; set; }
        public string CCCD { get; set; }
        public string SoNha { get; set; }
        public string TenDuong { get; set; }
        public string QuanHuyen { get; set; }
        public string TinhTP { get; set; }
        public string TienSuBNH { get; set; }
        public string TienSuBNHGD { get; set; }
        public string DiUngTH { get; set; }
        public string TaiKhoan { get; set; }
    }
}
