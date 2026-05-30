-- ============================================
-- SCRIPT: 05_audit_triggers.sql
-- MÔ TẢ: Triggers ghi vết (audit trail)
-- Chạy bằng: QLBV (schema owner)
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED

-- ============================================
-- 1. TRG_AUDIT_HSBA
--    Bảng: HSBA
--    Sự kiện: BEFORE UPDATE, FOR EACH ROW
--    Giám sát: CHANDOAN, DIEUTRI, KETLUAN
--    Yêu cầu: TC#3c – Ghi vết thay đổi hồ sơ bệnh án
-- ============================================
CREATE OR REPLACE TRIGGER QLBV.TRG_AUDIT_HSBA
BEFORE UPDATE ON QLBV.HSBA
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    -- Kiểm tra thay đổi cột CHANDOAN
    IF NVL(:OLD.CHANDOAN, N'(null)') != NVL(:NEW.CHANDOAN, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'HSBA', 'UPDATE', 'CHANDOAN', :OLD.CHANDOAN, :NEW.CHANDOAN);
    END IF;

    -- Kiểm tra thay đổi cột DIEUTRI
    IF NVL(:OLD.DIEUTRI, N'(null)') != NVL(:NEW.DIEUTRI, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'HSBA', 'UPDATE', 'DIEUTRI', :OLD.DIEUTRI, :NEW.DIEUTRI);
    END IF;

    -- Kiểm tra thay đổi cột KETLUAN
    IF NVL(:OLD.KETLUAN, N'(null)') != NVL(:NEW.KETLUAN, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'HSBA', 'UPDATE', 'KETLUAN', :OLD.KETLUAN, :NEW.KETLUAN);
    END IF;
END;
/

PROMPT >> Trigger TRG_AUDIT_HSBA đã được tạo.

-- ============================================
-- 2. TRG_AUDIT_DONTHUOC
--    Bảng: DONTHUOC
--    Sự kiện: BEFORE UPDATE, FOR EACH ROW
--    Giám sát: TENTHUOC, LIEUDUNG
--    Yêu cầu: TC#3e – Ghi vết thay đổi đơn thuốc
-- ============================================
CREATE OR REPLACE TRIGGER QLBV.TRG_AUDIT_DONTHUOC
BEFORE UPDATE ON QLBV.DONTHUOC
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    -- Kiểm tra thay đổi cột TENTHUOC
    IF NVL(:OLD.TENTHUOC, N'(null)') != NVL(:NEW.TENTHUOC, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'DONTHUOC', 'UPDATE', 'TENTHUOC', :OLD.TENTHUOC, :NEW.TENTHUOC);
    END IF;

    -- Kiểm tra thay đổi cột LIEUDUNG
    IF NVL(:OLD.LIEUDUNG, N'(null)') != NVL(:NEW.LIEUDUNG, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'DONTHUOC', 'UPDATE', 'LIEUDUNG', :OLD.LIEUDUNG, :NEW.LIEUDUNG);
    END IF;
END;
/

PROMPT >> Trigger TRG_AUDIT_DONTHUOC đã được tạo.

-- ============================================
-- 3. TRG_AUDIT_HSBA_DV
--    Bảng: HSBA_DV
--    Sự kiện: BEFORE UPDATE, FOR EACH ROW
--    Giám sát: KETQUA
--    Yêu cầu: TC#4 – Ghi vết thay đổi kết quả dịch vụ
-- ============================================
CREATE OR REPLACE TRIGGER QLBV.TRG_AUDIT_HSBA_DV
BEFORE UPDATE ON QLBV.HSBA_DV
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    -- Kiểm tra thay đổi cột KETQUA
    IF NVL(:OLD.KETQUA, N'(null)') != NVL(:NEW.KETQUA, N'(null)') THEN
        INSERT INTO QLBV.AUDIT_LOG (TAIKHOAN, BANG, HANH_VI, TRUONG, GIA_TRI_CU, GIA_TRI_MOI)
        VALUES (v_user, 'HSBA_DV', 'UPDATE', 'KETQUA', :OLD.KETQUA, :NEW.KETQUA);
    END IF;
END;
/

PROMPT >> Trigger TRG_AUDIT_HSBA_DV đã được tạo.

-- ============================================
-- KIỂM TRA: Xác nhận tất cả trigger đã được tạo
-- ============================================
PROMPT
PROMPT >> Danh sách trigger audit đã tạo:
SELECT trigger_name, table_name, status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_AUDIT%'
ORDER BY trigger_name;

-- ============================================
-- HƯỚNG DẪN KIỂM THỬ
-- ============================================
-- Test 1: Cập nhật chẩn đoán trong HSBA
--   UPDATE QLBV.HSBA SET CHANDOAN = N'Test chẩn đoán' WHERE MAHSBA = 'HSBA00001';
--   SELECT * FROM QLBV.AUDIT_LOG ORDER BY MA_LOG DESC;
--
-- Test 2: Cập nhật đơn thuốc
--   UPDATE QLBV.DONTHUOC SET TENTHUOC = N'Paracetamol 500mg' WHERE ROWNUM = 1;
--   SELECT * FROM QLBV.AUDIT_LOG ORDER BY MA_LOG DESC;
--
-- Test 3: Cập nhật kết quả dịch vụ
--   UPDATE QLBV.HSBA_DV SET KETQUA = N'Bình thường' WHERE ROWNUM = 1;
--   SELECT * FROM QLBV.AUDIT_LOG ORDER BY MA_LOG DESC;
-- ============================================

PROMPT
PROMPT >> Script 05_audit_triggers.sql hoàn tất.
