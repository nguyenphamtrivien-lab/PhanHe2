-- ==============================================================================
-- File: 08_backup.sql
-- Mô tả: TC#4 - Kế hoạch Sao lưu và Phục hồi dữ liệu
-- Lưu ý: Các lệnh RMAN và LogMiner cần được thực thi qua công cụ dòng lệnh RMAN
-- hoặc SQL*Plus với quyền SYSDBA. Đây là script mẫu minh hoạ quy trình.
-- ==============================================================================
SET DEFINE OFF;

/*
==============================================================================
PHẦN 1: TÌM HIỂU VÀ ĐÁNH GIÁ CÁC PHƯƠNG PHÁP (LÝ THUYẾT)
==============================================================================

1. RMAN (Recovery Manager)
   - Ưu điểm: Công cụ mạnh mẽ nhất của Oracle. Hỗ trợ incremental backup (sao lưu 
     những block thay đổi), nén dữ liệu, mã hoá backup. Phục hồi ở mức block.
   - Khuyết điểm: Cần cấu hình và kiến thức quản trị (DBA).

2. Data Pump (EXPDP / IMPDP)
   - Ưu điểm: Trích xuất dữ liệu logic (Table, Schema). Dễ dàng chuyển dữ liệu giữa
     các môi trường hoặc khác phiên bản Oracle. Dễ sử dụng.
   - Khuyết điểm: Tốn thời gian với DB lớn, không phục hồi được đến thời điểm point-in-time.

3. LogMiner
   - Ưu điểm: Phân tích Redo Logs và Archive Logs để lấy lại các câu lệnh SQL thay đổi 
     (UNDO SQL). Giúp khôi phục lỗi do người dùng (VD: lỡ UPDATE sai dòng).
   - Khuyết điểm: Khó dùng cho phục hồi quy mô lớn, thao tác phức tạp.

4. Flashback Technology
   - Ưu điểm: Phục hồi cực nhanh lùi về một thời điểm trong quá khứ mà không cần 
     restore từ file backup (chỉ dùng UNDO data).
   - Khuyết điểm: Dữ liệu UNDO có giới hạn thời gian lưu trữ (undo_retention).

KẾT LUẬN: 
Dự án sử dụng kết hợp RMAN cho sao lưu định kỳ (chống thảm hoạ mất ổ cứng) 
và Flashback / LogMiner cho phục hồi nhanh các sự cố do người dùng (Logical errors).

==============================================================================
PHẦN 2: THỰC HÀNH CÁC PHƯƠNG PHÁP
==============================================================================
*/

-- ==============================================================================
-- A. CẤU HÌNH FLASHBACK & ARCHIVELOG (Thực hiện bởi SYSDBA)
-- ==============================================================================
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE FLASHBACK ON;
-- ALTER DATABASE OPEN;

-- Cho phép Flashback trên một số bảng quan trọng
-- ALTER TABLE SYSTEM."BỆNHNHÂN" ENABLE ROW MOVEMENT;
-- ALTER TABLE SYSTEM."HSBA" ENABLE ROW MOVEMENT;

-- ==============================================================================
-- B. KỊCH BẢN FLASHBACK TABLE
-- ==============================================================================
-- Giả sử bác sĩ lỡ tay UPDATE sai kết luận của HSBA lúc 10:00 sáng
-- Khôi phục bảng HSBA về thời điểm cách đây 15 phút:
-- FLASHBACK TABLE SYSTEM."HSBA" TO TIMESTAMP (SYSTIMESTAMP - INTERVAL '15' MINUTE);

-- ==============================================================================
-- C. SỬ DỤNG LOGMINER (Phân tích Redo Log)
-- ==============================================================================
-- 1. Bật supplemental logging
-- ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- 2. Chỉ định file log cần phân tích (Thay đường dẫn phù hợp)
-- EXEC DBMS_LOGMNR.ADD_LOGFILE(LogFileName => '/opt/oracle/oradata/XE/redo01.log', Options => DBMS_LOGMNR.NEW);

-- 3. Bắt đầu phân tích
-- EXEC DBMS_LOGMNR.START_LOGMNR(Options => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);

-- 4. Tìm kiếm các câu lệnh SQL đã làm hỏng dữ liệu và SQL để hoàn tác (UNDO)
-- SELECT SQL_REDO, SQL_UNDO FROM V$LOGMNR_CONTENTS 
-- WHERE SEG_OWNER = 'SYSTEM' AND TABLE_NAME = 'HSBA';

-- 5. Kết thúc phiên
-- EXEC DBMS_LOGMNR.END_LOGMNR;


/*
==============================================================================
D. KỊCH BẢN RMAN BACKUP VÀ RECOVERY
(Chạy trên Terminal của OS: rman target /)
==============================================================================

# 1. Full Database Backup (Thực hiện chủ nhật hàng tuần)
RMAN> BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;

# 2. Incremental Backup Level 1 (Thực hiện hằng ngày)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;

# 3. Kịch bản phục hồi khi mất Datafile
RMAN> SHUTDOWN IMMEDIATE;
RMAN> STARTUP MOUNT;
RMAN> RESTORE DATABASE;
RMAN> RECOVER DATABASE;
RMAN> ALTER DATABASE OPEN;

*/
