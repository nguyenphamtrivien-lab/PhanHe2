-- =====================================================================
-- File: 01_schema.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: Tạo các bảng, sequences cho hệ thống
-- Chạy với quyền: SYSTEM hoặc DBA
-- Thứ tự chạy: 1/8
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- =====================================================================
-- XÓA CÁC ĐỐI TƯỢNG CŨ NẾU TỒN TẠI (chạy an toàn)
-- =====================================================================
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "THÔNGBÁO"  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "ĐƠNTHUỐC"  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "HSBA_DV"   CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "HSBA"      CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "NHÂNVIÊN"  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE "BỆNHNHÂN"  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Xóa sequences cũ
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_BENHNHAN'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_NHANVIEN'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_HSBA';     EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Xóa functions cũ
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION FN_NEXT_MABN';   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION FN_NEXT_MANV';   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP FUNCTION FN_NEXT_MAHSBA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BẢNG 1: BỆNHNHÂN
-- Lưu trữ thông tin cá nhân và y tế của bệnh nhân
-- Cột ORAUSER liên kết với tài khoản Oracle tương ứng
-- =====================================================================
CREATE TABLE "BỆNHNHÂN" (
  "MÃBN"          VARCHAR2(10)    NOT NULL,
  "TÊNBN"         NVARCHAR2(100)  NOT NULL,
  "PHÁI"          NVARCHAR2(10),
  "NGÀYSINH"      DATE,
  "CCCD"          VARCHAR2(12),
  "SỐNHÀ"         NVARCHAR2(20),
  "TÊNĐƯỜNG"      NVARCHAR2(100),
  "QUẬNHUYỆN"     NVARCHAR2(50),
  "TỈNHTP"        NVARCHAR2(50),
  "TIỀNSỬBỆNH"    NCLOB,
  "TIỀNSỬBỆNHGĐ"  NCLOB,
  "DỊỨNGTHUỐC"    NVARCHAR2(500),
  "ORAUSER"       VARCHAR2(100),
  CONSTRAINT PK_BENHNHAN    PRIMARY KEY ("MÃBN"),
  CONSTRAINT UQ_BN_CCCD     UNIQUE ("CCCD"),
  CONSTRAINT UQ_BN_ORAUSER  UNIQUE ("ORAUSER"),
  CONSTRAINT CHK_BN_PHAI    CHECK ("PHÁI" IN (N'Nam', N'Nữ', N'Khác'))
);

COMMENT ON TABLE  "BỆNHNHÂN"                IS N'Thông tin hồ sơ bệnh nhân';
COMMENT ON COLUMN "BỆNHNHÂN"."MÃBN"         IS N'Mã định danh bệnh nhân (vd: BN001)';
COMMENT ON COLUMN "BỆNHNHÂN"."ORAUSER"      IS N'Tài khoản Oracle tương ứng với bệnh nhân';
COMMENT ON COLUMN "BỆNHNHÂN"."TIỀNSỬBỆNH"   IS N'Tiền sử bệnh cá nhân';
COMMENT ON COLUMN "BỆNHNHÂN"."TIỀNSỬBỆNHGĐ" IS N'Tiền sử bệnh gia đình';

-- =====================================================================
-- BẢNG 2: NHÂNVIÊN
-- Lưu thông tin nhân viên: Điều phối viên, Bác sĩ/Y sĩ, Kỹ thuật viên
-- =====================================================================
CREATE TABLE "NHÂNVIÊN" (
  "MÃNV"       VARCHAR2(10)   NOT NULL,
  "HỌTÊN"      NVARCHAR2(100) NOT NULL,
  "PHÁI"       NVARCHAR2(10),
  "NGÀYSINH"   DATE,
  "CMND"       VARCHAR2(12),
  "QUÊQUÁN"    NVARCHAR2(200),
  "SỐĐt"       VARCHAR2(15),
  "VAITRÒ"     NVARCHAR2(30)  NOT NULL,
  "CHUYÊNKHOA" NVARCHAR2(100),
  "ORAUSER"    VARCHAR2(100),
  CONSTRAINT PK_NHANVIEN   PRIMARY KEY ("MÃNV"),
  CONSTRAINT UQ_NV_CMND    UNIQUE ("CMND"),
  CONSTRAINT UQ_NV_ORAUSER UNIQUE ("ORAUSER"),
  CONSTRAINT CHK_NV_VAITRO CHECK ("VAITRÒ" IN (N'Điều phối viên', N'Bác sĩ/Y sĩ', N'Kỹ thuật viên')),
  CONSTRAINT CHK_NV_PHAI   CHECK ("PHÁI" IN (N'Nam', N'Nữ', N'Khác'))
);

COMMENT ON TABLE  "NHÂNVIÊN"           IS N'Thông tin nhân viên bệnh viện';
COMMENT ON COLUMN "NHÂNVIÊN"."VAITRÒ"  IS N'Vai trò: Điều phối viên, Bác sĩ/Y sĩ, Kỹ thuật viên';
COMMENT ON COLUMN "NHÂNVIÊN"."ORAUSER" IS N'Tài khoản Oracle tương ứng với nhân viên';

-- =====================================================================
-- BẢNG 3: HSBA (Hồ sơ bệnh án)
-- Mỗi HSBA thuộc 1 bệnh nhân và được phụ trách bởi 1 bác sĩ
-- =====================================================================
CREATE TABLE "HSBA" (
  "MÃHSBA"   VARCHAR2(15)  NOT NULL,
  "MÃBN"     VARCHAR2(10)  NOT NULL,
  "NGÀY"     DATE          DEFAULT SYSDATE,
  "CHẨNĐOÁN" NCLOB,
  "ĐIỀUTRỊ"  NCLOB,
  "MÃBS"     VARCHAR2(10),
  "MÃKHOA"   NVARCHAR2(50),
  "KẾTLUẬN"  NCLOB,
  CONSTRAINT PK_HSBA    PRIMARY KEY ("MÃHSBA"),
  CONSTRAINT FK_HSBA_BN FOREIGN KEY ("MÃBN")
      REFERENCES "BỆNHNHÂN" ("MÃBN") ON DELETE CASCADE,
  CONSTRAINT FK_HSBA_BS FOREIGN KEY ("MÃBS")
      REFERENCES "NHÂNVIÊN" ("MÃNV")
);

COMMENT ON TABLE  "HSBA"          IS N'Hồ sơ bệnh án';
COMMENT ON COLUMN "HSBA"."MÃHSBA" IS N'Mã hồ sơ bệnh án (vd: HSBA001)';
COMMENT ON COLUMN "HSBA"."MÃBS"   IS N'Mã bác sĩ phụ trách hồ sơ';
COMMENT ON COLUMN "HSBA"."MÃKHOA" IS N'Khoa điều trị';

-- =====================================================================
-- BẢNG 4: HSBA_DV (Dịch vụ trong hồ sơ bệnh án)
-- Khóa chính composite: MÃHSBA + LOẠIDV + NGÀYDV
-- =====================================================================
CREATE TABLE "HSBA_DV" (
  "MÃHSBA"  VARCHAR2(15)   NOT NULL,
  "LOẠIDV"  NVARCHAR2(100) NOT NULL,
  "NGÀYDV"  DATE           NOT NULL,
  "MÃKTV"   VARCHAR2(10),
  "KẾTQUẢ"  NCLOB,
  CONSTRAINT PK_HSBA_DV   PRIMARY KEY ("MÃHSBA", "LOẠIDV", "NGÀYDV"),
  CONSTRAINT FK_HSBADV_HS FOREIGN KEY ("MÃHSBA")
      REFERENCES "HSBA" ("MÃHSBA") ON DELETE CASCADE,
  CONSTRAINT FK_HSBADV_KT FOREIGN KEY ("MÃKTV")
      REFERENCES "NHÂNVIÊN" ("MÃNV")
);

COMMENT ON TABLE  "HSBA_DV"          IS N'Dịch vụ kỹ thuật trong hồ sơ bệnh án';
COMMENT ON COLUMN "HSBA_DV"."LOẠIDV" IS N'Loại dịch vụ kỹ thuật (xét nghiệm, chụp chiếu...)';
COMMENT ON COLUMN "HSBA_DV"."MÃKTV"  IS N'Mã kỹ thuật viên thực hiện';

-- =====================================================================
-- BẢNG 5: ĐƠNTHUỐC
-- Khóa chính composite: MÃHSBA + NGÀYĐT + TÊNTHUỐC
-- =====================================================================
CREATE TABLE "ĐƠNTHUỐC" (
  "MÃHSBA"   VARCHAR2(15)   NOT NULL,
  "NGÀYĐT"   DATE           NOT NULL,
  "TÊNTHUỐC" NVARCHAR2(200) NOT NULL,
  "LIỀUDÙNG" NVARCHAR2(500),
  CONSTRAINT PK_DONTHUOC PRIMARY KEY ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC"),
  CONSTRAINT FK_DT_HSBA  FOREIGN KEY ("MÃHSBA")
      REFERENCES "HSBA" ("MÃHSBA") ON DELETE CASCADE
);

COMMENT ON TABLE  "ĐƠNTHUỐC"            IS N'Đơn thuốc kê trong hồ sơ bệnh án';
COMMENT ON COLUMN "ĐƠNTHUỐC"."TÊNTHUỐC" IS N'Tên thuốc được kê';
COMMENT ON COLUMN "ĐƠNTHUỐC"."LIỀUDÙNG" IS N'Liều dùng và hướng dẫn sử dụng';

-- =====================================================================
-- BẢNG 6: THÔNGBÁO
-- MÃTB tự sinh bởi IDENTITY, dùng cho OLS demo
-- =====================================================================
CREATE TABLE "THÔNGBÁO" (
  "MÃTB"     NUMBER         GENERATED ALWAYS AS IDENTITY,
  "NỘIDUNG"  NCLOB,
  "NGÀYGIỜ"  TIMESTAMP      DEFAULT SYSTIMESTAMP,
  "ĐỊAĐIỂM"  NVARCHAR2(200),
  CONSTRAINT PK_THONGBAO PRIMARY KEY ("MÃTB")
);

COMMENT ON TABLE  "THÔNGBÁO"           IS N'Bảng thông báo nội bộ bệnh viện (dùng cho OLS demo)';
COMMENT ON COLUMN "THÔNGBÁO"."MÃTB"    IS N'Mã thông báo (tự sinh)';
COMMENT ON COLUMN "THÔNGBÁO"."NỘIDUNG" IS N'Nội dung thông báo';

-- =====================================================================
-- SEQUENCES - Sinh mã tự động
-- =====================================================================
-- Sequence cho MÃBN: BN001, BN002, ...
CREATE SEQUENCE SEQ_BENHNHAN
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Sequence cho MÃNV: NV001, NV002, ...
CREATE SEQUENCE SEQ_NHANVIEN
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Sequence cho MÃHSBA: HSBA001, HSBA002, ...
CREATE SEQUENCE SEQ_HSBA
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- =====================================================================
-- FUNCTIONS HỖ TRỢ SINH MÃ
-- =====================================================================

-- Hàm sinh MÃBN từ sequence
CREATE OR REPLACE FUNCTION FN_NEXT_MABN RETURN VARCHAR2 IS
  v_num NUMBER;
BEGIN
  SELECT SEQ_BENHNHAN.NEXTVAL INTO v_num FROM DUAL;
  RETURN 'BN' || LPAD(TO_CHAR(v_num), 3, '0');
END FN_NEXT_MABN;
/

-- Hàm sinh MÃNV từ sequence
CREATE OR REPLACE FUNCTION FN_NEXT_MANV RETURN VARCHAR2 IS
  v_num NUMBER;
BEGIN
  SELECT SEQ_NHANVIEN.NEXTVAL INTO v_num FROM DUAL;
  RETURN 'NV' || LPAD(TO_CHAR(v_num), 3, '0');
END FN_NEXT_MANV;
/

-- Hàm sinh MÃHSBA từ sequence
CREATE OR REPLACE FUNCTION FN_NEXT_MAHSBA RETURN VARCHAR2 IS
  v_num NUMBER;
BEGIN
  SELECT SEQ_HSBA.NEXTVAL INTO v_num FROM DUAL;
  RETURN 'HSBA' || LPAD(TO_CHAR(v_num), 3, '0');
END FN_NEXT_MAHSBA;
/

COMMIT;

-- Kiểm tra kết quả
-- PROMPT --- Danh sách bảng đã tạo ---
SELECT TABLE_NAME, NUM_ROWS
FROM USER_TABLES
WHERE TABLE_NAME IN ('BỆNHNHÂN','NHÂNVIÊN','HSBA','HSBA_DV','ĐƠNTHUỐC','THÔNGBÁO')
ORDER BY TABLE_NAME;

-- PROMPT --- Danh sách sequences đã tạo ---
SELECT SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, LAST_NUMBER
FROM USER_SEQUENCES
WHERE SEQUENCE_NAME IN ('SEQ_BENHNHAN','SEQ_NHANVIEN','SEQ_HSBA');

-- PROMPT === 01_schema.sql completed successfully ===
