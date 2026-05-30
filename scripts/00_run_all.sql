-- ============================================
-- SCRIPT: 00_run_all.sql
-- MÔ TẢ: Chạy tất cả scripts theo thứ tự
-- Chạy bằng: SYS hoặc SYSTEM (vì cần tạo user)
-- Lưu ý: Cần chạy trong SQL*Plus hoặc SQLcl
-- ============================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT ==========================================
PROMPT  HỆ THỐNG QUẢN LÝ BỆNH VIỆN (QLBV)
PROMPT  Oracle 21c Healthcare Database
PROMPT  Bắt đầu cài đặt...
PROMPT ==========================================
PROMPT

-- ============================================
-- BƯỚC 1: Tạo schema owner QLBV
-- Kết nối: SYS AS SYSDBA
-- Mô tả: Tạo user QLBV với đầy đủ quyền quản trị
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 1: Tạo schema owner QLBV
PROMPT ==========================================

DECLARE
    v_count NUMBER;
BEGIN
    -- Kiểm tra user QLBV đã tồn tại chưa
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'QLBV';
    IF v_count = 0 THEN
        -- Tạo user QLBV với mật khẩu và tablespace mặc định
        EXECUTE IMMEDIATE 'CREATE USER QLBV IDENTIFIED BY "Oracle#123" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';

        -- Cấp role cơ bản
        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO QLBV';

        -- Cấp quyền tạo đối tượng
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO QLBV';

        -- Cấp quyền cho VPD (Virtual Private Database)
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_RLS TO QLBV';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_SESSION TO QLBV';

        -- Cấp quyền tạo context và trigger cấp database
        EXECUTE IMMEDIATE 'GRANT CREATE ANY CONTEXT TO QLBV';
        EXECUTE IMMEDIATE 'GRANT ADMINISTER DATABASE TRIGGER TO QLBV';

        -- Miễn trừ VPD cho schema owner (để QLBV không bị chặn bởi chính sách VPD)
        EXECUTE IMMEDIATE 'GRANT EXEMPT ACCESS POLICY TO QLBV';

        DBMS_OUTPUT.PUT_LINE('>> User QLBV đã được tạo thành công.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('>> User QLBV đã tồn tại, bỏ qua bước tạo.');
    END IF;
END;
/

PROMPT

-- ============================================
-- BƯỚC 2: Tạo cấu trúc bảng
-- Kết nối: QLBV
-- Mô tả: Tạo tất cả bảng, ràng buộc, index
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 2: Tạo cấu trúc bảng
PROMPT ==========================================

CONN QLBV/"Oracle#123"
@01_create_schema.sql

PROMPT

-- ============================================
-- BƯỚC 3: Tạo tài khoản người dùng
-- Kết nối: SYS AS SYSDBA (cần quyền CREATE USER)
-- Mô tả: Tạo tài khoản cho NV, BN
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 3: Tạo tài khoản người dùng
PROMPT ==========================================

CONN SYS/"your_sys_password" AS SYSDBA
@02_create_users.sql

PROMPT

-- ============================================
-- BƯỚC 4: Nhập dữ liệu mẫu
-- Kết nối: QLBV
-- Mô tả: Insert dữ liệu bệnh nhân, nhân viên,
--         hồ sơ bệnh án, dịch vụ, đơn thuốc
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 4: Nhập dữ liệu mẫu
PROMPT ==========================================

CONN QLBV/"Oracle#123"
@03_insert_data.sql

PROMPT

-- ============================================
-- BƯỚC 5: Cài đặt VPD Policies
-- Kết nối: QLBV (đã kết nối từ bước 4)
-- Mô tả: Tạo các policy function và áp dụng
--         chính sách bảo mật hàng (RLS)
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 5: Cài đặt VPD Policies
PROMPT ==========================================

@04_vpd_policies.sql

PROMPT

-- ============================================
-- BƯỚC 6: Tạo Audit Triggers
-- Kết nối: QLBV (đã kết nối từ bước 4)
-- Mô tả: Tạo trigger ghi vết thay đổi dữ liệu
--         trên các bảng HSBA, DONTHUOC, HSBA_DV
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 6: Tạo Audit Triggers
PROMPT ==========================================

@05_audit_triggers.sql

PROMPT

-- ============================================
-- BƯỚC 7: Cấp quyền cho người dùng
-- Kết nối: QLBV (đã kết nối từ bước 4)
-- Mô tả: Cấp quyền SELECT/INSERT/UPDATE/DELETE
--         trên các bảng cho từng nhóm user
-- ============================================
PROMPT ==========================================
PROMPT BƯỚC 7: Cấp quyền
PROMPT ==========================================

@06_grants.sql

PROMPT

-- ============================================
-- HOÀN TẤT
-- ============================================
PROMPT ==========================================
PROMPT  HOÀN TẤT CÀI ĐẶT HỆ THỐNG QLBV!
PROMPT ==========================================
PROMPT
PROMPT  Các bước đã thực hiện:
PROMPT    1. Tạo schema owner QLBV
PROMPT    2. Tạo cấu trúc bảng (01_create_schema.sql)
PROMPT    3. Tạo tài khoản người dùng (02_create_users.sql)
PROMPT    4. Nhập dữ liệu mẫu (03_insert_data.sql)
PROMPT    5. Cài đặt VPD Policies (04_vpd_policies.sql)
PROMPT    6. Tạo Audit Triggers (05_audit_triggers.sql)
PROMPT    7. Cấp quyền truy cập (06_grants.sql)
PROMPT
PROMPT  Lưu ý:
PROMPT    - Thay đổi mật khẩu SYS trong dòng CONN nếu cần
PROMPT    - Kiểm tra kết quả bằng:
PROMPT      SELECT * FROM QLBV.AUDIT_LOG;
PROMPT      SELECT grantee, table_name, privilege
PROMPT        FROM DBA_TAB_PRIVS WHERE grantor = 'QLBV';
PROMPT ==========================================
