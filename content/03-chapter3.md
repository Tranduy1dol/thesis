---
title: Phương pháp xây dựng đường cong elliptic
chapter: 3
toc-title: PHƯƠNG PHÁP XÂY DỰNG ĐƯỜNG CONG ELLIPTIC
---

# Phương pháp xây dựng đường cong elliptic
---

## Họ đường cong BLS
---
Họ đường cong **BLS (Barreto-Lynn-Scott)** là một tập hợp các đường cong Elliptic được thiết kế đặc biệt để **thân thiện với phép ghép cặp (pairing-friendly)**, đóng vai trò nền tảng trong các giao thức mật mã hiện đại như zk-SNARKs và chữ ký số tổng hợp,.

Dưới đây là các đặc điểm và chi tiết kỹ thuật về họ đường cong này:

### 1. Nguồn gốc và Đặc điểm cấu trúc

- **Tên gọi:** Được đặt theo tên của ba nhà toán học Paulo Barreto, Ben Lynn và Michael Scott, những người đã tìm ra cách tham số hóa bộ giải cho phương trình Nhân phức (Complex Multiplication - CM) vào năm 2002,.
- **Dạng phương trình:** Tất cả các đường cong BLS đều có biệt thức CM là **$D = -3$**, điều này dẫn đến phương trình đường cong có dạng **Short Weierstrass** tối giản: **$y^2 = x^3 + b$** (với $b$ là một hằng số trong trường cơ sở).
- **Trường định nghĩa:** Các đường cong này được định nghĩa trên các **trường số nguyên tố** (prime fields), nghĩa là tham số $m$ trong trường mở rộng $F_{p^m}$ bằng 1.
- **Bậc nhúng (Embedding Degree):** Họ BLS có thể được xây dựng với nhiều bậc nhúng khác nhau, thường là bội số của 6 (như $k=6, 12, 24, 48$).

### 2. Các đại diện tiêu biểu

- **BLS12-381:** Đây là đường cong nổi tiếng nhất trong họ này, được sử dụng rộng rãi trong các dự án như **Zcash, Ethereum 2.0** và các hệ thống zk-SNARK hiện đại,. Nó có bậc nhúng là **12** và cung cấp mức bảo mật khoảng 120-128 bit,. Trường cơ sở của nó được thiết kế để hỗ trợ thuật toán **FFT (Fast Fourier Transform)** hiệu quả, giúp tăng tốc độ tạo bằng chứng,.
- **BLS6_6 (Đường cong MoonMath):** Một đường cong "toy example" (ví dụ minh họa) được thiết kế riêng cho việc tính toán bằng tay (pen-and-paper). Nó có bậc nhúng $k=6$ và trường cơ sở 6-bit ($p=43$), cho phép người học tự tính toán các bảng cộng điểm và phép ghép cặp Weil mà không cần máy tính,.

### 3. Ứng dụng chính

- **zk-SNARKs:** Các đường cong BLS cho phép thực hiện các phép toán "trong số mũ" (in the exponent), giúp kiểm tra các ràng buộc đa thức mà không làm lộ dữ liệu gốc,.
- **Chữ ký số tổng hợp (Aggregate Signatures):** Cho phép kết hợp nhiều chữ ký từ các người dùng khác nhau thành một chữ ký duy nhất và xác minh toàn bộ chỉ trong một bước, giúp tiết kiệm không gian lưu trữ trên blockchain,.
- **Tính toán đệ quy:** Mặc dù các đường cong BLS không tạo thành các "chu kỳ đường cong" (cycles of curves) một cách tự nhiên như họ đường cong Pasta, nhưng chúng có thể được kết hợp với các đường cong khác (như BW6-761) để thực hiện xác minh đệ quy một lớp,.

### 4. Phương pháp xây dựng

Đường cong BLS được tổng hợp bằng **Phương pháp Nhân phức (CM Method)**. Quá trình này bao gồm:

1. Sử dụng các đa thức tham số $p(x)$ và $t(x)$ để tìm các số nguyên tố phù hợp cho trường cơ sở và vết Frobenius.
2. Tính **đa thức lớp Hilbert (Hilbert class polynomial)** tương ứng với $D = -3$.
3. Tìm nghiệm của đa thức này trong trường cơ sở để xác định giá trị **j-invariant**, từ đó suy ra các hệ số $a$ (bằng 0) và $b$ của đường cong,.

## Phương pháp nhân phức
---
**Phương pháp Nhân phức (Complex Multiplication Method - CM)** là kỹ thuật quan trọng nhất để **thiết kế và khởi tạo các đường cong Elliptic từ đầu** nhằm thỏa mãn các thuộc tính toán học cụ thể, chẳng hạn như có một bậc (order) hoặc bậc nhúng (embedding degree) nhất định. Đây là công cụ nền tảng để xây dựng các đường cong "thân thiện với phép ghép cặp" (pairing-friendly) như họ đường cong BLS hay MNT dùng trong các hệ thống zk-SNARK.

Dưới đây là các bước thực hiện cơ bản theo quy trình CM:

1. **Lựa chọn tham số mục tiêu:** Nhà thiết kế bắt đầu bằng cách chọn **trường cơ sở $\mathbb{F}_q$** và **vết Frobenius $t$** sao cho vết này thỏa mãn giới hạn Hasse $|t| \leq 2\sqrt{q}$. Lựa chọn này xác định chính xác số lượng điểm trên đường cong thông qua công thức $r = q + 1 - t$.
2. **Giải phương trình CM:** Để phương pháp này hoạt động, cần tồn tại một số nguyên âm $D$ (gọi là **biệt thức CM**) và một số nguyên $v$ thỏa mãn phương trình: **$4q = t^2 + |D|v^2$**.
3. **Tính đa thức lớp Hilbert:** Sử dụng biệt thức $D$, nhà toán học sẽ tính toán **đa thức lớp Hilbert $H_D(x)$**. Đây là một đa thức có các hệ số nguyên, và khi được chiếu lên trường hữu hạn $\mathbb{F}_q$ (bằng cách lấy các hệ số modulo $p$), các nghiệm của nó chính là các giá trị **$j$-invariant** của họ đường cong mong muốn.
4. **Xác định phương trình đường cong:** Từ mỗi nghiệm $j_0$ của đa thức, ta có thể tính toán các hệ số $a$ và $b$ cho phương trình dạng **Short Weierstrass** ($y^2 = x^3 + ax + b$).
5. **Xử lý đường cong xoắn (Twist):** Một giá trị $j$-invariant có thể tạo ra hai đường cong khác nhau: đường cong có bậc $r$ như mong muốn và "đường cong xoắn" của nó. Để xác định đúng đường cong, ta chọn một điểm ngẫu nhiên trên đường cong đó và kiểm tra xem phép nhân vô hướng của điểm đó với $r$ có trả về điểm vô cực hay không.

**Ví dụ thực tế:** Phương pháp này đã được sử dụng để tổng hợp đường cong **secp256k1** (dùng trong Bitcoin) với biệt thức $D = -3$, dẫn đến phương trình đơn giản $y^2 = x^3 + 7$. Trong các bài tập thực hành, chương trình `get_curve.c` thường được dùng để tự động hóa việc tìm các tham số này từ đầu ra của quá trình quét tham số.

## Phương pháp xây dựng đường cong với bậc nhúng cụ thể
---
Việc xây dựng các đường cong elliptic có **bậc nhúng** (embedding degree - $k$) cụ thể là một kỹ thuật quan trọng trong mật mã học dựa trên phép ghép cặp (pairing-based cryptography),.

Dưới đây là phương pháp xây dựng và cách lựa chọn bậc nhúng phù hợp dựa trên các nguồn tài liệu:

### 1. Phương pháp xây dựng đường cong có bậc nhúng cụ thể

Thông thường, một đường cong elliptic ngẫu nhiên sẽ có bậc nhúng cực kỳ lớn ($k \approx r$), khiến việc tính toán các phép ghép cặp trên trường mở rộng $\mathbb{F}_{q^k}$ là không khả thi,. Để tạo ra các đường cong "**pairing-friendly**" (có $k$ nhỏ), các nhà toán học sử dụng các phương pháp sau:

- **Sử dụng Đa thức Cyclotomic ($\Phi_k$):** Bậc nhúng $k$ được xác định là số nguyên dương nhỏ nhất sao cho bậc của nhóm điểm $r$ chia hết cho $q^k - 1$,. Một số nguyên tố $r$ phù hợp phải thỏa mãn $r | \Phi_k(q)$, trong đó $\Phi_k$ là đa thức cyclotomic bậc $k$,.
- **Tiêu chuẩn MNT (Miyaji, Nakabayashi, Takano):** Phương pháp này sử dụng các tính chất của đa thức cyclotomic để xây dựng các đường cong không siêu dị (non-supersingular) có bậc nhúng cụ thể như $k = 3, 4, 6$,.
- **Phương pháp Nhân Phức (Complex Multiplication - CM):** Đây là phương pháp phổ biến nhất để tổng hợp đường cong từ các tham số trừu tượng ($q, t, r, D$).
    1. **Tìm tham số:** Tìm các số nguyên $q$ (đặc số trường), $t$ (vết Frobenius), $r$ (bậc nhóm) và $D$ (biệt thức CM) thỏa mãn phương trình CM: $4q = t^2 + |D|v^2$,.
    2. **Tính đa thức lớp Hilbert ($H_D$):** Sử dụng biệt thức $D$ để lập đa thức lớp Hilbert,.
    3. **Tìm j-invariant:** Các nghiệm của đa thức $H_D \pmod q$ chính là giá trị $j$-invariant của đường cong cần tìm,.
    4. **Xác định hệ số $a, b$:** Từ $j$-invariant, ta tính toán được các hệ số $a, b$ cho phương trình Weierstrass $y^2 = x^3 + ax + b$,.
- **Các họ đường cong đặc biệt:** Ví dụ họ **BLS (Barreto-Lynn-Scott)** được thiết kế để có bậc nhúng là bội số của 6 (như BLS12-381 hoặc BLS6_6 dùng trong tính toán thủ công),.

### 2. Cách chọn bậc nhúng phù hợp (không ngẫu nhiên)

Bậc nhúng không được chọn ngẫu nhiên mà phải dựa trên sự cân bằng giữa **độ an toàn** và **hiệu suất tính toán**,.

- **Cân bằng độ an toàn giữa hai bài toán:**
    - Bài toán Logarit rời rạc trên đường cong (ECDLP) có độ khó phụ thuộc vào kích thước của $r$.
    - Bài toán Logarit rời rạc trên trường hữu hạn (DLP) trên trường mở rộng $\mathbb{F}_{q^k}$ có độ khó phụ thuộc vào kích thước của $q^k$.
    - Mục tiêu là chọn $k$ sao cho hai bài toán này có độ khó tương đương nhau để tối ưu hóa kích thước khóa.
- **Dựa trên mức an toàn mục tiêu:** Theo các tiêu chuẩn mật mã, ta có bảng tham khảo để chọn $k$ và $r$: 

| Mức an toàn (bit) | Kích thước r (bit) | Kích thước trường mở rộng $q^k$ (bit) | Bậc nhúng $k$ phù hợp |
| ----------------- | ------------------ | ------------------------------------- | --------------------- |
| 80                | 160                | 960-1280                              | 6-8                   |
| 112               | 224                | 2200-3600                             | 10-16                 |
| 128               | 256                | 3000-5000                             | 12-20                 |
| 192               | 384                | 8000-10000                            | 20-16                 |
| 256               | 512                | 14000-18000                           | 28-36                 |

- **Tỉ số $\rho$:** Các nhà thiết kế đường cong còn quan tâm đến giá trị $\rho = \log q / \log r$. Lý tưởng nhất là $\rho \approx 1$ để trường cơ sở $q$ không quá lớn so với nhóm điểm $r$, giúp tối ưu hiệu suất tính toán.
- **Tính toán hiệu quả:** Bậc nhúng $k$ nên được chọn sao cho trường mở rộng $\mathbb{F}_{q^k}$ có cấu trúc thuận lợi cho các thuật toán như nhân nhanh (FFT) hoặc các phép toán số học trường extension,.

## Thuật toán xây dựng đường cong họ BLS
---
Họ đường cong **BLS (Barreto-Lynn-Scott)** là một gia đình các đường cong Elliptic được thiết kế đặc biệt để tối ưu cho các phép ghép cặp (pairing-friendly), sử dụng biệt thức CM $D=3$. Thuật toán xây dựng và các công thức đặc trưng cho số phần tử trường cơ sở $q(u)$ và bậc nhóm $r(u)$ dựa trên các đa thức tham số hóa.

### 1. Thuật toán xây dựng đường cong BLS
---

Việc xây dựng đường cong BLS là một trường hợp cụ thể của **Phương pháp Nhân phức (CM Method)** với điều kiện $D=3$, dẫn đến phương trình đường cong có dạng Short Weierstrass tối giản là $y^2 = x^3 + b$.

**Các bước thực hiện:**

1. **Chọn tham số $u$:** Chọn một số nguyên $u$ (đôi khi ký hiệu là $x$) sao cho các giá trị đa thức $q(u)$ và $r(u)$ trả về kết quả là các số nguyên tố.
2. **Tính toán tham số:** Sử dụng các đa thức đặc trưng (tùy theo bậc nhúng $k$) để tính:
    - Vết Frobenius $t(u)$.
    - Số phần tử trường cơ sở $q(u)$.
    - Bậc của nhóm điểm $r(u)$.
3. **Kiểm tra điều kiện:** Đảm bảo $|t(u)| \leq 2\sqrt{q(u)}$ (giới hạn Hasse) và $r(u)$ là ước của số lượng điểm trên đường cong $n(u) = q(u) + 1 - t(u)$.
4. **Tìm hệ số $b$:** Vì $D=3$, Hilbert class polynomial luôn là $H_{-3}(x) = x$, dẫn đến $j$-invariant bằng $0$. Hệ số $b$ được tìm bằng cách thử các giá trị nhỏ trong trường $\mathbb{F}_q$ cho đến khi tìm được đường cong có bậc chính xác là $n(u)$.

### 2. Công thức tính $q(u)$ và $r(u)$ cho các họ BLS tiêu biểu
---

Các công thức này được xây dựng dựa trên **Đa thức Cyclotomic** $\Phi_k(u)$.
#### Đối với BLS12 (Bậc nhúng $k=12$, phổ biến nhất như BLS12-381)
---

Dựa trên cấu trúc tham số hóa cho $D=3$ và $k=12$:
- **Vết Frobenius:** $t(u) = u + 1$
- **Số phần tử nhóm (Bậc nhóm):** $$r(u) = \Phi_{12}(u) = u^4 - u^2 + 1$$
- **Số phần tử trường cơ sở:** $$q(u) = (u-1)^2 \cdot \frac{r(u)}{3} + u$$ _(Phép chia cho 3 đảm bảo $q(u)$ có thể là số nguyên khi $u \equiv 1 \pmod 3$)_ .

#### Đối với BLS6 (Bậc nhúng $k=6$, ví dụ trong MoonMath)

Dựa trên các đa thức cho $k=6$:

- **Vết Frobenius:** $t(u) = u + 1$
- **Số phần tử nhóm:** $$r(u) = \Phi_6(u) = u^2 - u + 1$$
- **Số phần tử trường cơ sở:** $$q(u) = \frac{1}{3}(u-1)^2(u^2-u+1) + u$$

### 3. Ý nghĩa của tham số hóa
---

Việc sử dụng các đa thức $q(u)$ và $r(u)$ cho phép các nhà thiết kế hệ thống mật mã tạo ra các đường cong có **độ an toàn mục tiêu cụ thể** chỉ bằng cách thay đổi giá trị đầu vào $u$.

- **Tỷ số $\rho$:** Trong các công thức BLS, tỷ số $\rho = \log q / \log r$ thường xấp xỉ $1.5$ đối với $k=12$, giúp cân bằng giữa độ khó của bài toán logarit rời rạc trên đường cong và trên trường mở rộng.
- **Tối ưu hóa:** Tham số $u$ thường được chọn có "trọng lượng Hamming thấp" (nhiều bit 0) để tăng tốc độ tính toán trong thuật toán Miller khi thực hiện phép ghép cặp.