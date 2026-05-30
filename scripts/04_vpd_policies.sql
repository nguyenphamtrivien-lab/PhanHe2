-- ============================================
-- SCRIPT: 04_vpd_policies.sql
-- MÔ TẢ: Cài đặt VPD Policies (Yêu cầu 1 - Câu 3)
-- Chạy bằng: SYS AS SYSDBA (cho context + trigger)
--            sau đó QLBV (cho policy functions + DBMS_RLS)
-- Yêu cầu: GRANT EXECUTE ON DBMS_RLS TO QLBV;
--           GRANT CREATE ANY CONTEXT TO QLBV;
--           GRANT ADMINISTER DATABASE TRIGGER TO QLBV;
-- ============================================
-- Các vai trò:
--   TC#2: Điều phối viên (Dieu phoi vien) - Quản lý bệnh nhân & phân công
--   TC#3: Bác sĩ/Y sĩ (Bac si/Y si) - Khám chữa bệnh
--   TC#4: Kỹ thuật viên (Ky thuat vien) - Thực hiện dịch vụ
--   TC#5: Bệnh nhân (Benh nhan) - Xem/cập nhật thông tin cá nhân
--         Nhân viên - Xem/cập nhật thông tin cá nhân
-- ============================================

SET SERVEROUTPUT ON;

-- ============================================
-- BƯỚC 0: CẤP QUYỀN CẦN THIẾT (chạy bằng SYS)
-- ============================================
-- Uncomment và chạy bằng SYS nếu chưa cấp:
-- GRANT EXECUTE ON DBMS_RLS TO QLBV;
-- GRANT CREATE ANY CONTEXT TO QLBV;
-- GRANT ADMINISTER DATABASE TRIGGER TO QLBV;
-- GRANT EXECUTE ON DBMS_SESSION TO QLBV;

-- ============================================
-- BƯỚC 1: TẠO APPLICATION CONTEXT
-- Mục đích: Lưu thông tin phiên (MANV, VAITRO, MABN)
-- để các hàm VPD không phải truy vấn lại NHANVIEN
-- mỗi lần thực thi.
-- ============================================

---------------------------------------------
-- 1.1 Tạo Package quản lý context
---------------------------------------------
CREATE OR REPLACE PACKAGE QLBV.PKG_CTX_QLBV AS
    -- Thiết lập context khi user đăng nhập
    PROCEDURE SET_CONTEXT;
END PKG_CTX_QLBV;
/

CREATE OR REPLACE PACKAGE BODY QLBV.PKG_CTX_QLBV AS
    PROCEDURE SET_CONTEXT IS
        v_user   VARCHAR2(30);
        v_manv   VARCHAR2(20);
        v_vaitro NVARCHAR2(30);
        v_mabn   VARCHAR2(20);
    BEGIN
        -- Lấy username của phiên hiện tại
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');

        -- Bỏ qua các tài khoản quản trị (DBA)
        IF v_user IN ('SYS', 'SYSTEM', 'QLBV') THEN
            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'VAITRO', 'DBA');
            RETURN;
        END IF;

        -- Tìm trong bảng NHANVIEN (Nhân viên)
        BEGIN
            SELECT MANV, VAITRO
            INTO   v_manv, v_vaitro
            FROM   QLBV.NHANVIEN
            WHERE  TAIKHOAN = v_user;

            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'MANV', v_manv);
            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'VAITRO', v_vaitro);
            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'LOAI_USER', 'NHANVIEN');
            RETURN;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- Không phải nhân viên, tiếp tục tìm
        END;

        -- Tìm trong bảng BENHNHAN (Bệnh nhân)
        BEGIN
            SELECT MABN
            INTO   v_mabn
            FROM   QLBV.BENHNHAN
            WHERE  TAIKHOAN = v_user;

            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'MABN', v_mabn);
            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'VAITRO', 'Benh nhan');
            DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'LOAI_USER', 'BENHNHAN');
            RETURN;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- Không phải bệnh nhân
        END;

        -- User không xác định
        DBMS_SESSION.SET_CONTEXT('CTX_QLBV', 'VAITRO', 'UNKNOWN');
    END SET_CONTEXT;
END PKG_CTX_QLBV;
/

---------------------------------------------
-- 1.2 Tạo Application Context
-- Context được quản lý bởi PKG_CTX_QLBV
---------------------------------------------
CREATE OR REPLACE CONTEXT CTX_QLBV USING QLBV.PKG_CTX_QLBV;

---------------------------------------------
-- 1.3 Tạo LOGON TRIGGER
-- Tự động thiết lập context khi user đăng nhập
---------------------------------------------
CREATE OR REPLACE TRIGGER QLBV.TRG_LOGON_SET_CTX
AFTER LOGON ON DATABASE
BEGIN
    QLBV.PKG_CTX_QLBV.SET_CONTEXT;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Không chặn đăng nhập nếu có lỗi
END;
/

PROMPT === Bước 1 hoàn tất: Application Context và Logon Trigger đã được tạo ===


-- ============================================
-- BƯỚC 2: TẠO CÁC HÀM VPD POLICY
-- Mỗi hàm trả về chuỗi predicate (điều kiện WHERE)
-- để giới hạn dữ liệu theo vai trò.
-- Signature chuẩn: (p_schema VARCHAR2, p_table VARCHAR2) RETURN VARCHAR2
-- ============================================

---------------------------------------------
-- 2.1 FN_VPD_HSBA_SELECT
-- Bảng: HSBA | Thao tác: SELECT
-- - DBA: không giới hạn
-- - Bác sĩ/Y sĩ: chỉ xem hồ sơ mình phụ trách (TC#3a)
-- - Điều phối viên: xem tất cả (cần để phân công)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_SELECT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ xem hồ sơ bệnh án do mình phụ trách
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MABS = ''' || v_manv || '''';
    END IF;

    -- Điều phối viên: xem tất cả hồ sơ bệnh án
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Các vai trò khác: từ chối truy cập
    RETURN '1=0';
END FN_VPD_HSBA_SELECT;
/

---------------------------------------------
-- 2.2 FN_VPD_HSBA_INSERT
-- Bảng: HSBA | Thao tác: INSERT
-- - DBA: không giới hạn
-- - Điều phối viên: được tạo hồ sơ bệnh án mới (TC#2b)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_INSERT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: được thêm hồ sơ bệnh án
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_HSBA_INSERT;
/

---------------------------------------------
-- 2.3 FN_VPD_HSBA_UPDATE
-- Bảng: HSBA | Thao tác: UPDATE
-- - DBA: không giới hạn
-- - Điều phối viên: cập nhật MAKHOA, MABS (TC#2c)
-- - Bác sĩ/Y sĩ: cập nhật CHANDOAN, DIEUTRI, KETLUAN
--   chỉ cho hồ sơ mình phụ trách (TC#3c)
-- - Khác: từ chối
-- Lưu ý: Cột nào được phép UPDATE sẽ dùng sec_relevant_cols
--         trong DBMS_RLS.ADD_POLICY
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_UPDATE(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: cập nhật tất cả hồ sơ (cột giới hạn bởi sec_relevant_cols)
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ cập nhật hồ sơ do mình phụ trách
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MABS = ''' || v_manv || '''';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_HSBA_UPDATE;
/

---------------------------------------------
-- 2.4 FN_VPD_BENHNHAN_SELECT
-- Bảng: BENHNHAN | Thao tác: SELECT
-- - DBA: không giới hạn
-- - Điều phối viên: xem tất cả bệnh nhân (TC#2a)
-- - Bác sĩ/Y sĩ: chỉ xem bệnh nhân mình điều trị (TC#3d)
-- - Bệnh nhân: chỉ xem hồ sơ của chính mình (TC#5a)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_BENHNHAN_SELECT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
    v_user   VARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: xem tất cả bệnh nhân
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ xem bệnh nhân có trong HSBA mình phụ trách
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MABN IN (SELECT MABN FROM QLBV.HSBA WHERE MABS = ''' || v_manv || ''')';
    END IF;

    -- Bệnh nhân: chỉ xem hồ sơ của chính mình
    IF v_vaitro = 'Benh nhan' THEN
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        RETURN 'TAIKHOAN = ''' || v_user || '''';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_BENHNHAN_SELECT;
/

---------------------------------------------
-- 2.5 FN_VPD_BENHNHAN_UPDATE
-- Bảng: BENHNHAN | Thao tác: UPDATE
-- - DBA: không giới hạn
-- - Điều phối viên: cập nhật tất cả bệnh nhân (TC#2a)
-- - Bác sĩ/Y sĩ: cập nhật TIENSUBNH, TIENSUBNHGD, DIUNGTH
--   cho bệnh nhân mình điều trị (TC#3e)
-- - Bệnh nhân: cập nhật SONHA, TENDUONG, QUANHUYEN, TINHTP
--   cho chính mình (TC#5b)
-- - Khác: từ chối
-- Lưu ý: Cột giới hạn bằng sec_relevant_cols trong ADD_POLICY
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_BENHNHAN_UPDATE(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
    v_user   VARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: cập nhật tất cả
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ cập nhật bệnh nhân mình điều trị
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MABN IN (SELECT MABN FROM QLBV.HSBA WHERE MABS = ''' || v_manv || ''')';
    END IF;

    -- Bệnh nhân: chỉ cập nhật hồ sơ chính mình
    IF v_vaitro = 'Benh nhan' THEN
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        RETURN 'TAIKHOAN = ''' || v_user || '''';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_BENHNHAN_UPDATE;
/

---------------------------------------------
-- 2.6 FN_VPD_BENHNHAN_INSERT
-- Bảng: BENHNHAN | Thao tác: INSERT
-- - DBA: không giới hạn
-- - Điều phối viên: được thêm bệnh nhân mới (TC#2a)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_BENHNHAN_INSERT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: được thêm bệnh nhân
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_BENHNHAN_INSERT;
/

---------------------------------------------
-- 2.7 FN_VPD_HSBA_DV_SELECT
-- Bảng: HSBA_DV | Thao tác: SELECT
-- - DBA: không giới hạn
-- - Điều phối viên: xem tất cả (cần để phân công KTV)
-- - Bác sĩ/Y sĩ: chỉ xem dịch vụ thuộc HSBA mình phụ trách (TC#3b)
-- - Kỹ thuật viên: chỉ xem dịch vụ được giao cho mình (TC#4a)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_DV_SELECT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Điều phối viên: xem tất cả dịch vụ
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ xem dịch vụ thuộc HSBA mình phụ trách
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MAHSBA IN (SELECT MAHSBA FROM QLBV.HSBA WHERE MABS = ''' || v_manv || ''')';
    END IF;

    -- Kỹ thuật viên: chỉ xem dịch vụ được giao
    IF v_vaitro = 'Ky thuat vien' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MAKTV = ''' || v_manv || '''';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_HSBA_DV_SELECT;
/

---------------------------------------------
-- 2.8 FN_VPD_HSBA_DV_MODIFY
-- Bảng: HSBA_DV | Thao tác: INSERT, DELETE
-- - DBA: không giới hạn
-- - Bác sĩ/Y sĩ: thêm/xóa dịch vụ cho HSBA mình phụ trách (TC#3b)
-- - Điều phối viên: được phép (cần để quản lý)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_DV_MODIFY(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ thao tác trên dịch vụ thuộc HSBA mình
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MAHSBA IN (SELECT MAHSBA FROM QLBV.HSBA WHERE MABS = ''' || v_manv || ''')';
    END IF;

    -- Điều phối viên: được phép
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_HSBA_DV_MODIFY;
/

---------------------------------------------
-- 2.9 FN_VPD_HSBA_DV_UPDATE
-- Bảng: HSBA_DV | Thao tác: UPDATE
-- - DBA: không giới hạn
-- - Kỹ thuật viên: cập nhật KETQUA cho dịch vụ mình thực hiện (TC#4b)
-- - Điều phối viên: cập nhật MAKTV (phân công KTV) (TC#2d)
-- - Khác: từ chối
-- Lưu ý: Cột giới hạn bằng sec_relevant_cols trong ADD_POLICY
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_HSBA_DV_UPDATE(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Kỹ thuật viên: chỉ cập nhật dịch vụ mình thực hiện
    IF v_vaitro = 'Ky thuat vien' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MAKTV = ''' || v_manv || '''';
    END IF;

    -- Điều phối viên: cập nhật tất cả (cột giới hạn bởi sec_relevant_cols)
    IF v_vaitro = 'Dieu phoi vien' THEN
        RETURN NULL;
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_HSBA_DV_UPDATE;
/

---------------------------------------------
-- 2.10 FN_VPD_DONTHUOC
-- Bảng: DONTHUOC | Thao tác: SELECT, INSERT, UPDATE, DELETE
-- - DBA: không giới hạn
-- - Bác sĩ/Y sĩ: toàn quyền trên đơn thuốc của HSBA mình (TC#3f)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_DONTHUOC(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_manv   VARCHAR2(20);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Bác sĩ/Y sĩ: chỉ thao tác trên đơn thuốc thuộc HSBA mình
    IF v_vaitro = 'Bac si/Y si' THEN
        v_manv := SYS_CONTEXT('CTX_QLBV', 'MANV');
        RETURN 'MAHSBA IN (SELECT MAHSBA FROM QLBV.HSBA WHERE MABS = ''' || v_manv || ''')';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_DONTHUOC;
/

---------------------------------------------
-- 2.11 FN_VPD_NHANVIEN_SELECT
-- Bảng: NHANVIEN | Thao tác: SELECT
-- - DBA: không giới hạn
-- - Nhân viên (mọi vai trò): chỉ xem thông tin chính mình (TC#5c)
-- - Khác: từ chối
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_NHANVIEN_SELECT(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_user   VARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Nhân viên (bất kỳ vai trò nào): chỉ xem hồ sơ chính mình
    IF v_vaitro IN ('Dieu phoi vien', 'Bac si/Y si', 'Ky thuat vien') THEN
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        RETURN 'TAIKHOAN = ''' || v_user || '''';
    END IF;

    -- Các vai trò khác (bệnh nhân, unknown): từ chối
    RETURN '1=0';
END FN_VPD_NHANVIEN_SELECT;
/

---------------------------------------------
-- 2.12 FN_VPD_NHANVIEN_UPDATE
-- Bảng: NHANVIEN | Thao tác: UPDATE
-- - DBA: không giới hạn
-- - Nhân viên: chỉ cập nhật QUEQUAN, SODT chính mình (TC#5d)
-- - Khác: từ chối
-- Lưu ý: Cột giới hạn bằng sec_relevant_cols trong ADD_POLICY
---------------------------------------------
CREATE OR REPLACE FUNCTION QLBV.FN_VPD_NHANVIEN_UPDATE(
    p_schema IN VARCHAR2,
    p_table  IN VARCHAR2
) RETURN VARCHAR2
AS
    v_vaitro NVARCHAR2(30);
    v_user   VARCHAR2(30);
BEGIN
    v_vaitro := SYS_CONTEXT('CTX_QLBV', 'VAITRO');

    -- DBA: không giới hạn
    IF v_vaitro = 'DBA' THEN
        RETURN NULL;
    END IF;

    -- Nhân viên (bất kỳ vai trò nào): chỉ cập nhật chính mình
    IF v_vaitro IN ('Dieu phoi vien', 'Bac si/Y si', 'Ky thuat vien') THEN
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        RETURN 'TAIKHOAN = ''' || v_user || '''';
    END IF;

    -- Các vai trò khác: từ chối
    RETURN '1=0';
END FN_VPD_NHANVIEN_UPDATE;
/

PROMPT === Bước 2 hoàn tất: Tất cả 12 hàm VPD Policy đã được tạo ===


-- ============================================
-- BƯỚC 3: ĐĂNG KÝ VPD POLICIES VỚI DBMS_RLS
-- Xóa policy cũ (nếu có) rồi tạo mới
-- ============================================

---------------------------------------------
-- 3.0 Xóa tất cả policy cũ (nếu tồn tại)
---------------------------------------------
DECLARE
    -- Danh sách policy cần xóa
    TYPE t_policy_rec IS RECORD (
        obj_name  VARCHAR2(30),
        pol_name  VARCHAR2(30)
    );
    TYPE t_policy_list IS TABLE OF t_policy_rec INDEX BY PLS_INTEGER;
    v_policies t_policy_list;
BEGIN
    -- Định nghĩa danh sách policy
    v_policies(1).obj_name  := 'HSBA';      v_policies(1).pol_name  := 'POL_HSBA_SELECT';
    v_policies(2).obj_name  := 'HSBA';      v_policies(2).pol_name  := 'POL_HSBA_INSERT';
    v_policies(3).obj_name  := 'HSBA';      v_policies(3).pol_name  := 'POL_HSBA_UPDATE_DPV';
    v_policies(4).obj_name  := 'HSBA';      v_policies(4).pol_name  := 'POL_HSBA_UPDATE_BS';
    v_policies(5).obj_name  := 'BENHNHAN';  v_policies(5).pol_name  := 'POL_BN_SELECT';
    v_policies(6).obj_name  := 'BENHNHAN';  v_policies(6).pol_name  := 'POL_BN_UPDATE_DPV';
    v_policies(7).obj_name  := 'BENHNHAN';  v_policies(7).pol_name  := 'POL_BN_UPDATE_BS';
    v_policies(8).obj_name  := 'BENHNHAN';  v_policies(8).pol_name  := 'POL_BN_UPDATE_BN';
    v_policies(9).obj_name  := 'BENHNHAN';  v_policies(9).pol_name  := 'POL_BN_INSERT';
    v_policies(10).obj_name := 'HSBA_DV';   v_policies(10).pol_name := 'POL_DV_SELECT';
    v_policies(11).obj_name := 'HSBA_DV';   v_policies(11).pol_name := 'POL_DV_MODIFY';
    v_policies(12).obj_name := 'HSBA_DV';   v_policies(12).pol_name := 'POL_DV_UPDATE_KTV';
    v_policies(13).obj_name := 'HSBA_DV';   v_policies(13).pol_name := 'POL_DV_UPDATE_DPV';
    v_policies(14).obj_name := 'DONTHUOC';  v_policies(14).pol_name := 'POL_DT_ALL';
    v_policies(15).obj_name := 'NHANVIEN';  v_policies(15).pol_name := 'POL_NV_SELECT';
    v_policies(16).obj_name := 'NHANVIEN';  v_policies(16).pol_name := 'POL_NV_UPDATE';

    FOR i IN 1..v_policies.COUNT LOOP
        BEGIN
            DBMS_RLS.DROP_POLICY(
                object_schema => 'QLBV',
                object_name   => v_policies(i).obj_name,
                policy_name   => v_policies(i).pol_name
            );
            DBMS_OUTPUT.PUT_LINE('Đã xóa policy: ' || v_policies(i).pol_name);
        EXCEPTION
            WHEN OTHERS THEN
                -- Policy chưa tồn tại, bỏ qua
                NULL;
        END;
    END LOOP;
END;
/

PROMPT === Đã xóa các policy cũ (nếu có) ===

---------------------------------------------
-- 3.1 HSBA Policies
---------------------------------------------

-- 3.1.1 POL_HSBA_SELECT: Giới hạn SELECT trên HSBA
-- Bác sĩ chỉ xem HSBA mình phụ trách; ĐPV xem tất cả
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'HSBA',
        policy_name     => 'POL_HSBA_SELECT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_HSBA_SELECT',
        statement_types => 'SELECT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_HSBA_SELECT');
END;
/

-- 3.1.2 POL_HSBA_INSERT: Giới hạn INSERT trên HSBA
-- Chỉ ĐPV được tạo hồ sơ bệnh án mới
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'HSBA',
        policy_name     => 'POL_HSBA_INSERT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_HSBA_INSERT',
        statement_types => 'INSERT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_HSBA_INSERT');
END;
/

-- 3.1.3 POL_HSBA_UPDATE_DPV: ĐPV cập nhật MAKHOA, MABS trên HSBA
-- Tách riêng policy cho ĐPV vì sec_relevant_cols khác nhau
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'HSBA',
        policy_name        => 'POL_HSBA_UPDATE_DPV',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_HSBA_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'MAKHOA,MABS',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_HSBA_UPDATE_DPV');
END;
/

-- 3.1.4 POL_HSBA_UPDATE_BS: Bác sĩ cập nhật CHANDOAN, DIEUTRI, KETLUAN trên HSBA
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'HSBA',
        policy_name        => 'POL_HSBA_UPDATE_BS',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_HSBA_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'CHANDOAN,DIEUTRI,KETLUAN',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_HSBA_UPDATE_BS');
END;
/

---------------------------------------------
-- 3.2 BENHNHAN Policies
---------------------------------------------

-- 3.2.1 POL_BN_SELECT: Giới hạn SELECT trên BENHNHAN
-- ĐPV xem tất cả; BS chỉ xem BN mình điều trị; BN chỉ xem chính mình
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'BENHNHAN',
        policy_name     => 'POL_BN_SELECT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_BENHNHAN_SELECT',
        statement_types => 'SELECT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_BN_SELECT');
END;
/

-- 3.2.2 POL_BN_UPDATE_DPV: ĐPV cập nhật tất cả cột trên BENHNHAN
-- ĐPV có toàn quyền cập nhật thông tin bệnh nhân (TC#2a)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'BENHNHAN',
        policy_name     => 'POL_BN_UPDATE_DPV',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_BENHNHAN_UPDATE',
        statement_types => 'UPDATE',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_BN_UPDATE_DPV');
END;
/

-- 3.2.3 POL_BN_UPDATE_BS: BS cập nhật TIENSUBNH, TIENSUBNHGD, DIUNGTH
-- Bác sĩ chỉ cập nhật tiền sử và dị ứng cho BN mình điều trị (TC#3e)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'BENHNHAN',
        policy_name        => 'POL_BN_UPDATE_BS',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_BENHNHAN_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'TIENSUBNH,TIENSUBNHGD,DIUNGTH',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_BN_UPDATE_BS');
END;
/

-- 3.2.4 POL_BN_UPDATE_BN: BN cập nhật SONHA, TENDUONG, QUANHUYEN, TINHTP
-- Bệnh nhân chỉ cập nhật địa chỉ của chính mình (TC#5b)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'BENHNHAN',
        policy_name        => 'POL_BN_UPDATE_BN',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_BENHNHAN_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'SONHA,TENDUONG,QUANHUYEN,TINHTP',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_BN_UPDATE_BN');
END;
/

-- 3.2.5 POL_BN_INSERT: Giới hạn INSERT trên BENHNHAN
-- Chỉ ĐPV được thêm bệnh nhân mới
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'BENHNHAN',
        policy_name     => 'POL_BN_INSERT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_BENHNHAN_INSERT',
        statement_types => 'INSERT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_BN_INSERT');
END;
/

---------------------------------------------
-- 3.3 HSBA_DV Policies
---------------------------------------------

-- 3.3.1 POL_DV_SELECT: Giới hạn SELECT trên HSBA_DV
-- BS xem dịch vụ thuộc HSBA mình; KTV xem dịch vụ mình thực hiện; ĐPV xem tất cả
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'HSBA_DV',
        policy_name     => 'POL_DV_SELECT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_HSBA_DV_SELECT',
        statement_types => 'SELECT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_DV_SELECT');
END;
/

-- 3.3.2 POL_DV_MODIFY: Giới hạn INSERT, DELETE trên HSBA_DV
-- BS thêm/xóa dịch vụ cho HSBA mình phụ trách (TC#3b)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'HSBA_DV',
        policy_name     => 'POL_DV_MODIFY',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_HSBA_DV_MODIFY',
        statement_types => 'INSERT,DELETE',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_DV_MODIFY');
END;
/

-- 3.3.3 POL_DV_UPDATE_KTV: KTV cập nhật KETQUA trên HSBA_DV
-- Kỹ thuật viên chỉ cập nhật kết quả cho dịch vụ mình thực hiện (TC#4b)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'HSBA_DV',
        policy_name        => 'POL_DV_UPDATE_KTV',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_HSBA_DV_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'KETQUA',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_DV_UPDATE_KTV');
END;
/

-- 3.3.4 POL_DV_UPDATE_DPV: ĐPV cập nhật MAKTV trên HSBA_DV
-- Điều phối viên phân công kỹ thuật viên cho dịch vụ (TC#2d)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'HSBA_DV',
        policy_name        => 'POL_DV_UPDATE_DPV',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_HSBA_DV_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'MAKTV',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_DV_UPDATE_DPV');
END;
/

---------------------------------------------
-- 3.4 DONTHUOC Policy
---------------------------------------------

-- POL_DT_ALL: Giới hạn tất cả thao tác trên DONTHUOC
-- Chỉ BS được SELECT, INSERT, UPDATE, DELETE đơn thuốc thuộc HSBA mình (TC#3f)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'DONTHUOC',
        policy_name     => 'POL_DT_ALL',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_DONTHUOC',
        statement_types => 'SELECT,INSERT,UPDATE,DELETE',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_DT_ALL');
END;
/

---------------------------------------------
-- 3.5 NHANVIEN Policies
---------------------------------------------

-- 3.5.1 POL_NV_SELECT: Nhân viên chỉ xem thông tin chính mình (TC#5c)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'QLBV',
        object_name     => 'NHANVIEN',
        policy_name     => 'POL_NV_SELECT',
        function_schema => 'QLBV',
        policy_function => 'FN_VPD_NHANVIEN_SELECT',
        statement_types => 'SELECT',
        policy_type     => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_NV_SELECT');
END;
/

-- 3.5.2 POL_NV_UPDATE: Nhân viên chỉ cập nhật QUEQUAN, SODT chính mình (TC#5d)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema      => 'QLBV',
        object_name        => 'NHANVIEN',
        policy_name        => 'POL_NV_UPDATE',
        function_schema    => 'QLBV',
        policy_function    => 'FN_VPD_NHANVIEN_UPDATE',
        statement_types    => 'UPDATE',
        sec_relevant_cols  => 'QUEQUAN,SODT',
        policy_type        => DBMS_RLS.CONTEXT_SENSITIVE
    );
    DBMS_OUTPUT.PUT_LINE('Đã tạo policy: POL_NV_UPDATE');
END;
/

PROMPT === Bước 3 hoàn tất: Tất cả VPD Policies đã được đăng ký ===


-- ============================================
-- BƯỚC 4: KIỂM TRA VPD POLICIES
-- ============================================

-- Liệt kê tất cả VPD policies trên schema QLBV
SELECT object_name, policy_name, function, sel, ins, upd, del
FROM   DBA_POLICIES
WHERE  object_owner = 'QLBV'
ORDER BY object_name, policy_name;

PROMPT === Cài đặt VPD Policies hoàn tất ===
PROMPT === Bạn có thể kiểm tra bằng các câu lệnh bên dưới ===

-- ============================================
-- CÁC LỆNH KIỂM TRA (chạy thủ công)
-- ============================================

/*
-- ============================================
-- KIỂM TRA 1: Xem danh sách policies đã tạo
-- ============================================
SELECT object_name, policy_name, function, sel, ins, upd, del,
       sec_relevant_cols
FROM   DBA_POLICIES
WHERE  object_owner = 'QLBV'
ORDER BY object_name, policy_name;

-- ============================================
-- KIỂM TRA 2: Xem context hiện tại
-- (Chạy với tài khoản bất kỳ sau khi đăng nhập)
-- ============================================
SELECT SYS_CONTEXT('CTX_QLBV', 'VAITRO')    AS VAITRO,
       SYS_CONTEXT('CTX_QLBV', 'MANV')      AS MANV,
       SYS_CONTEXT('CTX_QLBV', 'MABN')      AS MABN,
       SYS_CONTEXT('CTX_QLBV', 'LOAI_USER') AS LOAI_USER
FROM   DUAL;

-- ============================================
-- KIỂM TRA 3: Test với tài khoản Bác sĩ
-- (Đăng nhập bằng NV_BS001)
-- ============================================
-- Kỳ vọng: Chỉ thấy HSBA có MABS = 'BS001'
-- SELECT * FROM QLBV.HSBA;

-- Kỳ vọng: Chỉ thấy bệnh nhân mà BS001 điều trị
-- SELECT * FROM QLBV.BENHNHAN;

-- Kỳ vọng: Chỉ thấy dịch vụ thuộc HSBA của BS001
-- SELECT * FROM QLBV.HSBA_DV;

-- Kỳ vọng: Chỉ thấy đơn thuốc thuộc HSBA của BS001
-- SELECT * FROM QLBV.DONTHUOC;

-- Kỳ vọng: Chỉ thấy thông tin chính mình
-- SELECT * FROM QLBV.NHANVIEN;

-- Kỳ vọng: Được cập nhật CHANDOAN, DIEUTRI, KETLUAN cho HSBA mình
-- UPDATE QLBV.HSBA SET CHANDOAN = N'Viêm họng cấp' WHERE MAHSBA = 'HSBA001';

-- Kỳ vọng: Được cập nhật TIENSUBNH cho BN mình điều trị
-- UPDATE QLBV.BENHNHAN SET TIENSUBNH = N'Không có' WHERE MABN = 'BN001';

-- ============================================
-- KIỂM TRA 4: Test với tài khoản Điều phối viên
-- (Đăng nhập bằng NV_DPV01)
-- ============================================
-- Kỳ vọng: Thấy tất cả bệnh nhân
-- SELECT * FROM QLBV.BENHNHAN;

-- Kỳ vọng: Thấy tất cả HSBA
-- SELECT * FROM QLBV.HSBA;

-- Kỳ vọng: Được INSERT hồ sơ bệnh án mới
-- INSERT INTO QLBV.HSBA (MAHSBA, MABN, NGAY, MABS, MAKHOA)
-- VALUES ('HSBA_TEST', 'BN001', SYSDATE, 'BS001', 'KHOA01');

-- Kỳ vọng: Được UPDATE MAKHOA, MABS trên HSBA
-- UPDATE QLBV.HSBA SET MABS = 'BS002' WHERE MAHSBA = 'HSBA001';

-- Kỳ vọng: Chỉ thấy thông tin chính mình trên NHANVIEN
-- SELECT * FROM QLBV.NHANVIEN;

-- ============================================
-- KIỂM TRA 5: Test với tài khoản Kỹ thuật viên
-- (Đăng nhập bằng NV_KTV01)
-- ============================================
-- Kỳ vọng: Chỉ thấy HSBA_DV có MAKTV = MANV của mình
-- SELECT * FROM QLBV.HSBA_DV;

-- Kỳ vọng: Được UPDATE KETQUA cho dịch vụ mình
-- UPDATE QLBV.HSBA_DV SET KETQUA = N'Bình thường' WHERE MAHSBA = 'HSBA001' AND LOAIDV = 'XN01';

-- ============================================
-- KIỂM TRA 6: Test với tài khoản Bệnh nhân
-- (Đăng nhập bằng BN_00001)
-- ============================================
-- Kỳ vọng: Chỉ thấy hồ sơ chính mình
-- SELECT * FROM QLBV.BENHNHAN;

-- Kỳ vọng: Được cập nhật địa chỉ của chính mình
-- UPDATE QLBV.BENHNHAN SET SONHA = '123', TENDUONG = N'Nguyễn Huệ'
-- WHERE TAIKHOAN = SYS_CONTEXT('USERENV', 'SESSION_USER');

-- Kỳ vọng: Không thấy bảng HSBA (1=0)
-- SELECT * FROM QLBV.HSBA;  -- Trả về 0 dòng

-- ============================================
-- KIỂM TRA 7: Test từ chối truy cập
-- ============================================
-- Đăng nhập bằng NV_KTV01 (Kỹ thuật viên):
-- Kỳ vọng: Không INSERT được vào HSBA
-- INSERT INTO QLBV.HSBA (MAHSBA, MABN, NGAY) VALUES ('TEST', 'BN001', SYSDATE);
-- => ORA-28115: policy with check option violation

-- Đăng nhập bằng BN_00001 (Bệnh nhân):
-- Kỳ vọng: Không UPDATE được cột TIENSUBNH (chỉ BS mới được)
-- UPDATE QLBV.BENHNHAN SET TIENSUBNH = N'test';
-- => Không cập nhật được hoặc lỗi policy
*/

-- ============================================
-- GHI CHÚ QUAN TRỌNG
-- ============================================
-- 1. Script này nên chạy bằng QLBV (schema owner) hoặc SYS.
--    Nếu chạy bằng QLBV, cần GRANT EXECUTE ON DBMS_RLS và
--    GRANT CREATE ANY CONTEXT, GRANT ADMINISTER DATABASE TRIGGER.
--
-- 2. Logon Trigger (TRG_LOGON_SET_CTX) tự động thiết lập
--    context CTX_QLBV mỗi khi user đăng nhập.
--
-- 3. Tất cả policy function đều kiểm tra VAITRO = 'DBA'
--    để không giới hạn tài khoản quản trị.
--
-- 4. Các policy UPDATE sử dụng sec_relevant_cols để giới hạn
--    cột nào được phép cập nhật theo từng vai trò.
--
-- 5. Oracle VPD cho phép nhiều policy trên cùng một bảng.
--    Khi có nhiều policy trên cùng statement_type, Oracle sẽ
--    kết hợp chúng bằng AND. Cần thiết kế hàm policy sao cho
--    mỗi vai trò chỉ trả về predicate phù hợp.
--
-- 6. policy_type = DBMS_RLS.CONTEXT_SENSITIVE giúp tối ưu hiệu năng:
--    Oracle chỉ gọi lại hàm policy khi context thay đổi.
-- ============================================
