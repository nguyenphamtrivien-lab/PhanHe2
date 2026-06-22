namespace PhanHe2.Models;

/// <summary>Dịch vụ trong hồ sơ bệnh án</summary>
public class HsbaDv
{
    public string MaHSBA { get; set; } = "";
    public string LoaiDV { get; set; } = "";
    public DateTime? NgayDV { get; set; }
    public string MaKTV { get; set; } = "";
    public string KetQua { get; set; } = "";
}
