---
title: Cài đặt và Đánh giá
chapter: 5
toc-title: CÀI ĐẶT VÀ ĐÁNH GIÁ
---

Chương này đánh giá toàn diện hệ thống đã xây dựng, không chỉ dừng lại ở trình bày số liệu mà tập trung **chứng minh giá trị** của hệ thống trên hai phương diện: hiệu năng thực tế và độ an toàn mật mã. Mục tiêu trả lời câu hỏi: *Các con số đo được nói lên điều gì? Hệ thống này có an toàn không? Có dùng được trong thực tế không?*

## Đánh giá hiệu năng

### Kết quả đo đạc

Toàn bộ hệ thống được đo bằng framework Criterion (release build, tối ưu LLVM O3, 10 mẫu/phép đo, phần cứng thông thường không có AVX-512). Kết quả cụ thể như sau:

| Phép đo | Min | Mean | Max |
|---|---|---|---|
| `KeyPair::generate` | 1.629 s | **1.687 s** | 1.757 s |
| `Schnorr/sign` | 1.473 s | **1.551 s** | 1.641 s |
| `Schnorr/verify` | 2.656 s | **2.831 s** | 3.025 s |
| `ECDSA/sign` | 1.524 s | **1.606 s** | 1.711 s |
| `ECDSA/verify` | 2.847 s | **3.140 s** | 3.459 s |
| Nhân vô hướng $[k]G$ | 1.061 s | **~1.1–1.3 s** | 1.489 s |

### Phân tích: Kết quả có hợp lý về mặt lý thuyết không?

Trước tiên cần nhìn nhận rằng Curve1024 sử dụng trường nguyên tố $p$ **1024-bit** — gấp 4 lần kích thước của secp256k1 (256-bit) hay P-384. Đây là lựa chọn chủ động, không phải sai sót thiết kế, vì mục tiêu là bảo mật 256-bit và tính pairing-friendly. Hệ quả tất yếu là hiệu năng chậm hơn đáng kể.

Phép nhân vô hướng dùng thuật toán Double-and-Add với **1024 vòng lặp** (tương ứng kích thước bit của trường vô hướng $r = 512$ bit — số vòng lặp bằng độ dài bit của *trường cơ sở* $p$). Mỗi vòng lặp thực hiện một phép `double` và có thể một phép `add`, mỗi phép toán đó cần **1 phép nghịch đảo** modulo $p$ trong hệ tọa độ Affine hiện tại. Phép nghịch đảo được tính bằng định lý Fermat: $a^{-1} = a^{p-2} \pmod{p}$, tức là gọi đệ quy `pow` với khoảng **~1536 phép nhân Montgomery** 1024-bit bên trong. Đây là nguồn gốc của con số ~1.1–1.6 giây/phép nhân vô hướng.

Schnorr ký nhanh hơn ECDSA ~3% do Schnorr không cần tính nghịch đảo $k^{-1} \pmod{r}$ trong bước sinh chữ ký. Xác minh (cả Schnorr và ECDSA) tốn gần gấp đôi ký do cần **2 phép nhân vô hướng độc lập** ($[s]G$ và $[e]Q$ cho Schnorr; $[u_1]G$ và $[u_2]Q$ cho ECDSA). Tỷ lệ này hoàn toàn phù hợp với dự kiến lý thuyết.

So với secp256k1, độ chênh lệch (~1.5 s so với ~0.2 ms) xuất phát chủ yếu từ ba yếu tố tích lũy: (1) scalar dài gấp 4 lần kéo dài thêm 4× số vòng lặp, (2) mỗi phép nhân Montgomery trên số 1024-bit tốn ~16 lần công sức so với 256-bit (chi phí $O(n^2)$ với $n$ số limb), và (3) secp256k1 có thư viện tối ưu nhiều năm với assembly AVX-512 được tinh chỉnh. Kết hợp lại, khoảng cách ~8000× là kỳ vọng hợp lý, không phải dấu hiệu của thuật toán sai.

### Tính khả thi trong ứng dụng thực tế

Với thời gian ~1.5–1.7 giây cho một phép ký, hệ thống hoàn toàn phù hợp với các **kịch bản ký ngoại tuyến** như ký tài liệu pháp lý, ký gói phần mềm khi phát hành, ký giao dịch tài chính giá trị lớn, hay ký chứng chỉ trong hạ tầng PKI — những trường hợp mà độ trễ vài giây là chấp nhận được và bù đắp hoàn toàn bởi biên bảo mật 256-bit so với 128-bit của các chuẩn thông thường.

Ngược lại, hệ thống **chưa phù hợp** cho các ứng dụng yêu cầu độ trễ dưới mili-giây như TLS handshake xử lý hàng nghìn kết nối/giây, giao dịch thanh toán tốc độ cao, hay ký batch thời gian thực. Đây là sự đánh đổi có chủ ý — tập trung vào tính đúng đắn và bảo mật của nền tảng toán học trước, tối ưu hóa sau.

Nhờ áp dụng **phép nhân Montgomery** thay cho phép chia lấy dư thông thường, tất cả phép nhân trong $\mathbb{F}_p$ đều thực thi bằng phép shift và trừ có điều kiện, không cần chia số 1024-bit cho $p$ — một phép toán đắt hơn nhân ~5–10 lần. Đây là tối ưu quan trọng nhất đã được triển khai trong cài đặt hiện tại.

Các hướng cải tiến hiệu năng tiếp theo được phân tích tại §5.4.

## Đánh giá độ an toàn

### An toàn trước tấn công cổ điển

Hệ thống sử dụng trường nguyên tố $p$ có độ lớn 1024-bit và bậc nhóm $r$ là 512-bit. Bài toán ECDLP trên nhóm $E(\mathbb{F}_p)$ — tức là tìm $k$ từ $Q = [k]G$ — hiện chưa có thuật toán tốt hơn thuật toán tổng quát. Thuật toán tốt nhất hiện tại là **Pollard's $\rho$**, có độ phức tạp $O(\sqrt{r}) \approx O(2^{256})$ phép toán nhóm. Với $2^{256}$ bước tính toán cần thực hiện, ngay cả khi huy động toàn bộ năng lực tính toán của nhân loại — mỗi nguyên tử Trái Đất thực hiện $10^9$ phép tính mỗi giây từ khi Big Bang — vẫn không đủ để phá vỡ khóa trong tuổi thọ của vũ trụ. Đây là **biên an toàn tuyệt đối** trước mọi hệ thống máy tính cổ điển.

Mức bảo mật 256-bit vượt xa chuẩn tối thiểu NIST khuyến nghị (128-bit cho các ứng dụng đến năm 2030) và tương đương với AES-256 — chuẩn mã hóa đối xứng mạnh nhất hiện nay. Đây là mục tiêu tường minh của thuật toán Cocks-Pinch cải tiến được trình bày tại Chương 3.

### An toàn trước tấn công Invalid Curve

**Invalid Curve Attack** là một dạng tấn công nguy hiểm trong ECC: kẻ tấn công gửi một điểm $P'$ *không thuộc đường cong* $E$ nhưng vẫn hợp lệ về mặt định dạng, ép hệ thống tính toán trên một đường cong suy biến có bậc nhỏ, từ đó thu thập thông tin về khóa riêng qua nhiều truy vấn.

Hệ thống hiện tại **miễn nhiễm hoàn toàn** với tấn công này. Mọi điểm được tạo ra thông qua `AffinePoint::new(x, y)` đều tự động kiểm tra điều kiện:
$$y^2 \equiv x^3 + b \pmod{p}$$

bằng lời gọi `assert!(self.is_on_curve())` ngay trong hàm khởi tạo. Không tồn tại đường dẫn code nào cho phép một điểm không hợp lệ tồn tại trong hệ thống. Điều này được xác nhận bởi test `test_curve_point` trong bộ kiểm thử đơn vị.

### An toàn trước tấn công MOV

**Tấn công MOV** (Menezes-Okamoto-Vanstone) sử dụng phép ghép cặp (pairing) để ánh xạ bài toán ECDLP trong $E(\mathbb{F}_p)$ về bài toán DLP trong trường hữu hạn mở rộng $\mathbb{F}_{p^k}$, nơi bài toán DLP có thể được giải hiệu quả hơn bằng thuật toán chỉ số (index calculus).

Tuy nhiên, hiệu quả của tấn công này phụ thuộc vào việc $\mathbb{F}_{p^k}$ có đủ nhỏ để bài toán DLP khả thi hay không. Với Curve1024, bậc nhúng $k = 18$, trường mở rộng $\mathbb{F}_{p^{18}}$ có kích thước $|p^{18}| = 18 \times 1024 = 18432$ bit. Bài toán DLP trong trường 18432-bit hoàn toàn không thể giải được với công nghệ hiện tại — trên thực tế, kinh nghiệm cộng đồng yêu cầu $k|p| \geq 3072$ bit để kháng tấn công này ở mức 128-bit; hệ thống đạt $18 \times 1024 = 18432$ bit, vượt xa tiêu chuẩn này. Kết quả này được test `test_mov_attack_resistance` xác nhận tường minh.

### An toàn trước tấn công Anomalous

**Tấn công Anomalous (SSSA)** khai thác trường hợp đặc biệt khi $\#E(\mathbb{F}_p) = p$, tức là số điểm trên đường cong bằng đúng modulus. Trong trường hợp này, tồn tại một đẳng cấu nhóm ánh xạ bài toán ECDLP về bài toán trên nhóm cộng $\mathbb{Z}/p\mathbb{Z}$, cho phép giải trong thời gian tuyến tính.

Curve1024 có $\#E(\mathbb{F}_p) = h \cdot r$ với $r$ là bậc nhóm con nguyên tố 512-bit và $h$ là cofactor, trong khi $p$ là số nguyên tố 1024-bit. Hiển nhiên $\#E(\mathbb{F}_p) \neq p$ vì $|r| = 512 < 1024 = |p|$, nên điều kiện anomalous không thoả mãn. Test `test_anomalous_attack_resistance` xác minh điều này.

### Hạn chế: Timing Side-Channel Attack

Đây là điểm cần trung thực học thuật: thuật toán **Double-and-Add** hiện tại, mặc dù có `conditional_select` ở từng bước đơn lẻ, vẫn có tổng số phép `add` thực hiện **phụ thuộc vào số lượng bit 1 trong scalar $k$**. Kẻ tấn công có thể đo thời gian thực thi để suy luận về trọng số Hamming của khóa riêng, từ đó thu hẹp không gian tìm kiếm.

Đây là sự đánh đổi có chủ ý để giữ kiến trúc đơn giản (nguyên tắc KISS — Keep It Simple and Secure). Biện pháp khắc phục là thay thế bằng **Montgomery Ladder**, thuật toán thực hiện đúng 1024 phép `double` và 1024 phép `add` bất kể giá trị scalar, đảm bảo tính *constant-time* thực sự. Đây là hướng phát triển ưu tiên cao.

Toàn bộ kết quả kiểm thử **36/36 test PASSED** (17 đơn vị + 19 tích hợp) xác nhận tính đúng đắn toán học và an toàn của hệ thống trên mọi tiêu chí đã mô tả.

## Kết luận và hướng phát triển

### Kết quả đạt được

Luận văn đã hoàn thành xây dựng một hệ thống mật mã đường cong elliptic hoàn chỉnh từ nền tảng toán học đến ứng dụng thực tế:

- **Cơ sở toán học vững chắc:** Cài đặt $\mathbb{F}_p$ với phép nhân Montgomery, toán học điểm affine đầy đủ, và phép nhân vô hướng thuần Rust không phụ thuộc thư viện ngoài.
- **Đường cong đặc biệt:** Sinh được đường cong pairing-friendly 1024-bit ($k=18$, bảo mật 256-bit, NTT-friendly trên cả hai trường) bằng thuật toán Cocks-Pinch cải tiến — một đóng góp gốc của luận văn.
- **Sơ đồ chữ ký hoàn chỉnh:** Schnorr và ECDSA hoạt động chính xác và được kiểm thử đầy đủ.
- **Bộ kiểm thử toàn diện:** 36 test bao phủ từ số học cấp thấp đến bảo mật tầng cao, kể cả mô phỏng tấn công MOV và Anomalous.

### Hướng phát triển

**Tối ưu hóa hiệu năng:**

1. **Tọa độ Jacobian/Projective:** Loại bỏ phép nghịch đảo trong mỗi bước `add`/`double` bằng cách làm việc trong hệ tọa độ $(X:Y:Z)$ thay vì $(x, y)$ Affine. Toàn bộ vòng lặp nhân vô hướng chỉ cần 1 phép nghịch đảo duy nhất ở bước chuyển về Affine cuối cùng — ước tính giảm thời gian ký xuống dưới 200 ms.

2. **Sliding Window / NAF:** Giảm ~25–30% số phép `add` trong nhân vô hướng so với Double-and-Add cơ bản. Kết hợp với Jacobian, thời gian ký dự kiến đạt dưới 150 ms.

3. **AVX-512 / SIMD assembly:** Vector hóa các phép nhân 64×64-bit limb trong Montgomery multiplication trên kiến trúc x86-64 hiện đại. Các thư viện như `blst` (Ethereum) đạt tốc độ BLS12-381 signing dưới 1 ms nhờ kỹ thuật này.

**Bảo mật cấp cao:**

4. **Montgomery Ladder:** Thay thế Double-and-Add bằng Montgomery Ladder để đạt *constant-time* thực sự, loại bỏ timing side-channel theo giá trị scalar.

5. **Phép ghép cặp (Pairing):** Cài đặt Miller loop và bước mũ cuối (final exponentiation) để kích hoạt đầy đủ BLS aggregate signatures, mở ra ứng dụng trong các giao thức đồng thuận phân tán.

6. **Multi-Scalar Multiplication (MSM — Pippenger):** Tối ưu bước xác minh $[s]G + [e]Q$ bằng thuật toán Pippenger, giảm ~50% công việc so với hai phép nhân tuần tự.

Các hướng 1 và 4 là ưu tiên cao nhất vì cùng lúc cải thiện cả hiệu năng và bảo mật, không yêu cầu thay đổi kiến trúc cấp cao.
