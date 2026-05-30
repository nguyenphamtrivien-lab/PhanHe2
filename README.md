# Phân Hệ 2: Ứng dụng Quản lý Dữ liệu Y tế

**Môn học:** CSC12001 - An toàn bảo mật dữ liệu trong HTTT  
**Hệ quản trị CSDL:** Oracle 21c

---

## Mô tả

Hệ thống quản lý dữ liệu y tế cho bệnh viện X, bao gồm:
- Quản lý thông tin bệnh nhân, nhân viên, hồ sơ bệnh án
- Bảo mật dữ liệu bằng VPD (Virtual Private Database), RBAC, OLS
- Kiểm toán (Audit) hành vi truy cập và thay đổi dữ liệu
- Sao lưu và phục hồi dữ liệu

## Kiến trúc bảo mật

```
┌─────────────────────────────────────────────────────┐
│                   Oracle 21c                         │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │   RBAC   │  │   VPD    │  │       OLS        │   │
│  │ (Câu 2)  │  │ (Câu 3)  │  │   (Yêu cầu 2)   │   │
│  │          │  │          │  │                  │   │
│  │ KTV, BN  │  │ DPV, BS  │  │  Phát tán TB     │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
│                                                      │
│  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │   Audit Trail    │  │    Backup & Recovery     │  │
│  │   (Yêu cầu 3)   │  │    (Yêu cầu 4)          │  │
│  └──────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Cấu trúc thư mục

```
PhanHe2/
├── scripts/
│   ├── 00_run_all.sql           # Script chạy tất cả
│   ├── 01_create_schema.sql     # Tạo cấu trúc bảng
│   ├── 02_create_users.sql      # Tạo tài khoản Oracle
│   ├── 03_insert_data.sql       # Dữ liệu mẫu
│   ├── 04_vpd_policies.sql      # VPD policies (Câu 3)
│   ├── 05_audit_triggers.sql    # Triggers ghi vết
│   └── 06_grants.sql            # Cấp quyền
├── docs/
│   ├── phan_cong.md             # Bảng phân công
│   └── huong_dan.md             # Hướng dẫn cài đặt
└── README.md                    # File này
```

## Sơ đồ CSDL (ERD)

```
NHANVIEN (MANV PK, HOTEN, PHAI, NGAYSINH, CMND, QUEQUAN, SODT, VAITRO, CHUYENKHOA, TAIKHOAN)
    │
    ├──< HSBA.MABS (Bác sĩ điều trị)
    ├──< HSBA_DV.MAKTV (Kỹ thuật viên)
    │
BENHNHAN (MABN PK, TENBN, PHAI, NGAYSINH, CCCD, SONHA, TENDUONG, QUANHUYEN, TINHTP, TIENSUBNH, TIENSUBNHGD, DIUNGTH, TAIKHOAN)
    │
    └──< HSBA.MABN (Bệnh nhân)
              │
              ├──< HSBA_DV (MAHSBA, LOAIDV, NGAYDV PK, MAKTV, KETQUA)
              │
              └──< DONTHUOC (MAHSBA, NGAYDT, TENTHUOC PK, LIEUDUNG)

THONGBAO (MATB PK, NOIDUNG, NGAYGIO, DIADIEM)
AUDIT_LOG (MA_LOG PK, TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI, THOI_GIAN)
```

## Yêu cầu hệ thống

- Oracle Database 21c
- SQL*Plus hoặc SQLcl để chạy scripts
- Quyền SYSDBA để tạo users

## Hướng dẫn cài đặt nhanh

1. Kết nối Oracle với quyền SYSDBA
2. Di chuyển đến thư mục `scripts/`
3. Chạy: `@00_run_all.sql`
4. Xem chi tiết tại: `docs/huong_dan.md`

## Vai trò người dùng

| Vai trò | Số lượng | Username pattern | Cơ chế bảo mật |
|---------|----------|-----------------|-----------------|
| Điều phối viên | 20 | NV_DPV01..20 | VPD |
| Bác sĩ/Y sĩ | 100 | NV_BS001..100 | VPD |
| Kỹ thuật viên | 50 | NV_KTV01..50 | RBAC + VPD |
| Bệnh nhân | 40 (mẫu) | BN_00001..40 | RBAC + VPD |

## TC#1: Liên kết tài khoản Oracle

Giải pháp: Thêm cột `TAIKHOAN` vào bảng NHANVIEN và BENHNHAN, lưu tên tài khoản Oracle tương ứng. Truy vấn thông tin user hiện tại chỉ cần 1 bảng:

```sql
-- Với nhân viên:
SELECT * FROM NHANVIEN WHERE TAIKHOAN = SYS_CONTEXT('USERENV', 'SESSION_USER');
-- Với bệnh nhân:
SELECT * FROM BENHNHAN WHERE TAIKHOAN = SYS_CONTEXT('USERENV', 'SESSION_USER');
```
