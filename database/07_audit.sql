-- ==============================================================================
-- File: 07_audit.sql
-- Mô tả: TC#3 - Vận dụng cơ chế kiểm toán (Standard Audit & FGA)
-- ==============================================================================
SET DEFINE OFF;

-- BƯỚC 1: Kích hoạt Standard Audit (Yêu cầu DBA/SYS)
-- Ghi chú: Hệ thống có thể yêu cầu khởi động lại với thông số:
-- ALTER SYSTEM SET audit_trail=db,extended SCOPE=SPFILE;
-- SHUTDOWN IMMEDIATE;
-- STARTUP;

-- ==============================================================================
-- 2. Standard Audit: 5 ngữ cảnh tự chọn
-- ==============================================================================

-- a) Audit LOGIN failure (Theo dõi đăng nhập thất bại của tất cả người dùng)
AUDIT SESSION WHENEVER NOT SUCCESSFUL;

-- b) Audit DML (SELECT, INSERT, UPDATE) trên bảng NHÂNVIÊN bởi user bs001
-- (Theo dõi riêng một user cụ thể trên một đối tượng cụ thể)
AUDIT SELECT, INSERT, UPDATE ON "NHÂNVIÊN" BY bs001;

-- c) Audit DDL (CREATE TABLE, DROP TABLE) (Theo dõi thay đổi cấu trúc DB)
AUDIT TABLE;

-- d) Audit hành vi phân quyền (GRANT, REVOKE)
AUDIT GRANT PROCEDURE, GRANT TABLE;

-- e) Audit hành vi DELETE trên bảng BỆNHNHÂN (Theo dõi xóa dữ liệu quan trọng)
AUDIT DELETE ON "BỆNHNHÂN" BY ACCESS;


-- ==============================================================================
-- 3. Fine-Grained Audit (FGA) - 4 tình huống
-- ==============================================================================

BEGIN
    -- a) Hành vi cập nhật ĐƠNTHUỐC sau khi đã tạo (Update MÃHSBA, NGÀYĐT, TÊNTHUỐC, LIỀUDÙNG)
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'ĐƠNTHUỐC',
        policy_name     => 'AUD_FGA_DONTHUOC_UPDATE',
        audit_condition => NULL, -- Mọi dòng
        audit_column    => 'MÃHSBA, NGÀYĐT, TÊNTHUỐC, LIỀUDÙNG',
        statement_types => 'UPDATE',
        audit_trail     => DBMS_FGA.DB_EXTENDED
    );

    -- b) Hành vi UPDATE thành công trên CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN của HSBA bởi Y sĩ/Bác sĩ
    -- VPD đã giới hạn chỉ cập nhật được hồ sơ của mình, ta audit khi thao tác thành công
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA',
        policy_name     => 'AUD_FGA_HSBA_BACSI_UPDATE_SUCCESS',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') IN (SELECT "ORAUSER" FROM "NHÂNVIÊN" WHERE "VAITRÒ" = ''Bác sĩ/Y sĩ'')',
        audit_column    => 'CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN',
        statement_types => 'UPDATE',
        audit_trail     => DBMS_FGA.DB_EXTENDED
    );

    -- c) Hành vi cập nhật bất hợp pháp trên CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN của HSBA
    -- Tức là user cố gắng update nhưng bị lỗi (không đủ quyền, hoặc VPD chặn) -> Ta sẽ thiết lập FGA nhưng trên thực tế FGA chỉ bắt được nếu user có quyền truy cập dòng dữ liệu. 
    -- Nếu muốn bắt cả Unauthorized, ta có thể dùng Unified Audit. Ở đây dùng FGA để demo:
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA',
        policy_name     => 'AUD_FGA_HSBA_ILLEGAL_UPDATE',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') NOT IN (SELECT "ORAUSER" FROM "NHÂNVIÊN" WHERE "VAITRÒ" = ''Bác sĩ/Y sĩ'')',
        audit_column    => 'CHẨNĐOÁN, ĐIỀUTRỊ, KẾTLUẬN',
        statement_types => 'UPDATE',
        audit_trail     => DBMS_FGA.DB_EXTENDED
    );

    -- d) Hành vi thêm, xóa, sửa bất hợp pháp trên HSBA_DV
    -- (Ví dụ user KTV cố INSERT hoặc DELETE, hoặc user khác KTV cố UPDATE KẾTQUẢ)
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'HSBA_DV',
        policy_name     => 'AUD_FGA_HSBADV_ILLEGAL',
        audit_condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') NOT IN (SELECT "ORAUSER" FROM "NHÂNVIÊN" WHERE "VAITRÒ" IN (''Bác sĩ/Y sĩ'', ''Điều phối viên''))',
        audit_column    => NULL,
        statement_types => 'INSERT, DELETE',
        audit_trail     => DBMS_FGA.DB_EXTENDED
    );
END;
/

-- ==============================================================================
-- 4. Xem dữ liệu kiểm toán (Ví dụ các câu Query để báo cáo)
-- ==============================================================================

-- Xem Standard Audit Trail
-- SELECT USERNAME, ACTION_NAME, OBJ_NAME, TIMESTAMP, RETURNCODE FROM DBA_AUDIT_TRAIL ORDER BY TIMESTAMP DESC;

-- Xem Fine-Grained Audit Trail
-- SELECT DB_USER, OBJECT_NAME, POLICY_NAME, SQL_TEXT, TIMESTAMP FROM DBA_FGA_AUDIT_TRAIL ORDER BY TIMESTAMP DESC;

COMMIT;
