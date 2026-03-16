---
title: Kết luận
chapter: 5
---

# Kết quả đạt được

Khóa luận đã hoàn thành mục tiêu đề ra: thiết kế và cài đặt từ đầu (from scratch) một hệ thống mật mã đường cong elliptic hoàn chỉnh trên trường nguyên tố 1024-bit bằng ngôn ngữ Rust, không phụ thuộc bất kỳ thư viện mật mã bên ngoài nào. Các đóng góp cụ thể bao gồm:

- **Lớp số học bignum an toàn bộ nhớ:** Tự định nghĩa kiểu dữ liệu `U1024` với phép cộng, trừ, nhân, lũy thừa và nghịch đảo. Phép nhân Montgomery [@Montgomery1985] được cài đặt trực tiếp, loại bỏ hoàn toàn phép chia số lớn trong vòng lặp tính toán, đồng thời bảo đảm an toàn bộ nhớ tuyệt đối nhờ kiến trúc Rust.

- **Đường cong pairing-friendly mới 1024-bit:** Áp dụng thành công Phương pháp Nhân phức (CM) và thuật toán Cocks-Pinch cải tiến [@CocksPinch2001] để chủ động sinh đường cong KSS18 với bậc nhúng $k = 18$, bậc nhóm $r \approx 2^{512}$ (bảo mật 256-bit), và cấu trúc NTT-friendly trên cả hai trường $\mathbb{F}_r$ và $\mathbb{F}_p$. Đây là đóng góp gốc của khóa luận — đường cong tự sinh, không lấy từ bất kỳ tiêu chuẩn nước ngoài nào, đồng thời kháng được tấn công TNFS [@BarbulescuDuquesne2019], MOV [@MOV1993], và Anomalous [@SmartAnomaly1999].

- **Ba sơ đồ chữ ký số chuẩn mực:** Schnorr [@Schnorr1989] và ECDSA [@FIPS186_4] được cài đặt đầy đủ và xác minh đúng đắn. Nền tảng lý thuyết của BLS [@BLS2001] được trình bày và tích hợp vào kiến trúc, sẵn sàng cho cài đặt phép ghép cặp đầy đủ trong tương lai.

- **Bộ kiểm thử toàn diện:** 36/36 test PASSED, bao phủ từ số học cấp thấp (`U1024`, `FieldElement`) đến an toàn mật mã cấp cao (mô phỏng tấn công MOV, Anomalous, Invalid Curve).

# Đánh giá tổng quan

## So sánh với mục tiêu ban đầu

Nhìn lại bốn mục tiêu đặt ra tại Chương 1, khóa luận đạt được kết quả như sau:

| Mục tiêu | Kết quả |
|----------|---------|
| Tự chủ tham số đường cong | $\checkmark$ Sinh được đường cong KSS18 1024-bit mới, không tái sử dụng hằng số bên ngoài |
| Bảo mật trước máy tính cổ điển | $\checkmark$ Bảo mật 256-bit, vượt xa chuẩn NIST 128-bit đến năm 2030 |
| An toàn bộ nhớ ngôn ngữ | $\checkmark$ Rust loại bỏ toàn bộ lỗi bộ nhớ tại thời điểm biên dịch |
| Chữ ký số vận hành được | $\checkmark$ Schnorr và ECDSA ký/xác minh chính xác, 36/36 test PASSED |

: Đối chiếu kết quả với mục tiêu đề ra

## Đánh giá điểm mạnh và hạn chế

**Điểm mạnh:**

Hệ thống đạt được tính *đúng đắn toán học* cao — mọi công thức từ phép cộng điểm affine, phép nhân Montgomery đến quy trình ký/xác minh Schnorr và ECDSA đều được kiểm thử độc lập. Tính *minh bạch thuật toán* là ưu điểm nổi bật so với các thư viện "hộp đen" công nghiệp: toàn bộ tham số đường cong sinh ra từ quy trình Cocks-Pinch xác định, không có hạt giống (seed) bí ẩn, đảm bảo không thể tồn tại backdoor ẩn.

**Hạn chế:**

Hiệu năng hiện tại (~1.5 s/phép ký) chưa đủ cho các ứng dụng yêu cầu độ trễ thấp như TLS hay thanh toán thời gian thực. Đây là sự đánh đổi có chủ ý khi ưu tiên tính đúng đắn và kiến trúc phân tầng rõ ràng trước, tối ưu hóa sau. Ngoài ra, thuật toán Double-and-Add hiện tại tiềm ẩn nguy cơ timing side-channel do số phép `add` phụ thuộc vào trọng số Hamming của scalar — một điểm yếu cần giải quyết trước khi đưa vào môi trường production.

# Hướng phát triển

## Tối ưu hóa hiệu năng (ngắn hạn)

1. **Tọa độ Jacobian/Projective:** Loại bỏ phép nghịch đảo tốn kém ($a^{p-2} \bmod p$) trong mỗi bước `add`/`double` bằng cách biểu diễn điểm ở dạng $(X:Y:Z)$ thay vì $(x, y)$ Affine. Toàn bộ vòng lặp nhân vô hướng 1024 bước chỉ cần 1 phép nghịch đảo duy nhất ở cuối — ước tính giảm thời gian ký từ ~1.5 s xuống dưới **200 ms**.

2. **Sliding Window / NAF:** Giảm ~25–30% số phép `add` so với Double-and-Add cơ bản bằng cách nhóm nhiều bit scalar lại. Kết hợp với Jacobian, thời gian ký dự kiến đạt dưới **150 ms**.

3. **AVX-512 / SIMD assembly:** Vector hóa các phép nhân 64×64-bit limb trong Montgomery multiplication trên kiến trúc x86-64. Thư viện `blst` của Ethereum đạt tốc độ BLS12-381 signing dưới 1 ms nhờ kỹ thuật này — con số tham chiếu thực tế cho hướng tối ưu tiếp theo.

## Bảo mật cấp cao (trung hạn)

4. **Montgomery Ladder:** Thay thế Double-and-Add bằng Montgomery Ladder để đạt *constant-time* thực sự — thuật toán luôn thực hiện đúng 1024 phép `double` và 1024 phép `add` bất kể giá trị scalar, loại bỏ hoàn toàn timing side-channel.

5. **Phép ghép cặp đầy đủ (Pairing):** Cài đặt vòng lặp Miller và bước lũy thừa cuối (final exponentiation) trên $\mathbb{F}_{p^{18}}$ để kích hoạt BLS aggregate signatures. Đây là hướng có giá trị ứng dụng cao nhất — một chữ ký BLS tổng hợp từ $n$ người ký có thể xác minh bằng đúng 2 phép ghép cặp, không phụ thuộc vào $n$.

6. **Multi-Scalar Multiplication (MSM — Pippenger):** Tối ưu bước xác minh $[s]G + [e]Q$ bằng thuật toán Pippenger [@BLS12_381], giảm ~50% công việc so với hai phép nhân vô hướng tuần tự.

## Mở rộng ứng dụng (dài hạn)

7. **Giao thức ngưỡng (Threshold Signatures):** Dựa trên tính tổng hợp tự nhiên của Schnorr, cài đặt các giao thức MuSig2 hay FROST cho phép $t$-trong-$n$ người ký tham gia, phù hợp với ứng dụng đa chữ ký (multi-sig) trong blockchain và hệ thống tài chính.

8. **Kiểm định hình thức (Formal Verification):** Sử dụng framework như `creusot` hoặc `kani` để chứng minh tính đúng đắn của các tính chất quan trọng (ví dụ: `add` thỏa mãn luật giao hoán và kết hợp) ở mức ngôn ngữ hình thức, nâng mức độ đảm bảo an toàn lên chuẩn mực cao nhất.

Các hướng **1** và **4** là ưu tiên cao nhất vì chúng đồng thời cải thiện cả hiệu năng lẫn bảo mật mà không đòi hỏi thay đổi kiến trúc cấp cao, và có thể được triển khai độc lập trong phạm vi codebase hiện tại.
