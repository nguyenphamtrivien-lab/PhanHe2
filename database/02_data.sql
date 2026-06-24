-- =====================================================================
-- File: 02_data.sql
-- Dự án: PhanHe2 - Hệ thống Quản lý Y tế Bệnh viện
-- Oracle 21c XE, Charset: AL32UTF8
-- Mô tả: Dữ liệu mẫu cho hệ thống
-- Chạy với quyền: SYSTEM hoặc DBA (sau khi chạy 01_schema.sql)
-- Thứ tự chạy: 2/8
-- =====================================================================

-- SET DEFINE OFF;
-- SET ECHO ON;
-- SET SERVEROUTPUT ON;

-- Đặt định dạng ngày tháng
ALTER SESSION SET NLS_DATE_FORMAT      = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

-- =====================================================================
-- DỮ LIỆU BỆNH NHÂN (5 bệnh nhân)
-- ORAUSER liên kết với tài khoản Oracle: bn001..bn005
-- =====================================================================
-- PROMPT --- Insert 5 bệnh nhân ---

INSERT INTO "BỆNHNHÂN" (
  "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC", "ORAUSER"
) VALUES (
  'BN001', N'Nguyễn Văn An', N'Nam', TO_DATE('15/03/1985', 'DD/MM/YYYY'), '079085012345',
  N'12', N'Lê Lợi', N'Quận 1', N'TP. Hồ Chí Minh',
  N'Tiểu đường type 2 (phát hiện 2018), Tăng huyết áp độ II',
  N'Cha: bệnh tim mạch; Mẹ: tiểu đường',
  N'Penicillin, Sulfa',
  'BN001'
);

INSERT INTO "BỆNHNHÂN" (
  "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC", "ORAUSER"
) VALUES (
  'BN002', N'Trần Thị Bình', N'Nữ', TO_DATE('22/07/1990', 'DD/MM/YYYY'), '031090023456',
  N'45', N'Nguyễn Huệ', N'Quận 1', N'TP. Hồ Chí Minh',
  N'Hen suyễn (từ nhỏ), Viêm xoang mãn tính',
  N'Không có tiền sử đặc biệt',
  N'Aspirin',
  'BN002'
);

INSERT INTO "BỆNHNHÂN" (
  "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC", "ORAUSER"
) VALUES (
  'BN003', N'Lê Minh Cường', N'Nam', TO_DATE('08/11/1978', 'DD/MM/YYYY'), '026078034567',
  N'78', N'Trần Phú', N'Hoàn Kiếm', N'Hà Nội',
  N'Viêm loét dạ dày (phát hiện 2015), Đau thần kinh tọa L4-L5',
  N'Ông nội: ung thư dạ dày',
  N'Không',
  'BN003'
);

INSERT INTO "BỆNHNHÂN" (
  "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC", "ORAUSER"
) VALUES (
  'BN004', N'Phạm Thị Dung', N'Nữ', TO_DATE('30/04/1995', 'DD/MM/YYYY'), '033095045678',
  N'23', N'Lý Thường Kiệt', N'Hải Châu', N'Đà Nẵng',
  N'Suy giáp (phát hiện 2020)',
  N'Không có tiền sử đặc biệt',
  N'Iodine (dị ứng nhẹ)',
  'BN004'
);

INSERT INTO "BỆNHNHÂN" (
  "MÃBN", "TÊNBN", "PHÁI", "NGÀYSINH", "CCCD",
  "SỐNHÀ", "TÊNĐƯỜNG", "QUẬNHUYỆN", "TỈNHTP",
  "TIỀNSỬBỆNH", "TIỀNSỬBỆNHGĐ", "DỊỨNGTHUỐC", "ORAUSER"
) VALUES (
  'BN005', N'Hoàng Văn Em', N'Nam', TO_DATE('12/09/2000', 'DD/MM/YYYY'), '001000056789',
  N'5', N'Bạch Đằng', N'Hồng Bàng', N'Hải Phòng',
  N'Không có bệnh nền',
  N'Không có tiền sử đặc biệt',
  N'Không',
  'BN005'
);

COMMIT;
-- PROMPT --- Đã insert 5 bệnh nhân ---

-- =====================================================================
-- DỮ LIỆU NHÂN VIÊN (7 nhân viên)
-- 2 Điều phối viên (dpv001, dpv002)
-- 3 Bác sĩ/Y sĩ (bs001, bs002, bs003)
-- 2 Kỹ thuật viên (ktv001, ktv002)
-- =====================================================================
-- PROMPT --- Insert 7 nhân viên ---

-- Điều phối viên 1 (Giám đốc - OLS BGD toàn bộ)
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'DPV001', N'Võ Thị Hà', N'Nữ', TO_DATE('15/06/1980', 'DD/MM/YYYY'), '079080111111',
  N'TP. Hồ Chí Minh', '0901234567',
  N'Điều phối viên', N'Hành chính - Điều phối', 'DPV001'
);

-- Điều phối viên 2 (Lãnh đạo phòng - OLS LDKHOA all compartments)
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'DPV002', N'Nguyễn Minh Khoa', N'Nam', TO_DATE('22/03/1975', 'DD/MM/YYYY'), '026075222222',
  N'Hà Nội', '0912345678',
  N'Điều phối viên', N'Hành chính - Điều phối', 'DPV002'
);

-- Bác sĩ 1 - Lãnh đạo Khoa Tim mạch tại HCM
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'BS001', N'Trần Văn Long', N'Nam', TO_DATE('10/08/1972', 'DD/MM/YYYY'), '079072333333',
  N'TP. Hồ Chí Minh', '0923456789',
  N'Bác sĩ/Y sĩ', N'Tim mạch', 'BS001'
);

-- Bác sĩ 2 - Lãnh đạo Khoa Thần kinh tại Hà Nội
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'BS002', N'Lê Thị Mai', N'Nữ', TO_DATE('05/12/1978', 'DD/MM/YYYY'), '001078444444',
  N'Hà Nội', '0934567890',
  N'Bác sĩ/Y sĩ', N'Thần kinh', 'BS002'
);

-- Bác sĩ 3 - Lãnh đạo phòng Khoa Tim mạch tại HCM
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'BS003', N'Phạm Quốc Hùng', N'Nam', TO_DATE('18/04/1980', 'DD/MM/YYYY'), '079080555555',
  N'TP. Hồ Chí Minh', '0945678901',
  N'Bác sĩ/Y sĩ', N'Tim mạch', 'BS003'
);

-- Kỹ thuật viên 1 - Nhân viên Khoa Thần kinh tại HCM
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'KTV001', N'Đặng Thị Lan', N'Nữ', TO_DATE('25/09/1988', 'DD/MM/YYYY'), '079088666666',
  N'TP. Hồ Chí Minh', '0956789012',
  N'Kỹ thuật viên', N'Thần kinh', 'KTV001'
);

-- Kỹ thuật viên 2 - Nhân viên Khoa Tim mạch tại HCM
INSERT INTO "NHÂNVIÊN" (
  "MÃNV", "HỌTÊN", "PHÁI", "NGÀYSINH", "CMND",
  "QUÊQUÁN", "SỐĐt", "VAITRÒ", "CHUYÊNKHOA", "ORAUSER"
) VALUES (
  'KTV002', N'Bùi Văn Nam', N'Nam', TO_DATE('14/02/1992', 'DD/MM/YYYY'), '079092777777',
  N'TP. Hồ Chí Minh', '0967890123',
  N'Kỹ thuật viên', N'Tim mạch', 'KTV002'
);

COMMIT;
-- PROMPT --- Đã insert 7 nhân viên (2 DPV, 3 BS, 2 KTV) ---

-- =====================================================================
-- DỮ LIỆU HỒ SƠ BỆNH ÁN (3 HSBA)
-- =====================================================================
-- PROMPT --- Insert 3 HSBA ---

INSERT INTO "HSBA" ("MÃHSBA", "MÃBN", "NGÀY", "CHẨNĐOÁN", "ĐIỀUTRỊ", "MÃBS", "MÃKHOA", "KẾTLUẬN")
VALUES (
  'HSBA001', 'BN001', TO_DATE('10/06/2026', 'DD/MM/YYYY'),
  N'Tăng huyết áp độ II (HA: 160/95 mmHg), Tiểu đường type 2 không kiểm soát tốt (HbA1c: 8.5%)',
  N'Amlodipine 5mg/ngày, Metformin 500mg x2/ngày, Chế độ ăn ít muối đường, Tập thể dục 30 phút/ngày',
  'BS001', N'Tim mạch',
  N'Bệnh nhân cần theo dõi huyết áp hàng tuần, tái khám sau 4 tuần. Cân nhắc tăng liều Metformin nếu HbA1c không cải thiện'
);

INSERT INTO "HSBA" ("MÃHSBA", "MÃBN", "NGÀY", "CHẨNĐOÁN", "ĐIỀUTRỊ", "MÃBS", "MÃKHOA", "KẾTLUẬN")
VALUES (
  'HSBA002', 'BN002', TO_DATE('11/06/2026', 'DD/MM/YYYY'),
  N'Hen suyễn giai đoạn cấp tính, Nhiễm trùng hô hấp trên',
  N'Salbutamol MDI 2 puffs x4 lần/ngày, Amoxicillin 500mg x3/ngày x7 ngày, Budesonide hít 200mcg x2/ngày',
  'BS001', N'Tim mạch',
  N'Theo dõi SpO2 thường xuyên, nhập viện nếu SpO2 < 90%. Hẹn tái khám sau 1 tuần để đánh giá đáp ứng'
);

INSERT INTO "HSBA" ("MÃHSBA", "MÃBN", "NGÀY", "CHẨNĐOÁN", "ĐIỀUTRỊ", "MÃBS", "MÃKHOA", "KẾTLUẬN")
VALUES (
  'HSBA003', 'BN003', TO_DATE('12/06/2026', 'DD/MM/YYYY'),
  N'Đau thần kinh tọa L4-L5, Viêm dạ dày mãn tính tái phát',
  N'Diclofenac 75mg x2/ngày, Omeprazole 20mg/ngày, Vật lý trị liệu 5 buổi/tuần',
  'BS002', N'Thần kinh',
  N'Hẹn tái khám sau 2 tuần, chụp MRI cột sống thắt lưng nếu không cải thiện. Bổ sung kháng H.Pylori theo kết quả xét nghiệm'
);

COMMIT;
-- PROMPT --- Đã insert 3 HSBA ---

-- =====================================================================
-- DỮ LIỆU HSBA_DV (Dịch vụ kỹ thuật)
-- =====================================================================
-- PROMPT --- Insert 5 HSBA_DV ---

INSERT INTO "HSBA_DV" ("MÃHSBA", "LOẠIDV", "NGÀYDV", "MÃKTV", "KẾTQUẢ")
VALUES (
  'HSBA001', N'Xét nghiệm máu toàn bộ', TO_DATE('10/06/2026', 'DD/MM/YYYY'),
  'KTV002',
  N'HbA1c: 8.5% (cao), Glucose lúc đói: 12.3 mmol/L, Cholesterol toàn phần: 6.2 mmol/L, Triglyceride: 2.8 mmol/L. Đề nghị điều chỉnh liều Metformin và theo dõi lipid máu.'
);

INSERT INTO "HSBA_DV" ("MÃHSBA", "LOẠIDV", "NGÀYDV", "MÃKTV", "KẾTQUẢ")
VALUES (
  'HSBA001', N'Đo điện tim ECG 12 chuyển đạo', TO_DATE('10/06/2026', 'DD/MM/YYYY'),
  'KTV002',
  N'Nhịp xoang đều, tần số 78 bpm. PR: 0.16s, QRS: 0.09s, QT: 0.38s. ST bình thường. Không có dấu hiệu thiếu máu cục bộ hay phì đại thất trái.'
);

INSERT INTO "HSBA_DV" ("MÃHSBA", "LOẠIDV", "NGÀYDV", "MÃKTV", "KẾTQUẢ")
VALUES (
  'HSBA002', N'Đo chức năng hô hấp (Spirometry)', TO_DATE('11/06/2026', 'DD/MM/YYYY'),
  'KTV002',
  N'FVC: 3.2L (82% dự đoán), FEV1: 2.1L (68% dự đoán), FEV1/FVC: 65.6% (giảm). Hội chứng tắc nghẽn nhẹ đến trung bình. Đáp ứng tốt với thuốc giãn phế quản (tăng FEV1 15% sau test).'
);

INSERT INTO "HSBA_DV" ("MÃHSBA", "LOẠIDV", "NGÀYDV", "MÃKTV", "KẾTQUẢ")
VALUES (
  'HSBA003', N'Chụp X-quang cột sống thắt lưng', TO_DATE('12/06/2026', 'DD/MM/YYYY'),
  'KTV001',
  N'Hẹp khe gian đốt sống L4-L5 (giảm 30% so với bình thường). Thoái hóa đốt sống nhẹ, gai xương nhỏ L4, L5. Không thấy gãy xương hay trật khớp. Đề nghị chụp MRI để đánh giá đĩa đệm.'
);

INSERT INTO "HSBA_DV" ("MÃHSBA", "LOẠIDV", "NGÀYDV", "MÃKTV", "KẾTQUẢ")
VALUES (
  'HSBA003', N'Xét nghiệm H.Pylori (CLO test)', TO_DATE('12/06/2026', 'DD/MM/YYYY'),
  'KTV001',
  N'H.Pylori dương tính (++). Cần bổ sung phác đồ diệt H.Pylori (Amoxicillin + Clarithromycin + PPI x14 ngày).'
);

COMMIT;
-- PROMPT --- Đã insert 5 HSBA_DV ---

-- =====================================================================
-- DỮ LIỆU ĐƠN THUỐC
-- =====================================================================
-- PROMPT --- Insert 6 đơn thuốc ---

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA001', TO_DATE('10/06/2026', 'DD/MM/YYYY'),
  N'Amlodipine 5mg',
  N'Uống 1 viên/ngày vào buổi sáng sau ăn. Dùng liên tục, không tự ý ngừng thuốc. Theo dõi phù chi dưới.'
);

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA001', TO_DATE('10/06/2026', 'DD/MM/YYYY'),
  N'Metformin 500mg',
  N'Uống 1 viên x2 lần/ngày (sáng và tối) trong bữa ăn. Theo dõi đường huyết hàng ngày. Ngưng nếu có dấu hiệu nhiễm toan lactic.'
);

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA002', TO_DATE('11/06/2026', 'DD/MM/YYYY'),
  N'Salbutamol MDI 100mcg',
  N'Xịt 2 nhát x4 lần/ngày. Dùng khi khó thở, xịt ngay trước khi hít vào và nín thở 10 giây. Tối đa 8 nhát/ngày.'
);

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA002', TO_DATE('11/06/2026', 'DD/MM/YYYY'),
  N'Amoxicillin 500mg',
  N'Uống 1 viên x3 lần/ngày x7 ngày. Uống đúng liều, không bỏ ngày dù cảm thấy khỏe. Tái khám nếu không cải thiện sau 3 ngày.'
);

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA003', TO_DATE('12/06/2026', 'DD/MM/YYYY'),
  N'Diclofenac Sodium 75mg',
  N'Uống 1 viên x2 lần/ngày trong bữa ăn. Không dùng quá 14 ngày liên tục. Phải uống kèm Omeprazole để bảo vệ dạ dày.'
);

INSERT INTO "ĐƠNTHUỐC" ("MÃHSBA", "NGÀYĐT", "TÊNTHUỐC", "LIỀUDÙNG")
VALUES (
  'HSBA003', TO_DATE('12/06/2026', 'DD/MM/YYYY'),
  N'Omeprazole 20mg',
  N'Uống 1 viên/ngày trước ăn 30 phút. Bảo vệ dạ dày khi dùng Diclofenac. Dùng trong suốt thời gian dùng thuốc kháng viêm.'
);

COMMIT;
-- PROMPT --- Đã insert 6 đơn thuốc ---

-- =====================================================================
-- DỮ LIỆU THÔNG BÁO (7 thông báo cho OLS demo)
-- Nhãn OLS sẽ được gán trong file 06_ols.sql
-- t1=MÃTB:1, t2=MÃTB:2, ..., t7=MÃTB:7
-- =====================================================================
-- PROMPT --- Insert 7 thông báo ---

-- t1: Toàn bộ nhân viên (NHANVIEN)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB001] Thông báo họp toàn thể nhân viên bệnh viện: Ngày 25/06/2026 lúc 08:00, tại Hội trường A. Tất cả nhân viên vui lòng tham dự đúng giờ. Nội dung: Tổng kết quý II và kế hoạch quý III năm 2026.',
  TIMESTAMP '2026-06-22 08:00:00',
  N'Hội trường A - Tầng 1'
);

-- t2: Ban giám đốc (BGD)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB002] MẬT - Thông báo họp Ban Giám Đốc mở rộng: Ngày 24/06/2026 lúc 14:00. Nội dung: Kế hoạch đầu tư trang thiết bị y tế năm 2027, ngân sách và phân bổ nguồn lực. Tài liệu kèm theo mang ký hiệu MẬT.',
  TIMESTAMP '2026-06-22 09:00:00',
  N'Phòng họp Ban Giám Đốc - Tầng 5'
);

-- t3: Lãnh đạo khoa (LDKHOA)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB003] Thông báo dành cho Lãnh đạo các Khoa: Hội nghị chuyên đề cập nhật phác đồ điều trị mới ngày 23/06/2026 lúc 13:30. Mỗi khoa chuẩn bị báo cáo tình hình điều trị 6 tháng đầu năm.',
  TIMESTAMP '2026-06-22 09:30:00',
  N'Phòng họp chuyên môn - Tầng 3'
);

-- t4: Lãnh đạo khoa Tiêu hóa (LDKHOA:TIEUHOA)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB004] Thông báo nội bộ Khoa Tiêu Hóa (Lãnh đạo khoa): Triển khai kỹ thuật nội soi mới từ 01/07/2026. Lãnh đạo khoa vui lòng phân công nhân sự, chuẩn bị quy trình và tổ chức đào tạo nhân viên.',
  TIMESTAMP '2026-06-22 10:00:00',
  N'Khoa Tiêu Hóa - Phòng họp'
);

-- t5: Nhân viên Tiêu hóa tại HCM (NHANVIEN:TIEUHOA:HCM)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB005] Thông báo Khoa Tiêu Hóa - Cơ sở TP.HCM: Lịch trực tháng 7/2026 đã được cập nhật trên hệ thống. Nhân viên vui lòng kiểm tra và phản hồi trước 28/06/2026 nếu có vướng mắc.',
  TIMESTAMP '2026-06-22 10:30:00',
  N'Khoa Tiêu Hóa - Cơ sở TP.HCM'
);

-- t6: Nhân viên Tiêu hóa tại Hà Nội (NHANVIEN:TIEUHOA:HANOI)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB006] Thông báo Khoa Tiêu Hóa - Cơ sở Hà Nội: Buổi đào tạo kỹ năng nội soi dạ dày cho kỹ thuật viên sẽ diễn ra vào ngày 26/06/2026 lúc 14:00 tại phòng đào tạo. Bắt buộc tham dự.',
  TIMESTAMP '2026-06-22 11:00:00',
  N'Khoa Tiêu Hóa - Cơ sở Hà Nội'
);

-- t7: Lãnh đạo Tiêu hóa+Thần kinh tại Hải Phòng (LDKHOA:TIEUHOA,THANKINH:HAIPHONG)
INSERT INTO "THÔNGBÁO" ("NỘIDUNG", "NGÀYGIỜ", "ĐỊAĐIỂM")
VALUES (
  N'[TB007] Thông báo Lãnh đạo Khoa Tiêu Hóa và Thần Kinh - Cơ sở Hải Phòng: Kiểm tra định kỳ trang thiết bị y tế và hệ thống phòng cháy chữa cháy vào ngày 27/06/2026. Lãnh đạo khoa phụ trách giám sát và ký biên bản.',
  TIMESTAMP '2026-06-22 11:30:00',
  N'Khoa Tiêu Hóa và Thần Kinh - Cơ sở Hải Phòng'
);

COMMIT;
-- PROMPT --- Đã insert 7 thông báo ---

-- Kiểm tra kết quả
-- PROMPT --- Thống kê dữ liệu đã insert ---
SELECT 'BỆNHNHÂN' AS BANG, COUNT(*) AS SO_LUONG FROM "BỆNHNHÂN"
UNION ALL SELECT 'NHÂNVIÊN', COUNT(*) FROM "NHÂNVIÊN"
UNION ALL SELECT 'HSBA',     COUNT(*) FROM "HSBA"
UNION ALL SELECT 'HSBA_DV',  COUNT(*) FROM "HSBA_DV"
UNION ALL SELECT 'ĐƠNTHUỐC', COUNT(*) FROM "ĐƠNTHUỐC"
UNION ALL SELECT 'THÔNGBÁO', COUNT(*) FROM "THÔNGBÁO";

-- PROMPT === 02_data.sql completed successfully ===
