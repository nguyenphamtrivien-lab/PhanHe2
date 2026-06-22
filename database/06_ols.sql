-- =====================================================================
-- File: 06_ols.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: Yêu cầu 2 - Oracle Label Security (OLS)
--        Kiểm soát truy cập dữ liệu theo nhãn bảo mật đa chiều
-- Chạy với quyền: SYSDBA hoặc LBAC_DBA
-- Thứ tự chạy: 6/8
--
-- ĐIỀU KIỆN TIÊN QUYẾT:
--   Oracle Label Security phải được cài đặt:
--     EXEC LBACSYS.CONFIGURE_OLS;
--     EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
--   Hoặc trong Oracle 21c XE, kiểm tra: SELECT * FROM DBA_OLS_STATUS;
--
-- NGUYÊN LÝ OLS:
-- ┌──────────────────────────────────────────────────────────────────┐
-- │  Nhãn = Level:Compartments:Groups                                 │
-- │  VD: LDKHOA:TIMMANH,THANKINH:HCM                                 │
-- │                                                                    │
-- │  Cấu trúc nhãn trong bảng THÔNGBÁO:                              │
-- │  Level      Compartment(s)   Group(s)                             │
-- │  ─────────  ───────────────  ──────────                           │
-- │  BGD=30     TIEUHOA=100      HCM=10                               │
-- │  LDKHOA=20  THANKINH=200     HAIPHONG=20                          │
-- │  NHANVIEN=10 TIMMANH=300     HANOI=30                             │
-- │                                                                    │
-- │  Quy tắc đọc: User đọc được row nếu:                             │
-- │  1. Level(user) >= Level(data)  VÀ                                │
-- │  2. Compartments(user) ⊇ Compartments(data)  VÀ                  │
-- │  3. Groups(user) ∩ Groups(data) ≠ ∅ (nếu có groups)              │
-- └──────────────────────────────────────────────────────────────────┘
-- =====================================================================

SET DEFINE OFF;
SET ECHO ON;
SET SERVEROUTPUT ON;

-- =====================================================================
-- BƯỚC 1: KÍCH HOẠT ORACLE LABEL SECURITY
-- Lưu ý: Trong Oracle 21c XE, OLS có thể cần cấu hình thêm
-- =====================================================================
PROMPT --- Kiểm tra và cài đặt OLS ---

-- Cấu hình OLS (nếu chưa được cài đặt)
-- EXEC LBACSYS.CONFIGURE_OLS;

-- Kích hoạt OLS
BEGIN
  SA_SYSDBA.ALTER_OLS_STATUS(status => 'ACTIVATE');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('OLS status: ' || SQLERRM);
END;
/

-- =====================================================================
-- BƯỚC 2: TẠO OLS POLICY
-- =====================================================================
PROMPT --- Tạo OLS Policy HOSPITAL_POLICY ---

-- Xóa policy cũ nếu tồn tại
BEGIN
  SA_SYSDBA.DROP_POLICY(
    policy_name  => 'HOSPITAL_POLICY',
    drop_column  => TRUE
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Tạo policy mới
-- NO_CONTROL: DBA/SYSTEM không bị ảnh hưởng bởi OLS
-- HIDE: Cột nhãn được ẩn khỏi SELECT *
BEGIN
  SA_SYSDBA.CREATE_POLICY(
    policy_name      => 'HOSPITAL_POLICY',
    column_name      => 'OLS_LABEL',       -- Cột nhãn được thêm vào bảng
    default_options  => 'NO_CONTROL,HIDE'
  );
END;
/

PROMPT --- Đã tạo HOSPITAL_POLICY ---

-- =====================================================================
-- BƯỚC 3: TẠO LEVELS (Mức độ bảo mật)
-- Level cao hơn = quyền xem nhiều hơn (số lớn hơn)
-- BGD(30) > LDKHOA(20) > NHANVIEN(10)
-- =====================================================================
PROMPT --- Tạo Levels ---

BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 30, 'BGD',      'Ban Giam Doc - Cap cao nhat');      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 20, 'LDKHOA',   'Lanh dao Khoa');                    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 10, 'NHANVIEN', 'Nhan vien thuong');                 EXCEPTION WHEN OTHERS THEN NULL; END;
/

PROMPT --- Đã tạo 3 Levels: BGD(30), LDKHOA(20), NHANVIEN(10) ---

-- =====================================================================
-- BƯỚC 4: TẠO COMPARTMENTS (Phòng ban/Khoa chuyên môn)
-- Mỗi compartment đại diện cho một khoa bệnh viện
-- =====================================================================
PROMPT --- Tạo Compartments ---

BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 100, 'TIEUHOA',  'Khoa Tieu Hoa');  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 200, 'THANKINH', 'Khoa Than Kinh'); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 300, 'TIMMANH',  'Khoa Tim Manh'); EXCEPTION WHEN OTHERS THEN NULL; END;
/

PROMPT --- Đã tạo 3 Compartments: TIEUHOA(100), THANKINH(200), TIMMANH(300) ---

-- =====================================================================
-- BƯỚC 5: TẠO GROUPS (Cơ sở địa lý)
-- Groups hỗ trợ phân cấp: Group cha → con
-- =====================================================================
PROMPT --- Tạo Groups ---

BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 10, 'HCM',      'TP. Ho Chi Minh', NULL);     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 20, 'HAIPHONG', 'Hai Phong',       NULL);     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 30, 'HANOI',    'Ha Noi',          NULL);     EXCEPTION WHEN OTHERS THEN NULL; END;
/

PROMPT --- Đã tạo 3 Groups: HCM(10), HAIPHONG(20), HANOI(30) ---

-- =====================================================================
-- BƯỚC 6: ÁP DỤNG POLICY VÀO BẢNG THÔNGBÁO
-- =====================================================================
PROMPT --- Áp dụng Policy vào bảng THÔNGBÁO ---

-- Xóa policy cũ trên bảng nếu tồn tại
BEGIN
  SA_POLICY_ADMIN.REMOVE_TABLE_POLICY(
    policy_name => 'HOSPITAL_POLICY',
    schema_name => 'SYSTEM',
    table_name  => 'THÔNGBÁO'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Áp dụng policy:
-- READ_CONTROL: kiểm tra nhãn khi SELECT
-- WRITE_CONTROL: kiểm tra nhãn khi INSERT/UPDATE/DELETE
-- UPDATE_CONTROL: cho phép DBA cập nhật nhãn
BEGIN
  SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
    policy_name        => 'HOSPITAL_POLICY',
    schema_name        => 'SYSTEM',
    table_name         => '"THÔNGBÁO"',
    table_options      => 'READ_CONTROL,WRITE_CONTROL,UPDATE_CONTROL',
    label_function     => NULL,
    predicate          => NULL
  );
END;
/

PROMPT --- Đã áp dụng OLS Policy vào THÔNGBÁO ---

-- =====================================================================
-- BƯỚC 7: GÁN NHÃN NGƯỜI DÙNG
-- Nhãn user = nhãn tối đa được phép đọc
-- =====================================================================
PROMPT --- Gán nhãn cho người dùng ---

-- -----------------------------------------------------------------------
-- u1: DPV001 - Giám đốc - Level BGD (đọc toàn bộ không giới hạn)
-- Nhãn: BGD - không compartment, không group → đọc được tất cả level <= BGD
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'DPV001',
    max_read_label    => 'BGD',        -- Đọc tối đa level BGD
    max_write_label   => 'BGD',        -- Viết tối đa level BGD
    min_write_label   => 'NHANVIEN',   -- Viết tối thiểu level NHANVIEN
    def_label         => 'BGD',        -- Nhãn mặc định khi INSERT
    row_label         => 'BGD'         -- Nhãn session hiện tại
  );
END;
/

-- -----------------------------------------------------------------------
-- u2: BS001 - Lãnh đạo Khoa Tim mạch tại HCM
-- Nhãn: LDKHOA:TIMMANH:HCM
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'BS001',
    max_read_label    => 'LDKHOA:TIMMANH:HCM',
    max_write_label   => 'LDKHOA:TIMMANH:HCM',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:TIMMANH:HCM',
    row_label         => 'LDKHOA:TIMMANH:HCM'
  );
END;
/

-- -----------------------------------------------------------------------
-- u3: BS002 - Lãnh đạo Khoa Thần kinh tại Hà Nội
-- Nhãn: LDKHOA:THANKINH:HANOI
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'BS002',
    max_read_label    => 'LDKHOA:THANKINH:HANOI',
    max_write_label   => 'LDKHOA:THANKINH:HANOI',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:THANKINH:HANOI',
    row_label         => 'LDKHOA:THANKINH:HANOI'
  );
END;
/

-- -----------------------------------------------------------------------
-- u4: KTV001 - Nhân viên Khoa Thần kinh tại HCM
-- Nhãn: NHANVIEN:THANKINH:HCM
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'KTV001',
    max_read_label    => 'NHANVIEN:THANKINH:HCM',
    max_write_label   => 'NHANVIEN:THANKINH:HCM',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:THANKINH:HCM',
    row_label         => 'NHANVIEN:THANKINH:HCM'
  );
END;
/

-- -----------------------------------------------------------------------
-- u5: KTV002 - Nhân viên Khoa Tim mạch tại HCM
-- Nhãn: NHANVIEN:TIMMANH:HCM
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'KTV002',
    max_read_label    => 'NHANVIEN:TIMMANH:HCM',
    max_write_label   => 'NHANVIEN:TIMMANH:HCM',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:TIMMANH:HCM',
    row_label         => 'NHANVIEN:TIMMANH:HCM'
  );
END;
/

-- -----------------------------------------------------------------------
-- u6: BS003 - Lãnh đạo phòng Khoa Tim mạch tại HCM
-- Nhãn: LDKHOA:TIMMANH:HCM
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'BS003',
    max_read_label    => 'LDKHOA:TIMMANH:HCM',
    max_write_label   => 'LDKHOA:TIMMANH:HCM',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:TIMMANH:HCM',
    row_label         => 'LDKHOA:TIMMANH:HCM'
  );
END;
/

-- -----------------------------------------------------------------------
-- u7: DPV002 - Lãnh đạo phòng đọc toàn bộ (LDKHOA, all compartments)
-- Nhãn: LDKHOA (không giới hạn compartment → đọc tất cả compartment)
-- Lưu ý: Không có compartment → đọc được row không có compartment VÀ
--        đọc được row có bất kỳ compartment nào
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'DPV002',
    max_read_label    => 'LDKHOA:TIEUHOA,THANKINH,TIMMANH:HCM,HAIPHONG,HANOI',
    max_write_label   => 'LDKHOA:TIEUHOA,THANKINH,TIMMANH:HCM,HAIPHONG,HANOI',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA',
    row_label         => 'LDKHOA'
  );
END;
/

-- -----------------------------------------------------------------------
-- u8: BN001 - Nhân viên (bệnh nhân) Khoa Tiêu hóa tại Hà Nội
-- Nhãn: NHANVIEN:TIEUHOA:HANOI
-- -----------------------------------------------------------------------
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name => 'HOSPITAL_POLICY',
    user_name   => 'BN001',
    max_read_label    => 'NHANVIEN:TIEUHOA:HANOI',
    max_write_label   => 'NHANVIEN',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:TIEUHOA:HANOI',
    row_label         => 'NHANVIEN:TIEUHOA:HANOI'
  );
END;
/

PROMPT --- Đã gán nhãn cho 8 users ---

-- =====================================================================
-- BƯỚC 8: GÁN NHÃN DỮ LIỆU THÔNGBÁO
-- Sau khi policy được áp dụng, cần gán nhãn cho từng row
-- Dùng SA_LABEL_ADMIN.CREATE_LABEL để tạo nhãn trước khi gán
-- =====================================================================
PROMPT --- Tạo các nhãn dữ liệu ---

-- Tạo các nhãn cần thiết cho dữ liệu
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1001, 'NHANVIEN',                         TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1002, 'BGD',                               TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1003, 'LDKHOA',                            TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1004, 'LDKHOA:TIEUHOA',                    TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1005, 'NHANVIEN:TIEUHOA:HCM',              TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1006, 'NHANVIEN:TIEUHOA:HANOI',            TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1007, 'LDKHOA:TIEUHOA,THANKINH:HAIPHONG',  TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/

PROMPT --- Đã tạo 7 nhãn dữ liệu ---

-- =====================================================================
-- BƯỚC 9: GÁN NHÃN CHO TỪNG ROW THÔNGBÁO
-- Dùng SA_LABEL_ADMIN.CREATE_LABEL tag và UPDATE cột OLS_LABEL
-- =====================================================================
PROMPT --- Gán nhãn dữ liệu cho THÔNGBÁO ---

-- t1 (MÃTB=1): NHANVIEN - toàn bộ nhân viên đọc được
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN')
WHERE "MÃTB" = 1;

-- t2 (MÃTB=2): BGD - chỉ Ban Giám Đốc
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'BGD')
WHERE "MÃTB" = 2;

-- t3 (MÃTB=3): LDKHOA - lãnh đạo khoa trở lên
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA')
WHERE "MÃTB" = 3;

-- t4 (MÃTB=4): LDKHOA:TIEUHOA - lãnh đạo khoa Tiêu hóa
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA:TIEUHOA')
WHERE "MÃTB" = 4;

-- t5 (MÃTB=5): NHANVIEN:TIEUHOA:HCM - nhân viên Tiêu hóa tại HCM
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN:TIEUHOA:HCM')
WHERE "MÃTB" = 5;

-- t6 (MÃTB=6): NHANVIEN:TIEUHOA:HANOI - nhân viên Tiêu hóa tại Hà Nội
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN:TIEUHOA:HANOI')
WHERE "MÃTB" = 6;

-- t7 (MÃTB=7): LDKHOA:TIEUHOA,THANKINH:HAIPHONG - lãnh đạo Tiêu hóa+Thần kinh tại Hải Phòng
UPDATE "THÔNGBÁO"
SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA:TIEUHOA,THANKINH:HAIPHONG')
WHERE "MÃTB" = 7;

COMMIT;
PROMPT --- Đã gán nhãn cho 7 thông báo ---

-- =====================================================================
-- BƯỚC 10: KIỂM TRA VÀ DEMO OLS
-- =====================================================================
PROMPT --- Kiểm tra OLS Policy ---
SELECT
  POLICY_NAME,
  STATUS,
  COLUMN_NAME
FROM SA_POLICIES
WHERE POLICY_NAME = 'HOSPITAL_POLICY';

PROMPT --- Kiểm tra Labels đã tạo ---
SELECT LABEL_TAG, LABEL, POLICY_NAME, DATA_LABEL
FROM SA_LABELS
WHERE POLICY_NAME = 'HOSPITAL_POLICY'
ORDER BY LABEL_TAG;

PROMPT --- Kiểm tra nhãn của Users ---
SELECT USER_NAME, MAX_READ_LABEL, MAX_WRITE_LABEL, DEF_LABEL, ROW_LABEL
FROM SA_USER_LABELS
WHERE POLICY_NAME = 'HOSPITAL_POLICY'
ORDER BY USER_NAME;

PROMPT --- Kiểm tra nhãn dữ liệu THÔNGBÁO ---
SELECT
  "MÃTB",
  SUBSTR("NỘIDUNG", 1, 50) AS NOIDUNG_SUMMARY,
  LABEL_TO_CHAR(OLS_LABEL) AS NHAN_OLS
FROM "THÔNGBÁO"
ORDER BY "MÃTB";

-- =====================================================================
-- BẢNG PHÂN TÍCH: AI ĐỌC ĐƯỢC GÌ?
-- =====================================================================
-- THÔNGBÁO  | NHÃN DỮ LIỆU              | CÓ THỂ ĐỌC BỞI
-- ----------|---------------------------|------------------------
-- t1 (MÃTB=1)| NHANVIEN                 | Tất cả (>=NHANVIEN)
-- t2 (MÃTB=2)| BGD                      | Chỉ DPV001 (BGD)
-- t3 (MÃTB=3)| LDKHOA                   | BGD, LDKHOA (DPV001,DPV002,BS001-3)
-- t4 (MÃTB=4)| LDKHOA:TIEUHOA           | BGD, LDKHOA với TIEUHOA compartment
-- t5 (MÃTB=5)| NHANVIEN:TIEUHOA:HCM     | >=NHANVIEN có TIEUHOA tại HCM
-- t6 (MÃTB=6)| NHANVIEN:TIEUHOA:HANOI   | >=NHANVIEN có TIEUHOA tại HANOI
-- t7 (MÃTB=7)| LDKHOA:TIEUHOA,THANKINH: | LDKHOA có TIEUHOA hoặc THANKINH tại HAIPHONG
--            |   HAIPHONG               |

PROMPT === 06_ols.sql completed successfully ===
