-- =====================================================================
-- File: 04_rbac.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: Yêu cầu 1 - Câu 2: Role-Based Access Control (RBAC)
--        Ép thỏa chính sách bảo mật cho Kỹ thuật viên (TC#4) và
--        Bệnh nhân (TC#5), đồng thời bổ sung TC#5 cho tất cả nhân viên
-- Chạy với quyền: SYSDBA hoặc DBA (sau khi chạy 01, 02, 03)
-- Thứ tự chạy: 4/8
--
-- CÁC CHÍNH SÁCH BẢO MẬT TRIỂN KHAI:
-- ┌──────────────────────────────────────────────────────────────────┐
-- │ TC#4 – Kỹ thuật viên (KTV):                                      │
-- │   ✓ Chỉ xem HSBA_DV do mình được phân công (qua VW_HSBA_DV_KTV)│
-- │   ✓ Cập nhật KẾTQUẢ trên đúng dòng mình phụ trách               │
-- │                                                                    │
-- │ TC#5 – Mỗi người dùng xem/sửa đúng thông tin của chính mình:    │
-- │   • Bệnh nhân  → VW_BENHNHAN_SELF + INSTEAD OF TRIGGER           │
-- │     (được sửa: SỐNHÀ, TÊNĐƯỜNG, QUẬNHUYỆN, TỈNHTP,              │
-- │      TIỀNSỬBỆNH, TIỀNSỬBỆNHGĐ, DỊỨNGTHUỐC)                      │
-- │   • Nhân viên  → VW_NHANVIEN_SELF + INSTEAD OF TRIGGER           │
-- │     (được sửa: QUÊQUÁN, SỐĐT)                                    │
-- │                                                                    │
-- │ NGUYÊN TẮC: Không grant UPDATE trực tiếp lên bảng cho bệnh nhân │
-- │ → dùng INSTEAD OF trigger trên view để kiểm soát đúng trường    │
-- └──────────────────────────────────────────────────────────────────┘
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

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

-- Role dành cho Kỹ thuật viên: chỉ xem/cập nhật dịch vụ mình phụ trách
CREATE ROLE ROLE_KTHUATVIEN;

-- Role dành cho Bệnh nhân: chỉ xem/sửa thông tin cá nhân và HSBA của mình
CREATE ROLE ROLE_BENHNHAN;

-- PROMPT --- Đã tạo 4 roles: ROLE_DIEUPHOI, ROLE_BACSI, ROLE_KTHUATVIEN, ROLE_BENHNHAN ---

-- =====================================================================
-- BƯỚC 3: VIEW VW_HSBA_DV_KTV (TC#4 – Kỹ thuật viên)
-- Lọc HSBA_DV theo MÃKTV = user đang đăng nhập (qua ORAUSER)
-- Kỹ thuật viên chỉ thấy các dịch vụ mình được điều phối thực hiện
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
  'TC#4: View bảo mật - KTV chỉ thấy HSBA_DV do mình phụ trách theo ORAUSER';

-- =====================================================================
-- BƯỚC 4: VIEW VW_BENHNHAN_SELF (TC#5 – Bệnh nhân)
-- Bệnh nhân chỉ thấy đúng 1 dòng dữ liệu của chính mình
-- =====================================================================
CREATE OR REPLACE VIEW VW_BENHNHAN_SELF AS
  SELECT
    "MÃBN",
    "TÊNBN",
    "PHÁI",
    "NGÀYSINH",
    "CCCD",
    "SỐNHÀ",
    "TÊNĐƯỜNG",
    "QUẬNHUYỆN",
    "TỈNHTP",
    "TIỀNSỬBỆNH",
    "TIỀNSỬBỆNHGĐ",
    "DỊỨNGTHUỐC"
  FROM SYSTEM."BỆNHNHÂN"
  WHERE "ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_BENHNHAN_SELF IS
  'TC#5: View bảo mật - Bệnh nhân chỉ thấy thông tin cá nhân của chính mình';

-- =====================================================================
-- BƯỚC 5: VIEW VW_NHANVIEN_SELF (TC#5 – Nhân viên)
-- Mỗi nhân viên chỉ thấy đúng 1 dòng dữ liệu của chính mình
-- =====================================================================
CREATE OR REPLACE VIEW VW_NHANVIEN_SELF AS
  SELECT
    "MÃNV",
    "HỌTÊN",
    "PHÁI",
    "NGÀYSINH",
    "CMND",
    "QUÊQUÁN",
    "SỐĐt",
    "VAITRÒ",
    "CHUYÊNKHOA"
  FROM SYSTEM."NHÂNVIÊN"
  WHERE "ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_NHANVIEN_SELF IS
  'TC#5: View bảo mật - Nhân viên chỉ thấy thông tin cá nhân của chính mình';

-- =====================================================================
-- BƯỚC 6: CÁC VIEW BỔ SUNG CHO BỆNH NHÂN
-- =====================================================================

-- Bệnh nhân xem HSBA của mình
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
  'TC#5: View bảo mật - Bệnh nhân chỉ thấy HSBA của chính mình';

-- Bệnh nhân xem đơn thuốc của mình
CREATE OR REPLACE VIEW VW_DONTHUOC_BENHNHAN AS
  SELECT
    dt."MÃHSBA",
    dt."NGÀYĐT",
    dt."TÊNTHUỐC",
    dt."LIỀUDÙNG"
  FROM SYSTEM."ĐƠNTHUỐC" dt
  JOIN SYSTEM."HSBA" h  ON h."MÃHSBA"  = dt."MÃHSBA"
  JOIN SYSTEM."BỆNHNHÂN" b ON b."MÃBN" = h."MÃBN"
  WHERE b."ORAUSER" = SYS_CONTEXT('USERENV', 'SESSION_USER');

COMMENT ON TABLE VW_DONTHUOC_BENHNHAN IS
  'TC#5: View bảo mật - Bệnh nhân chỉ thấy đơn thuốc của chính mình';

-- PROMPT --- Đã tạo 5 security views ---

-- =====================================================================
-- BƯỚC 7: INSTEAD OF UPDATE TRIGGER CHO VW_BENHNHAN_SELF (TC#5)
-- ─────────────────────────────────────────────────────────────────────
-- Cơ chế:
--   Khi bệnh nhân UPDATE trên VW_BENHNHAN_SELF:
--   1. Trigger kiểm tra xem có cố thay đổi trường bị cấm không
--   2. Nếu có → báo lỗi ngay, không thực hiện UPDATE
--   3. Nếu không → UPDATE đúng các trường được phép lên bảng gốc
--
-- Trường BỊ CẤM (theo TC#5): MÃBN, TÊNBN, PHÁI, NGÀYSINH, CCCD
-- Trường ĐƯỢC PHÉP sửa:
--   SỐNHÀ, TÊNĐƯỜNG, QUẬNHUYỆN, TỈNHTP,
--   TIỀNSỬBỆNH, TIỀNSỬBỆNHGĐ, DỊỨNGTHUỐC
--
-- Bảo mật 2 lớp:
--   Lớp 1: GRANT UPDATE(allowed_cols) ON view → Oracle chặn cột không hợp lệ
--   Lớp 2: Trigger raise lỗi nếu bị lách (defense in depth)
-- =====================================================================
CREATE OR REPLACE TRIGGER TRG_BENHNHAN_SELF_UPD
  INSTEAD OF UPDATE ON VW_BENHNHAN_SELF
DECLARE
  v_session_user  VARCHAR2(100);
  v_rows_updated  NUMBER;
BEGIN
  v_session_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

  -- ── Lớp bảo vệ: từ chối nếu cố thay đổi trường bị hạn chế ──────
  IF :NEW."MÃBN" != :OLD."MÃBN" THEN
    RAISE_APPLICATION_ERROR(-20001,
      'TC#5 vi phạm: Không được phép thay đổi MÃBN');
  END IF;

  IF :NEW."TÊNBN" != :OLD."TÊNBN" THEN
    RAISE_APPLICATION_ERROR(-20002,
      'TC#5 vi phạm: Không được phép thay đổi TÊNBN');
  END IF;

  IF NVL(TO_CHAR(:NEW."PHÁI"), 'NULL') != NVL(TO_CHAR(:OLD."PHÁI"), 'NULL') THEN
    RAISE_APPLICATION_ERROR(-20003,
      'TC#5 vi phạm: Không được phép thay đổi PHÁI');
  END IF;

  IF NVL(:NEW."NGÀYSINH", DATE '0001-01-01')
       != NVL(:OLD."NGÀYSINH", DATE '0001-01-01') THEN
    RAISE_APPLICATION_ERROR(-20004,
      'TC#5 vi phạm: Không được phép thay đổi NGÀYSINH');
  END IF;

  IF NVL(:NEW."CCCD", 'NULL') != NVL(:OLD."CCCD", 'NULL') THEN
    RAISE_APPLICATION_ERROR(-20005,
      'TC#5 vi phạm: Không được phép thay đổi CCCD');
  END IF;

  -- ── Cập nhật chỉ các trường được phép lên bảng gốc ─────────────
  UPDATE SYSTEM."BỆNHNHÂN"
  SET
    "SỐNHÀ"        = :NEW."SỐNHÀ",
    "TÊNĐƯỜNG"     = :NEW."TÊNĐƯỜNG",
    "QUẬNHUYỆN"    = :NEW."QUẬNHUYỆN",
    "TỈNHTP"       = :NEW."TỈNHTP",
    "TIỀNSỬBỆNH"   = :NEW."TIỀNSỬBỆNH",
    "TIỀNSỬBỆNHGĐ" = :NEW."TIỀNSỬBỆNHGĐ",
    "DỊỨNGTHUỐC"   = :NEW."DỊỨNGTHUỐC"
  WHERE "ORAUSER" = v_session_user;

  -- Kiểm tra có cập nhật được dòng nào không
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20009,
      'Không tìm thấy bệnh nhân tương ứng với tài khoản ' || v_session_user);
  END IF;
END TRG_BENHNHAN_SELF_UPD;
/

COMMENT ON TRIGGER TRG_BENHNHAN_SELF_UPD IS
  'TC#5: INSTEAD OF UPDATE trigger - Bệnh nhân cập nhật thông tin cá nhân qua VW_BENHNHAN_SELF';

-- =====================================================================
-- BƯỚC 8: INSTEAD OF UPDATE TRIGGER CHO VW_NHANVIEN_SELF (TC#5)
-- ─────────────────────────────────────────────────────────────────────
-- Trường BỊ CẤM (theo TC#5):
--   MÃNV, HỌTÊN, PHÁI, NGÀYSINH, CMND, VAITRÒ, CHUYÊNKHOA
-- Trường ĐƯỢC PHÉP sửa: QUÊQUÁN, SỐĐT
-- =====================================================================
CREATE OR REPLACE TRIGGER TRG_NHANVIEN_SELF_UPD
  INSTEAD OF UPDATE ON VW_NHANVIEN_SELF
DECLARE
  v_session_user VARCHAR2(100);
BEGIN
  v_session_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

  -- ── Lớp bảo vệ: từ chối nếu cố thay đổi trường bị hạn chế ──────
  IF :NEW."MÃNV" != :OLD."MÃNV" THEN
    RAISE_APPLICATION_ERROR(-20011,
      'TC#5 vi phạm: Không được phép thay đổi MÃNV');
  END IF;

  IF :NEW."HỌTÊN" != :OLD."HỌTÊN" THEN
    RAISE_APPLICATION_ERROR(-20012,
      'TC#5 vi phạm: Không được phép thay đổi HỌTÊN');
  END IF;

  IF NVL(TO_CHAR(:NEW."PHÁI"), 'NULL') != NVL(TO_CHAR(:OLD."PHÁI"), 'NULL') THEN
    RAISE_APPLICATION_ERROR(-20013,
      'TC#5 vi phạm: Không được phép thay đổi PHÁI');
  END IF;

  IF NVL(:NEW."NGÀYSINH", DATE '0001-01-01')
       != NVL(:OLD."NGÀYSINH", DATE '0001-01-01') THEN
    RAISE_APPLICATION_ERROR(-20014,
      'TC#5 vi phạm: Không được phép thay đổi NGÀYSINH');
  END IF;

  IF NVL(:NEW."CMND", 'NULL') != NVL(:OLD."CMND", 'NULL') THEN
    RAISE_APPLICATION_ERROR(-20015,
      'TC#5 vi phạm: Không được phép thay đổi CMND');
  END IF;

  IF :NEW."VAITRÒ" != :OLD."VAITRÒ" THEN
    RAISE_APPLICATION_ERROR(-20016,
      'TC#5 vi phạm: Không được phép thay đổi VAITRÒ');
  END IF;

  IF NVL(TO_CHAR(:NEW."CHUYÊNKHOA"), 'NULL')
       != NVL(TO_CHAR(:OLD."CHUYÊNKHOA"), 'NULL') THEN
    RAISE_APPLICATION_ERROR(-20017,
      'TC#5 vi phạm: Không được phép thay đổi CHUYÊNKHOA');
  END IF;

  -- ── Cập nhật chỉ các trường được phép ───────────────────────────
  UPDATE SYSTEM."NHÂNVIÊN"
  SET
    "QUÊQUÁN" = :NEW."QUÊQUÁN",
    "SỐĐt"    = :NEW."SỐĐt"
  WHERE "ORAUSER" = v_session_user;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20018,
      'Không tìm thấy nhân viên tương ứng với tài khoản ' || v_session_user);
  END IF;
END TRG_NHANVIEN_SELF_UPD;
/

COMMENT ON TRIGGER TRG_NHANVIEN_SELF_UPD IS
  'TC#5: INSTEAD OF UPDATE trigger - Nhân viên cập nhật QUÊQUÁN, SỐĐT qua VW_NHANVIEN_SELF';

-- PROMPT --- Đã tạo 2 INSTEAD OF UPDATE triggers ---

-- =====================================================================
-- BƯỚC 9: GRANT QUYỀN CHO ROLE_DIEUPHOI (TC#2)
-- Điều phối viên:
--   ✓ SELECT/INSERT/UPDATE toàn bộ BỆNHNHÂN (tiếp nhận và cập nhật)
--   ✓ INSERT HSBA (tạo hồ sơ bệnh án mới)
--   ✓ SELECT HSBA (xem toàn bộ - VPD sẽ lọc thêm ở câu 3)
--   ✓ UPDATE(MÃKHOA, MÃBS) on HSBA (phân công bác sĩ và khoa)
--   ✓ SELECT HSBA_DV, UPDATE(MÃKTV) (phân công kỹ thuật viên)
--   ✓ SELECT NHÂNVIÊN (để biết ai có thể phân công)
--   ✓ SELECT + UPDATE(QUÊQUÁN,SỐĐT) on VW_NHANVIEN_SELF (TC#5)
-- =====================================================================
-- PROMPT --- Grant quyền ROLE_DIEUPHOI ---

GRANT SELECT, INSERT, UPDATE ON SYSTEM."BỆNHNHÂN" TO ROLE_DIEUPHOI;
GRANT INSERT                  ON SYSTEM."HSBA"     TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."HSBA"     TO ROLE_DIEUPHOI;
GRANT UPDATE ("MÃKHOA", "MÃBS")  ON SYSTEM."HSBA" TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."HSBA_DV"  TO ROLE_DIEUPHOI;
GRANT UPDATE ("MÃKTV")        ON SYSTEM."HSBA_DV"  TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."NHÂNVIÊN" TO ROLE_DIEUPHOI;
GRANT SELECT                  ON SYSTEM."THÔNGBÁO" TO ROLE_DIEUPHOI;

-- TC#5: Điều phối viên xem/sửa thông tin cá nhân của chính mình
GRANT SELECT ON SYSTEM.VW_NHANVIEN_SELF TO ROLE_DIEUPHOI;
GRANT UPDATE ("QUÊQUÁN", "SỐĐt") ON SYSTEM.VW_NHANVIEN_SELF TO ROLE_DIEUPHOI;

-- =====================================================================
-- BƯỚC 10: GRANT QUYỀN CHO ROLE_BACSI (TC#3)
-- Bác sĩ/Y sĩ:
--   ✓ SELECT HSBA (VPD sẽ lọc chỉ HSBA mình phụ trách ở câu 3)
--   ✓ UPDATE(CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN) on HSBA
--   ✓ SELECT/INSERT/DELETE HSBA_DV
--   ✓ SELECT BỆNHNHÂN (VPD sẽ lọc theo bệnh nhân của bác sĩ)
--   ✓ UPDATE(TIỀNSỬBỆNH, TIỀNSỬBỆNHGĐ, DỊỨNGTHUỐC) on BỆNHNHÂN
--   ✓ SELECT/INSERT/UPDATE/DELETE ĐƠNTHUỐC
--   ✓ SELECT + UPDATE(QUÊQUÁN,SỐĐT) on VW_NHANVIEN_SELF (TC#5)
-- =====================================================================
-- PROMPT --- Grant quyền ROLE_BACSI ---

GRANT SELECT ON SYSTEM."HSBA" TO ROLE_BACSI;
GRANT UPDATE ("CHẨNĐOÁN", "ĐIỀUTRỊ", "KẾTLUẬN") ON SYSTEM."HSBA" TO ROLE_BACSI;

GRANT SELECT, INSERT, DELETE ON SYSTEM."HSBA_DV" TO ROLE_BACSI;

GRANT SELECT ON SYSTEM."BỆNHNHÂN" TO ROLE_BACSI;
GRANT UPDATE ("TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC") ON SYSTEM."BỆNHNHÂN" TO ROLE_BACSI;

GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM."ĐƠNTHUỐC" TO ROLE_BACSI;

GRANT SELECT ON SYSTEM."NHÂNVIÊN" TO ROLE_BACSI;
GRANT SELECT ON SYSTEM."THÔNGBÁO" TO ROLE_BACSI;

-- TC#5: Bác sĩ xem/sửa thông tin cá nhân của chính mình
GRANT SELECT ON SYSTEM.VW_NHANVIEN_SELF TO ROLE_BACSI;
GRANT UPDATE ("QUÊQUÁN", "SỐĐt") ON SYSTEM.VW_NHANVIEN_SELF TO ROLE_BACSI;

-- =====================================================================
-- BƯỚC 11: GRANT QUYỀN CHO ROLE_KTHUATVIEN (TC#4)
-- Kỹ thuật viên:
--   ✓ SELECT VW_HSBA_DV_KTV (view đã lọc theo ORAUSER – chỉ dịch vụ mình)
--   ✓ UPDATE(KẾTQUẢ) on HSBA_DV (nhập kết quả xét nghiệm / dịch vụ)
--   ✓ SELECT THÔNGBÁO (xem thông báo nội bộ)
--   ✓ SELECT + UPDATE(QUÊQUÁN,SỐĐT) on VW_NHANVIEN_SELF (TC#5)
--
-- LƯU Ý BẢO MẬT ĐÃ SỬA LỖI (Review Lần 2):
--   KTV KHÔNG có quyền SELECT hay UPDATE trực tiếp trên HSBA_DV (bảng gốc).
--   KTV chỉ được SELECT và UPDATE qua VW_HSBA_DV_KTV (đã lọc theo ORAUSER).
--   Điều này chặn hoàn toàn lỗ hổng KTV cố tình "cập nhật mù" dữ liệu
--   của KTV khác nếu họ biết MÃHSBA.
-- =====================================================================
-- PROMPT --- Grant quyền ROLE_KTHUATVIEN ---

GRANT SELECT ON SYSTEM.VW_HSBA_DV_KTV         TO ROLE_KTHUATVIEN;
GRANT UPDATE ("KẾTQUẢ") ON SYSTEM.VW_HSBA_DV_KTV TO ROLE_KTHUATVIEN;
GRANT SELECT ON SYSTEM."THÔNGBÁO"             TO ROLE_KTHUATVIEN;

-- TC#5: Kỹ thuật viên xem/sửa thông tin cá nhân của chính mình
GRANT SELECT ON SYSTEM.VW_NHANVIEN_SELF        TO ROLE_KTHUATVIEN;
GRANT UPDATE ("QUÊQUÁN", "SỐĐt") ON SYSTEM.VW_NHANVIEN_SELF TO ROLE_KTHUATVIEN;

-- =====================================================================
-- BƯỚC 12: GRANT QUYỀN CHO ROLE_BENHNHAN (TC#5)
-- Bệnh nhân:
--   ✓ SELECT VW_BENHNHAN_SELF (xem thông tin cá nhân)
--   ✓ UPDATE(allowed_cols) VW_BENHNHAN_SELF (sửa qua INSTEAD OF trigger)
--   ✓ SELECT VW_HSBA_BENHNHAN (xem HSBA của mình)
--   ✓ SELECT VW_DONTHUOC_BENHNHAN (xem đơn thuốc của mình)
--   ✓ SELECT THÔNGBÁO (xem thông báo nội bộ)
--
-- BẢO MẬT NHIỀU LỚP:
--   Lớp 1 (Grant cột): Chỉ cho phép UPDATE đúng các cột được phép
--          → Oracle tự động từ chối UPDATE cột không trong danh sách grant
--   Lớp 2 (INSTEAD OF trigger): Trigger kiểm tra lại và thực thi UPDATE
--          → Không bao giờ UPDATE trực tiếp lên bảng gốc BỆNHNHÂN
--   → Bệnh nhân KHÔNG CÓ quyền UPDATE bảng BỆNHNHÂN trực tiếp
-- =====================================================================
-- PROMPT --- Grant quyền ROLE_BENHNHAN ---

GRANT SELECT ON SYSTEM.VW_BENHNHAN_SELF      TO ROLE_BENHNHAN;
GRANT UPDATE (
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC"
) ON SYSTEM.VW_BENHNHAN_SELF                 TO ROLE_BENHNHAN;

GRANT SELECT ON SYSTEM.VW_HSBA_BENHNHAN      TO ROLE_BENHNHAN;
GRANT SELECT ON SYSTEM.VW_DONTHUOC_BENHNHAN  TO ROLE_BENHNHAN;
GRANT SELECT ON SYSTEM."THÔNGBÁO"            TO ROLE_BENHNHAN;

-- =====================================================================
-- BƯỚC 13: GRANT ROLES CHO USERS CỤ THỂ
-- Trong thực tế: DBA cần grant cho toàn bộ 50 KTV và ~100.000 BN
-- Ở đây demo với các user đã tạo trong 03_accounts.sql
-- =====================================================================
-- PROMPT --- Gán Role cho Users ---

-- Điều phối viên (demo 2 users)
GRANT ROLE_DIEUPHOI TO DPV001;
GRANT ROLE_DIEUPHOI TO DPV002;

-- Bác sĩ/Y sĩ (demo 3 users)
GRANT ROLE_BACSI TO BS001;
GRANT ROLE_BACSI TO BS002;
GRANT ROLE_BACSI TO BS003;

-- Kỹ thuật viên – TC#4 (demo 2 users)
GRANT ROLE_KTHUATVIEN TO KTV001;
GRANT ROLE_KTHUATVIEN TO KTV002;

-- Bệnh nhân – TC#5 (demo 5 users)
GRANT ROLE_BENHNHAN TO BN001;
GRANT ROLE_BENHNHAN TO BN002;
GRANT ROLE_BENHNHAN TO BN003;
GRANT ROLE_BENHNHAN TO BN004;
GRANT ROLE_BENHNHAN TO BN005;

-- =====================================================================
-- BƯỚC 14: ĐẶT DEFAULT ROLE (kích hoạt tự động khi đăng nhập)
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
-- PROMPT ================================================================
-- PROMPT  KIỂM TRA RBAC – KỸ THUẬT VIÊN (TC#4) VÀ BỆNH NHÂN (TC#5)
-- PROMPT ================================================================

-- PROMPT --- [1] Danh sách Roles đã tạo ---
SELECT ROLE FROM DBA_ROLES
WHERE ROLE IN ('ROLE_DIEUPHOI','ROLE_BACSI','ROLE_KTHUATVIEN','ROLE_BENHNHAN')
ORDER BY ROLE;

-- PROMPT --- [2] Quyền được grant cho mỗi role (table-level và column-level) ---
SELECT ROLE, OWNER, TABLE_NAME, PRIVILEGE, COLUMN_NAME, GRANTABLE
FROM ROLE_TAB_PRIVS
WHERE ROLE IN ('ROLE_DIEUPHOI','ROLE_BACSI','ROLE_KTHUATVIEN','ROLE_BENHNHAN')
ORDER BY ROLE, TABLE_NAME, PRIVILEGE, COLUMN_NAME;

-- PROMPT --- [3] User – Role mapping ---
SELECT GRANTEE, GRANTED_ROLE, DEFAULT_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN (
  'DPV001','DPV002',
  'BS001','BS002','BS003',
  'KTV001','KTV002',
  'BN001','BN002','BN003','BN004','BN005'
)
ORDER BY GRANTEE, GRANTED_ROLE;

-- PROMPT --- [4] Danh sách Security Views đã tạo ---
SELECT VIEW_NAME, TEXT_LENGTH
FROM USER_VIEWS
WHERE VIEW_NAME IN (
  'VW_HSBA_DV_KTV',
  'VW_BENHNHAN_SELF',
  'VW_NHANVIEN_SELF',
  'VW_HSBA_BENHNHAN',
  'VW_DONTHUOC_BENHNHAN'
)
ORDER BY VIEW_NAME;

-- PROMPT --- [5] Danh sách INSTEAD OF Triggers đã tạo ---
SELECT TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_NAME, STATUS
FROM USER_TRIGGERS
WHERE TRIGGER_NAME IN ('TRG_BENHNHAN_SELF_UPD','TRG_NHANVIEN_SELF_UPD')
ORDER BY TRIGGER_NAME;

-- ─────────────────────────────────────────────────────────────────────
-- DEMO: Kiểm chứng TC#4 – Kỹ thuật viên chỉ thấy dịch vụ của mình
-- (Chạy với tư cách KTV001 để kiểm tra)
-- ─────────────────────────────────────────────────────────────────────
-- CONNECT KTV001/"Welcome1#";
-- SELECT * FROM SYSTEM.VW_HSBA_DV_KTV;
-- -- Kết quả: chỉ thấy dòng có MÃKTV = MÃNV của KTV001

-- DEMO: Kiểm chứng TC#5 – Bệnh nhân chỉ thấy/sửa thông tin của mình
-- (Chạy với tư cách BN001 để kiểm tra)
-- ─────────────────────────────────────────────────────────────────────
-- CONNECT BN001/"Welcome1#";
-- SELECT * FROM SYSTEM.VW_BENHNHAN_SELF;  -- Chỉ thấy 1 dòng của BN001
-- UPDATE SYSTEM.VW_BENHNHAN_SELF SET "SỐNHÀ" = '100';  -- Thành công
-- UPDATE SYSTEM.VW_BENHNHAN_SELF SET "TÊNBN" = 'Hack'; -- Lỗi ORA-20002

-- PROMPT === 04_rbac.sql completed successfully ===
