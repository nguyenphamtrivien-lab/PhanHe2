namespace PhanHe2.Models;

/// <summary>Thông báo (Oracle Label Security tự lọc theo nhãn)</summary>
public class ThongBao
{
    public int MaTB { get; set; }
    public string NoiDung { get; set; } = "";
    public DateTime? NgayGio { get; set; }
    public string DiaDiem { get; set; } = "";
}
