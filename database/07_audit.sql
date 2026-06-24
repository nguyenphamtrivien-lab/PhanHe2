-- ==============================================================================
-- File: 07_audit.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Mô tả: Yêu cầu 3 - Vận dụng cơ chế kiểm toán
--        Standard Audit (5 ngữ cảnh) + FGA (4 tình huống) + Unified Audit
-- Chạy với quyền: SYS / SYSDBA
-- ==============================================================================
-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- ==============================================================================
-- BƯỚC 1: KÍCH HOẠT KIỂM TOÁN HỆ THỐNG
-- ==============================================================================
-- Kiểm tra trạng thái hiện tại
SELECT VALUE FROM V$PARAMETER WHERE NAME = 'audit_trail';

-- Nếu audit_trail chưa bật (giá trị = NONE), chạy lệnh sau với SYSDBA rồi restart:
--   ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE = SPFILE;
--   SHUTDOWN IMMEDIATE;
--   STARTUP;
-- Oracle 21c XE thường bật sẵn audit_trail=DB và Unified Audit mặc định.

-- ==============================================================================
-- DỌN DẸP AUDIT CŨ (chạy an toàn, không lỗi nếu chưa tồn tại)
-- ==============================================================================
BEGIN DBMS_FGA.DROP_POLICY('SYSTEM', 'ĐƠNTHUỐC', 'AUD_FGA_DONTHUOC_UPDATE');      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN DBMS_FGA.DROP_POLICY('SYSTEM', 'HSBA',     'AUD_FGA_HSBA_BACSI_UPDATE_SUCCESS'); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN DBMS_FGA.DROP_POLICY('SYSTEM', 'HSBA',     'AUD_FGA_HSBA_BACSI_UPDATE');     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN DBMS_FGA.DROP_POLICY('SYSTEM', 'HSBA',     'AUD_FGA_HSBA_ILLEGAL_UPDATE');   EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN DBMS_FGA.DROP_POLICY('SYSTEM', 'HSBA_DV',  'AUD_FGA_HSBADV_ILLEGAL');        EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'NOAUDIT POLICY AUD_UA_HSBA_ILLEGAL_UPDATE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP AUDIT POLICY AUD_UA_HSBA_ILLEGAL_UPDATE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'NOAUDIT POLICY AUD_UA_HSBADV_ILLEGAL'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP AUDIT POLICY AUD_UA_HSBADV_ILLEGAL'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

NOAUDIT SESSION WHENEVER NOT SUCCESSFUL;
NOAUDIT SELECT, INSERT, UPDATE ON SYSTEM."NHÂNVIÊN";
NOAUDIT TABLE;
NOAUDIT GRANT PROCEDURE, GRANT TABLE;
NOAUDIT DELETE ON SYSTEM."BỆNHNHÂN";


-- ==============================================================================
-- BƯỚC 2: STANDARD AUDIT - 5 NGỮ CẢNH TỰ CHỌN
-- Ghi vào: DBA_AUDIT_TRAIL
-- WHENEVER NOT SUCCESSFUL : chỉ ghi khi thất bại
-- WHENEVER SUCCESSFUL     : chỉ ghi khi thành công
-- BY ACCESS               : ghi mỗi lần truy cập (không gộp)
-- ==============================================================================

-- Ngữ cảnh 1: Đăng nhập thất bại của tất cả người dùng
-- Mục đích: Phát hiện tấn công brute-force hoặc tài khoản bị lộ mật khẩu
AUDIT SESSION WHENEVER NOT SUCCESSFUL;

-- Ngữ cảnh 2: SELECT, INSERT, UPDATE trên NHÂNVIÊN bởi bs001
-- Mục đích: Giám sát bác sĩ cụ thể khi truy cập dữ liệu nhân sự
AUDIT SELECT, INSERT, UPDATE ON SYSTEM."NHÂNVIÊN" BY bs001 WHENEVER SUCCESSFUL;

-- Ngữ cảnh 3: CREATE TABLE, DROP TABLE (thay đổi cấu trúc CSDL)
-- Mục đích: Phát hiện tạo/xóa bảng trái phép trong hệ thống y tế
AUDIT TABLE BY ACCESS;

-- Ngữ cảnh 4: GRANT quyền trên TABLE và PROCEDURE
-- Mục đích: Kiểm soát mọi thay đổi phân quyền, tránh leo thang đặc quyền
AUDIT GRANT PROCEDURE, GRANT TABLE BY ACCESS;

-- Ngữ cảnh 5: DELETE trên bảng BỆNHNHÂN
-- Mục đích: Bảo vệ hồ sơ bệnh nhân, ghi nhận mọi thao tác xóa dữ liệu quan trọng
AUDIT DELETE ON SYSTEM."BỆNHNHÂN" BY ACCESS;

COMMIT;
-- PROMPT >> [OK] Standard Audit 5 ngu canh da thiet lap.


-- ==============================================================================
-- BƯỚC 3: FINE-GRAINED AUDIT (FGA) - 4 TÌNH HUỐNG THEO ĐỀ
-- Ghi vào: DBA_FGA_AUDIT_TRAIL
-- Lưu ý: FGA chỉ kích hoạt khi câu lệnh được Oracle chấp nhận (không lỗi ORA-
-- 00942 hay ORA-01031). Trường hợp bị chặn hoàn toàn → Unified Audit (Bước 4).
-- ==============================================================================
BEGIN

    -- Tình huống a: Bác sĩ/y sĩ cập nhật ĐƠNTHUỐC sau khi đã tạo xong
    -- Theo dõi UPDATE trên tất cả các cột quan trọng của ĐƠNTHUỐC
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'ĐƠNTHUỐC',
        policy_name     => 'AUD_FGA_DONTHUOC_UPDATE',
        audit_condition => NULL,
        audit_column    => '"MÃHSBA","NGÀYĐT","TÊNTHUỐC","LIỀUDÙNG"',
        statement_types => 'UPDATE',
        enable          => TRUE,
        audit_trail     => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
    DBMS_OUTPUT.PUT_LINE('[OK] FGA a: AUD_FGA_DONTHUOC_UPDATE');

    -- Tình huống b: Bác sĩ/y sĩ cập nhật THÀNH CÔNG CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN
    -- Điều kiện: SESSION_USER phải là ORAUSER của Bác sĩ/Y sĩ trong NHÂNVIÊN
    -- VPD giới hạn bác sĩ chỉ thấy HSBA của mình → FGA ghi lại thao tác hợp lệ
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA',
        policy_name     => 'AUD_FGA_HSBA_BACSI_UPDATE',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') IN ' ||
                           '(SELECT "ORAUSER" FROM "NHÂNVIÊN" ' ||
                           ' WHERE "VAITRÒ" = ''Bác sĩ/Y sĩ'')',
        audit_column    => '"CHẨNĐOÁN","ĐIỀUTRỊ","KẾTLUẬN"',
        statement_types => 'UPDATE',
        enable          => TRUE,
        audit_trail     => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
    DBMS_OUTPUT.PUT_LINE('[OK] FGA b: AUD_FGA_HSBA_BACSI_UPDATE');

    -- Tình huống c: Cập nhật BẤT HỢP PHÁP CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN
    -- Bắt khi user không phải Bác sĩ/Y sĩ nhưng có quyền SELECT trên HSBA và cố UPDATE
    -- Kết hợp Unified Audit (Bước 4) để bắt thêm trường hợp bị từ chối hoàn toàn
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA',
        policy_name     => 'AUD_FGA_HSBA_ILLEGAL_UPDATE',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') NOT IN ' ||
                           '(SELECT "ORAUSER" FROM "NHÂNVIÊN" ' ||
                           ' WHERE "VAITRÒ" = ''Bác sĩ/Y sĩ'') ' ||
                           'AND SYS_CONTEXT(''USERENV'',''SESSION_USER'') ' ||
                           'NOT IN (''SYS'',''SYSTEM'')',
        audit_column    => '"CHẨNĐOÁN","ĐIỀUTRỊ","KẾTLUẬN"',
        statement_types => 'UPDATE',
        enable          => TRUE,
        audit_trail     => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
    DBMS_OUTPUT.PUT_LINE('[OK] FGA c: AUD_FGA_HSBA_ILLEGAL_UPDATE');

    -- Tình huống d: Thêm, xóa BẤT HỢP PHÁP trên HSBA_DV
    -- Chỉ Bác sĩ/Y sĩ và Điều phối viên được INSERT/DELETE HSBA_DV
    -- FGA bắt khi KTV, Bệnh nhân hoặc user khác cố thao tác (và vẫn tiếp cận được object)
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA_DV',
        policy_name     => 'AUD_FGA_HSBADV_ILLEGAL',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') NOT IN ' ||
                           '(SELECT "ORAUSER" FROM "NHÂNVIÊN" ' ||
                           ' WHERE "VAITRÒ" IN (''Bác sĩ/Y sĩ'',''Điều phối viên'')) ' ||
                           'AND SYS_CONTEXT(''USERENV'',''SESSION_USER'') ' ||
                           'NOT IN (''SYS'',''SYSTEM'')',
        audit_column    => NULL,
        statement_types => 'INSERT,DELETE',
        enable          => TRUE,
        audit_trail     => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
    DBMS_OUTPUT.PUT_LINE('[OK] FGA d: AUD_FGA_HSBADV_ILLEGAL');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Khong the tao FGA policy: ' || SQLERRM);
        RAISE;
END;
/

COMMIT;
-- PROMPT >> [OK] Fine-Grained Audit 4 tinh huong da thiet lap.


-- ==============================================================================
-- BƯỚC 4: UNIFIED AUDIT - BỔ SUNG TÌNH HUỐNG c, d (BỊ TỪ CHỐI DO THIẾU QUYỀN)
-- Unified Audit bắt được cả WHENEVER NOT SUCCESSFUL (ORA-00942, ORA-01031...)
-- Ghi vào: UNIFIED_AUDIT_TRAIL
-- ==============================================================================

-- Bổ sung tình huống c: UPDATE HSBA thất bại do thiếu quyền
CREATE OR REPLACE AUDIT POLICY AUD_UA_HSBA_ILLEGAL_UPDATE
    ACTIONS UPDATE ON SYSTEM."HSBA";
AUDIT POLICY AUD_UA_HSBA_ILLEGAL_UPDATE WHENEVER NOT SUCCESSFUL;

-- Bổ sung tình huống d: INSERT/DELETE HSBA_DV thất bại do thiếu quyền
CREATE OR REPLACE AUDIT POLICY AUD_UA_HSBADV_ILLEGAL
    ACTIONS INSERT ON SYSTEM."HSBA_DV",
            DELETE ON SYSTEM."HSBA_DV";
AUDIT POLICY AUD_UA_HSBADV_ILLEGAL WHENEVER NOT SUCCESSFUL;

COMMIT;
-- PROMPT >> [OK] Unified Audit bo sung tinh huong c, d da thiet lap.


-- ==============================================================================
-- BƯỚC 5: KỊCH BẢN TẠO DỮ LIỆU DEMO
-- Chạy từng khối bằng tài khoản tương ứng trong SQL*Plus / SQLcl
-- ==============================================================================

/*
-- Kịch bản 1 (Ngữ cảnh 1): Đăng nhập sai mật khẩu
-- Chạy ở terminal OS:
--   sqlplus bs001/SAI_MAT_KHAU@localhost:1521/XE
-- Kết quả: ORA-01017 → ghi vào DBA_AUDIT_TRAIL (RETURNCODE=1017, ACTION_NAME='LOGON')

-- Kịch bản 2 (Ngữ cảnh 2): bs001 truy vấn bảng NHÂNVIÊN
CONNECT bs001/Password123@localhost:1521/XE
SELECT * FROM SYSTEM."NHÂNVIÊN";
-- Kết quả: ghi vào DBA_AUDIT_TRAIL (ACTION_NAME='SELECT', OBJ_NAME='NHÂNVIÊN')

-- Kịch bản 3 (Tình huống b - FGA): Bác sĩ cập nhật CHẨNĐOÁN hợp lệ
CONNECT bs001/Password123@localhost:1521/XE
UPDATE SYSTEM."HSBA"
SET "CHẨNĐOÁN" = N'Viêm phổi cấp - đã xác nhận'
WHERE "MÃHSBA" = 'HS001';
COMMIT;
-- Kết quả: ghi vào DBA_FGA_AUDIT_TRAIL (POLICY_NAME='AUD_FGA_HSBA_BACSI_UPDATE')

-- Kịch bản 4 (Tình huống a - FGA): Bác sĩ chỉnh sửa ĐƠNTHUỐC sau khi tạo
CONNECT bs001/Password123@localhost:1521/XE
UPDATE SYSTEM."ĐƠNTHUỐC"
SET "LIỀUDÙNG" = N'2 viên/ngày sau ăn - điều chỉnh'
WHERE "MÃHSBA" = 'HS001' AND "TÊNTHUỐC" = N'Paracetamol';
COMMIT;
-- Kết quả: ghi vào DBA_FGA_AUDIT_TRAIL (POLICY_NAME='AUD_FGA_DONTHUOC_UPDATE')

-- Kịch bản 5 (Tình huống c - FGA + Unified): Điều phối viên cố cập nhật CHẨNĐOÁN
CONNECT dpv001/Password123@localhost:1521/XE
UPDATE SYSTEM."HSBA"
SET "CHẨNĐOÁN" = N'Illegal attempt by DPV'
WHERE "MÃHSBA" = 'HS001';
-- Nếu VPD chặn    → ghi vào UNIFIED_AUDIT_TRAIL (AUD_UA_HSBA_ILLEGAL_UPDATE, RETURN_CODE!=0)
-- Nếu VPD cho qua → ghi vào DBA_FGA_AUDIT_TRAIL (AUD_FGA_HSBA_ILLEGAL_UPDATE)

-- Kịch bản 6 (Tình huống d - FGA + Unified): KTV cố xóa dịch vụ
CONNECT ktv001/Password123@localhost:1521/XE
DELETE FROM SYSTEM."HSBA_DV" WHERE "MÃHSBA" = 'HS001';
-- Nếu không có quyền → ghi vào UNIFIED_AUDIT_TRAIL (AUD_UA_HSBADV_ILLEGAL, RETURN_CODE!=0)
-- Nếu có quyền đọc   → ghi vào DBA_FGA_AUDIT_TRAIL (AUD_FGA_HSBADV_ILLEGAL)

-- Kịch bản 7 (Ngữ cảnh 5): Xóa bệnh nhân (rollback sau để không mất dữ liệu)
CONNECT system/YourPassword@localhost:1521/XE
DELETE FROM SYSTEM."BỆNHNHÂN" WHERE "MÃBN" = 'BN099';
ROLLBACK;
-- Kết quả: ghi vào DBA_AUDIT_TRAIL (ACTION_NAME='DELETE', OBJ_NAME='BỆNHNHÂN')
*/


-- ==============================================================================
-- BƯỚC 6: ĐỌC XUẤT DỮ LIỆU KIỂM TOÁN
-- ==============================================================================

-- 6A. Toàn bộ Standard Audit Trail (50 bản ghi mới nhất)
SELECT
    USERNAME        AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    ACTION_NAME     AS "Hanh vi",
    OBJ_NAME        AS "Doi tuong",
    RETURNCODE      AS "Ma loi (0=OK)",
    USERHOST        AS "May tram"
FROM DBA_AUDIT_TRAIL
ORDER BY TIMESTAMP DESC
FETCH FIRST 50 ROWS ONLY;

-- 6B. Ngữ cảnh 1: Đăng nhập thất bại
SELECT
    USERNAME        AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    ACTION_NAME     AS "Hanh vi",
    RETURNCODE      AS "Ma loi",
    USERHOST        AS "May tram"
FROM DBA_AUDIT_TRAIL
WHERE ACTION_NAME = 'LOGON'
  AND RETURNCODE  != 0
ORDER BY TIMESTAMP DESC;

-- 6C. Ngữ cảnh 2: bs001 truy cập NHÂNVIÊN
SELECT
    USERNAME        AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    ACTION_NAME     AS "Hanh vi",
    OBJ_NAME        AS "Bang",
    RETURNCODE      AS "Ma loi (0=OK)"
FROM DBA_AUDIT_TRAIL
WHERE UPPER(USERNAME) = 'BS001'
  AND OBJ_NAME        = 'NHÂNVIÊN'
ORDER BY TIMESTAMP DESC;

-- 6D. Ngữ cảnh 5: DELETE trên BỆNHNHÂN
SELECT
    USERNAME        AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    ACTION_NAME     AS "Hanh vi",
    OBJ_NAME        AS "Bang",
    RETURNCODE      AS "Ma loi (0=OK)"
FROM DBA_AUDIT_TRAIL
WHERE ACTION_NAME = 'DELETE'
  AND OBJ_NAME    = 'BỆNHNHÂN'
ORDER BY TIMESTAMP DESC;

-- 6E. Toàn bộ FGA Audit Trail (50 bản ghi mới nhất)
SELECT
    DB_USER         AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    OBJECT_NAME     AS "Bang",
    POLICY_NAME     AS "FGA Policy",
    STATEMENT_TYPE  AS "Loai lenh",
    SQL_TEXT        AS "Cau SQL"
FROM DBA_FGA_AUDIT_TRAIL
ORDER BY TIMESTAMP DESC
FETCH FIRST 50 ROWS ONLY;

-- 6F. FGA Tình huống a: Cập nhật ĐƠNTHUỐC
SELECT
    DB_USER         AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    SQL_TEXT        AS "Cau SQL"
FROM DBA_FGA_AUDIT_TRAIL
WHERE POLICY_NAME = 'AUD_FGA_DONTHUOC_UPDATE'
ORDER BY TIMESTAMP DESC;

-- 6G. FGA Tình huống b: Bác sĩ cập nhật HSBA thành công
SELECT
    DB_USER         AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    SQL_TEXT        AS "Cau SQL"
FROM DBA_FGA_AUDIT_TRAIL
WHERE POLICY_NAME = 'AUD_FGA_HSBA_BACSI_UPDATE'
ORDER BY TIMESTAMP DESC;

-- 6H. FGA Tình huống c: Cập nhật bất hợp pháp HSBA
SELECT
    DB_USER         AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    SQL_TEXT        AS "Cau SQL bat hop phap"
FROM DBA_FGA_AUDIT_TRAIL
WHERE POLICY_NAME = 'AUD_FGA_HSBA_ILLEGAL_UPDATE'
ORDER BY TIMESTAMP DESC;

-- 6I. FGA Tình huống d: INSERT/DELETE bất hợp pháp HSBA_DV
SELECT
    DB_USER         AS "Nguoi dung",
    TO_CHAR(TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    STATEMENT_TYPE  AS "Loai lenh",
    SQL_TEXT        AS "Cau SQL bat hop phap"
FROM DBA_FGA_AUDIT_TRAIL
WHERE POLICY_NAME = 'AUD_FGA_HSBADV_ILLEGAL'
ORDER BY TIMESTAMP DESC;

-- 6J. Unified Audit: Thao tác thất bại do thiếu quyền (bổ sung c, d)
SELECT
    DBUSERNAME      AS "Nguoi dung",
    TO_CHAR(EVENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') AS "Thoi gian",
    ACTION_NAME     AS "Hanh vi",
    OBJECT_NAME     AS "Doi tuong",
    UNIFIED_AUDIT_POLICIES AS "Policy",
    RETURN_CODE     AS "Ma loi"
FROM UNIFIED_AUDIT_TRAIL
WHERE UNIFIED_AUDIT_POLICIES IN (
    'AUD_UA_HSBA_ILLEGAL_UPDATE',
    'AUD_UA_HSBADV_ILLEGAL'
)
ORDER BY EVENT_TIMESTAMP DESC;

-- PROMPT >> 07_audit.sql hoan tat.
