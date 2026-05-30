-- ============================================
-- SCRIPT: 01_create_schema.sql
-- MÔ TẢ: Tạo cấu trúc bảng CSDL Phân Hệ 2
-- Schema owner: QLBV
-- Oracle version: 21c
-- ============================================

-- ============================================
-- XÓA BẢNG NẾU TỒN TẠI (theo thứ tự phụ thuộc)
-- ============================================

-- Xóa DONTHUOC (phụ thuộc HSBA)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.DONTHUOC CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa HSBA_DV (phụ thuộc HSBA, NHANVIEN)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.HSBA_DV CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa HSBA (phụ thuộc BENHNHAN, NHANVIEN)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.HSBA CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa BENHNHAN
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.BENHNHAN CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa NHANVIEN
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.NHANVIEN CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa THONGBAO
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.THONGBAO CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Xóa AUDIT_LOG
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE QLBV.AUDIT_LOG CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- ============================================
-- 1. BẢNG NHANVIEN (Nhân viên)
-- ============================================
CREATE TABLE QLBV.NHANVIEN (
    MANV        VARCHAR2(20)        PRIMARY KEY,
    HOTEN       NVARCHAR2(100)      NOT NULL,
    PHAI        NVARCHAR2(10)       CHECK (PHAI IN (N'Nam', N'Nữ')),
    NGAYSINH    DATE,
    CMND        VARCHAR2(12)        UNIQUE,
    QUEQUAN     NVARCHAR2(200),
    SODT        VARCHAR2(15),
    VAITRO      NVARCHAR2(30)       NOT NULL
                                    CHECK (VAITRO IN (N'Dieu phoi vien', N'Bac si/Y si', N'Ky thuat vien')),
    CHUYENKHOA  NVARCHAR2(100),
    TAIKHOAN    VARCHAR2(30)        UNIQUE  -- Liên kết tài khoản Oracle (TC#1)
);

COMMENT ON TABLE QLBV.NHANVIEN IS 'Bảng lưu thông tin nhân viên bệnh viện';
COMMENT ON COLUMN QLBV.NHANVIEN.MANV IS 'Mã nhân viên (khóa chính)';
COMMENT ON COLUMN QLBV.NHANVIEN.HOTEN IS 'Họ tên nhân viên';
COMMENT ON COLUMN QLBV.NHANVIEN.PHAI IS 'Giới tính: Nam hoặc Nữ';
COMMENT ON COLUMN QLBV.NHANVIEN.VAITRO IS 'Vai trò: Dieu phoi vien, Bac si/Y si, Ky thuat vien';
COMMENT ON COLUMN QLBV.NHANVIEN.TAIKHOAN IS 'Tên tài khoản Oracle liên kết (TC#1)';

-- ============================================
-- 2. BẢNG BENHNHAN (Bệnh nhân)
-- ============================================
CREATE TABLE QLBV.BENHNHAN (
    MABN        VARCHAR2(20)        PRIMARY KEY,
    TENBN       NVARCHAR2(100)      NOT NULL,
    PHAI        NVARCHAR2(10)       CHECK (PHAI IN (N'Nam', N'Nữ')),
    NGAYSINH    DATE,
    CCCD        VARCHAR2(12)        UNIQUE,
    SONHA       NVARCHAR2(50),
    TENDUONG    NVARCHAR2(100),
    QUANHUYEN   NVARCHAR2(100),
    TINHTP      NVARCHAR2(100),
    TIENSUBNH   NVARCHAR2(500),
    TIENSUBNHGD NVARCHAR2(500),
    DIUNGTH     NVARCHAR2(500),
    TAIKHOAN    VARCHAR2(30)        UNIQUE  -- Liên kết tài khoản Oracle (TC#1)
);

COMMENT ON TABLE QLBV.BENHNHAN IS 'Bảng lưu thông tin bệnh nhân';
COMMENT ON COLUMN QLBV.BENHNHAN.MABN IS 'Mã bệnh nhân (khóa chính)';
COMMENT ON COLUMN QLBV.BENHNHAN.TENBN IS 'Tên bệnh nhân';
COMMENT ON COLUMN QLBV.BENHNHAN.CCCD IS 'Căn cước công dân';
COMMENT ON COLUMN QLBV.BENHNHAN.TIENSUBNH IS 'Tiền sử bệnh nhân';
COMMENT ON COLUMN QLBV.BENHNHAN.TIENSUBNHGD IS 'Tiền sử bệnh nhân gia đình';
COMMENT ON COLUMN QLBV.BENHNHAN.DIUNGTH IS 'Dị ứng thuốc';
COMMENT ON COLUMN QLBV.BENHNHAN.TAIKHOAN IS 'Tên tài khoản Oracle liên kết (TC#1)';

-- ============================================
-- 3. BẢNG HSBA (Hồ sơ bệnh án)
-- ============================================
CREATE TABLE QLBV.HSBA (
    MAHSBA      VARCHAR2(20)        PRIMARY KEY,
    MABN        VARCHAR2(20)        NOT NULL
                                    REFERENCES QLBV.BENHNHAN(MABN),
    NGAY        DATE                NOT NULL,
    CHANDOAN    NVARCHAR2(500),
    DIEUTRI     NVARCHAR2(500),
    MABS        VARCHAR2(20)        REFERENCES QLBV.NHANVIEN(MANV),
    MAKHOA      VARCHAR2(20),
    KETLUAN     NVARCHAR2(500)
);

COMMENT ON TABLE QLBV.HSBA IS 'Bảng hồ sơ bệnh án';
COMMENT ON COLUMN QLBV.HSBA.MAHSBA IS 'Mã hồ sơ bệnh án (khóa chính)';
COMMENT ON COLUMN QLBV.HSBA.MABN IS 'Mã bệnh nhân (FK → BENHNHAN)';
COMMENT ON COLUMN QLBV.HSBA.MABS IS 'Mã bác sĩ phụ trách (FK → NHANVIEN)';
COMMENT ON COLUMN QLBV.HSBA.MAKHOA IS 'Mã khoa: KTH, KTK, KTM';
COMMENT ON COLUMN QLBV.HSBA.CHANDOAN IS 'Chẩn đoán bệnh';
COMMENT ON COLUMN QLBV.HSBA.DIEUTRI IS 'Phương pháp điều trị';
COMMENT ON COLUMN QLBV.HSBA.KETLUAN IS 'Kết luận cuối cùng';

-- ============================================
-- 4. BẢNG HSBA_DV (Dịch vụ hỗ trợ chẩn đoán)
-- ============================================
CREATE TABLE QLBV.HSBA_DV (
    MAHSBA      VARCHAR2(20)        NOT NULL
                                    REFERENCES QLBV.HSBA(MAHSBA),
    LOAIDV      NVARCHAR2(100)      NOT NULL,
    NGAYDV      DATE                NOT NULL,
    MAKTV       VARCHAR2(20)        REFERENCES QLBV.NHANVIEN(MANV),
    KETQUA      NVARCHAR2(500),
    CONSTRAINT PK_HSBA_DV PRIMARY KEY (MAHSBA, LOAIDV, NGAYDV)
);

COMMENT ON TABLE QLBV.HSBA_DV IS 'Bảng dịch vụ hỗ trợ chẩn đoán';
COMMENT ON COLUMN QLBV.HSBA_DV.MAHSBA IS 'Mã hồ sơ bệnh án (FK → HSBA)';
COMMENT ON COLUMN QLBV.HSBA_DV.LOAIDV IS 'Loại dịch vụ: Xét nghiệm, Chụp X-quang, CT, Siêu âm...';
COMMENT ON COLUMN QLBV.HSBA_DV.MAKTV IS 'Mã kỹ thuật viên thực hiện (FK → NHANVIEN)';
COMMENT ON COLUMN QLBV.HSBA_DV.KETQUA IS 'Kết quả dịch vụ';

-- ============================================
-- 5. BẢNG DONTHUOC (Đơn thuốc)
-- ============================================
CREATE TABLE QLBV.DONTHUOC (
    MAHSBA      VARCHAR2(20)        NOT NULL
                                    REFERENCES QLBV.HSBA(MAHSBA),
    NGAYDT      DATE                NOT NULL,
    TENTHUOC    NVARCHAR2(200)      NOT NULL,
    LIEUDUNG    NVARCHAR2(200),
    CONSTRAINT PK_DONTHUOC PRIMARY KEY (MAHSBA, NGAYDT, TENTHUOC)
);

COMMENT ON TABLE QLBV.DONTHUOC IS 'Bảng đơn thuốc';
COMMENT ON COLUMN QLBV.DONTHUOC.MAHSBA IS 'Mã hồ sơ bệnh án (FK → HSBA)';
COMMENT ON COLUMN QLBV.DONTHUOC.NGAYDT IS 'Ngày điều trị';
COMMENT ON COLUMN QLBV.DONTHUOC.TENTHUOC IS 'Tên thuốc';
COMMENT ON COLUMN QLBV.DONTHUOC.LIEUDUNG IS 'Liều dùng';

-- ============================================
-- 6. BẢNG THONGBAO (cho OLS - Yêu cầu 2)
-- ============================================
CREATE TABLE QLBV.THONGBAO (
    MATB        NUMBER              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NOIDUNG     NVARCHAR2(1000),
    NGAYGIO     TIMESTAMP           DEFAULT SYSTIMESTAMP,
    DIADIEM     NVARCHAR2(200)
);

COMMENT ON TABLE QLBV.THONGBAO IS 'Bảng thông báo cho Oracle Label Security (OLS)';
COMMENT ON COLUMN QLBV.THONGBAO.MATB IS 'Mã thông báo (tự động tăng)';
COMMENT ON COLUMN QLBV.THONGBAO.NOIDUNG IS 'Nội dung thông báo';
COMMENT ON COLUMN QLBV.THONGBAO.NGAYGIO IS 'Ngày giờ tạo thông báo';
COMMENT ON COLUMN QLBV.THONGBAO.DIADIEM IS 'Địa điểm liên quan';

-- ============================================
-- 7. BẢNG AUDIT_LOG (Bảng ghi vết)
-- ============================================
CREATE TABLE QLBV.AUDIT_LOG (
    MA_LOG      NUMBER              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TAIKHOAN    VARCHAR2(30),
    BANG        VARCHAR2(50),
    HANH_VI     VARCHAR2(20),
    TRUONG      VARCHAR2(50),
    GIA_TRI_CU  NVARCHAR2(2000),
    GIA_TRI_MOI NVARCHAR2(2000),
    THOI_GIAN   TIMESTAMP           DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE QLBV.AUDIT_LOG IS 'Bảng ghi vết hành vi truy cập và thay đổi dữ liệu';
COMMENT ON COLUMN QLBV.AUDIT_LOG.TAIKHOAN IS 'Tài khoản thực hiện hành vi';
COMMENT ON COLUMN QLBV.AUDIT_LOG.BANG IS 'Bảng bị ảnh hưởng';
COMMENT ON COLUMN QLBV.AUDIT_LOG.HANH_VI IS 'Loại hành vi: INSERT, UPDATE, DELETE, SELECT';
COMMENT ON COLUMN QLBV.AUDIT_LOG.TRUONG IS 'Trường bị thay đổi';
COMMENT ON COLUMN QLBV.AUDIT_LOG.GIA_TRI_CU IS 'Giá trị cũ trước khi thay đổi';
COMMENT ON COLUMN QLBV.AUDIT_LOG.GIA_TRI_MOI IS 'Giá trị mới sau khi thay đổi';
COMMENT ON COLUMN QLBV.AUDIT_LOG.THOI_GIAN IS 'Thời gian thực hiện hành vi';

-- ============================================
-- COMMIT & KIỂM TRA
-- ============================================
COMMIT;

-- Xác minh các bảng đã tạo
SELECT table_name FROM user_tables ORDER BY table_name;

-- Hoàn tất
PROMPT ================================================
PROMPT   TẠO CẤU TRÚC BẢNG HOÀN TẤT THÀNH CÔNG!
PROMPT   Schema: QLBV | Oracle 21c
PROMPT ================================================
