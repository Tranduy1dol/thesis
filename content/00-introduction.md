---
title: "Mở đầu"
unnumbered: true
---

Điện toán hiện đại đang phụ thuộc sâu sắc vào mã hóa khóa công khai, trong đó Đường cong Elliptic (Elliptic Curve Cryptography - ECC) đóng vai trò xương sống cho hầu hết các giao thức bảo mật từ TLS, SSH cho đến các hệ thống blockchain. Tuy ECC mang lại hiệu năng và kích thước khóa tối ưu, việc phụ thuộc vào các thư viện và cấu hình sinh sẵn từ các tổ chức nước ngoài cũng đặt ra những thách thức lớn về an ninh và làm chủ công nghệ lõi. Việc tự xây dựng một hệ thống từ tầng thấp nhất (Lớp số nguyên lớn U1024) đến tầng cao nhất (Chữ ký Schnorr/ECDSA) giúp loại bỏ cái vỏ bọc "hộp đen" công nghệ.

### Lý do chọn đề tài

**Sự cần thiết của Tự chủ mật mã (Loại bỏ "Hộp đen" công nghệ)**:
Hiện nay, hầu hết các hệ thống phần mềm đều sử dụng thiết kế các đường cong do Viện Tiêu chuẩn và Công nghệ Quốc gia Hoa Kỳ (NIST) hoặc các tổ chức nước ngoài khuyến cáo (như secp256r1 hay ed25519) và đóng gói sẵn dưới dạng thư viện "hộp đen" (ví dụ: OpenSSL). Tuy nhiên, việc phụ thuộc hoàn toàn vào các bộ tham số sinh sẵn đã dấy lên nhiều lo ngại về an ninh quốc gia, điển hình là nghi án cơ quan tình báo cài cắm "cửa hậu" (backdoor) vào thuật toán sinh số ngẫu nhiên Dual_EC_DRBG [@DualECDRBG]. Việc tự xây dựng một hệ thống giúp chúng ta có khả năng kiểm duyệt và làm chủ hoàn toàn công nghệ lõi, đảm bảo xác suất bằng không đối với bất kỳ dòng mã độc ngầm hay cửa hậu nào. Đây là bước đệm cần thiết hướng tới việc tự chủ "đường cong thuần Việt".

**Nhu cầu an toàn tuyệt đối trước sức mạnh máy tính cổ điển**:
Hiện nay, các tiêu chuẩn an toàn thông tin do NIST khuyến nghị thường chỉ định Đường cong Elliptic ở mức 256-bit đến tối đa 521-bit [@NIST80057]. Tuy đủ dùng trong bối cảnh hiện tại nhưng khóa 256-bit chỉ cung cấp độ an toàn dài hạn (khoảng 128-bit an toàn đối xứng). Đề tài này nhằm khám phá khả năng và sự đánh đổi (trade-off) khi đẩy cấp độ bảo mật lên bậc cực hạn: đường cong trên trường nguyên tố 1024-bit. Với tham số khổng lồ này, hệ thống cung cấp mức độ an toàn xấp xỉ 512-bit, khiến cho mọi cuộc tấn công bằng máy tính cổ điển sử dụng các thuật toán giải bài toán logarit rời rạc (DLP) tốt nhất hiện nay như thuật toán Pollard's rho hay Baby-step Giant-step trở thành bất khả thi tuyệt đối trong biên niên kỷ tương lai.

**Vấn đề an toàn bộ nhớ trong Mật mã học**:
Trong thực tế triển khai, các thư viện mật mã truyền thống chủ yếu được viết bằng C/C++, dẫn tới việc thường xuyên đối mặt với các lỗ hổng hệ thống nghiêm trọng liên quan đến an toàn bộ nhớ. Tiêu biểu có thể kể đến sự cố rò rỉ bộ nhớ Heartbleed năm 2014, đe dọa trực tiếp sự toàn vẹn của nền tảng Internet toàn cầu [@CVE_Heartbleed]. Theo thống kê từ báo cáo của hệ điều hành Microsoft, khoảng 70% các bản vá lỗi bảo mật (CVE) cốt lõi của họ đều có nguyên nhân trực tiếp từ những lỗi quản lý bộ nhớ như vậy [@MicrosoftMemorySafety]. Thiết kế của đề tài này giải quyết triệt để rủi ro đó ngay ở giai đoạn đầu bằng cách sử dụng Rust – một ngôn ngữ lập trình hệ thống hiện đại, đảm bảo nguyên tắc an toàn bộ nhớ (memory-safe) ở cấp độ trình biên dịch. Điều này giúp hệ thống triệt tiêu hoàn toàn rủi ro tràn bộ nhớ đệm (buffer overflow) hay sử dụng vùng nhớ đã giải phóng (use-after-free) phổ biến trong các thư viện tiền nhiệm.

### Đóng góp của đề tài

Trong khóa luận này, hệ thống thiết kế tập trung nghiên cứu, thiết kế và cài đặt một nền tảng mật mã đường cong elliptic với tham số kích thước cực lớn (1024-bit). Khóa luận đạt được các đóng góp sau:
- Xây dựng từ đầu hệ thống số học bignum cho cấp độ phần cứng bằng ngôn ngữ hệ thống đảm bảo an toàn bộ nhớ và luồng thực thi tuyệt đối.
- Ứng dụng thành công lý thuyết thuật toán CM (Complex Multiplication) và phương pháp Cocks-Pinch cải tiến để chủ động sinh ra một đường cong "pairing-friendly" mới 1024-bit không có trong bất kỳ tiêu chuẩn có sẵn nào, nhưng vẫn đảm bảo đặc tính bảo mật chống các cuộc gọi tấn công MOV và Anomalous attack nổi tiếng.
- Cài đặt và tích hợp ba sơ đồ chữ ký tiêu chuẩn: ECDSA, Schnorr và chữ ký tổng hợp nền tảng ghép cặp BLS.

### Bố cục của khóa luận

Nội dung của khóa luận được trình bày bao gồm các phần chính sau:

- **Phần Mở đầu**: Trình bày tính cấp thiết, mục đích, nội dung và đóng góp của khóa luận.
- **Chương 1. Giới thiệu bài toán**: Khái quát phạm vi đồ án và bối cảnh sử dụng.
- **Chương 2. Cơ sở toán học**: Cung cấp các kiến thức nền tảng trong lý thuyết nhóm, trường hữu hạn, định nghĩa và luật tính toán trên đường cong elliptic.
- **Chương 3. Phương pháp xây dựng đường cong elliptic**: Trình bày lý thuyết và biến đổi toán học cùng thuật toán Cocks-Pinch để tính toán và tự thiết kế tham số đường cong.
- **Chương 4. Sơ đồ chữ ký số**: Mô tả cấu trúc dữ liệu và logic thiết kế phần mềm bằng Rust triển khai ba thuật toán chữ ký ECDSA, Schnorr và chữ ký BLS.
- **Chương 5. Cài đặt và Đánh giá**: Tổng hợp thông số kỹ thuật thực nghiệm, báo cáo đánh giá benchmark phần cứng, chứng minh độ tin cậy và so sánh tính bảo mật thực tiễn so với các nền tảng mật mã tiêu chuẩn toàn cầu. Cuối cùng, luận văn mở ra những đề xuất định hướng khắc phục hạn chế và tối ưu quy mô sản phẩm trong tương lai.
