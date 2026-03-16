---
title: "Tóm tắt"
---


Khóa luận trình bày quá trình thiết kế và cài đặt từ đầu (from scratch) một hệ thống mật mã đường cong elliptic (ECC) hoàn chỉnh bằng ngôn ngữ Rust, không phụ thuộc vào bất kỳ thư viện mật mã bên ngoài nào. Công trình tập trung vào hai đóng góp chính: (i) xây dựng lớp số học bignum an toàn bộ nhớ với phép nhân Montgomery và các phép toán số học cơ bản trên trường nguyên tố 1024-bit; (ii) chủ động sinh tham số đường cong pairing-friendly KSS18 với bậc nhúng $k=18$ và bậc nhóm $r \approx 2^{512}$ thông qua thuật toán Cocks-Pinch cải tiến, đảm bảo tính kháng tấn công MOV, Anomalous và TNFS. Trên nền tảng này, khóa luận cài đặt thành công hai sơ đồ chữ ký số chuẩn mực là Schnorr và ECDSA, đồng thời xây dựng bộ kiểm thử toàn diện với 36/36 test cases PASSED, chứng minh tính đúng đắn của toàn bộ hệ thống. Kết quả cho thấy khả năng tự chủ hoàn toàn trong việc phát triển hạ tầng mật mã an toàn, minh bạch và có thể kiểm chứng, đặt nền móng cho các ứng dụng mật mã thế hệ mới.

**Từ khóa**: mật mã đường cong elliptic, Rust, số học bignum, phép nhân Montgomery, đường cong pairing-friendly, Cocks-Pinch, chữ ký số Schnorr, ECDSA, bảo mật 256-bit
