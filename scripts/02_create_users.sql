-- ============================================
-- SCRIPT: 02_create_users.sql  
-- MÔ TẢ: Tạo tài khoản Oracle & liên kết TC#1
-- Chạy bằng: DBA (SYS hoặc SYSTEM)
-- ============================================

-- ============================================
-- CHO PHÉP TẠO USER TRONG CDB (Oracle 21c)
-- ============================================
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- ============================================
-- 1. TẠO 20 ĐIỀU PHỐI VIÊN (NV_DPV01 → NV_DPV20)
-- ============================================
PROMPT Đang tạo 20 tài khoản Điều phối viên (NV_DPV01..NV_DPV20)...

BEGIN
    FOR i IN 1..20 LOOP
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER NV_DPV' || LPAD(i, 2, '0') ||
                              ' IDENTIFIED BY "Oracle#123"' ||
                              ' DEFAULT TABLESPACE USERS' ||
                              ' QUOTA UNLIMITED ON USERS';
            DBMS_OUTPUT.PUT_LINE('Đã tạo user NV_DPV' || LPAD(i, 2, '0'));
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -1920 THEN  -- ORA-01920: user name conflicts
                    DBMS_OUTPUT.PUT_LINE('User NV_DPV' || LPAD(i, 2, '0') || ' đã tồn tại - bỏ qua.');
                ELSE
                    RAISE;
                END IF;
        END;

        BEGIN
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO NV_DPV' || LPAD(i, 2, '0');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- ============================================
-- 2. TẠO 100 BÁC SĨ / Y SĨ (NV_BS001 → NV_BS100)
-- ============================================
PROMPT Đang tạo 100 tài khoản Bác sĩ/Y sĩ (NV_BS001..NV_BS100)...

BEGIN
    FOR i IN 1..100 LOOP
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER NV_BS' || LPAD(i, 3, '0') ||
                              ' IDENTIFIED BY "Oracle#123"' ||
                              ' DEFAULT TABLESPACE USERS' ||
                              ' QUOTA UNLIMITED ON USERS';
            DBMS_OUTPUT.PUT_LINE('Đã tạo user NV_BS' || LPAD(i, 3, '0'));
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -1920 THEN
                    DBMS_OUTPUT.PUT_LINE('User NV_BS' || LPAD(i, 3, '0') || ' đã tồn tại - bỏ qua.');
                ELSE
                    RAISE;
                END IF;
        END;

        BEGIN
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO NV_BS' || LPAD(i, 3, '0');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- ============================================
-- 3. TẠO 50 KỸ THUẬT VIÊN (NV_KTV01 → NV_KTV50)
-- ============================================
PROMPT Đang tạo 50 tài khoản Kỹ thuật viên (NV_KTV01..NV_KTV50)...

BEGIN
    FOR i IN 1..50 LOOP
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER NV_KTV' || LPAD(i, 2, '0') ||
                              ' IDENTIFIED BY "Oracle#123"' ||
                              ' DEFAULT TABLESPACE USERS' ||
                              ' QUOTA UNLIMITED ON USERS';
            DBMS_OUTPUT.PUT_LINE('Đã tạo user NV_KTV' || LPAD(i, 2, '0'));
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -1920 THEN
                    DBMS_OUTPUT.PUT_LINE('User NV_KTV' || LPAD(i, 2, '0') || ' đã tồn tại - bỏ qua.');
                ELSE
                    RAISE;
                END IF;
        END;

        BEGIN
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO NV_KTV' || LPAD(i, 2, '0');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- ============================================
-- 4. TẠO 40 BỆNH NHÂN (BN_00001 → BN_00040)
-- ============================================
PROMPT Đang tạo 40 tài khoản Bệnh nhân (BN_00001..BN_00040)...

BEGIN
    FOR i IN 1..40 LOOP
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER BN_' || LPAD(i, 5, '0') ||
                              ' IDENTIFIED BY "Oracle#123"' ||
                              ' DEFAULT TABLESPACE USERS' ||
                              ' QUOTA UNLIMITED ON USERS';
            DBMS_OUTPUT.PUT_LINE('Đã tạo user BN_' || LPAD(i, 5, '0'));
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -1920 THEN
                    DBMS_OUTPUT.PUT_LINE('User BN_' || LPAD(i, 5, '0') || ' đã tồn tại - bỏ qua.');
                ELSE
                    RAISE;
                END IF;
        END;

        BEGIN
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO BN_' || LPAD(i, 5, '0');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- ============================================
-- TẮT CHẾ ĐỘ ORACLE SCRIPT
-- ============================================
ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE;

-- ============================================
-- XÁC MINH TÀI KHOẢN ĐÃ TẠO
-- ============================================
PROMPT ;
PROMPT Danh sách tài khoản đã tạo:

SELECT username, account_status, created
FROM dba_users
WHERE username LIKE 'NV_%' OR username LIKE 'BN_%'
ORDER BY username;

PROMPT ;
PROMPT Thống kê số lượng tài khoản:

SELECT 
    CASE 
        WHEN username LIKE 'NV_DPV%' THEN 'Điều phối viên'
        WHEN username LIKE 'NV_BS%'  THEN 'Bác sĩ/Y sĩ'
        WHEN username LIKE 'NV_KTV%' THEN 'Kỹ thuật viên'
        WHEN username LIKE 'BN_%'    THEN 'Bệnh nhân'
    END AS loai_tai_khoan,
    COUNT(*) AS so_luong
FROM dba_users
WHERE username LIKE 'NV_%' OR username LIKE 'BN_%'
GROUP BY 
    CASE 
        WHEN username LIKE 'NV_DPV%' THEN 'Điều phối viên'
        WHEN username LIKE 'NV_BS%'  THEN 'Bác sĩ/Y sĩ'
        WHEN username LIKE 'NV_KTV%' THEN 'Kỹ thuật viên'
        WHEN username LIKE 'BN_%'    THEN 'Bệnh nhân'
    END
ORDER BY loai_tai_khoan;

-- Hoàn tất
PROMPT ;
PROMPT ================================================
PROMPT   TẠO TÀI KHOẢN ORACLE HOÀN TẤT!
PROMPT   Tổng cộng: 210 tài khoản
PROMPT   (20 DPV + 100 BS + 50 KTV + 40 BN)
PROMPT ================================================
