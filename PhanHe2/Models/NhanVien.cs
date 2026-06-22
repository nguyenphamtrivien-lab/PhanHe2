namespace PhanHe2.Models;

/// <summary>Thực thể Nhân viên</summary>
public class NhanVien
{
    public string MaNV { get; set; } = "";
    public string HoTen { get; set; } = "";
    public string Phai { get; set; } = "";
    public DateTime? NgaySinh { get; set; }
    public string CMND { get; set; } = "";
    public string QueQuan { get; set; } = "";
    public string SoDT { get; set; } = "";
    public string VaiTro { get; set; } = "";
    public string ChuyenKhoa { get; set; } = "";
    public string OraUser { get; set; } = "";
}
