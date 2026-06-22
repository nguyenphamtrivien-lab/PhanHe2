namespace PhanHe2.Models;

/// <summary>Hồ sơ bệnh án</summary>
public class Hsba
{
    public string MaHSBA { get; set; } = "";
    public string MaBN { get; set; } = "";
    public DateTime? Ngay { get; set; }
    public string ChanDoan { get; set; } = "";
    public string DieuTri { get; set; } = "";
    public string MaBS { get; set; } = "";
    public string MaKhoa { get; set; } = "";
    public string KetLuan { get; set; } = "";
}
