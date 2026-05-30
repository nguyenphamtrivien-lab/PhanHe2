using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Äá»‘i tÆ°á»£ng truyá»n dá»¯ liá»‡u cho báº£ng HSBA_DV
    /// </summary>
    public class DichVuDTO
    {
        public string MaHSBA { get; set; }
        public string LoaiDV { get; set; }
        public DateTime NgayDV { get; set; }
        public string MaKTV { get; set; }
        public string KetQua { get; set; }

        public string TenKTV { get; set; }
    }
}
