-- =====================================================================
-- File: 05_vpd.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: TC#2,3 - VPD (Virtual Private Database) Row-Level Security
--        + Trigger ghi vết thay đổi dữ liệu
-- Chạy với quyền: SYSDBA hoặc DBA (sau khi chạy 01,02,03,04)
-- Thứ tự chạy: 5/8
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- =====================================================================
-- BẢNG AUDIT_LOG: Ghi vết thay đổi dữ liệu nhạy cảm
-- =====================================================================
-- PROMPT --- Tạo bảng AUDIT_LOG ---

BEGIN EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE AUDIT_LOG (
  LOG_ID      NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  TABLE_NAME  VARCHAR2(100) NOT NULL,
  ACTION      VARCHAR2(20)  NOT NULL,
  COLUMN_NAME VARCHAR2(100),
  OLD_VAL     NCLOB,
  NEW_VAL     NCLOB,
  USER_NAME   VARCHAR2(100) NOT NULL,
  CHANGED_AT  TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
  SESSION_ID  NUMBER,
  OS_USER     VARCHAR2(100),
  HOST_NAME   VARCHAR2(200)
);

COMMENT ON TABLE  AUDIT_LOG              IS 'Ghi vết thay đổi dữ liệu nhạy cảm trong hệ thống';
COMMENT ON COLUMN AUDIT_LOG.TABLE_NAME   IS 'Tên bảng bị thay đổi';
COMMENT ON COLUMN AUDIT_LOG.ACTION       IS 'Loại thao tác: INSERT, UPDATE, DELETE';
COMMENT ON COLUMN AUDIT_LOG.COLUMN_NAME  IS 'Cột bị thay đổi (NULL nếu INSERT/DELETE)';
COMMENT ON COLUMN AUDIT_LOG.OLD_VAL      IS 'Giá trị trước khi thay đổi';
COMMENT ON COLUMN AUDIT_LOG.NEW_VAL      IS 'Giá trị sau khi thay đổi';
COMMENT ON COLUMN AUDIT_LOG.USER_NAME    IS 'Tên Oracle user thực hiện thay đổi';
COMMENT ON COLUMN AUDIT_LOG.SESSION_ID   IS 'Session ID Oracle';

-- Index để tìm kiếm nhanh
CREATE INDEX IDX_AUDITLOG_USER    ON AUDIT_LOG (USER_NAME, CHANGED_AT);
CREATE INDEX IDX_AUDITLOG_TABLE   ON AUDIT_LOG (TABLE_NAME, CHANGED_AT);
CREATE INDEX IDX_AUDITLOG_TIME    ON AUDIT_LOG (CHANGED_AT);

-- PROMPT --- Đã tạo bảng AUDIT_LOG ---

-- =====================================================================
-- PACKAGE VPD_BACSI_PKG: Chính sách VPD cho Bác sĩ
-- =====================================================================
-- Nguyên lý VPD (Virtual Private Database):
-- 1. Khi bác sĩ truy vấn bảng HSBA hoặc BỆNHNHÂN
-- 2. Oracle tự động thêm điều kiện WHERE vào câu SQL
-- 3. Bác sĩ chỉ thấy dữ liệu của bệnh nhân mình phụ trách
-- Điều này transparent với ứng dụng - không cần thay đổi SQL

CREATE OR REPLACE PACKAGE VPD_BACSI_PKG AS
  -- Policy cho bảng HSBA: bác sĩ chỉ thấy HSBA do mình phụ trách
  FUNCTION policy_hsba(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2;

  -- Policy cho bảng BỆNHNHÂN: bác sĩ chỉ thấy BN trong HSBA của mình
  FUNCTION policy_benhnhan(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2;

  -- Policy cho bảng ĐƠNTHUỐC: bác sĩ chỉ thấy đơn thuốc trong HSBA của mình
  FUNCTION policy_donthuoc(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2;
END VPD_BACSI_PKG;
/

CREATE OR REPLACE PACKAGE BODY VPD_BACSI_PKG AS

  -- -----------------------------------------------------------------------
  -- policy_hsba: Lọc HSBA theo MÃBS = mã của bác sĩ hiện tại
  -- Điều kiện WHERE được thêm tự động:
  --   "MÃBS" = (SELECT "MÃNV" FROM "NHÂNVIÊN"
  --              WHERE "ORAUSER" = SYS_CONTEXT('USERENV','SESSION_USER'))
  -- Nếu không phải bác sĩ (không tìm thấy MÃNV) → trả về rỗng (1=0)
  -- -----------------------------------------------------------------------
  FUNCTION policy_hsba(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_user      VARCHAR2(100);
    v_vaitro    NVARCHAR2(30);
    v_predicate VARCHAR2(4000);
  BEGIN
    -- Lấy user hiện tại
    v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- Kiểm tra vai trò của user (chỉ áp dụng policy nếu là Bác sĩ/Y sĩ)
    BEGIN
      SELECT "VAITRÒ" INTO v_vaitro
      FROM "NHÂNVIÊN"
      WHERE "ORAUSER" = v_user;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Không phải nhân viên hoặc không phải bác sĩ
        -- DBA/SYSTEM thấy tất cả
        IF v_user IN ('SYSTEM', 'SYS') THEN
          RETURN NULL; -- NULL = không lọc = thấy tất cả
        END IF;
        RETURN '1=0'; -- Không phải nhân viên → không thấy gì
    END;

    -- Nếu là Bác sĩ/Y sĩ → lọc theo MÃBS
    IF v_vaitro = N'Bác sĩ/Y sĩ' THEN
      v_predicate :=
        '"MÃBS" = (' ||
        '  SELECT "MÃNV" FROM "NHÂNVIÊN" ' ||
        '  WHERE "ORAUSER" = SYS_CONTEXT(''USERENV'',''SESSION_USER'')' ||
        ')';
      RETURN v_predicate;
    ELSIF v_vaitro = N'Điều phối viên' THEN
      RETURN NULL; -- Điều phối viên thấy tất cả HSBA (để phân công)
    ELSE
      RETURN '1=0'; -- Vai trò khác không thấy HSBA trực tiếp
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- An toàn: lỗi → không cho thấy gì
      RETURN '1=0';
  END policy_hsba;

  -- -----------------------------------------------------------------------
  -- policy_benhnhan: Bác sĩ chỉ thấy BN có HSBA do mình phụ trách
  -- Điều kiện WHERE:
  --   "MÃBN" IN (SELECT h."MÃBN" FROM "HSBA" h
  --               JOIN "NHÂNVIÊN" n ON n."MÃNV" = h."MÃBS"
  --               WHERE n."ORAUSER" = SYS_CONTEXT('USERENV','SESSION_USER'))
  -- -----------------------------------------------------------------------
  FUNCTION policy_benhnhan(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_user      VARCHAR2(100);
    v_vaitro    NVARCHAR2(30);
    v_predicate VARCHAR2(4000);
  BEGIN
    v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- DBA/SYSTEM thấy tất cả
    IF v_user IN ('SYSTEM', 'SYS') THEN
      RETURN NULL;
    END IF;

    BEGIN
      SELECT "VAITRÒ" INTO v_vaitro
      FROM "NHÂNVIÊN"
      WHERE "ORAUSER" = v_user;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Có thể là bệnh nhân → tự lọc theo ORAUSER
        v_predicate :=
          '"ORAUSER" = SYS_CONTEXT(''USERENV'',''SESSION_USER'')';
        RETURN v_predicate;
    END;

    IF v_vaitro = N'Bác sĩ/Y sĩ' THEN
      -- Bác sĩ thấy BN có HSBA do mình phụ trách
      v_predicate :=
        '"MÃBN" IN (' ||
        '  SELECT h."MÃBN" FROM "HSBA" h ' ||
        '  JOIN "NHÂNVIÊN" n ON n."MÃNV" = h."MÃBS" ' ||
        '  WHERE n."ORAUSER" = SYS_CONTEXT(''USERENV'',''SESSION_USER'')' ||
        ')';
      RETURN v_predicate;
    ELSIF v_vaitro = N'Điều phối viên' THEN
      RETURN NULL; -- Điều phối viên thấy tất cả BN
    ELSE
      RETURN '1=0';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '1=0';
  END policy_benhnhan;

  -- -----------------------------------------------------------------------
  -- policy_donthuoc: Bác sĩ chỉ thấy đơn thuốc trong HSBA của mình
  -- -----------------------------------------------------------------------
  FUNCTION policy_donthuoc(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_user      VARCHAR2(100);
    v_vaitro    NVARCHAR2(30);
    v_predicate VARCHAR2(4000);
  BEGIN
    v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

    IF v_user IN ('SYSTEM', 'SYS') THEN
      RETURN NULL;
    END IF;

    BEGIN
      SELECT "VAITRÒ" INTO v_vaitro
      FROM "NHÂNVIÊN"
      WHERE "ORAUSER" = v_user;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN '1=0';
    END;

    IF v_vaitro = N'Bác sĩ/Y sĩ' THEN
      v_predicate :=
        '"MÃHSBA" IN (' ||
        '  SELECT h."MÃHSBA" FROM "HSBA" h ' ||
        '  JOIN "NHÂNVIÊN" n ON n."MÃNV" = h."MÃBS" ' ||
        '  WHERE n."ORAUSER" = SYS_CONTEXT(''USERENV'',''SESSION_USER'')' ||
        ')';
      RETURN v_predicate;
    ELSIF v_vaitro = N'Điều phối viên' THEN
      RETURN NULL;
    ELSE
      RETURN '1=0';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '1=0';
  END policy_donthuoc;

END VPD_BACSI_PKG;
/

-- PROMPT --- Đã tạo VPD_BACSI_PKG ---

-- =====================================================================
-- PACKAGE VPD_DIEUPHOI_PKG: Chính sách VPD cho Điều phối viên
-- Điều phối viên thấy tất cả HSBA nhưng chỉ cập nhật được MÃKHOA, MÃBS
-- (quyền UPDATE cột đã được giới hạn bởi RBAC trong 04_rbac.sql)
-- =====================================================================
CREATE OR REPLACE PACKAGE VPD_DIEUPHOI_PKG AS
  FUNCTION policy_hsba_dpv(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2;
END VPD_DIEUPHOI_PKG;
/

CREATE OR REPLACE PACKAGE BODY VPD_DIEUPHOI_PKG AS

  -- Điều phối viên thấy tất cả HSBA (để phân công bác sĩ và KTV)
  -- Policy chủ yếu để audit và kiểm soát
  FUNCTION policy_hsba_dpv(
    schema_name IN VARCHAR2,
    table_name  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_user   VARCHAR2(100);
    v_vaitro NVARCHAR2(30);
  BEGIN
    v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

    IF v_user IN ('SYSTEM', 'SYS') THEN
      RETURN NULL;
    END IF;

    BEGIN
      SELECT "VAITRÒ" INTO v_vaitro
      FROM "NHÂNVIÊN"
      WHERE "ORAUSER" = v_user;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN '1=0'; -- Không phải nhân viên
    END;

    -- Điều phối viên thấy tất cả
    IF v_vaitro = N'Điều phối viên' THEN
      RETURN NULL;
    ELSE
      RETURN '1=0';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '1=0';
  END policy_hsba_dpv;

END VPD_DIEUPHOI_PKG;
/

-- PROMPT --- Đã tạo VPD_DIEUPHOI_PKG ---

-- =====================================================================
-- ÁP DỤNG VPD POLICIES
-- =====================================================================
-- PROMPT --- Áp dụng VPD Policies ---

-- Xóa policies cũ nếu tồn tại
BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'SYSTEM',
    object_name   => '"HSBA"',
    policy_name   => 'POL_BACSI_HSBA'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'SYSTEM',
    object_name   => '"BỆNHNHÂN"',
    policy_name   => 'POL_BACSI_BENHNHAN'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  DBMS_RLS.DROP_POLICY(
    object_schema => 'SYSTEM',
    object_name   => '"ĐƠNTHUỐC"',
    policy_name   => 'POL_BACSI_DONTHUOC'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Policy VPD cho bảng HSBA (áp dụng khi SELECT, INSERT, UPDATE, DELETE)
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'SYSTEM',
    object_name     => '"HSBA"',
    policy_name     => 'POL_BACSI_HSBA',
    function_schema => 'SYSTEM',
    policy_function => 'VPD_BACSI_PKG.policy_hsba',
    statement_types => 'SELECT,INSERT,UPDATE,DELETE',
    update_check    => TRUE,   -- Kiểm tra cả sau khi UPDATE
    enable          => TRUE
  );
END;
/

-- Policy VPD cho bảng BỆNHNHÂN
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'SYSTEM',
    object_name     => '"BỆNHNHÂN"',
    policy_name     => 'POL_BACSI_BENHNHAN',
    function_schema => 'SYSTEM',
    policy_function => 'VPD_BACSI_PKG.policy_benhnhan',
    statement_types => 'SELECT,UPDATE',
    update_check    => TRUE,
    enable          => TRUE
  );
END;
/

-- Policy VPD cho bảng ĐƠNTHUỐC
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'SYSTEM',
    object_name     => '"ĐƠNTHUỐC"',
    policy_name     => 'POL_BACSI_DONTHUOC',
    function_schema => 'SYSTEM',
    policy_function => 'VPD_BACSI_PKG.policy_donthuoc',
    statement_types => 'SELECT,INSERT,UPDATE,DELETE',
    update_check    => TRUE,
    enable          => TRUE
  );
END;
/

-- PROMPT --- Đã áp dụng 3 VPD policies ---

-- =====================================================================
-- TRIGGERS GHI VẾT (AUDIT TRIGGERS)
-- TC#3: Ghi lại mọi thay đổi dữ liệu nhạy cảm vào AUDIT_LOG
-- =====================================================================

-- -----------------------------------------------------------------------
-- TRG_AUDIT_HSBA: Ghi vết khi UPDATE CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN
-- -----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_AUDIT_HSBA
AFTER UPDATE OF "CHẨNĐOÁN", "ĐIỀUTRỊ", "KẾTLUẬN" ON "HSBA"
FOR EACH ROW
DECLARE
  v_user     VARCHAR2(100) := SYS_CONTEXT('USERENV', 'SESSION_USER');
  v_session  NUMBER        := TO_NUMBER(SYS_CONTEXT('USERENV', 'SESSIONID'));
  v_os_user  VARCHAR2(100) := SYS_CONTEXT('USERENV', 'OS_USER');
  v_host     VARCHAR2(200) := SYS_CONTEXT('USERENV', 'HOST');
BEGIN
  -- Ghi vết CHẨNĐOÁN nếu thay đổi
  IF :NEW."CHẨNĐOÁN" IS DISTINCT FROM :OLD."CHẨNĐOÁN" THEN
    INSERT INTO AUDIT_LOG (
      TABLE_NAME, ACTION, COLUMN_NAME, OLD_VAL, NEW_VAL,
      USER_NAME, CHANGED_AT, SESSION_ID, OS_USER, HOST_NAME
    ) VALUES (
      'HSBA', 'UPDATE', 'CHẨNĐOÁN',
      :OLD."CHẨNĐOÁN", :NEW."CHẨNĐOÁN",
      v_user, SYSTIMESTAMP, v_session, v_os_user, v_host
    );
  END IF;

  -- Ghi vết ĐIỀUTRỊ nếu thay đổi
  IF :NEW."ĐIỀUTRỊ" IS DISTINCT FROM :OLD."ĐIỀUTRỊ" THEN
    INSERT INTO AUDIT_LOG (
      TABLE_NAME, ACTION, COLUMN_NAME, OLD_VAL, NEW_VAL,
      USER_NAME, CHANGED_AT, SESSION_ID, OS_USER, HOST_NAME
    ) VALUES (
      'HSBA', 'UPDATE', 'ĐIỀUTRỊ',
      :OLD."ĐIỀUTRỊ", :NEW."ĐIỀUTRỊ",
      v_user, SYSTIMESTAMP, v_session, v_os_user, v_host
    );
  END IF;

  -- Ghi vết KẾTLUẬN nếu thay đổi
  IF :NEW."KẾTLUẬN" IS DISTINCT FROM :OLD."KẾTLUẬN" THEN
    INSERT INTO AUDIT_LOG (
      TABLE_NAME, ACTION, COLUMN_NAME, OLD_VAL, NEW_VAL,
      USER_NAME, CHANGED_AT, SESSION_ID, OS_USER, HOST_NAME
    ) VALUES (
      'HSBA', 'UPDATE', 'KẾTLUẬN',
      :OLD."KẾTLUẬN", :NEW."KẾTLUẬN",
      v_user, SYSTIMESTAMP, v_session, v_os_user, v_host
    );
  END IF;
END TRG_AUDIT_HSBA;
/

-- -----------------------------------------------------------------------
-- TRG_AUDIT_HSBA_DV: Ghi vết khi UPDATE KẾTQUẢ trong HSBA_DV
-- -----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_AUDIT_HSBA_DV
AFTER UPDATE OF "KẾTQUẢ" ON "HSBA_DV"
FOR EACH ROW
DECLARE
  v_user    VARCHAR2(100) := SYS_CONTEXT('USERENV', 'SESSION_USER');
  v_session NUMBER        := TO_NUMBER(SYS_CONTEXT('USERENV', 'SESSIONID'));
  v_os_user VARCHAR2(100) := SYS_CONTEXT('USERENV', 'OS_USER');
  v_host    VARCHAR2(200) := SYS_CONTEXT('USERENV', 'HOST');
BEGIN
  IF :NEW."KẾTQUẢ" IS DISTINCT FROM :OLD."KẾTQUẢ" THEN
    INSERT INTO AUDIT_LOG (
      TABLE_NAME, ACTION, COLUMN_NAME, OLD_VAL, NEW_VAL,
      USER_NAME, CHANGED_AT, SESSION_ID, OS_USER, HOST_NAME
    ) VALUES (
      'HSBA_DV', 'UPDATE', 'KẾTQUẢ (MÃHSBA=' || :OLD."MÃHSBA" ||
        ', LOẠIDV=' || :OLD."LOẠIDV" || ')',
      :OLD."KẾTQUẢ", :NEW."KẾTQUẢ",
      v_user, SYSTIMESTAMP, v_session, v_os_user, v_host
    );
  END IF;
END TRG_AUDIT_HSBA_DV;
/

-- -----------------------------------------------------------------------
-- TRG_AUDIT_DONTHUOC: Ghi vết INSERT, UPDATE, DELETE trên ĐƠNTHUỐC
-- -----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_AUDIT_DONTHUOC
AFTER INSERT OR UPDATE OF "TÊNTHUỐC", "LIỀUDÙNG" OR DELETE ON "ĐƠNTHUỐC"
FOR EACH ROW
DECLARE
  v_user    VARCHAR2(100) := SYS_CONTEXT('USERENV', 'SESSION_USER');
  v_session NUMBER        := TO_NUMBER(SYS_CONTEXT('USERENV', 'SESSIONID'));
  v_os_user VARCHAR2(100) := SYS_CONTEXT('USERENV', 'OS_USER');
  v_host    VARCHAR2(200) := SYS_CONTEXT('USERENV', 'HOST');
  v_action  VARCHAR2(20);
  v_old_val NCLOB;
  v_new_val NCLOB;
BEGIN
  IF INSERTING THEN
    v_action  := 'INSERT';
    v_old_val := NULL;
    v_new_val := N'MÃHSBA=' || :NEW."MÃHSBA" ||
                 N', NGÀYĐT=' || TO_CHAR(:NEW."NGÀYĐT", 'DD/MM/YYYY') ||
                 N', TÊNTHUỐC=' || :NEW."TÊNTHUỐC" ||
                 N', LIỀUDÙNG=' || :NEW."LIỀUDÙNG";
  ELSIF DELETING THEN
    v_action  := 'DELETE';
    v_old_val := N'MÃHSBA=' || :OLD."MÃHSBA" ||
                 N', NGÀYĐT=' || TO_CHAR(:OLD."NGÀYĐT", 'DD/MM/YYYY') ||
                 N', TÊNTHUỐC=' || :OLD."TÊNTHUỐC";
    v_new_val := NULL;
  ELSE
    v_action  := 'UPDATE';
    v_old_val := N'TÊNTHUỐC=' || :OLD."TÊNTHUỐC" ||
                 N', LIỀUDÙNG=' || :OLD."LIỀUDÙNG";
    v_new_val := N'TÊNTHUỐC=' || :NEW."TÊNTHUỐC" ||
                 N', LIỀUDÙNG=' || :NEW."LIỀUDÙNG";
  END IF;

  INSERT INTO AUDIT_LOG (
    TABLE_NAME, ACTION, COLUMN_NAME, OLD_VAL, NEW_VAL,
    USER_NAME, CHANGED_AT, SESSION_ID, OS_USER, HOST_NAME
  ) VALUES (
    'ĐƠNTHUỐC', v_action, 'TÊNTHUỐC/LIỀUDÙNG',
    v_old_val, v_new_val,
    v_user, SYSTIMESTAMP, v_session, v_os_user, v_host
  );
END TRG_AUDIT_DONTHUOC;
/

-- PROMPT --- Đã tạo 3 audit triggers ---

COMMIT;

-- =====================================================================
-- KIỂM TRA KẾT QUẢ
-- =====================================================================
-- PROMPT --- Kiểm tra VPD Policies đã áp dụng ---
SELECT
  OBJECT_OWNER,
  OBJECT_NAME,
  POLICY_NAME,
  FUNCTION,
  SEL,
  INS,
  UPD,
  DEL,
  ENABLE
FROM DBA_POLICIES
WHERE OBJECT_OWNER = 'SYSTEM'
  AND OBJECT_NAME IN ('"HSBA"', '"BỆNHNHÂN"', '"ĐƠNTHUỐC"')
ORDER BY OBJECT_NAME;

-- PROMPT --- Kiểm tra Triggers đã tạo ---
SELECT
  TRIGGER_NAME,
  TRIGGER_TYPE,
  TRIGGERING_EVENT,
  TABLE_NAME,
  STATUS
FROM USER_TRIGGERS
WHERE TRIGGER_NAME IN ('TRG_AUDIT_HSBA', 'TRG_AUDIT_HSBA_DV', 'TRG_AUDIT_DONTHUOC')
ORDER BY TRIGGER_NAME;

-- PROMPT --- Demo Test VPD: BS001 thấy bao nhiêu HSBA ---
-- PROMPT --- (Chạy lệnh này khi login là BS001) ---
-- PROMPT --- SELECT COUNT(*) FROM HSBA; ---

-- PROMPT === 05_vpd.sql completed successfully ===
