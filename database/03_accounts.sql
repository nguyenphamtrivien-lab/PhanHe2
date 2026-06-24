-- =====================================================================
-- File: 03_accounts.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: TC#1 - DBA tạo tài khoản Oracle và liên kết với dữ liệu
-- Chạy với quyền: SYSDBA hoặc DBA
-- Thứ tự chạy: 3/8 (sau 01_schema.sql và 02_data.sql)
--
-- NGUYÊN LÝ LIÊN KẾT TÀI KHOẢN VỚI DỮ LIỆU:
-- ============================================
-- 1. Mỗi nhân viên/bệnh nhân có 1 tài khoản Oracle riêng (username).
-- 2. Cột ORAUSER trong BỆNHNHÂN và NHÂNVIÊN lưu tên tài khoản Oracle
--    tương ứng (uppercase, vd: 'BS001', 'BN001').
-- 3. Khi user đăng nhập, hàm SYS_CONTEXT('USERENV','SESSION_USER')
--    trả về tên tài khoản hiện tại (uppercase).
-- 4. VPD policies và Views sử dụng điều kiện:
--       WHERE "ORAUSER" = SYS_CONTEXT('USERENV','SESSION_USER')
--    để tự động lọc dữ liệu theo người đăng nhập - không cần
--    ứng dụng phải truyền tham số, bảo mật ở tầng database.
-- 5. Ví dụ: BS001 đăng nhập → SESSION_USER = 'BS001'
--           VPD lọc HSBA chỉ trả về hồ sơ của BS001.
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- =====================================================================
-- BƯỚC 1: TẠO CÁC TÀI KHOẢN ORACLE
-- Password tạm: Welcome1# (buộc đổi lần đầu đăng nhập trong production)
-- Lưu ý: Oracle 21c yêu cầu password phức tạp (chữ hoa, thường, số, ký tự đặc biệt)
-- =====================================================================
-- PROMPT --- Tạo tài khoản Điều phối viên ---

-- DPV001: Giám đốc - OLS level BGD (đọc toàn bộ)
CREATE USER DPV001 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- DPV002: Lãnh đạo phòng - OLS level LDKHOA (all compartments)
CREATE USER DPV002 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- PROMPT --- Tạo tài khoản Bác sĩ/Y sĩ ---

-- BS001: Lãnh đạo Khoa Tim mạch tại HCM - OLS: LDKHOA:TIMMANH:HCM
CREATE USER BS001 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- BS002: Lãnh đạo Khoa Thần kinh tại Hà Nội - OLS: LDKHOA:THANKINH:HANOI
CREATE USER BS002 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- BS003: Lãnh đạo phòng Khoa Tim mạch tại HCM - OLS: LDKHOA:TIMMANH:HCM
CREATE USER BS003 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- PROMPT --- Tạo tài khoản Kỹ thuật viên ---

-- KTV001: Nhân viên Khoa Thần kinh tại HCM - OLS: NHANVIEN:THANKINH:HCM
CREATE USER KTV001 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- KTV002: Nhân viên Khoa Tim mạch tại HCM - OLS: NHANVIEN:TIMMANH:HCM
CREATE USER KTV002 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- PROMPT --- Tạo tài khoản Bệnh nhân ---

-- BN001..BN005: Bệnh nhân - OLS: NHANVIEN (hoặc tùy cấu hình OLS)
CREATE USER BN001 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

CREATE USER BN002 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

CREATE USER BN003 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

CREATE USER BN004 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

CREATE USER BN005 IDENTIFIED BY "Welcome1#"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- =====================================================================
-- BƯỚC 2: GRANT CREATE SESSION VÀ CONNECT
-- CREATE SESSION: quyền cơ bản để tạo kết nối đến database
-- CONNECT role: tập hợp các quyền cơ bản (bao gồm CREATE SESSION)
-- =====================================================================
-- PROMPT --- Grant CONNECT và CREATE SESSION ---

GRANT CONNECT, CREATE SESSION TO DPV001;
GRANT CONNECT, CREATE SESSION TO DPV002;
GRANT CONNECT, CREATE SESSION TO BS001;
GRANT CONNECT, CREATE SESSION TO BS002;
GRANT CONNECT, CREATE SESSION TO BS003;
GRANT CONNECT, CREATE SESSION TO KTV001;
GRANT CONNECT, CREATE SESSION TO KTV002;
GRANT CONNECT, CREATE SESSION TO BN001;
GRANT CONNECT, CREATE SESSION TO BN002;
GRANT CONNECT, CREATE SESSION TO BN003;
GRANT CONNECT, CREATE SESSION TO BN004;
GRANT CONNECT, CREATE SESSION TO BN005;

-- =====================================================================
-- BƯỚC 3: LIÊN KẾT TÀI KHOẢN ORACLE VỚI DỮ LIỆU
-- UPDATE cột ORAUSER = tên tài khoản Oracle tương ứng
--
-- Cơ chế hoạt động:
-- ┌─────────────────────────────────────────────────────────┐
-- │  Oracle User: BS001                                      │
-- │  ↓ đăng nhập                                            │
-- │  SYS_CONTEXT('USERENV','SESSION_USER') = 'BS001'        │
-- │  ↓ VPD/View kiểm tra                                    │
-- │  WHERE "ORAUSER" = 'BS001'  → tìm trong NHÂNVIÊN        │
-- │  ↓ lấy được MÃNV = 'BS001'                              │
-- │  ↓ lọc HSBA WHERE MÃBS = 'BS001'                        │
-- └─────────────────────────────────────────────────────────┘
-- =====================================================================
-- PROMPT --- Cập nhật liên kết ORAUSER ---

-- Liên kết tài khoản cho NHÂNVIÊN (đảm bảo uppercase)
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'DPV001' WHERE "MÃNV" = 'DPV001';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'DPV002' WHERE "MÃNV" = 'DPV002';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'BS001'  WHERE "MÃNV" = 'BS001';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'BS002'  WHERE "MÃNV" = 'BS002';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'BS003'  WHERE "MÃNV" = 'BS003';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'KTV001' WHERE "MÃNV" = 'KTV001';
UPDATE "NHÂNVIÊN" SET "ORAUSER" = 'KTV002' WHERE "MÃNV" = 'KTV002';

-- Liên kết tài khoản cho BỆNHNHÂN
UPDATE "BỆNHNHÂN" SET "ORAUSER" = 'BN001' WHERE "MÃBN" = 'BN001';
UPDATE "BỆNHNHÂN" SET "ORAUSER" = 'BN002' WHERE "MÃBN" = 'BN002';
UPDATE "BỆNHNHÂN" SET "ORAUSER" = 'BN003' WHERE "MÃBN" = 'BN003';
UPDATE "BỆNHNHÂN" SET "ORAUSER" = 'BN004' WHERE "MÃBN" = 'BN004';
UPDATE "BỆNHNHÂN" SET "ORAUSER" = 'BN005' WHERE "MÃBN" = 'BN005';

COMMIT;

-- =====================================================================
-- KIỂM TRA KẾT QUẢ
-- =====================================================================
-- PROMPT --- Kiểm tra tài khoản đã tạo ---
SELECT
  USERNAME,
  ACCOUNT_STATUS,
  DEFAULT_TABLESPACE,
  TO_CHAR(CREATED, 'DD/MM/YYYY HH24:MI') AS CREATED
FROM DBA_USERS
WHERE USERNAME IN (
  'DPV001','DPV002',
  'BS001','BS002','BS003',
  'KTV001','KTV002',
  'BN001','BN002','BN003','BN004','BN005'
)
ORDER BY USERNAME;

-- PROMPT --- Kiểm tra liên kết ORAUSER trong NHÂNVIÊN ---
SELECT "MÃNV", "HỌTÊN", "VAITRÒ", "ORAUSER" FROM "NHÂNVIÊN" ORDER BY "MÃNV";

-- PROMPT --- Kiểm tra liên kết ORAUSER trong BỆNHNHÂN ---
SELECT "MÃBN", "TÊNBN", "ORAUSER" FROM "BỆNHNHÂN" ORDER BY "MÃBN";

-- PROMPT --- Demo: Mô phỏng SYS_CONTEXT ---
SELECT
  'BS001' AS "ORACLE_USER",
  (SELECT "MÃNV" FROM "NHÂNVIÊN" WHERE "ORAUSER" = 'BS001') AS "MÃNV_TÌM_ĐƯỢC",
  (SELECT COUNT(*) FROM "HSBA"
   WHERE "MÃBS" = (SELECT "MÃNV" FROM "NHÂNVIÊN" WHERE "ORAUSER" = 'BS001')
  ) AS "SỐ_HSBA_THẤY"
FROM DUAL;

-- PROMPT === 03_accounts.sql completed successfully ===
