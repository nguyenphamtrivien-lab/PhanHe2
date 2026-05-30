# Hướng dẫn Cài đặt — Phân Hệ 2

## Yêu cầu hệ thống

- **Oracle Database 21c** (hoặc 19c trở lên)
- **SQL*Plus** hoặc **SQLcl** (để chạy script với lệnh `@`)
- **Quyền SYSDBA** (SYS hoặc SYSTEM)
- **Tablespace USERS** phải tồn tại (mặc định có sẵn)

---

## Cài đặt tự động (khuyến nghị)

### Bước 1: Kết nối Oracle với quyền SYSDBA

```bash
sqlplus / as sysdba
```

Hoặc:
```bash
sqlplus sys/"your_password"@localhost:1521/XEPDB1 as sysdba
```

### Bước 2: Di chuyển đến thư mục scripts

```sql
-- Trong SQL*Plus, thay đổi thư mục làm việc:
-- (Trên Windows)
HOST cd c:\Data(user)\Project\PhanHe2\scripts

-- Hoặc dùng đường dẫn đầy đủ khi gọi script
```

### Bước 3: Chạy script tổng

```sql
@00_run_all.sql
```

> **Lưu ý:** Cần sửa mật khẩu SYS trong file `00_run_all.sql` trước khi chạy.

---

## Cài đặt từng bước (thủ công)

### Bước 1: Tạo schema owner QLBV

Kết nối SYS AS SYSDBA và chạy:

```sql
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

CREATE USER QLBV IDENTIFIED BY "Oracle#123"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

-- Cấp quyền cần thiết
GRANT CONNECT, RESOURCE, DBA TO QLBV;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO QLBV;
GRANT CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO QLBV;
GRANT EXECUTE ON DBMS_RLS TO QLBV;
GRANT EXECUTE ON DBMS_SESSION TO QLBV;
GRANT CREATE ANY CONTEXT TO QLBV;
GRANT ADMINISTER DATABASE TRIGGER TO QLBV;
GRANT EXEMPT ACCESS POLICY TO QLBV;

ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE;
```

### Bước 2: Tạo cấu trúc bảng

```sql
CONN QLBV/"Oracle#123"
@01_create_schema.sql
```

**Kết quả mong đợi:** 7 bảng được tạo (NHANVIEN, BENHNHAN, HSBA, HSBA_DV, DONTHUOC, THONGBAO, AUDIT_LOG).

### Bước 3: Tạo tài khoản người dùng

```sql
CONN SYS/"your_password" AS SYSDBA
@02_create_users.sql
```

**Kết quả mong đợi:** 210 tài khoản Oracle (20 DPV + 100 BS + 50 KTV + 40 BN).

### Bước 4: Nhập dữ liệu mẫu

```sql
CONN QLBV/"Oracle#123"
@03_insert_data.sql
```

**Kết quả mong đợi:** Dữ liệu mẫu trong tất cả các bảng.

### Bước 5: Cài đặt VPD Policies

```sql
CONN QLBV/"Oracle#123"
@04_vpd_policies.sql
```

**Kết quả mong đợi:** Application Context, Logon Trigger, 12+ policy functions, 12+ VPD policies.

### Bước 6: Tạo Audit Triggers

```sql
CONN QLBV/"Oracle#123"
@05_audit_triggers.sql
```

**Kết quả mong đợi:** 3 triggers (HSBA, DONTHUOC, HSBA_DV).

### Bước 7: Cấp quyền

```sql
CONN QLBV/"Oracle#123"
@06_grants.sql
```

**Kết quả mong đợi:** Quyền SELECT/INSERT/UPDATE/DELETE trên các bảng cho tất cả user.

---

## Kiểm tra cài đặt

### Kiểm tra bảng

```sql
CONN QLBV/"Oracle#123"
SELECT table_name FROM user_tables ORDER BY table_name;
```

### Kiểm tra users

```sql
CONN SYS AS SYSDBA
SELECT username FROM dba_users 
WHERE username LIKE 'NV_%' OR username LIKE 'BN_%' 
ORDER BY username;
```

### Kiểm tra VPD policies

```sql
SELECT object_name, policy_name, function, sel, ins, upd, del 
FROM dba_policies 
WHERE object_owner = 'QLBV'
ORDER BY object_name, policy_name;
```

### Kiểm tra quyền

```sql
SELECT grantee, table_name, privilege 
FROM dba_tab_privs 
WHERE grantor = 'QLBV' 
ORDER BY grantee, table_name;
```

---

## Test VPD

### Test 1: Bác sĩ chỉ thấy HSBA của mình

```sql
CONN NV_BS001/"Oracle#123"
SELECT * FROM QLBV.HSBA;
-- Kết quả: Chỉ hiển thị các HSBA có MABS = 'BS001'
```

### Test 2: Điều phối viên thấy tất cả bệnh nhân

```sql
CONN NV_DPV01/"Oracle#123"
SELECT COUNT(*) FROM QLBV.BENHNHAN;
-- Kết quả: 40 (tất cả bệnh nhân)
```

### Test 3: Bệnh nhân chỉ thấy thông tin của mình

```sql
CONN BN_00001/"Oracle#123"
SELECT * FROM QLBV.BENHNHAN;
-- Kết quả: Chỉ 1 dòng - thông tin của BN_00001
```

### Test 4: Kỹ thuật viên chỉ thấy dịch vụ được phân công

```sql
CONN NV_KTV01/"Oracle#123"
SELECT * FROM QLBV.HSBA_DV;
-- Kết quả: Chỉ các dòng có MAKTV = 'KTV01'
```

### Test 5: Audit trail

```sql
CONN NV_BS001/"Oracle#123"
UPDATE QLBV.HSBA SET CHANDOAN = N'Viêm dạ dày cấp' WHERE MAHSBA = 'HSBA00001';
COMMIT;

CONN QLBV/"Oracle#123"
SELECT * FROM AUDIT_LOG WHERE TAIKHOAN = 'NV_BS001';
-- Kết quả: Ghi nhận hành vi UPDATE trên trường CHANDOAN
```

---

## Xử lý lỗi thường gặp

### ORA-65096: invalid common user or role name
**Nguyên nhân:** Oracle 21c CDB yêu cầu common users bắt đầu bằng `C##`
**Giải pháp:** Thêm `ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;` trước khi tạo user

### ORA-28115: policy with check option violation
**Nguyên nhân:** VPD policy không cho phép INSERT/UPDATE dòng không thỏa predicate
**Giải pháp:** Kiểm tra policy function và đảm bảo predicate đúng cho vai trò

### ORA-28110: policy function or package has error
**Nguyên nhân:** Policy function bị lỗi compile
**Giải pháp:** `SHOW ERRORS FUNCTION <function_name>;`

### ORA-00942: table or view does not exist
**Nguyên nhân:** User chưa được GRANT quyền trên bảng
**Giải pháp:** Chạy lại `06_grants.sql`
