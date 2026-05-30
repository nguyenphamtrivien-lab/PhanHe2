# BẢNG PHÂN CÔNG CÔNG VIỆC — PHÂN HỆ 2
## Ứng dụng Quản lý Dữ liệu Y tế

**Môn học:** CSC12001 - An toàn bảo mật dữ liệu trong HTTT  
**Đồ án:** Phân hệ 2 — Quản lý dữ liệu y tế  
**Hệ quản trị CSDL:** Oracle 21c

---

## Tổng quan phân công

| # | Mô tả công việc | Thành viên | Yêu cầu liên quan | Trạng thái |
|---|-----------------|------------|-------------------|------------|
| 1 | Thiết kế & tạo cấu trúc bảng CSDL | Thành viên A | YC1 - Câu 1 | ✅ Hoàn thành |
| 2 | Giải pháp liên kết tài khoản Oracle (TC#1) | Thành viên A | YC1 - Câu 1 | ✅ Hoàn thành |
| 3 | Script Schema & Data mẫu | Thành viên A | YC1 - Câu 1 | ✅ Hoàn thành |
| 4 | VPD policies cho Điều phối viên & Bác sĩ/Y sĩ | Thành viên A | YC1 - Câu 3 | ✅ Hoàn thành |
| 5 | RBAC cho Kỹ thuật viên & Bệnh nhân + Giao diện | Thành viên B | YC1 - Câu 2 | 🔄 Đang thực hiện |
| 6 | VPD giao diện cho Điều phối viên & Bác sĩ/Y sĩ | Thành viên C | YC1 - Câu 3 | 🔄 Đang thực hiện |
| 7 | Oracle Label Security (OLS) + Giao diện | Thành viên D | YC2 | 🔄 Đang thực hiện |
| 8 | Kiểm toán (Audit) | Thành viên E | YC3 | 🔄 Đang thực hiện |
| 9 | Sao lưu & phục hồi dữ liệu | Thành viên F | YC4 | 🔄 Đang thực hiện |

---

## Chi tiết phân công — Phần Backend CSDL & VPD

### Thành viên A: Backend CSDL & Kiến trúc Bảo mật (VPD)

#### Công việc 1: Thiết kế & tạo cấu trúc bảng CSDL
- **File:** `scripts/01_create_schema.sql`
- **Nội dung:**
  - Tạo 7 bảng: NHANVIEN, BENHNHAN, HSBA, HSBA_DV, DONTHUOC, THONGBAO, AUDIT_LOG
  - Thiết lập PRIMARY KEY, FOREIGN KEY, CHECK constraints
  - Sử dụng NVARCHAR2 cho trường text tiếng Việt
  - Thêm cột TAIKHOAN vào NHANVIEN và BENHNHAN (giải pháp TC#1)

#### Công việc 2: Giải pháp liên kết tài khoản Oracle (TC#1)
- **File:** `scripts/02_create_users.sql`
- **Nội dung:**
  - Tạo 210 tài khoản Oracle (20 DPV + 100 BS + 50 KTV + 40 BN)
  - Liên kết mỗi tài khoản với dòng dữ liệu tương ứng qua cột TAIKHOAN
  - Sử dụng `SYS_CONTEXT('USERENV', 'SESSION_USER')` để xác định user

#### Công việc 3: Dữ liệu mẫu
- **File:** `scripts/03_insert_data.sql`
- **Nội dung:**
  - 170 nhân viên (20 DPV + 100 BS + 50 KTV)
  - 40 bệnh nhân
  - 60+ hồ sơ bệnh án, 30+ dịch vụ, 40+ đơn thuốc

#### Công việc 4: VPD Policies (Yêu cầu 1 - Câu 3)
- **File:** `scripts/04_vpd_policies.sql`
- **Nội dung:**
  - Application Context (`CTX_QLBV`) + Logon Trigger
  - 12 policy functions cho các vai trò khác nhau
  - VPD policies trên 5 bảng: HSBA, BENHNHAN, HSBA_DV, DONTHUOC, NHANVIEN
  - Kiểm soát row-level và column-level access

#### Công việc 5: Audit Triggers & Cấp quyền
- **Files:** `scripts/05_audit_triggers.sql`, `scripts/06_grants.sql`
- **Nội dung:**
  - Triggers ghi vết trên HSBA, DONTHUOC, HSBA_DV
  - GRANT object privileges cho tất cả user theo vai trò

---

## Sơ đồ phụ thuộc giữa các yêu cầu

```
YC1 - Câu 1 (Schema + Users)
    ├── YC1 - Câu 2 (RBAC cho KTV & BN)
    ├── YC1 - Câu 3 (VPD cho DPV & BS)
    ├── YC2 (OLS - Thông báo)
    ├── YC3 (Kiểm toán)
    └── YC4 (Sao lưu & phục hồi)
```

---

## Thứ tự chạy scripts

| Bước | Script | Chạy bằng user |
|------|--------|---------------|
| 0 | `00_run_all.sql` | SYS (SYSDBA) |
| 1 | `01_create_schema.sql` | QLBV |
| 2 | `02_create_users.sql` | SYS (SYSDBA) |
| 3 | `03_insert_data.sql` | QLBV |
| 4 | `04_vpd_policies.sql` | QLBV |
| 5 | `05_audit_triggers.sql` | QLBV |
| 6 | `06_grants.sql` | QLBV |
