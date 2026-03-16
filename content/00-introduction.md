---
title: "Mở đầu"
unnumbered: true
---

Hệ mật mã Đường cong Elliptic (ECC) là nền tảng bảo mật của hạ tầng số hiện đại, từ giao thức TLS, SSH cho đến các hệ thống blockchain [@DiffieHellman1976; @Rosing2024]. Tuy nhiên, sự phụ thuộc vào các bộ tham số sinh sẵn bởi các tổ chức quốc tế đặt ra những thách thức nghiêm trọng về tự chủ công nghệ và an ninh quốc gia. Đồng thời, hầu hết các thư viện mật mã truyền thống được viết bằng C/C++ — một ngôn ngữ tiềm ẩn nhiều rủi ro về an toàn bộ nhớ.

Khóa luận này đặt mục tiêu thiết kế và cài đặt từ đầu (from scratch) một hệ thống mật mã đường cong elliptic trên trường nguyên tố cực lớn 1024-bit, sử dụng ngôn ngữ lập trình Rust. Hệ thống bao gồm toàn bộ ngăn xếp — từ lớp số nguyên lớn `U1024`, số học trường hữu hạn Montgomery, phép toán nhóm trên đường cong, đến các sơ đồ chữ ký số Schnorr và ECDSA — không phụ thuộc bất kỳ thư viện mật mã bên ngoài nào.

# Đóng góp của đề tài

Khóa luận đạt được các đóng góp chính sau:

1. **Xây dựng hệ thống số học bignum hoàn chỉnh** — Tự định nghĩa kiểu dữ liệu `U1024` với phép nhân Montgomery, lũy thừa hằng-thời-gian, và nghịch đảo Fermat, đảm bảo an toàn bộ nhớ tuyệt đối nhờ kiến trúc Rust.
2. **Sinh đường cong elliptic mới bằng thuật toán Cocks-Pinch cải tiến** — Chủ động xây dựng đường cong pairing-friendly ($k = 18$, $r \approx 2^{512}$, $p \approx 2^{1024}$) với cấu trúc NTT-friendly trên cả hai trường, đạt mức bảo mật 256-bit và kháng tấn công TNFS [@CocksPinch2001; @BarbulescuDuquesne2019].
3. **Cài đặt ba sơ đồ chữ ký số** — Schnorr, ECDSA và chữ ký tổng hợp BLS, với bộ kiểm thử 36 test bao phủ từ số học cấp thấp đến mô phỏng tấn công MOV và Anomalous.

# Bố cục của khóa luận

- **Chương 1. Tổng quan và Giới thiệu bài toán**: Bối cảnh lịch sử của ECC, thực trạng các tiêu chuẩn hiện hành, vấn đề tự chủ mật mã, vai trò của ngôn ngữ lập trình, và phát biểu bài toán.
- **Chương 2. Cơ sở toán học**: Trường hữu hạn, đường cong elliptic Short Weierstrass, phép cộng điểm, nhân vô hướng, và phép nhân Montgomery.
- **Chương 3. Phương pháp xây dựng đường cong elliptic**: Phương pháp Nhân phức (CM), thuật toán Cocks-Pinch truyền thống và cải tiến NTT-friendly.
- **Chương 4. Sơ đồ chữ ký số**: Cấu trúc cặp khóa, Schnorr, ECDSA, và chữ ký tổng hợp BLS.
- **Chương 5. Cài đặt và Đánh giá**: Benchmark hiệu năng, phân tích an toàn trước 5 loại tấn công, và định hướng phát triển.
