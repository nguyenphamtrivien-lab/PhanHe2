-- =====================================================================
-- File: 06_ols.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: Yêu cầu 2 - Oracle Label Security (OLS)
--        Cơ chế phát tán thông báo theo nhãn bảo mật 3 thành phần
-- Chạy với quyền: SYSDBA hoặc LBAC_DBA
-- Thứ tự chạy: 6/8
--
-- ĐIỀU KIỆN TIÊN QUYẾT:
--   Oracle Label Security phải được cài đặt:
--     EXEC LBACSYS.CONFIGURE_OLS;
--     EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
--
-- KIẾN TRÚC NHÃN OLS MỚI (Review Lần 2):
-- ┌──────────────────────────────────────────────────────────────────┐
-- │ Cấu trúc nhãn 3 thành phần: Level : Compartments : Groups        │
-- │                                                                  │
-- │ THÀNH PHẦN   | ĐẠI DIỆN     | LOGIC ĐỌC (READ_CONTROL)           │
-- │ ──────────── | ──────────── | ────────────────────────────────── │
-- │ LEVEL        | Cấp bậc      | Level(User) >= Level(Data)         │
-- │              | (BGD/LDKHOA..)                                    │
-- │ COMPARTMENT  | Cơ sở (Địa lý)| Comps(Data) ⊆ Comps(User)          │
-- │              | (HCM/HP/HN)  | (Logic AND - Bắt buộc có ĐỦ)       │
-- │ GROUP        | Khoa         | Grps(Data) = ∅ HOẶC                │
-- │              | (TH/TK/TM)   | Grps(User) ∩ Grps(Data) ≠ ∅        │
-- │                             | (Logic OR - Có ÍT NHẤT 1 là đủ)    │
-- │                                                                  │
-- │ GIẢI THÍCH LÝ DO DÙNG KHOA LÀM GROUP VÀ CƠ SỞ LÀM COMPARTMENT:   │
-- │   t7 yêu cầu "Gửi đến Khoa tiêu hóa VÀ Khoa thần kinh tại HP".   │
-- │   Về mặt nghiệp vụ, câu này nghĩa là: LĐ Khoa Tiêu Hóa tại HP    │
-- │   đọc được, LĐ Khoa Thần Kinh tại HP cũng đọc được (HOẶC).       │
-- │   Nếu dùng Khoa làm Compartment, user PHẢI có TẤT CẢ compartment │
-- │   của data (nghĩa là phải làm lãnh đạo ở CẢ 2 khoa cùng lúc),    │
-- │   điều này sai thực tế. Do đó Khoa BẮT BUỘC phải là Group.       │
-- └──────────────────────────────────────────────────────────────────┘
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- =====================================================================
-- BƯỚC 1: KÍCH HOẠT ORACLE LABEL SECURITY
-- =====================================================================
-- PROMPT --- Kiểm tra và cài đặt OLS ---

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
-- PROMPT --- Tạo OLS Policy HOSPITAL_POLICY ---

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
BEGIN
  SA_SYSDBA.CREATE_POLICY(
    policy_name      => 'HOSPITAL_POLICY',
    column_name      => 'OLS_LABEL',
    default_options  => 'NO_CONTROL,HIDE'
  );
END;
/

-- PROMPT --- Đã tạo HOSPITAL_POLICY ---

-- =====================================================================
-- BƯỚC 3: TẠO LEVELS (Cấp bậc)
-- BGD(30) > LDKHOA(20) > NHANVIEN(10)
-- =====================================================================
-- PROMPT --- Tạo Levels ---

BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 30, 'BGD',      'Ban Giam Doc');      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 20, 'LDKHOA',   'Lanh dao Khoa');     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_LEVEL('HOSPITAL_POLICY', 10, 'NHANVIEN', 'Nhan vien');         EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BƯỚC 4: TẠO COMPARTMENTS (Cơ sở địa lý)
-- Dùng Compartment vì một thông báo địa lý thường gắn chặt với địa lý đó
-- =====================================================================
-- PROMPT --- Tạo Compartments ---

BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 100, 'HCM',      'TP Ho Chi Minh'); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 200, 'HAIPHONG', 'Hai Phong');      EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_COMPARTMENT('HOSPITAL_POLICY', 300, 'HANOI',    'Ha Noi');         EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BƯỚC 5: TẠO GROUPS (Khoa chuyên môn)
-- Dùng Group để hỗ trợ logic OR (thông báo gửi cho nhiều Khoa)
-- =====================================================================
-- PROMPT --- Tạo Groups ---

BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 10, 'TIEUHOA',  'Khoa Tieu Hoa',  NULL); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 20, 'THANKINH', 'Khoa Than Kinh', NULL); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_COMPONENTS.CREATE_GROUP('HOSPITAL_POLICY', 30, 'TIMMANH',  'Khoa Tim Manh',  NULL); EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BƯỚC 6: ÁP DỤNG POLICY VÀO BẢNG THÔNGBÁO
-- =====================================================================
-- PROMPT --- Áp dụng Policy vào bảng THÔNGBÁO ---

BEGIN
  SA_POLICY_ADMIN.REMOVE_TABLE_POLICY(
    policy_name => 'HOSPITAL_POLICY',
    schema_name => 'SYSTEM',
    table_name  => 'THÔNGBÁO'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
    policy_name        => 'HOSPITAL_POLICY',
    schema_name        => 'SYSTEM',
    table_name         => 'THÔNGBÁO',
    table_options      => 'READ_CONTROL,WRITE_CONTROL,UPDATE_CONTROL',
    label_function     => NULL,
    predicate          => NULL
  );
END;
/

-- =====================================================================
-- BƯỚC 7: GÁN NHÃN NGƯỜI DÙNG
-- Format: LEVEL : COMPARTMENTS : GROUPS
-- =====================================================================
-- PROMPT --- Gán nhãn cho người dùng ---

-- u1: Giám đốc - đọc TOÀN BỘ thông báo
-- Cần full Compartments và full Groups để không bị chặn bởi bất kỳ row nào
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'DPV001',
    max_read_label    => 'BGD:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH',
    max_write_label   => 'BGD:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'BGD',
    row_label         => 'BGD'
  );
END;
/

-- u2: Lãnh đạo Khoa tim mạch tại Hồ Chí Minh
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'BS001',
    max_read_label    => 'LDKHOA:HCM:TIMMANH',
    max_write_label   => 'LDKHOA:HCM:TIMMANH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:HCM:TIMMANH',
    row_label         => 'LDKHOA:HCM:TIMMANH'
  );
END;
/

-- u3: Lãnh đạo Khoa thần kinh tại Hà Nội
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'BS002',
    max_read_label    => 'LDKHOA:HANOI:THANKINH',
    max_write_label   => 'LDKHOA:HANOI:THANKINH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:HANOI:THANKINH',
    row_label         => 'LDKHOA:HANOI:THANKINH'
  );
END;
/

-- u4: Nhân viên thuộc Khoa thần kinh tại Hồ Chí Minh
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'KTV001',
    max_read_label    => 'NHANVIEN:HCM:THANKINH',
    max_write_label   => 'NHANVIEN:HCM:THANKINH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:HCM:THANKINH',
    row_label         => 'NHANVIEN:HCM:THANKINH'
  );
END;
/

-- u5: Nhân viên thuộc Khoa tim mạch tại Hồ Chí Minh
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'KTV002',
    max_read_label    => 'NHANVIEN:HCM:TIMMANH',
    max_write_label   => 'NHANVIEN:HCM:TIMMANH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:HCM:TIMMANH',
    row_label         => 'NHANVIEN:HCM:TIMMANH'
  );
END;
/

-- u6: Lãnh đạo phòng Khoa Tim mạch tại HCM (có thể đọc t.báo của Khoa Tim Mạch tại HCM)
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'BS003',
    max_read_label    => 'LDKHOA:HCM:TIMMANH',
    max_write_label   => 'LDKHOA:HCM:TIMMANH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA:HCM:TIMMANH',
    row_label         => 'LDKHOA:HCM:TIMMANH'
  );
END;
/

-- u7: Lãnh đạo phòng đọc được TOÀN BỘ thông báo phù hợp với cấp lãnh đạo phòng
-- Tức là đọc mọi Khoa, mọi Cơ sở ở mức Level LDKHOA trở xuống
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'DPV002',
    max_read_label    => 'LDKHOA:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH',
    max_write_label   => 'LDKHOA:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH',
    min_write_label   => 'NHANVIEN',
    def_label         => 'LDKHOA',
    row_label         => 'LDKHOA'
  );
END;
/

-- u8: Nhân viên thuộc Khoa Tiêu hóa tại Hà Nội
BEGIN
  SA_USER_ADMIN.SET_USER_LABELS(
    policy_name       => 'HOSPITAL_POLICY',
    user_name         => 'BN001',
    max_read_label    => 'NHANVIEN:HANOI:TIEUHOA',
    max_write_label   => 'NHANVIEN:HANOI:TIEUHOA',
    min_write_label   => 'NHANVIEN',
    def_label         => 'NHANVIEN:HANOI:TIEUHOA',
    row_label         => 'NHANVIEN:HANOI:TIEUHOA'
  );
END;
/

-- =====================================================================
-- BƯỚC 8: TẠO NHÃN DỮ LIỆU THÔNGBÁO (t1-t7)
-- =====================================================================
-- PROMPT --- Tạo các nhãn dữ liệu ---

-- t1: Gửi đến toàn bộ nhân viên -> Level: NHANVIEN (no comp, no group)
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1001, 'NHANVIEN', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t2: Gửi đến toàn bộ Ban giám đốc -> Level: BGD
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1002, 'BGD', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t3: Gửi đến các lãnh đạo khoa -> Level: LDKHOA
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1003, 'LDKHOA', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t4: Gửi đến lãnh đạo Khoa tiêu hóa -> LDKHOA :: TIEUHOA (Group)
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1004, 'LDKHOA::TIEUHOA', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t5: Gửi đến nhân viên Khoa tiêu hóa ở HCM -> NHANVIEN : HCM : TIEUHOA
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1005, 'NHANVIEN:HCM:TIEUHOA', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t6: Gửi đến nhân viên Khoa tiêu hóa ở Hà Nội -> NHANVIEN : HANOI : TIEUHOA
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1006, 'NHANVIEN:HANOI:TIEUHOA', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- t7: Gửi đến lãnh đạo Khoa tiêu hóa VÀ Khoa thần kinh tại Hải Phòng
-- Giải thích: 1 row gửi cho 2 Khoa (Group) thì dùng OR -> Group TIEUHOA,THANKINH
-- Tại 1 cơ sở -> Compartment HAIPHONG
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1007, 'LDKHOA:HAIPHONG:TIEUHOA,THANKINH', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Nhãn max_read_label cho u1, u7 (nếu cần thiết để cache label)
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1000, 'BGD:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN SA_LABEL_ADMIN.CREATE_LABEL('HOSPITAL_POLICY', 1008, 'LDKHOA:HCM,HAIPHONG,HANOI:TIEUHOA,THANKINH,TIMMANH', TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================================
-- BƯỚC 9: GÁN NHÃN CHO TỪNG ROW THÔNGBÁO
-- =====================================================================
-- PROMPT --- Gán nhãn dữ liệu cho THÔNGBÁO ---

UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN') WHERE "MÃTB" = 1;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'BGD') WHERE "MÃTB" = 2;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA') WHERE "MÃTB" = 3;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA::TIEUHOA') WHERE "MÃTB" = 4;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN:HCM:TIEUHOA') WHERE "MÃTB" = 5;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'NHANVIEN:HANOI:TIEUHOA') WHERE "MÃTB" = 6;
UPDATE "THÔNGBÁO" SET OLS_LABEL = CHAR_TO_LABEL('HOSPITAL_POLICY', 'LDKHOA:HAIPHONG:TIEUHOA,THANKINH') WHERE "MÃTB" = 7;

COMMIT;

-- =====================================================================
-- BƯỚC 10: KIỂM TRA VÀ DEMO OLS
-- =====================================================================
-- PROMPT --- Kiểm tra Labels ---
SELECT LABEL_TAG, LABEL FROM SA_LABELS WHERE POLICY_NAME = 'HOSPITAL_POLICY' ORDER BY LABEL_TAG;

-- PROMPT --- Kiểm tra nhãn dữ liệu THÔNGBÁO ---
SELECT "MÃTB", SUBSTR("NỘIDUNG", 1, 30) AS NOIDUNG, LABEL_TO_CHAR(OLS_LABEL) AS NHAN_OLS FROM "THÔNGBÁO" ORDER BY "MÃTB";

-- =====================================================================
-- BẢNG PHÂN TÍCH CHI TIẾT: AI ĐỌC ĐƯỢC GÌ? (SAU KHI ĐỔI KIẾN TRÚC)
-- =====================================================================
-- u1 (Giám đốc toàn quyền)             -> Đọc TẤT CẢ t1-t7
-- u2 (LĐ Tim Mạch HCM)                 -> t1, t3
-- u3 (LĐ Thần Kinh HN)                 -> t1, t3
-- u4 (NV Thần Kinh HCM)                -> t1
-- u5 (NV Tim Mạch HCM)                 -> t1
-- u6 (LĐ phòng Tim Mạch HCM)           -> t1, t3
-- u7 (LĐ phòng toàn quyền mọi khoa/cs) -> t1, t3, t4, t5, t6, t7 (trừ t2 vì Level BGD)
-- u8 (NV Tiêu Hóa HN)                  -> t1, t6
--
-- GIẢI THÍCH MỘT SỐ CA ĐẶC BIỆT:
-- [t4] LDKHOA::TIEUHOA
--      - Cần Level >= LDKHOA
--      - KHÔNG cần Compartment nào (Cơ sở nào cũng được)
--      - Cần Group TIEUHOA (nếu user có TIEUHOA thì thỏa).
--      -> u1 (có đủ), u7 (có đủ). u2, u3 bị chặn vì không có group TIEUHOA.
--
-- [t7] LDKHOA:HAIPHONG:TIEUHOA,THANKINH
--      - Cần Level >= LDKHOA
--      - Cần Compartment HAIPHONG
--      - Cần Group TIEUHOA *HOẶC* THANKINH
--      -> u1 và u7 có HAIPHONG và có đủ group nên thỏa.
--      (Giả sử có u9 là LĐ Khoa Tiêu Hóa tại Hải Phòng, u9 sẽ đọc được vì khớp group TIEUHOA.
--       Tương tự u10 là LĐ Khoa Thần Kinh tại HP cũng đọc được. Đây là sức mạnh của Group OR logic).
-- =====================================================================

-- PROMPT === 06_ols.sql completed successfully ===
