namespace PhanHe2.Models;

/// <summary>Thực thể Bệnh nhân</summary>
public class BenhNhan
{
    public string MaBN { get; set; } = "";
    public string TenBN { get; set; } = "";
    public string Phai { get; set; } = "";
    public DateTime? NgaySinh { get; set; }
    public string CCCD { get; set; } = "";
    public string SoNha { get; set; } = "";
    public string TenDuong { get; set; } = "";
    public string QuanHuyen { get; set; } = "";
    public string TinhTP { get; set; } = "";
    public string TienSuBenh { get; set; } = "";
    public string TienSuBenhGD { get; set; } = "";
    public string DiUngThuoc { get; set; } = "";
    public string OraUser { get; set; } = "";
}
