using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng HSBA (Há»“ sÆ¡ bá»‡nh Ã¡n)
    /// </summary>
    public class HoSoBenhAnDTO
    {
        public string MaHSBA { get; set; }
        public string MaBN { get; set; }
        public DateTime Ngay { get; set; }
        public string ChanDoan { get; set; }
        public string DieuTri { get; set; }
        public string MaBS { get; set; }
        public string MaKhoa { get; set; }
        public string KetLuan { get; set; }

        // Navigation properties
        public string TenBN { get; set; }
        public string TenBS { get; set; }
    }
}
