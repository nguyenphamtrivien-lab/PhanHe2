-- ============================================
-- SCRIPT: 03_insert_data.sql
-- MÔ TẢ: Nhập dữ liệu mẫu cho tất cả các bảng
-- Chạy bằng: QLBV (schema owner)
-- ============================================

SET SERVEROUTPUT ON;
SET DEFINE OFF;

-- ============================================
-- 1. NHẬP DỮ LIỆU NHÂN VIÊN (170 dòng)
-- ============================================

-- ------------------------------------------------
-- 1A. 20 ĐIỀU PHỐI VIÊN (DPV01 → DPV20)
-- ------------------------------------------------
PROMPT Đang nhập 20 Điều phối viên...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(50) INDEX BY PLS_INTEGER;
    v_ho        t_arr;
    v_dem       t_arr;
    v_ten       t_arr;
    v_quequan   t_arr;
    v_sodt_pre  t_arr;
    v_phai      NVARCHAR2(10);
    v_hoten     NVARCHAR2(100);
    v_cmnd      VARCHAR2(12);
    v_ngaysinh  DATE;
    v_quequan_v NVARCHAR2(200);
    v_sodt      VARCHAR2(15);
BEGIN
    -- Mảng họ (10)
    v_ho(1)  := N'Nguyễn'; v_ho(2)  := N'Trần';  v_ho(3)  := N'Lê';
    v_ho(4)  := N'Phạm';   v_ho(5)  := N'Hoàng'; v_ho(6)  := N'Huỳnh';
    v_ho(7)  := N'Phan';   v_ho(8)  := N'Vũ';    v_ho(9)  := N'Võ';
    v_ho(10) := N'Đặng';

    -- Mảng tên đệm (6)
    v_dem(1) := N'Văn';  v_dem(2) := N'Thị';   v_dem(3) := N'Hoàng';
    v_dem(4) := N'Minh'; v_dem(5) := N'Thanh'; v_dem(6) := N'Quốc';

    -- Mảng tên (20)
    v_ten(1)  := N'An';    v_ten(2)  := N'Bình';  v_ten(3)  := N'Chi';
    v_ten(4)  := N'Dũng';  v_ten(5)  := N'Em';    v_ten(6)  := N'Phúc';
    v_ten(7)  := N'Gia';   v_ten(8)  := N'Hải';   v_ten(9)  := N'Khánh';
    v_ten(10) := N'Linh';  v_ten(11) := N'Minh';  v_ten(12) := N'Nam';
    v_ten(13) := N'Phong'; v_ten(14) := N'Quân';  v_ten(15) := N'Sơn';
    v_ten(16) := N'Tùng';  v_ten(17) := N'Uyên';  v_ten(18) := N'Việt';
    v_ten(19) := N'Xuân';  v_ten(20) := N'Yến';

    -- Mảng quê quán (5)
    v_quequan(1) := N'TP. Hồ Chí Minh';  v_quequan(2) := N'Hà Nội';
    v_quequan(3) := N'Đà Nẵng';          v_quequan(4) := N'Hải Phòng';
    v_quequan(5) := N'Cần Thơ';

    -- Đầu số điện thoại (5)
    v_sodt_pre(1) := '090'; v_sodt_pre(2) := '091'; v_sodt_pre(3) := '098';
    v_sodt_pre(4) := '035'; v_sodt_pre(5) := '038';

    FOR i IN 1..20 LOOP
        -- Giới tính luân phiên
        IF MOD(i, 3) = 0 THEN
            v_phai := N'Nữ';
        ELSE
            v_phai := N'Nam';
        END IF;

        -- Họ tên kết hợp từ mảng
        v_hoten := v_ho(MOD(i-1, 10) + 1) || N' ' || v_dem(MOD(i-1, 6) + 1) || N' ' || v_ten(MOD(i-1, 20) + 1);

        -- CMND giả lập
        v_cmnd := '07910' || LPAD(TO_CHAR(10000 + i), 7, '0');

        -- Ngày sinh: từ 1980 đến 1995
        v_ngaysinh := TO_DATE('1980-01-01', 'YYYY-MM-DD') + (i * 97 MOD 5475);

        -- Quê quán
        v_quequan_v := v_quequan(MOD(i-1, 5) + 1);

        -- Số điện thoại
        v_sodt := v_sodt_pre(MOD(i-1, 5) + 1) || LPAD(TO_CHAR(1000000 + i * 137), 7, '0');

        INSERT INTO QLBV.NHANVIEN (MANV, HOTEN, PHAI, NGAYSINH, CMND, QUEQUAN, SODT, VAITRO, CHUYENKHOA, TAIKHOAN)
        VALUES (
            'DPV' || LPAD(i, 2, '0'),
            v_hoten,
            v_phai,
            v_ngaysinh,
            v_cmnd,
            v_quequan_v,
            v_sodt,
            N'Dieu phoi vien',
            NULL,
            'NV_DPV' || LPAD(i, 2, '0')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 20 Điều phối viên.');
END;
/

-- ------------------------------------------------
-- 1B. 100 BÁC SĨ / Y SĨ (BS001 → BS100)
-- ------------------------------------------------
PROMPT Đang nhập 100 Bác sĩ/Y sĩ...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(50) INDEX BY PLS_INTEGER;
    v_ho        t_arr;
    v_dem       t_arr;
    v_ten       t_arr;
    v_chuyenkhoa t_arr;
    v_quequan   t_arr;
    v_sodt_pre  t_arr;
    v_phai      NVARCHAR2(10);
    v_hoten     NVARCHAR2(100);
    v_cmnd      VARCHAR2(12);
    v_ngaysinh  DATE;
    v_quequan_v NVARCHAR2(200);
    v_sodt      VARCHAR2(15);
    v_ck        NVARCHAR2(100);
BEGIN
    -- Mảng họ (10)
    v_ho(1)  := N'Nguyễn'; v_ho(2)  := N'Trần';  v_ho(3)  := N'Lê';
    v_ho(4)  := N'Phạm';   v_ho(5)  := N'Hoàng'; v_ho(6)  := N'Huỳnh';
    v_ho(7)  := N'Phan';   v_ho(8)  := N'Vũ';    v_ho(9)  := N'Võ';
    v_ho(10) := N'Đặng';

    -- Mảng tên đệm (6)
    v_dem(1) := N'Văn';  v_dem(2) := N'Thị';   v_dem(3) := N'Hoàng';
    v_dem(4) := N'Minh'; v_dem(5) := N'Thanh'; v_dem(6) := N'Quốc';

    -- Mảng tên (20)
    v_ten(1)  := N'An';    v_ten(2)  := N'Bình';  v_ten(3)  := N'Chi';
    v_ten(4)  := N'Dũng';  v_ten(5)  := N'Em';    v_ten(6)  := N'Phúc';
    v_ten(7)  := N'Gia';   v_ten(8)  := N'Hải';   v_ten(9)  := N'Khánh';
    v_ten(10) := N'Linh';  v_ten(11) := N'Minh';  v_ten(12) := N'Nam';
    v_ten(13) := N'Phong'; v_ten(14) := N'Quân';  v_ten(15) := N'Sơn';
    v_ten(16) := N'Tùng';  v_ten(17) := N'Uyên';  v_ten(18) := N'Việt';
    v_ten(19) := N'Xuân';  v_ten(20) := N'Yến';

    -- Mảng chuyên khoa (3)
    v_chuyenkhoa(1) := N'Khoa Tiêu hóa';
    v_chuyenkhoa(2) := N'Khoa Thần kinh';
    v_chuyenkhoa(3) := N'Khoa Tim mạch';

    -- Mảng quê quán (5)
    v_quequan(1) := N'TP. Hồ Chí Minh';  v_quequan(2) := N'Hà Nội';
    v_quequan(3) := N'Đà Nẵng';          v_quequan(4) := N'Hải Phòng';
    v_quequan(5) := N'Cần Thơ';

    -- Đầu số điện thoại (5)
    v_sodt_pre(1) := '090'; v_sodt_pre(2) := '091'; v_sodt_pre(3) := '098';
    v_sodt_pre(4) := '035'; v_sodt_pre(5) := '038';

    FOR i IN 1..100 LOOP
        -- Giới tính
        IF MOD(i, 3) = 0 THEN
            v_phai := N'Nữ';
        ELSE
            v_phai := N'Nam';
        END IF;

        -- Họ tên - dùng offset khác DPV để đa dạng
        v_hoten := v_ho(MOD(i + 2, 10) + 1) || N' ' || v_dem(MOD(i + 1, 6) + 1) || N' ' || v_ten(MOD(i + 4, 20) + 1);

        -- CMND
        v_cmnd := '02520' || LPAD(TO_CHAR(20000 + i), 7, '0');

        -- Ngày sinh: từ 1970 đến 1990
        v_ngaysinh := TO_DATE('1970-01-01', 'YYYY-MM-DD') + (i * 73 MOD 7300);

        -- Quê quán
        v_quequan_v := v_quequan(MOD(i-1, 5) + 1);

        -- Số điện thoại
        v_sodt := v_sodt_pre(MOD(i-1, 5) + 1) || LPAD(TO_CHAR(2000000 + i * 211), 7, '0');

        -- Chuyên khoa phân bố đều: 1→Tiêu hóa, 2→Thần kinh, 3→Tim mạch
        v_ck := v_chuyenkhoa(MOD(i-1, 3) + 1);

        INSERT INTO QLBV.NHANVIEN (MANV, HOTEN, PHAI, NGAYSINH, CMND, QUEQUAN, SODT, VAITRO, CHUYENKHOA, TAIKHOAN)
        VALUES (
            'BS' || LPAD(i, 3, '0'),
            v_hoten,
            v_phai,
            v_ngaysinh,
            v_cmnd,
            v_quequan_v,
            v_sodt,
            N'Bac si/Y si',
            v_ck,
            'NV_BS' || LPAD(i, 3, '0')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 100 Bác sĩ/Y sĩ.');
END;
/

-- ------------------------------------------------
-- 1C. 50 KỸ THUẬT VIÊN (KTV01 → KTV50)
-- ------------------------------------------------
PROMPT Đang nhập 50 Kỹ thuật viên...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(50) INDEX BY PLS_INTEGER;
    v_ho        t_arr;
    v_dem       t_arr;
    v_ten       t_arr;
    v_quequan   t_arr;
    v_sodt_pre  t_arr;
    v_phai      NVARCHAR2(10);
    v_hoten     NVARCHAR2(100);
    v_cmnd      VARCHAR2(12);
    v_ngaysinh  DATE;
    v_quequan_v NVARCHAR2(200);
    v_sodt      VARCHAR2(15);
BEGIN
    -- Mảng họ (10)
    v_ho(1)  := N'Nguyễn'; v_ho(2)  := N'Trần';  v_ho(3)  := N'Lê';
    v_ho(4)  := N'Phạm';   v_ho(5)  := N'Hoàng'; v_ho(6)  := N'Huỳnh';
    v_ho(7)  := N'Phan';   v_ho(8)  := N'Vũ';    v_ho(9)  := N'Võ';
    v_ho(10) := N'Đặng';

    -- Mảng tên đệm (6)
    v_dem(1) := N'Văn';  v_dem(2) := N'Thị';   v_dem(3) := N'Hoàng';
    v_dem(4) := N'Minh'; v_dem(5) := N'Thanh'; v_dem(6) := N'Quốc';

    -- Mảng tên (20)
    v_ten(1)  := N'An';    v_ten(2)  := N'Bình';  v_ten(3)  := N'Chi';
    v_ten(4)  := N'Dũng';  v_ten(5)  := N'Em';    v_ten(6)  := N'Phúc';
    v_ten(7)  := N'Gia';   v_ten(8)  := N'Hải';   v_ten(9)  := N'Khánh';
    v_ten(10) := N'Linh';  v_ten(11) := N'Minh';  v_ten(12) := N'Nam';
    v_ten(13) := N'Phong'; v_ten(14) := N'Quân';  v_ten(15) := N'Sơn';
    v_ten(16) := N'Tùng';  v_ten(17) := N'Uyên';  v_ten(18) := N'Việt';
    v_ten(19) := N'Xuân';  v_ten(20) := N'Yến';

    -- Mảng quê quán (5)
    v_quequan(1) := N'TP. Hồ Chí Minh';  v_quequan(2) := N'Hà Nội';
    v_quequan(3) := N'Đà Nẵng';          v_quequan(4) := N'Hải Phòng';
    v_quequan(5) := N'Cần Thơ';

    -- Đầu số điện thoại (5)
    v_sodt_pre(1) := '090'; v_sodt_pre(2) := '091'; v_sodt_pre(3) := '098';
    v_sodt_pre(4) := '035'; v_sodt_pre(5) := '038';

    FOR i IN 1..50 LOOP
        -- Giới tính
        IF MOD(i, 4) = 0 THEN
            v_phai := N'Nữ';
        ELSE
            v_phai := N'Nam';
        END IF;

        -- Họ tên - dùng offset khác BS để đa dạng
        v_hoten := v_ho(MOD(i + 5, 10) + 1) || N' ' || v_dem(MOD(i + 3, 6) + 1) || N' ' || v_ten(MOD(i + 7, 20) + 1);

        -- CMND
        v_cmnd := '03820' || LPAD(TO_CHAR(30000 + i), 7, '0');

        -- Ngày sinh: từ 1985 đến 2000
        v_ngaysinh := TO_DATE('1985-01-01', 'YYYY-MM-DD') + (i * 109 MOD 5475);

        -- Quê quán
        v_quequan_v := v_quequan(MOD(i-1, 5) + 1);

        -- Số điện thoại
        v_sodt := v_sodt_pre(MOD(i-1, 5) + 1) || LPAD(TO_CHAR(3000000 + i * 179), 7, '0');

        INSERT INTO QLBV.NHANVIEN (MANV, HOTEN, PHAI, NGAYSINH, CMND, QUEQUAN, SODT, VAITRO, CHUYENKHOA, TAIKHOAN)
        VALUES (
            'KTV' || LPAD(i, 2, '0'),
            v_hoten,
            v_phai,
            v_ngaysinh,
            v_cmnd,
            v_quequan_v,
            v_sodt,
            N'Ky thuat vien',
            NULL,
            'NV_KTV' || LPAD(i, 2, '0')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 50 Kỹ thuật viên.');
END;
/

-- ============================================
-- 2. NHẬP DỮ LIỆU BỆNH NHÂN (40 dòng)
-- ============================================
PROMPT Đang nhập 40 Bệnh nhân...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(100) INDEX BY PLS_INTEGER;
    v_ho        t_arr;
    v_dem       t_arr;
    v_ten       t_arr;
    v_duong     t_arr;
    v_quan_hcm  t_arr;
    v_quan_hn   t_arr;
    v_quan_hp   t_arr;
    v_tiensu    t_arr;
    v_tsgia     t_arr;
    v_diung     t_arr;
    v_phai      NVARCHAR2(10);
    v_tenbn     NVARCHAR2(100);
    v_cccd      VARCHAR2(12);
    v_ngaysinh  DATE;
    v_sonha     NVARCHAR2(50);
    v_tenduong  NVARCHAR2(100);
    v_quanhuyen NVARCHAR2(100);
    v_tinhtp    NVARCHAR2(100);
    v_ts_val    NVARCHAR2(500);
    v_tsgd_val  NVARCHAR2(500);
    v_du_val    NVARCHAR2(500);
BEGIN
    -- Mảng họ (10)
    v_ho(1)  := N'Nguyễn'; v_ho(2)  := N'Trần';  v_ho(3)  := N'Lê';
    v_ho(4)  := N'Phạm';   v_ho(5)  := N'Hoàng'; v_ho(6)  := N'Huỳnh';
    v_ho(7)  := N'Phan';   v_ho(8)  := N'Vũ';    v_ho(9)  := N'Võ';
    v_ho(10) := N'Đặng';

    -- Mảng tên đệm (6)
    v_dem(1) := N'Văn';  v_dem(2) := N'Thị';   v_dem(3) := N'Hoàng';
    v_dem(4) := N'Minh'; v_dem(5) := N'Thanh'; v_dem(6) := N'Quốc';

    -- Mảng tên (20)
    v_ten(1)  := N'An';    v_ten(2)  := N'Bình';  v_ten(3)  := N'Chi';
    v_ten(4)  := N'Dũng';  v_ten(5)  := N'Em';    v_ten(6)  := N'Phúc';
    v_ten(7)  := N'Gia';   v_ten(8)  := N'Hải';   v_ten(9)  := N'Khánh';
    v_ten(10) := N'Linh';  v_ten(11) := N'Minh';  v_ten(12) := N'Nam';
    v_ten(13) := N'Phong'; v_ten(14) := N'Quân';  v_ten(15) := N'Sơn';
    v_ten(16) := N'Tùng';  v_ten(17) := N'Uyên';  v_ten(18) := N'Việt';
    v_ten(19) := N'Xuân';  v_ten(20) := N'Yến';

    -- Mảng tên đường (8)
    v_duong(1) := N'Nguyễn Huệ';        v_duong(2) := N'Lê Lợi';
    v_duong(3) := N'Trần Hưng Đạo';     v_duong(4) := N'Nguyễn Trãi';
    v_duong(5) := N'Võ Văn Tần';         v_duong(6) := N'Pasteur';
    v_duong(7) := N'Cách Mạng Tháng 8'; v_duong(8) := N'Điện Biên Phủ';

    -- Quận HCM (5)
    v_quan_hcm(1) := N'Quận 1';     v_quan_hcm(2) := N'Quận 3';
    v_quan_hcm(3) := N'Quận 5';     v_quan_hcm(4) := N'Quận 7';
    v_quan_hcm(5) := N'Quận Bình Thạnh';

    -- Quận Hà Nội (3)
    v_quan_hn(1) := N'Quận Hoàn Kiếm'; v_quan_hn(2) := N'Quận Ba Đình';
    v_quan_hn(3) := N'Quận Đống Đa';

    -- Quận Hải Phòng (2)
    v_quan_hp(1) := N'Quận Hồng Bàng'; v_quan_hp(2) := N'Quận Lê Chân';

    -- Tiền sử bệnh (5)
    v_tiensu(1) := N'Viêm loét dạ dày';
    v_tiensu(2) := N'Tiểu đường type 2';
    v_tiensu(3) := N'Cao huyết áp';
    v_tiensu(4) := N'Hen suyễn';
    v_tiensu(5) := N'Viêm gan B';

    -- Tiền sử gia đình (4)
    v_tsgia(1) := N'Cha bị tiểu đường';
    v_tsgia(2) := N'Mẹ bị cao huyết áp';
    v_tsgia(3) := N'Ông ngoại bị ung thư phổi';
    v_tsgia(4) := N'Bà nội bị tim mạch';

    -- Dị ứng thuốc (4)
    v_diung(1) := N'Dị ứng Penicillin';
    v_diung(2) := N'Dị ứng Sulfonamide';
    v_diung(3) := N'Dị ứng Aspirin';
    v_diung(4) := N'Không dị ứng thuốc';

    FOR i IN 1..40 LOOP
        -- Giới tính
        IF MOD(i, 2) = 0 THEN
            v_phai := N'Nữ';
        ELSE
            v_phai := N'Nam';
        END IF;

        -- Tên bệnh nhân
        v_tenbn := v_ho(MOD(i + 3, 10) + 1) || N' ' || v_dem(MOD(i, 6) + 1) || N' ' || v_ten(MOD(i + 9, 20) + 1);

        -- CCCD
        v_cccd := '0790' || LPAD(TO_CHAR(40000 + i * 3), 8, '0');

        -- Ngày sinh: 1960 đến 2000
        v_ngaysinh := TO_DATE('1960-01-01', 'YYYY-MM-DD') + (i * 367 MOD 14600);

        -- Số nhà
        v_sonha := TO_CHAR(10 + i * 7) || '/' || TO_CHAR(MOD(i * 3, 50) + 1);

        -- Địa chỉ phân bố: 1-20 HCM, 21-32 Hà Nội, 33-40 Hải Phòng
        v_tenduong := v_duong(MOD(i-1, 8) + 1);
        IF i <= 20 THEN
            v_quanhuyen := v_quan_hcm(MOD(i-1, 5) + 1);
            v_tinhtp    := N'TP. Hồ Chí Minh';
        ELSIF i <= 32 THEN
            v_quanhuyen := v_quan_hn(MOD(i-1, 3) + 1);
            v_tinhtp    := N'Hà Nội';
        ELSE
            v_quanhuyen := v_quan_hp(MOD(i-1, 2) + 1);
            v_tinhtp    := N'Hải Phòng';
        END IF;

        -- Tiền sử bệnh (70% có tiền sử)
        IF MOD(i, 10) <= 6 THEN
            v_ts_val := v_tiensu(MOD(i-1, 5) + 1);
        ELSE
            v_ts_val := NULL;
        END IF;

        -- Tiền sử gia đình (50% có)
        IF MOD(i, 2) = 1 THEN
            v_tsgd_val := v_tsgia(MOD(i-1, 4) + 1);
        ELSE
            v_tsgd_val := NULL;
        END IF;

        -- Dị ứng thuốc (60% có)
        IF MOD(i, 5) <= 2 THEN
            v_du_val := v_diung(MOD(i-1, 4) + 1);
        ELSE
            v_du_val := NULL;
        END IF;

        INSERT INTO QLBV.BENHNHAN (MABN, TENBN, PHAI, NGAYSINH, CCCD, SONHA, TENDUONG, QUANHUYEN, TINHTP, TIENSUBNH, TIENSUBNHGD, DIUNGTH, TAIKHOAN)
        VALUES (
            'BN' || LPAD(i, 5, '0'),
            v_tenbn,
            v_phai,
            v_ngaysinh,
            v_cccd,
            v_sonha,
            v_tenduong,
            v_quanhuyen,
            v_tinhtp,
            v_ts_val,
            v_tsgd_val,
            v_du_val,
            'BN_' || LPAD(i, 5, '0')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 40 Bệnh nhân.');
END;
/

-- ============================================
-- 3. NHẬP DỮ LIỆU HỒ SƠ BỆNH ÁN (60 dòng)
-- ============================================
PROMPT Đang nhập 60 Hồ sơ bệnh án...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(500) INDEX BY PLS_INTEGER;
    v_chandoan  t_arr;
    v_dieutri   t_arr;
    v_ketluan   t_arr;
    v_makhoa    VARCHAR2(20);
    v_mabs      VARCHAR2(20);
    v_mabn      VARCHAR2(20);
    v_ngay      DATE;
    v_cd        NVARCHAR2(500);
    v_dt        NVARCHAR2(500);
    v_kl        NVARCHAR2(500);
    v_bs_idx    PLS_INTEGER;
BEGIN
    -- Mảng chẩn đoán (10)
    v_chandoan(1)  := N'Viêm loét dạ dày tá tràng';
    v_chandoan(2)  := N'Hội chứng ruột kích thích';
    v_chandoan(3)  := N'Đau đầu migraine';
    v_chandoan(4)  := N'Viêm dây thần kinh ngoại biên';
    v_chandoan(5)  := N'Tăng huyết áp độ 2';
    v_chandoan(6)  := N'Rối loạn nhịp tim';
    v_chandoan(7)  := N'Trào ngược dạ dày thực quản';
    v_chandoan(8)  := N'Thiếu máu não thoáng qua';
    v_chandoan(9)  := N'Suy tim sung huyết';
    v_chandoan(10) := N'Viêm đại tràng mãn tính';

    -- Mảng điều trị (10)
    v_dieutri(1)  := N'Điều trị nội khoa, dùng thuốc ức chế bơm proton';
    v_dieutri(2)  := N'Chế độ ăn kiêng, thuốc chống co thắt';
    v_dieutri(3)  := N'Thuốc giảm đau nhóm triptan, nghỉ ngơi';
    v_dieutri(4)  := N'Vitamin B12, vật lý trị liệu';
    v_dieutri(5)  := N'Thuốc hạ áp nhóm ARB, chế độ ăn giảm muối';
    v_dieutri(6)  := N'Thuốc chống loạn nhịp, theo dõi Holter';
    v_dieutri(7)  := N'PPI liều cao, thay đổi lối sống';
    v_dieutri(8)  := N'Thuốc chống đông, kiểm soát yếu tố nguy cơ';
    v_dieutri(9)  := N'Thuốc lợi tiểu, ức chế men chuyển';
    v_dieutri(10) := N'Thuốc kháng viêm, men tiêu hóa';

    -- Mảng kết luận (6)
    v_ketluan(1) := N'Bệnh nhân ổn định, tiếp tục điều trị ngoại trú';
    v_ketluan(2) := N'Cần tái khám sau 2 tuần';
    v_ketluan(3) := N'Chuyển tuyến trên để phẫu thuật';
    v_ketluan(4) := N'Xuất viện, dặn dò chế độ ăn uống';
    v_ketluan(5) := N'Nhập viện theo dõi thêm';
    v_ketluan(6) := N'Hồi phục tốt, ngưng thuốc';

    FOR i IN 1..60 LOOP
        -- Bệnh nhân: phân bố 60 HSBA cho 40 BN (nhiều BN có 2 HSBA)
        v_mabn := 'BN' || LPAD(MOD(i-1, 40) + 1, 5, '0');

        -- Bác sĩ: phân bố 10 bác sĩ (BS001..BS010)
        v_bs_idx := MOD(i-1, 10) + 1;
        v_mabs := 'BS' || LPAD(v_bs_idx, 3, '0');

        -- Mã khoa tương ứng chuyên khoa bác sĩ
        CASE MOD(v_bs_idx - 1, 3)
            WHEN 0 THEN v_makhoa := 'KTH';  -- Khoa Tiêu hóa
            WHEN 1 THEN v_makhoa := 'KTK';  -- Khoa Thần kinh
            WHEN 2 THEN v_makhoa := 'KTM';  -- Khoa Tim mạch
        END CASE;

        -- Ngày khám: rải từ 01/01/2025 đến 30/05/2025
        v_ngay := TO_DATE('2025-01-01', 'YYYY-MM-DD') + (i * 2.5);

        -- Chẩn đoán (80% có, 20% NULL)
        IF MOD(i, 5) != 0 THEN
            v_cd := v_chandoan(MOD(i-1, 10) + 1);
        ELSE
            v_cd := NULL;
        END IF;

        -- Điều trị (tương ứng chẩn đoán)
        IF v_cd IS NOT NULL THEN
            v_dt := v_dieutri(MOD(i-1, 10) + 1);
        ELSE
            v_dt := NULL;
        END IF;

        -- Kết luận (70% có)
        IF MOD(i, 10) <= 6 THEN
            v_kl := v_ketluan(MOD(i-1, 6) + 1);
        ELSE
            v_kl := NULL;
        END IF;

        INSERT INTO QLBV.HSBA (MAHSBA, MABN, NGAY, CHANDOAN, DIEUTRI, MABS, MAKHOA, KETLUAN)
        VALUES (
            'HSBA' || LPAD(i, 5, '0'),
            v_mabn,
            v_ngay,
            v_cd,
            v_dt,
            v_mabs,
            v_makhoa,
            v_kl
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 60 Hồ sơ bệnh án.');
END;
/

-- ============================================
-- 4. NHẬP DỮ LIỆU DỊCH VỤ HỖ TRỢ (35 dòng)
-- ============================================
PROMPT Đang nhập 35 Dịch vụ hỗ trợ chẩn đoán...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(500) INDEX BY PLS_INTEGER;
    v_loaidv    t_arr;
    v_ketqua    t_arr;
    v_mahsba    VARCHAR2(20);
    v_maktv     VARCHAR2(20);
    v_ngaydv    DATE;
    v_kq        NVARCHAR2(500);
    v_ldv       NVARCHAR2(100);
BEGIN
    -- Mảng loại dịch vụ (6)
    v_loaidv(1) := N'Xét nghiệm máu';
    v_loaidv(2) := N'Chụp X-quang';
    v_loaidv(3) := N'Chụp CT';
    v_loaidv(4) := N'Siêu âm';
    v_loaidv(5) := N'Điện tim';
    v_loaidv(6) := N'Xét nghiệm nước tiểu';

    -- Mảng kết quả (8)
    v_ketqua(1) := N'Bạch cầu: 8.500/μL, Hồng cầu: 4.5 triệu/μL, Tiểu cầu: 250.000/μL - Bình thường';
    v_ketqua(2) := N'Không phát hiện bất thường trên phim X-quang ngực thẳng';
    v_ketqua(3) := N'Phát hiện khối u nhỏ 1.2cm tại thùy phải gan, cần theo dõi';
    v_ketqua(4) := N'Siêu âm ổ bụng bình thường, gan mật lách thận không bất thường';
    v_ketqua(5) := N'Nhịp xoang đều, tần số 72 lần/phút, không rối loạn nhịp';
    v_ketqua(6) := N'Protein niệu (-), Glucose niệu (-), pH 6.0 - Bình thường';
    v_ketqua(7) := N'Đường huyết lúc đói: 5.8 mmol/L, HbA1c: 6.2% - Tiền tiểu đường';
    v_ketqua(8) := N'Cholesterol toàn phần: 5.2 mmol/L, Triglyceride: 1.8 mmol/L';

    FOR i IN 1..35 LOOP
        -- Liên kết với HSBA: dùng HSBA00001 → HSBA00035
        v_mahsba := 'HSBA' || LPAD(i, 5, '0');

        -- Kỹ thuật viên: phân bố KTV01..KTV10
        v_maktv := 'KTV' || LPAD(MOD(i-1, 10) + 1, 2, '0');

        -- Loại dịch vụ
        v_ldv := v_loaidv(MOD(i-1, 6) + 1);

        -- Ngày dịch vụ: cùng ngày hoặc ngày sau HSBA
        v_ngaydv := TO_DATE('2025-01-01', 'YYYY-MM-DD') + (i * 2.5) + 1;

        -- Kết quả (75% có, 25% NULL - chờ kết quả)
        IF MOD(i, 4) != 0 THEN
            v_kq := v_ketqua(MOD(i-1, 8) + 1);
        ELSE
            v_kq := NULL;
        END IF;

        INSERT INTO QLBV.HSBA_DV (MAHSBA, LOAIDV, NGAYDV, MAKTV, KETQUA)
        VALUES (
            v_mahsba,
            v_ldv,
            v_ngaydv,
            v_maktv,
            v_kq
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 35 Dịch vụ hỗ trợ chẩn đoán.');
END;
/

-- ============================================
-- 5. NHẬP DỮ LIỆU ĐƠN THUỐC (45 dòng)
-- ============================================
PROMPT Đang nhập 45 Đơn thuốc...

DECLARE
    TYPE t_arr IS TABLE OF NVARCHAR2(200) INDEX BY PLS_INTEGER;
    v_tenthuoc  t_arr;
    v_lieudung  t_arr;
    v_mahsba    VARCHAR2(20);
    v_ngaydt    DATE;
    v_tt        NVARCHAR2(200);
    v_ld        NVARCHAR2(200);
BEGIN
    -- Mảng tên thuốc (15)
    v_tenthuoc(1)  := N'Paracetamol';
    v_tenthuoc(2)  := N'Amoxicillin';
    v_tenthuoc(3)  := N'Omeprazole';
    v_tenthuoc(4)  := N'Metformin';
    v_tenthuoc(5)  := N'Aspirin';
    v_tenthuoc(6)  := N'Ibuprofen';
    v_tenthuoc(7)  := N'Losartan';
    v_tenthuoc(8)  := N'Atorvastatin';
    v_tenthuoc(9)  := N'Amlodipine';
    v_tenthuoc(10) := N'Clopidogrel';
    v_tenthuoc(11) := N'Metoprolol';
    v_tenthuoc(12) := N'Pantoprazole';
    v_tenthuoc(13) := N'Ciprofloxacin';
    v_tenthuoc(14) := N'Domperidone';
    v_tenthuoc(15) := N'Vitamin B Complex';

    -- Mảng liều dùng (10)
    v_lieudung(1)  := N'500mg x 2 lần/ngày';
    v_lieudung(2)  := N'250mg x 3 lần/ngày';
    v_lieudung(3)  := N'20mg x 1 lần/ngày (trước ăn sáng)';
    v_lieudung(4)  := N'500mg x 2 lần/ngày (sau ăn)';
    v_lieudung(5)  := N'81mg x 1 lần/ngày (sau ăn sáng)';
    v_lieudung(6)  := N'400mg x 3 lần/ngày (sau ăn)';
    v_lieudung(7)  := N'50mg x 1 lần/ngày';
    v_lieudung(8)  := N'10mg x 1 lần/ngày (buổi tối)';
    v_lieudung(9)  := N'5mg x 1 lần/ngày';
    v_lieudung(10) := N'75mg x 1 lần/ngày (sau ăn sáng)';

    FOR i IN 1..45 LOOP
        -- Liên kết với HSBA: dùng HSBA00001 → HSBA00045
        v_mahsba := 'HSBA' || LPAD(MOD(i-1, 45) + 1, 5, '0');

        -- Ngày điều trị: tương ứng ngày HSBA
        v_ngaydt := TO_DATE('2025-01-01', 'YYYY-MM-DD') + ((MOD(i-1, 45) + 1) * 2.5);

        -- Tên thuốc
        v_tt := v_tenthuoc(MOD(i-1, 15) + 1);

        -- Liều dùng
        v_ld := v_lieudung(MOD(i-1, 10) + 1);

        INSERT INTO QLBV.DONTHUOC (MAHSBA, NGAYDT, TENTHUOC, LIEUDUNG)
        VALUES (
            v_mahsba,
            v_ngaydt,
            v_tt,
            v_ld
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Đã nhập 45 Đơn thuốc.');
END;
/

-- ============================================
-- 6. NHẬP DỮ LIỆU THÔNG BÁO MẪU (5 dòng)
-- ============================================
PROMPT Đang nhập 5 Thông báo mẫu...

INSERT INTO QLBV.THONGBAO (NOIDUNG, DIADIEM)
VALUES (N'Lịch trực khoa Tiêu hóa tuần 10/2025 đã được cập nhật', N'Khoa Tiêu hóa - Tầng 3');

INSERT INTO QLBV.THONGBAO (NOIDUNG, DIADIEM)
VALUES (N'Hội nghị khoa học thường niên bệnh viện sẽ diễn ra ngày 15/03/2025', N'Hội trường A - Tầng 1');

INSERT INTO QLBV.THONGBAO (NOIDUNG, DIADIEM)
VALUES (N'Thông báo bảo trì hệ thống CNTT ngày 20/03/2025 từ 22:00 đến 06:00', N'Toàn bệnh viện');

INSERT INTO QLBV.THONGBAO (NOIDUNG, DIADIEM)
VALUES (N'Khoa Tim mạch tiếp nhận thiết bị siêu âm tim 4D mới', N'Khoa Tim mạch - Tầng 5');

INSERT INTO QLBV.THONGBAO (NOIDUNG, DIADIEM)
VALUES (N'Chương trình đào tạo nâng cao kỹ năng cấp cứu cho điều dưỡng', N'Phòng đào tạo - Tầng 2');

-- ============================================
-- COMMIT & KIỂM TRA DỮ LIỆU
-- ============================================
COMMIT;

-- Thống kê dữ liệu đã nhập
PROMPT ;
PROMPT ================================================
PROMPT   THỐNG KÊ DỮ LIỆU ĐÃ NHẬP
PROMPT ================================================

SELECT 'NHANVIEN' AS BANG, COUNT(*) AS SO_DONG FROM QLBV.NHANVIEN
UNION ALL
SELECT 'BENHNHAN', COUNT(*) FROM QLBV.BENHNHAN
UNION ALL
SELECT 'HSBA', COUNT(*) FROM QLBV.HSBA
UNION ALL
SELECT 'HSBA_DV', COUNT(*) FROM QLBV.HSBA_DV
UNION ALL
SELECT 'DONTHUOC', COUNT(*) FROM QLBV.DONTHUOC
UNION ALL
SELECT 'THONGBAO', COUNT(*) FROM QLBV.THONGBAO
ORDER BY BANG;

-- Kiểm tra phân bố vai trò nhân viên
PROMPT ;
PROMPT Phân bố vai trò nhân viên:

SELECT VAITRO, COUNT(*) AS SO_LUONG
FROM QLBV.NHANVIEN
GROUP BY VAITRO
ORDER BY VAITRO;

-- Kiểm tra phân bố chuyên khoa bác sĩ
PROMPT ;
PROMPT Phân bố chuyên khoa bác sĩ:

SELECT CHUYENKHOA, COUNT(*) AS SO_LUONG
FROM QLBV.NHANVIEN
WHERE VAITRO = N'Bac si/Y si'
GROUP BY CHUYENKHOA
ORDER BY CHUYENKHOA;

-- Kiểm tra phân bố bệnh nhân theo tỉnh/TP
PROMPT ;
PROMPT Phân bố bệnh nhân theo tỉnh/thành phố:

SELECT TINHTP, COUNT(*) AS SO_LUONG
FROM QLBV.BENHNHAN
GROUP BY TINHTP
ORDER BY TINHTP;

-- Hoàn tất
PROMPT ;
PROMPT ================================================
PROMPT   NHẬP DỮ LIỆU MẪU HOÀN TẤT THÀNH CÔNG!
PROMPT   Schema: QLBV | Oracle 21c
PROMPT ================================================
