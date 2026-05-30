$ErrorActionPreference = "Stop"

$baseDir = "c:\Data(user)\Project\PhanHe2"
$srcDir = Join-Path $baseDir "src"
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null

function Write-File {
    param([string]$path, [string]$content)
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -Path $path -Value $content.Trim() -Encoding UTF8
}

# ----------------- DTO -----------------
$dtoDir = Join-Path $srcDir "QLBV.DTO"

Write-File (Join-Path $dtoDir "NhanVienDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng NHANVIEN
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
"@

Write-File (Join-Path $dtoDir "BenhNhanDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng BENHNHAN
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
"@

Write-File (Join-Path $dtoDir "HoSoBenhAnDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng HSBA (Hồ sơ bệnh án)
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
"@

Write-File (Join-Path $dtoDir "DichVuDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng HSBA_DV
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
"@

Write-File (Join-Path $dtoDir "DonThuocDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng DONTHUOC
    /// </summary>
    public class DonThuocDTO
    {
        public string MaHSBA { get; set; }
        public DateTime NgayDT { get; set; }
        public string TenThuoc { get; set; }
        public string LieuDung { get; set; }
    }
}
"@

Write-File (Join-Path $dtoDir "ThongBaoDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng THONGBAO
    /// </summary>
    public class ThongBaoDTO
    {
        public int MaTB { get; set; }
        public string NoiDung { get; set; }
        public DateTime? NgayGio { get; set; }
        public string DiaDiem { get; set; }
    }
}
"@

Write-File (Join-Path $dtoDir "AuditLogDTO.cs") @"
using System;

namespace QLBV.DTO
{
    /// <summary>
    /// Đối tượng truyền dữ liệu cho bảng AUDIT_LOG
    /// </summary>
    public class AuditLogDTO
    {
        public int MaLog { get; set; }
        public string TaiKhoan { get; set; }
        public string Bang { get; set; }
        public string HanhVi { get; set; }
        public string Truong { get; set; }
        public string GiaTriCu { get; set; }
        public string GiaTriMoi { get; set; }
        public DateTime? ThoiGian { get; set; }
    }
}
"@

Write-File (Join-Path $dtoDir "UserSessionDTO.cs") @"
namespace QLBV.DTO
{
    /// <summary>
    /// Lưu thông tin phiên đăng nhập hiện tại
    /// </summary>
    public class UserSessionDTO
    {
        public string Username { get; set; }
        public string VaiTro { get; set; }
        public string MaNguoiDung { get; set; }
        public string HoTen { get; set; }
        public string ChuyenKhoa { get; set; }
        public string LoaiUser { get; set; }
    }
}
"@

Write-File (Join-Path $dtoDir "QLBV.DTO.csproj") @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net8.0-windows</TargetFramework>
    <RootNamespace>QLBV.DTO</RootNamespace>
    <AssemblyName>QLBV.DTO</AssemblyName>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
"@

# ----------------- DAL -----------------
$dalDir = Join-Path $srcDir "QLBV.DAL"

Write-File (Join-Path $dalDir "OracleDataProvider.cs") @"
using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace QLBV.DAL
{
    public class OracleDataProvider : IDisposable
    {
        private static OracleDataProvider _instance;
        public static OracleDataProvider Instance
        {
            get
            {
                if (_instance == null)
                    throw new InvalidOperationException("Chưa thiết lập kết nối.");
                return _instance;
            }
        }

        private const string DEFAULT_HOST = "localhost";
        private const int DEFAULT_PORT = 1521;
        private const string DEFAULT_SERVICE = "ORCLPDB";

        private readonly string _connectionString;
        private OracleConnection _connection;
        private bool _disposed = false;

        public string CurrentUser { get; private set; }

        public OracleDataProvider(string username, string password,
            string host = DEFAULT_HOST, int port = DEFAULT_PORT,
            string serviceName = DEFAULT_SERVICE)
        {
            CurrentUser = username;
            _connectionString = new OracleConnectionStringBuilder
            {
                UserID = username,
                Password = password,
                DataSource = $"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={host})(PORT={port}))(CONNECT_DATA=(SERVICE_NAME={serviceName})))",
                Pooling = true,
                MinPoolSize = 1,
                MaxPoolSize = 10,
                ConnectionTimeout = 30
            }.ConnectionString;
        }

        public OracleConnection GetConnection()
        {
            if (_connection == null) _connection = new OracleConnection(_connectionString);
            if (_connection.State != ConnectionState.Open) _connection.Open();
            return _connection;
        }

        public void CloseConnection()
        {
            if (_connection != null && _connection.State == ConnectionState.Open)
                _connection.Close();
        }

        public bool TestConnection()
        {
            try { using var conn = new OracleConnection(_connectionString); conn.Open(); return true; }
            catch { return false; }
        }

        public DataTable ExecuteQuery(string sql, OracleParameter[] parameters = null)
        {
            var dataTable = new DataTable();
            using var cmd = new OracleCommand(sql, GetConnection());
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            using var adapter = new OracleDataAdapter(cmd);
            adapter.Fill(dataTable);
            return dataTable;
        }

        public int ExecuteNonQuery(string sql, OracleParameter[] parameters = null)
        {
            using var cmd = new OracleCommand(sql, GetConnection());
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteNonQuery();
        }

        public static OracleDataProvider CreateSession(string username, string password)
        {
            _instance?.Dispose();
            _instance = new OracleDataProvider(username, password);
            return _instance;
        }

        public static void DestroySession()
        {
            _instance?.Dispose();
            _instance = null;
        }

        public void Dispose()
        {
            if (!_disposed) { CloseConnection(); _connection?.Dispose(); _connection = null; _disposed = true; }
            GC.SuppressFinalize(this);
        }
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\ILoginDAL.cs") @"
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface ILoginDAL
    {
        UserSessionDTO DangNhap(string username, string password);
        void DangXuat();
        bool DoiMatKhau(string matKhauCu, string matKhauMoi);
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\IBenhNhanDAL.cs") @"
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IBenhNhanDAL
    {
        List<BenhNhanDTO> LayDanhSach();
        BenhNhanDTO TimTheoMa(string maBN);
        bool ThemMoi(BenhNhanDTO bn);
        bool CapNhat(BenhNhanDTO bn);
        List<BenhNhanDTO> TimKiem(string tuKhoa);
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\IHoSoBenhAnDAL.cs") @"
using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IHoSoBenhAnDAL
    {
        List<HoSoBenhAnDTO> LayDanhSach();
        HoSoBenhAnDTO TimTheoMa(string maHSBA);
        List<HoSoBenhAnDTO> LayTheoMaBN(string maBN);
        bool ThemMoi(HoSoBenhAnDTO hsba);
        bool CapNhat(HoSoBenhAnDTO hsba);
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\IDichVuDAL.cs") @"
using System;
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IDichVuDAL
    {
        List<DichVuDTO> LayDanhSach();
        List<DichVuDTO> LayTheoHSBA(string maHSBA);
        bool ThemMoi(DichVuDTO dv);
        bool CapNhatKetQua(DichVuDTO dv);
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\IDonThuocDAL.cs") @"
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface IDonThuocDAL
    {
        List<DonThuocDTO> LayTheoHSBA(string maHSBA);
        bool ThemMoi(DonThuocDTO dt);
        bool CapNhat(DonThuocDTO dt);
    }
}
"@

Write-File (Join-Path $dalDir "Interfaces\INhanVienDAL.cs") @"
using System.Collections.Generic;
using QLBV.DTO;

namespace QLBV.DAL.Interfaces
{
    public interface INhanVienDAL
    {
        List<NhanVienDTO> LayDanhSach();
        NhanVienDTO TimTheoMa(string maNV);
        bool CapNhatThongTinCaNhan(NhanVienDTO nv);
    }
}
"@

Write-File (Join-Path $dalDir "Implementations\LoginDAL.cs") @"
using System;
using Oracle.ManagedDataAccess.Client;
using QLBV.DAL.Interfaces;
using QLBV.DTO;

namespace QLBV.DAL.Implementations
{
    public class LoginDAL : ILoginDAL
    {
        public UserSessionDTO DangNhap(string username, string password)
        {
            try
            {
                var provider = OracleDataProvider.CreateSession(username, password);
                if (!provider.TestConnection()) { OracleDataProvider.DestroySession(); return null; }

                var session = new UserSessionDTO { Username = username };
                var dt = provider.ExecuteQuery(
                    @"SELECT SYS_CONTEXT('CTX_QLBV', 'VAITRO') AS VAITRO, SYS_CONTEXT('CTX_QLBV', 'MANV') AS MANV, SYS_CONTEXT('CTX_QLBV', 'MABN') AS MABN, SYS_CONTEXT('CTX_QLBV', 'LOAI_USER') AS LOAI_USER FROM DUAL");

                if (dt.Rows.Count > 0)
                {
                    var row = dt.Rows[0];
                    session.VaiTro = row["VAITRO"]?.ToString();
                    session.LoaiUser = row["LOAI_USER"]?.ToString();

                    if (session.LoaiUser == "NHANVIEN") {
                        session.MaNguoiDung = row["MANV"]?.ToString();
                        var dtNV = provider.ExecuteQuery("SELECT HOTEN, CHUYENKHOA FROM QLBV.NHANVIEN WHERE TAIKHOAN = :user", new[] { new OracleParameter("user", username) });
                        if (dtNV.Rows.Count > 0) { session.HoTen = dtNV.Rows[0]["HOTEN"]?.ToString(); session.ChuyenKhoa = dtNV.Rows[0]["CHUYENKHOA"]?.ToString(); }
                    }
                    else if (session.LoaiUser == "BENHNHAN") {
                        session.MaNguoiDung = row["MABN"]?.ToString();
                        var dtBN = provider.ExecuteQuery("SELECT TENBN FROM QLBV.BENHNHAN WHERE TAIKHOAN = :user", new[] { new OracleParameter("user", username) });
                        if (dtBN.Rows.Count > 0) session.HoTen = dtBN.Rows[0]["TENBN"]?.ToString();
                    }
                }
                return session;
            }
            catch { OracleDataProvider.DestroySession(); return null; }
        }
        public void DangXuat() { OracleDataProvider.DestroySession(); }
        public bool DoiMatKhau(string matKhauCu, string matKhauMoi) { return false; }
    }
}
"@

Write-File (Join-Path $dalDir "QLBV.DAL.csproj") @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net8.0-windows</TargetFramework>
    <RootNamespace>QLBV.DAL</RootNamespace>
    <AssemblyName>QLBV.DAL</AssemblyName>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include=`"Oracle.ManagedDataAccess.Core`" Version=`"23.4.0`" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\QLBV.DTO\QLBV.DTO.csproj`" />
  </ItemGroup>
</Project>
"@

# ----------------- BUS -----------------
$busDir = Join-Path $srcDir "QLBV.BUS"

Write-File (Join-Path $busDir "SessionManager.cs") @"
using QLBV.DTO;

namespace QLBV.BUS
{
    public static class SessionManager
    {
        public static UserSessionDTO CurrentUser { get; private set; }
        public static bool IsLoggedIn => CurrentUser != null;
        public static void SetSession(UserSessionDTO session) { CurrentUser = session; }
        public static void ClearSession() { CurrentUser = null; }
        public static bool IsRole(string vaiTro) { return CurrentUser?.VaiTro == vaiTro; }

        public const string ROLE_DPV = "Dieu phoi vien";
        public const string ROLE_BS = "Bac si/Y si";
        public const string ROLE_KTV = "Ky thuat vien";
        public const string ROLE_BN = "Benh nhan";
    }
}
"@

Write-File (Join-Path $busDir "Interfaces\ILoginBUS.cs") @"
using QLBV.DTO;

namespace QLBV.BUS.Interfaces
{
    public interface ILoginBUS
    {
        UserSessionDTO DangNhap(string username, string password);
        void DangXuat();
        (bool ThanhCong, string ThongBao) DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhan);
    }
}
"@

Write-File (Join-Path $busDir "Implementations\LoginBUS.cs") @"
using QLBV.BUS.Interfaces;
using QLBV.DAL.Interfaces;
using QLBV.DAL.Implementations;
using QLBV.DTO;

namespace QLBV.BUS.Implementations
{
    public class LoginBUS : ILoginBUS
    {
        private readonly ILoginDAL _loginDAL;
        public LoginBUS() { _loginDAL = new LoginDAL(); }
        public UserSessionDTO DangNhap(string username, string password) { return _loginDAL.DangNhap(username, password); }
        public void DangXuat() { _loginDAL.DangXuat(); }
        public (bool ThanhCong, string ThongBao) DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhan) { return (false, "Not implemented"); }
    }
}
"@

Write-File (Join-Path $busDir "QLBV.BUS.csproj") @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <TargetFramework>net8.0-windows</TargetFramework>
    <RootNamespace>QLBV.BUS</RootNamespace>
    <AssemblyName>QLBV.BUS</AssemblyName>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\QLBV.DTO\QLBV.DTO.csproj`" />
    <ProjectReference Include=`"..\QLBV.DAL\QLBV.DAL.csproj`" />
  </ItemGroup>
</Project>
"@

# ----------------- UI -----------------
$uiDir = Join-Path $srcDir "QLBV.UI"

Write-File (Join-Path $uiDir "Program.cs") @"
using System;
using System.Windows.Forms;

namespace QLBV.UI
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Forms.frmLogin());
        }
    }
}
"@

Write-File (Join-Path $uiDir "Forms\frmLogin.cs") @"
using System;
using System.Windows.Forms;
using QLBV.BUS;
using QLBV.BUS.Implementations;
using QLBV.BUS.Interfaces;

namespace QLBV.UI.Forms
{
    public partial class frmLogin : Form
    {
        private readonly ILoginBUS _loginBUS;
        public frmLogin() { InitializeComponent(); _loginBUS = new LoginBUS(); }

        private void btnDangNhap_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;
            var session = _loginBUS.DangNhap(username, password);
            if (session != null) {
                SessionManager.SetSession(session);
                this.Hide();
                Form frmMain = MoFormTheoVaiTro(session.VaiTro);
                if (frmMain != null) {
                    frmMain.FormClosed += (s, args) => { _loginBUS.DangXuat(); SessionManager.ClearSession(); this.Show(); };
                    frmMain.Show();
                }
            } else { MessageBox.Show("Sai tài khoản/mật khẩu."); }
        }

        private Form MoFormTheoVaiTro(string vaiTro)
        {
            switch (vaiTro) {
                case SessionManager.ROLE_DPV: return new frmDieuPhoiVien();
                case SessionManager.ROLE_BS: return new frmBacSi();
                case SessionManager.ROLE_KTV: return new frmKyThuatVien();
                case SessionManager.ROLE_BN: return new frmBenhNhan();
                default: return null;
            }
        }
    }
}
"@

Write-File (Join-Path $uiDir "Forms\frmLogin.Designer.cs") @"
namespace QLBV.UI.Forms
{
    partial class frmLogin
    {
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing) { if (disposing && (components != null)) components.Dispose(); base.Dispose(disposing); }
        private void InitializeComponent()
        {
            this.txtUsername = new System.Windows.Forms.TextBox();
            this.txtPassword = new System.Windows.Forms.TextBox();
            this.btnDangNhap = new System.Windows.Forms.Button();
            this.SuspendLayout();
            
            this.txtUsername.Location = new System.Drawing.Point(50, 50);
            this.txtUsername.Name = "txtUsername";
            
            this.txtPassword.Location = new System.Drawing.Point(50, 100);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.UseSystemPasswordChar = true;
            
            this.btnDangNhap.Location = new System.Drawing.Point(50, 150);
            this.btnDangNhap.Name = "btnDangNhap";
            this.btnDangNhap.Text = "Đăng nhập";
            this.btnDangNhap.Click += new System.EventHandler(this.btnDangNhap_Click);
            
            this.ClientSize = new System.Drawing.Size(300, 250);
            this.Controls.Add(this.txtUsername);
            this.Controls.Add(this.txtPassword);
            this.Controls.Add(this.btnDangNhap);
            this.Name = "frmLogin";
            this.Text = "Đăng nhập";
            this.ResumeLayout(false);
            this.PerformLayout();
        }
        private System.Windows.Forms.TextBox txtUsername;
        private System.Windows.Forms.TextBox txtPassword;
        private System.Windows.Forms.Button btnDangNhap;
    }
}
"@

Write-File (Join-Path $uiDir "Forms\frmDieuPhoiVien.cs") @"
using System.Windows.Forms;
namespace QLBV.UI.Forms { public partial class frmDieuPhoiVien : Form { public frmDieuPhoiVien() { InitializeComponent(); } } }
"@

Write-File (Join-Path $uiDir "Forms\frmDieuPhoiVien.Designer.cs") @"
namespace QLBV.UI.Forms { partial class frmDieuPhoiVien { private void InitializeComponent() { this.Text = "Điều phối viên"; } } }
"@

Write-File (Join-Path $uiDir "Forms\frmBacSi.cs") @"
using System.Windows.Forms;
namespace QLBV.UI.Forms { public partial class frmBacSi : Form { public frmBacSi() { InitializeComponent(); } } }
"@

Write-File (Join-Path $uiDir "Forms\frmBacSi.Designer.cs") @"
namespace QLBV.UI.Forms { partial class frmBacSi { private void InitializeComponent() { this.Text = "Bác sĩ"; } } }
"@

Write-File (Join-Path $uiDir "Forms\frmKyThuatVien.cs") @"
using System.Windows.Forms;
namespace QLBV.UI.Forms { public partial class frmKyThuatVien : Form { public frmKyThuatVien() { InitializeComponent(); } } }
"@

Write-File (Join-Path $uiDir "Forms\frmKyThuatVien.Designer.cs") @"
namespace QLBV.UI.Forms { partial class frmKyThuatVien { private void InitializeComponent() { this.Text = "Kỹ thuật viên"; } } }
"@

Write-File (Join-Path $uiDir "Forms\frmBenhNhan.cs") @"
using System.Windows.Forms;
namespace QLBV.UI.Forms { public partial class frmBenhNhan : Form { public frmBenhNhan() { InitializeComponent(); } } }
"@

Write-File (Join-Path $uiDir "Forms\frmBenhNhan.Designer.cs") @"
namespace QLBV.UI.Forms { partial class frmBenhNhan { private void InitializeComponent() { this.Text = "Bệnh nhân"; } } }
"@


Write-File (Join-Path $uiDir "QLBV.UI.csproj") @"
<Project Sdk=`"Microsoft.NET.Sdk`">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <RootNamespace>QLBV.UI</RootNamespace>
    <AssemblyName>QLBV.UI</AssemblyName>
    <UseWindowsForms>true</UseWindowsForms>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include=`"..\QLBV.BUS\QLBV.BUS.csproj`" />
    <ProjectReference Include=`"..\QLBV.DTO\QLBV.DTO.csproj`" />
  </ItemGroup>
</Project>
"@

Write-File (Join-Path $baseDir "QLBV_Security.sln") @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"QLBV.UI`", `"src\QLBV.UI\QLBV.UI.csproj`", `"{A1B2C3D4-0001-0001-0001-000000000001}`"
EndProject
Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"QLBV.BUS`", `"src\QLBV.BUS\QLBV.BUS.csproj`", `"{A1B2C3D4-0002-0002-0002-000000000002}`"
EndProject
Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"QLBV.DAL`", `"src\QLBV.DAL\QLBV.DAL.csproj`", `"{A1B2C3D4-0003-0003-0003-000000000003}`"
EndProject
Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"QLBV.DTO`", `"src\QLBV.DTO\QLBV.DTO.csproj`", `"{A1B2C3D4-0004-0004-0004-000000000004}`"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{A1B2C3D4-0001-0001-0001-000000000001}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1B2C3D4-0001-0001-0001-000000000001}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1B2C3D4-0001-0001-0001-000000000001}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1B2C3D4-0001-0001-0001-000000000001}.Release|Any CPU.Build.0 = Release|Any CPU
		{A1B2C3D4-0002-0002-0002-000000000002}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1B2C3D4-0002-0002-0002-000000000002}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1B2C3D4-0002-0002-0002-000000000002}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1B2C3D4-0002-0002-0002-000000000002}.Release|Any CPU.Build.0 = Release|Any CPU
		{A1B2C3D4-0003-0003-0003-000000000003}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1B2C3D4-0003-0003-0003-000000000003}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1B2C3D4-0003-0003-0003-000000000003}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1B2C3D4-0003-0003-0003-000000000003}.Release|Any CPU.Build.0 = Release|Any CPU
		{A1B2C3D4-0004-0004-0004-000000000004}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1B2C3D4-0004-0004-0004-000000000004}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1B2C3D4-0004-0004-0004-000000000004}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1B2C3D4-0004-0004-0004-000000000004}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
"@

Write-File (Join-Path $baseDir ".gitignore") @"
# Build results
[Bb]in/
[Oo]bj/
[Dd]ebug/
[Rr]elease/

# Visual Studio
.vs/
*.suo
*.user
*.userosscache
*.sln.docstates

# NuGet
packages/
*.nupkg
"@

Write-Host "XONG!"
