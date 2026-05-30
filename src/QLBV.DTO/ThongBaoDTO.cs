using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng THONGBAO
    /// </summary>
    public class ThongBaoDTO
    {
        public int MaTB { get; set; }
        public string NoiDung { get; set; }
        public DateTime? NgayGio { get; set; }
        public string DiaDiem { get; set; }
    }
}
