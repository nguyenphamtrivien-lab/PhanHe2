-- =====================================================================
-- File: 04_rbac.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: TC#2,4,5 - Role-Based Access Control (RBAC)
--        Tạo Roles, Views bảo mật, Grant quyền cho users
-- Chạy với quyền: SYSDBA hoặc DBA (sau khi chạy 01,02,03)
-- Thứ tự chạy: 4/8
-- =====================================================================

SET DEFINE OFF;
SET ECHO ON;
SET SERVEROUTPUT ON;

-- =====================================================================
-- BƯỚC 1: XÓA ROLES CŨ NẾU TỒN TẠI
-- =====================================================================
BEGIN EXECUTE IMMEDIATE 'DROP ROLE ROLE_DIEUPHOI';   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP ROLE ROLE_BACSI';      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP ROLE ROLE_KTHUATVIEN'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP ROLE ROLE_BENHNHAN';   EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BƯỚC 2: TẠO CÁC ROLES
-- =====================================================================
-- Role dành cho Điều phối viên: quản lý bệnh nhân, phân công nhân sự
CREATE ROLE ROLE_DIEUPHOI;

-- Role dành cho Bác sĩ/Y sĩ: xem/cập nhật HSBA, kê đơn thuốc
CREATE ROLE ROLE_BACSI;

-- Role dành cho Kỹ thuật viên: xem và cập nhật kết quả dịch vụ của mình
CREATE ROLE ROLE_KTHUATVIEN;

-- Role dành cho Bệnh nhân: chỉ xem/cập nhật thông tin cá nhân và HSBA của mình
CREATE ROLE ROLE_BENHNHAN;

PROMPT --- Đã tạo 4 roles ---

-- =====================================================================
-- BƯỚC 3: TẠO VIEW VW_HSBA_DV_KTV
-- View lọc HSBA_DV theo MÃKTV = user hiện tại (qua ORAUSER)
-- Đây là security view - KTV chỉ thấy dịch vụ mình được phân công
-- =====================================================================
CREATE OR REPLACE VIEW VW_HSBA_DV_KTV AS
  SELECT
    d."MÃHSBA",
    d."LOẠIDV",
    d."NGÀYDV",
    d."MÃKTV",
    d."KẾTQUẢ"
  FROM SYSTEM."HSBA_DV" d
  JOIN SYSTEM."NHÂNVIÊN" n ON n."MÃNV" = d."MÃKTV"
  WHERE n."ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_HSBA_DV_KTV IS
  'View bảo mật: Kỹ thuật viên chỉ thấy HSBA_DV của mình theo ORAUSER';

-- =====================================================================
-- BƯỚC 4: TẠO VIEW VW_BENHNHAN_SELF
-- View lọc BỆNHNHÂN theo ORAUSER = user hiện tại
-- Bệnh nhân chỉ thấy thông tin cá nhân của mình
-- =====================================================================
CREATE OR REPLACE VIEW VW_BENHNHAN_SELF AS
  SELECT
    "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
    "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
    "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC"
  FROM SYSTEM."BỆNHNHÂN"
  WHERE "ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_BENHNHAN_SELF IS
  'View bảo mật: Bệnh nhân chỉ thấy thông tin cá nhân của chính mình';

-- =====================================================================
-- BƯỚC 5: TẠO CÁC VIEW BỔ SUNG CHO BỆNH NHÂN
-- =====================================================================

-- View bệnh nhân xem HSBA của mình
CREATE OR REPLACE VIEW VW_HSBA_BENHNHAN AS
  SELECT
    h."MÃHSBA",
    h."NGÀY",
    h."CHẨNĐOÁN",
    h."ĐIỀUTRỊ",
    h."MÃBS",
    h."MÃKHOA",
    h."KẾTLUẬN"
  FROM SYSTEM."HSBA" h
  JOIN SYSTEM."BỆNHNHÂN" b ON b."MÃBN" = h."MÃBN"
  WHERE b."ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_HSBA_BENHNHAN IS
  'View bảo mật: Bệnh nhân chỉ thấy HSBA của chính mình';

-- View bệnh nhân xem đơn thuốc của mình
CREATE OR REPLACE VIEW VW_DONTHUOC_BENHNHAN AS
  SELECT
    dt."MÃHSBA",
    dt."NGÀYĐT",
    dt."TÊNTHUỐC",
    dt."LIỀUDÙNG"
  FROM SYSTEM."ĐƠNTHUỐC" dt
  JOIN SYSTEM."HSBA" h ON h."MÃHSBA" = dt."MÃHSBA"
  JOIN SYSTEM."BỆNHNHÂN" b ON b."MÃBN" = h."MÃBN"
  WHERE b."ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_DONTHUOC_BENHNHAN IS
  'View bảo mật: Bệnh nhân chỉ thấy đơn thuốc của chính mình';

PROMPT --- Đã tạo 4 security views ---

-- =====================================================================
-- BƯỚC 6: GRANT QUYỀN CHO ROLE_DIEUPHOI (TC#2)
-- Điều phối viên:
--   ✓ SELECT/INSERT/UPDATE trên BỆNHNHÂN (tiếp nhận, cập nhật thông tin)
--   ✓ INSERT on HSBA (tạo hồ sơ mới)
--   ✓ UPDATE(MÃKHOA, MÃBS) on HSBA (phân công bác sĩ và khoa)
--   ✓ UPDATE(MÃKTV) on HSBA_DV (phân công kỹ thuật viên)
--   ✓ SELECT on NHÂNVIÊN (để biết ai có thể phân công)
--   ✓ SELECT on THÔNGBÁO (xem thông báo)
-- =====================================================================
PROMPT --- Grant quyền ROLE_DIEUPHOI ---

GRANT SELECT, INSERT, UPDATE ON SYSTEM."BỆNHNHÂN"  TO ROLE_DIEUPHOI;
GRANT INSERT                  ON SYSTEM."HSBA"      TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."HSBA"      TO ROLE_DIEUPHOI;
GRANT UPDATE ("MÃKHOA", "MÃBS")  ON SYSTEM."HSBA"  TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."HSBA_DV"   TO ROLE_DIEUPHOI;
GRANT UPDATE ("MÃKTV")        ON SYSTEM."HSBA_DV"   TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."NHÂNVIÊN"  TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."THÔNGBÁO"  TO ROLE_DIEUPHOI;

-- =====================================================================
-- BƯỚC 7: GRANT QUYỀN CHO ROLE_BACSI (TC#4)
-- Bác sĩ:
--   ✓ SELECT on HSBA (VPD sẽ lọc chỉ hồ sơ của bác sĩ đó)
--   ✓ UPDATE(CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN) on HSBA
--   ✓ SELECT/INSERT/DELETE on HSBA_DV
--   ✓ SELECT on BỆNHNHÂN (VPD lọc theo bệnh nhân của bác sĩ)
--   ✓ UPDATE(TIỀNSỬBỆNH, TIỀNSỬBỆNHGĐ, DỊỨNGTHUỐC) on BỆNHNHÂN
--   ✓ SELECT/INSERT/UPDATE/DELETE on ĐƠNTHUỐC
-- =====================================================================
PROMPT --- Grant quyền ROLE_BACSI ---

GRANT SELECT ON SYSTEM."HSBA" TO ROLE_BACSI;
GRANT UPDATE ("CHẨNĐOÁN", "ĐIỀUTRỊ", "KẾTLUẬN") ON SYSTEM."HSBA" TO ROLE_BACSI;

GRANT SELECT, INSERT, DELETE ON SYSTEM."HSBA_DV" TO ROLE_BACSI;

GRANT SELECT ON SYSTEM."BỆNHNHÂN" TO ROLE_BACSI;
GRANT UPDATE ("TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC") ON SYSTEM."BỆNHNHÂN" TO ROLE_BACSI;

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM."ĐƠNTHUỐC" TO ROLE_BACSI;

GRANT SELECT ON SYSTEM."NHÂNVIÊN" TO ROLE_BACSI;
GRANT SELECT ON SYSTEM."THÔNGBÁO" TO ROLE_BACSI;

-- =====================================================================
-- BƯỚC 8: GRANT QUYỀN CHO ROLE_KTHUATVIEN (TC#5)
-- Kỹ thuật viên:
--   ✓ SELECT on VW_HSBA_DV_KTV (view đã lọc theo ORAUSER)
--   ✓ UPDATE(KẾTQUẢ) on HSBA_DV (nhập kết quả dịch vụ)
--   ✓ SELECT on THÔNGBÁO (xem thông báo)
-- =====================================================================
PROMPT --- Grant quyền ROLE_KTHUATVIEN ---

GRANT SELECT ON SYSTEM.VW_HSBA_DV_KTV TO ROLE_KTHUATVIEN;
GRANT UPDATE ("KẾTQUẢ") ON SYSTEM."HSBA_DV" TO ROLE_KTHUATVIEN;
GRANT SELECT ON SYSTEM."THÔNGBÁO" TO ROLE_KTHUATVIEN;

-- =====================================================================
-- BƯỚC 9: GRANT QUYỀN CHO ROLE_BENHNHAN
-- Bệnh nhân:
--   ✓ SELECT on VW_BENHNHAN_SELF (xem thông tin cá nhân)
--   ✓ UPDATE cột địa chỉ, tiền sử bệnh cá nhân
--   ✓ SELECT on VW_HSBA_BENHNHAN (xem HSBA của mình)
--   ✓ SELECT on VW_DONTHUOC_BENHNHAN (xem đơn thuốc của mình)
--   ✓ SELECT on THÔNGBÁO (xem thông báo)
-- =====================================================================
PROMPT --- Grant quyền ROLE_BENHNHAN ---

GRANT SELECT ON SYSTEM.VW_BENHNHAN_SELF TO ROLE_BENHNHAN;
GRANT UPDATE (
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC"
) ON SYSTEM."BỆNHNHÂN" TO ROLE_BENHNHAN;
GRANT SELECT ON SYSTEM.VW_HSBA_BENHNHAN     TO ROLE_BENHNHAN;
GRANT SELECT ON SYSTEM.VW_DONTHUOC_BENHNHAN TO ROLE_BENHNHAN;
GRANT SELECT ON SYSTEM."THÔNGBÁO"           TO ROLE_BENHNHAN;

-- =====================================================================
-- BƯỚC 10: GRANT ROLES CHO USERS
-- =====================================================================
PROMPT --- Gán Role cho Users ---

-- Điều phối viên
GRANT ROLE_DIEUPHOI TO DPV001;
GRANT ROLE_DIEUPHOI TO DPV002;

-- Bác sĩ
GRANT ROLE_BACSI TO BS001;
GRANT ROLE_BACSI TO BS002;
GRANT ROLE_BACSI TO BS003;

-- Kỹ thuật viên
GRANT ROLE_KTHUATVIEN TO KTV001;
GRANT ROLE_KTHUATVIEN TO KTV002;

-- Bệnh nhân
GRANT ROLE_BENHNHAN TO BN001;
GRANT ROLE_BENHNHAN TO BN002;
GRANT ROLE_BENHNHAN TO BN003;
GRANT ROLE_BENHNHAN TO BN004;
GRANT ROLE_BENHNHAN TO BN005;

-- =====================================================================
-- BƯỚC 11: ĐẶT DEFAULT ROLE (kích hoạt tự động khi login)
-- =====================================================================
ALTER USER DPV001 DEFAULT ROLE ROLE_DIEUPHOI;
ALTER USER DPV002 DEFAULT ROLE ROLE_DIEUPHOI;
ALTER USER BS001  DEFAULT ROLE ROLE_BACSI;
ALTER USER BS002  DEFAULT ROLE ROLE_BACSI;
ALTER USER BS003  DEFAULT ROLE ROLE_BACSI;
ALTER USER KTV001 DEFAULT ROLE ROLE_KTHUATVIEN;
ALTER USER KTV002 DEFAULT ROLE ROLE_KTHUATVIEN;
ALTER USER BN001  DEFAULT ROLE ROLE_BENHNHAN;
ALTER USER BN002  DEFAULT ROLE ROLE_BENHNHAN;
ALTER USER BN003  DEFAULT ROLE ROLE_BENHNHAN;
ALTER USER BN004  DEFAULT ROLE ROLE_BENHNHAN;
ALTER USER BN005  DEFAULT ROLE ROLE_BENHNHAN;

COMMIT;

-- =====================================================================
-- KIỂM TRA KẾT QUẢ
-- =====================================================================
PROMPT --- Kiểm tra Roles đã tạo ---
SELECT ROLE FROM DBA_ROLES
WHERE ROLE IN ('ROLE_DIEUPHOI','ROLE_BACSI','ROLE_KTHUATVIEN','ROLE_BENHNHAN')
ORDER BY ROLE;

PROMPT --- Kiểm tra quyền được grant cho roles ---
SELECT ROLE, TABLE_NAME, PRIVILEGE, COLUMN_NAME, GRANTABLE
FROM ROLE_TAB_PRIVS
WHERE ROLE IN ('ROLE_DIEUPHOI','ROLE_BACSI','ROLE_KTHUATVIEN','ROLE_BENHNHAN')
ORDER BY ROLE, TABLE_NAME, PRIVILEGE;

PROMPT --- Kiểm tra user-role mapping ---
SELECT GRANTEE, GRANTED_ROLE, DEFAULT_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN (
  'DPV001','DPV002',
  'BS001','BS002','BS003',
  'KTV001','KTV002',
  'BN001','BN002','BN003','BN004','BN005'
)
ORDER BY GRANTEE, GRANTED_ROLE;

PROMPT --- Kiểm tra views đã tạo ---
SELECT VIEW_NAME, TEXT_LENGTH
FROM USER_VIEWS
WHERE VIEW_NAME IN ('VW_HSBA_DV_KTV','VW_BENHNHAN_SELF','VW_HSBA_BENHNHAN','VW_DONTHUOC_BENHNHAN')
ORDER BY VIEW_NAME;

PROMPT === 04_rbac.sql completed successfully ===
