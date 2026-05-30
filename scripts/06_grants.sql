-- ============================================
-- SCRIPT: 06_grants.sql
-- MÔ TẢ: Cấp quyền truy cập cho các nhóm user
-- Chạy bằng: QLBV (schema owner)
-- ============================================

SET SERVEROUTPUT ON SIZE UNLIMITED

-- ============================================
-- 1. CẤP QUYỀN CHO ĐIỀU PHỐI VIÊN (NV_DPV01 .. NV_DPV20)
--    Vai trò: Tiếp nhận bệnh nhân, phân bổ bác sĩ/khoa
-- ============================================
PROMPT >> Cấp quyền cho Điều phối viên (NV_DPV01..NV_DPV20)...

BEGIN
    FOR i IN 1..20 LOOP
        DECLARE
            v_user VARCHAR2(30) := 'NV_DPV' || LPAD(i, 2, '0');
        BEGIN
            -- Quyền trên bảng BENHNHAN: xem, thêm, sửa thông tin bệnh nhân
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON QLBV.BENHNHAN TO ' || v_user;

            -- Quyền trên bảng HSBA: xem, thêm hồ sơ bệnh án
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON QLBV.HSBA TO ' || v_user;
            -- Chỉ cho phép cập nhật khoa và bác sĩ phụ trách
            EXECUTE IMMEDIATE 'GRANT UPDATE (MAKHOA, MABS) ON QLBV.HSBA TO ' || v_user;

            -- Quyền trên bảng HSBA_DV: xem dịch vụ
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.HSBA_DV TO ' || v_user;
            -- Chỉ cho phép phân công kỹ thuật viên
            EXECUTE IMMEDIATE 'GRANT UPDATE (MAKTV) ON QLBV.HSBA_DV TO ' || v_user;

            -- Quyền trên bảng NHANVIEN: xem thông tin nhân viên
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.NHANVIEN TO ' || v_user;
            -- Chỉ cho phép cập nhật thông tin cá nhân của mình
            EXECUTE IMMEDIATE 'GRANT UPDATE (QUEQUAN, SODT) ON QLBV.NHANVIEN TO ' || v_user;

            -- Quyền xem bảng AUDIT_LOG (tùy chọn – để kiểm tra lịch sử)
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.AUDIT_LOG TO ' || v_user;

            DBMS_OUTPUT.PUT_LINE('  + Đã cấp quyền cho ' || v_user);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ! Lỗi cấp quyền cho ' || v_user || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT >> Hoàn tất cấp quyền Điều phối viên.
PROMPT

-- ============================================
-- 2. CẤP QUYỀN CHO BÁC SĨ / Y SĨ (NV_BS001 .. NV_BS100)
--    Vai trò: Khám bệnh, chẩn đoán, kê đơn
-- ============================================
PROMPT >> Cấp quyền cho Bác sĩ/Y sĩ (NV_BS001..NV_BS100)...

BEGIN
    FOR i IN 1..100 LOOP
        DECLARE
            v_user VARCHAR2(30) := 'NV_BS' || LPAD(i, 3, '0');
        BEGIN
            -- Quyền trên bảng HSBA: xem hồ sơ bệnh án
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.HSBA TO ' || v_user;
            -- Chỉ cho phép cập nhật chẩn đoán, điều trị, kết luận
            EXECUTE IMMEDIATE 'GRANT UPDATE (CHANDOAN, DIEUTRI, KETLUAN) ON QLBV.HSBA TO ' || v_user;

            -- Quyền trên bảng HSBA_DV: xem, thêm, xóa dịch vụ y tế
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE ON QLBV.HSBA_DV TO ' || v_user;

            -- Quyền trên bảng BENHNHAN: xem thông tin bệnh nhân
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.BENHNHAN TO ' || v_user;
            -- Cập nhật tiền sử bệnh, dị ứng thuốc
            EXECUTE IMMEDIATE 'GRANT UPDATE (TIENSUBNH, TIENSUBNHGD, DIUNGTH) ON QLBV.BENHNHAN TO ' || v_user;

            -- Quyền trên bảng DONTHUOC: toàn quyền CRUD đơn thuốc
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON QLBV.DONTHUOC TO ' || v_user;

            -- Quyền trên bảng NHANVIEN: xem thông tin nhân viên
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.NHANVIEN TO ' || v_user;
            -- Chỉ cho phép cập nhật thông tin cá nhân của mình
            EXECUTE IMMEDIATE 'GRANT UPDATE (QUEQUAN, SODT) ON QLBV.NHANVIEN TO ' || v_user;

            -- Quyền xem bảng AUDIT_LOG (tùy chọn)
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.AUDIT_LOG TO ' || v_user;

            DBMS_OUTPUT.PUT_LINE('  + Đã cấp quyền cho ' || v_user);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ! Lỗi cấp quyền cho ' || v_user || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT >> Hoàn tất cấp quyền Bác sĩ/Y sĩ.
PROMPT

-- ============================================
-- 3. CẤP QUYỀN CHO KỸ THUẬT VIÊN (NV_KTV01 .. NV_KTV50)
--    Vai trò: Thực hiện dịch vụ, cập nhật kết quả
-- ============================================
PROMPT >> Cấp quyền cho Kỹ thuật viên (NV_KTV01..NV_KTV50)...

BEGIN
    FOR i IN 1..50 LOOP
        DECLARE
            v_user VARCHAR2(30) := 'NV_KTV' || LPAD(i, 2, '0');
        BEGIN
            -- Quyền trên bảng HSBA_DV: xem dịch vụ được phân công
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.HSBA_DV TO ' || v_user;
            -- Chỉ cho phép cập nhật kết quả dịch vụ
            EXECUTE IMMEDIATE 'GRANT UPDATE (KETQUA) ON QLBV.HSBA_DV TO ' || v_user;

            -- Quyền trên bảng NHANVIEN: xem thông tin nhân viên
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.NHANVIEN TO ' || v_user;
            -- Chỉ cho phép cập nhật thông tin cá nhân của mình
            EXECUTE IMMEDIATE 'GRANT UPDATE (QUEQUAN, SODT) ON QLBV.NHANVIEN TO ' || v_user;

            -- Quyền xem bảng AUDIT_LOG (tùy chọn)
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.AUDIT_LOG TO ' || v_user;

            DBMS_OUTPUT.PUT_LINE('  + Đã cấp quyền cho ' || v_user);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ! Lỗi cấp quyền cho ' || v_user || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT >> Hoàn tất cấp quyền Kỹ thuật viên.
PROMPT

-- ============================================
-- 4. CẤP QUYỀN CHO BỆNH NHÂN (BN_00001 .. BN_00040)
--    Vai trò: Xem thông tin cá nhân, cập nhật địa chỉ
-- ============================================
PROMPT >> Cấp quyền cho Bệnh nhân (BN_00001..BN_00040)...

BEGIN
    FOR i IN 1..40 LOOP
        DECLARE
            v_user VARCHAR2(30) := 'BN_' || LPAD(i, 5, '0');
        BEGIN
            -- Quyền trên bảng BENHNHAN: xem thông tin cá nhân
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.BENHNHAN TO ' || v_user;
            -- Chỉ cho phép cập nhật địa chỉ (số nhà, đường, quận/huyện, tỉnh/TP)
            EXECUTE IMMEDIATE 'GRANT UPDATE (SONHA, TENDUONG, QUANHUYEN, TINHTP) ON QLBV.BENHNHAN TO ' || v_user;

            -- Quyền xem bảng AUDIT_LOG (tùy chọn)
            EXECUTE IMMEDIATE 'GRANT SELECT ON QLBV.AUDIT_LOG TO ' || v_user;

            DBMS_OUTPUT.PUT_LINE('  + Đã cấp quyền cho ' || v_user);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  ! Lỗi cấp quyền cho ' || v_user || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT >> Hoàn tất cấp quyền Bệnh nhân.
PROMPT

-- ============================================
-- KIỂM TRA: Xác nhận quyền đã được cấp
-- ============================================
PROMPT >> Tổng hợp quyền đã cấp:
SELECT grantee, table_name, privilege
FROM user_tab_privs_made
ORDER BY grantee, table_name, privilege;

PROMPT
PROMPT >> Script 06_grants.sql hoàn tất.
