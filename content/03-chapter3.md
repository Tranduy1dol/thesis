---
title: Phương pháp xây dựng đường cong elliptic
chapter: 3
toc-title: PHƯƠNG PHÁP XÂY DỰNG ĐƯỜNG CONG ELLIPTIC
---

# Chương 3: Phương pháp xây dựng đường cong elliptic thân thiện với phép ghép cặp

Chương này trình bày trọng tâm lý thuyết của luận văn: các phương pháp xây dựng đường cong elliptic có bậc nhúng (embedding degree) xác định, phục vụ cho các ứng dụng mật mã dựa trên phép ghép cặp (pairing-based cryptography). Chúng ta sẽ đi từ nền tảng lý thuyết của Phương pháp Nhân phức (CM) và Đa thức lớp Hilbert, đến thuật toán Cocks-Pinch truyền thống, và cuối cùng là thuật toán Cocks-Pinch Cải tiến được đề xuất trong luận văn này, với khả năng sinh tham số trường cơ sở có cấu trúc NTT-friendly nhằm kháng lại tấn công rây trường số tháp (Tower Number Field Sieve - TNFS).

## Phương pháp Nhân phức (Complex Multiplication Method)

### Ý tưởng cốt lõi

Phương pháp Nhân phức (CM) là công cụ nền tảng để **xây dựng đường cong elliptic có số điểm định trước**. Thay vì chọn ngẫu nhiên các hệ số $a, b$ rồi đếm điểm, CM đi ngược lại: bắt đầu từ bậc nhóm mong muốn $\#E(\mathbb{F}_p) = p + 1 - t$ rồi suy ngược ra phương trình đường cong.

Ý tưởng xuất phát từ lý thuyết số học phức: mỗi đường cong elliptic $E$ sở hữu một **vành nội cấu** (endomorphism ring) $\text{End}(E)$. Với đường cong thông thường (không siêu dị), vành này đẳng cấu với một **thứ tự trong trường số** $\mathbb{Q}(\sqrt{D})$, trong đó $D < 0$ là số nguyên âm gọi là **biệt thức CM**. Giá trị $D$ đặc trưng hoàn toàn cho "loại" đường cong về mặt số học phức.

### Điều kiện CM và phương trình Diophantine

Để tồn tại một đường cong elliptic trên $\mathbb{F}_p$ có vết Frobenius $t$ và biệt thức CM là $D$, điều kiện cần và đủ là phương trình Diophantine sau phải có nghiệm nguyên:

$$4p = t^2 + |D| \cdot v^2$$

trong đó $p$ là đặc số trường, $t$ là vết Frobenius, $v$ là một số nguyên dương, và $D < 0$. Phương trình này **ràng buộc trực tiếp** bộ tham số $(p, t, D)$ với nhau; không phải mọi bộ ba nào cũng có thể thỏa mãn đồng thời.

Ví dụ: Với $D = -3$ (biệt thức của secp256k1, BLS12-381), phương trình trở thành $4p = t^2 + 3v^2$.

### Đa thức lớp Hilbert $H_D(x)$

Khi đã có $D$, bước tiếp theo là tính **Đa thức lớp Hilbert** (Hilbert class polynomial) $H_D(x)$. Đây là đa thức hệ số nguyên được xây dựng từ lý thuyết số học phức mà nghiệm phức của nó chính là các **$j$-invariant** của tất cả đường cong elliptic phức $\mathbb{C}/\mathcal{O}$ với thứ tự CM là $\mathcal{O}$.

Bậc của $H_D(x)$ bằng **số lớp** (class number) $h(D)$ — một bất biến số học của thứ tự $\mathbb{Z}[\sqrt{D}]$. Với $|D|$ nhỏ:

| $   | D   | $              | $h(D)$ | $H_D(x)$ |
| --- | --- | -------------- | ------ | -------- |
| 3   | 1   | $x$            |        |          |
| 4   | 1   | $x - 1728$     |        |          |
| 7   | 1   | $x + 3375$     |        |          |
| 11  | 1   | $x + 32768$    |        |          |
| 23  | 3   | $x^3 + \cdots$ |        |          |

Với $|D| = 3$ và $|D| = 4$, đa thức này bậc 1, nên **$j$-invariant được xác định ngay lập tức**: $j = 0$ và $j = 1728$ tương ứng. Đây là lý do tại sao secp256k1 ($j=0$, $D=-3$) và nhiều đường cong BLS có dạng đơn giản $y^2 = x^3 + b$.

### Quy trình CM đầy đủ

Cho bộ tham số $(p, t, D)$ thỏa mãn $4p = t^2 + |D|v^2$:

1. **Tính $j$-invariant**: Tìm nghiệm $j_0 \in \mathbb{F}_p$ của $H_D(x) \pmod{p}$.
2. **Suy ra hệ số đường cong**: Từ $j_0$, tính $c = j_0 \cdot (1728 - j_0)^{-1} \pmod{p}$, sau đó:
   - $a = 3c$, $b = 2c$ (trường hợp tổng quát $j_0 \neq 0, 1728$)
   - $a = 0$, $b$ tùy ý (khi $j_0 = 0$, tức $D = -3$)
   - $a$ tùy ý, $b = 0$ (khi $j_0 = 1728$, tức $D = -4$)
3. **Kiểm tra xoắn (Twist test)**: Đường cong $E: y^2 = x^3 + ax + b$ và đường cong xoắn $E': y^2 = x^3 + a\delta^2 x + b\delta^3$ (với $\delta$ là phần tử không phải thặng dư bậc hai) có tổng số điểm $\#E + \#E' = 2(p+1)$. Ta cần chọn đúng đường cong có $r \mid \#E$.
4. **Tìm điểm sinh (Generator)**: Nhân ngẫu nhiên một điểm trên đường cong với hệ số cofactor $h = \#E / r$ để tìm điểm sinh $G$ có bậc chính xác là $r$.

### Trường hợp $D = -3$: Xoắn sextic

Với $D = -3$, tình huống phức tạp hơn vì đường cong $y^2 = x^3 + b$ có **6 xoắn** (sextic twists) thay vì chỉ 2. Sáu vết Frobenius khả dĩ là:

$$t, \quad -t, \quad \frac{t \pm 3v}{2}, \quad \frac{-t \pm 3v}{2}$$

trong đó $4p = t^2 + 3v^2$. Để xác định xoắn đúng, ta lần lượt thử các giá trị $b$ nhỏ và kiểm tra số điểm thực sự của đường cong $y^2 = x^3 + b$ bằng cách tính phép nhân vô hướng $[p+1-t']P$ với điểm ngẫu nhiên $P$.

Trong cài đặt của luận văn (tệp `complex_multiplication.rs`), hàm `find_twist` thực hiện:

```rust
// Sáu bậc nhóm khả dĩ cho D = -3 (j = 0)
let candidates = [
    p1.borrowing_sub(&config.t).0,    //  p + 1 - t
    p1.carrying_add(&config.t).0,     //  p + 1 + t
    p1.borrowing_sub(&t3p).0,         //  p + 1 - (t+3v)/2
    p1.carrying_add(&t3p).0,          //  p + 1 + (t+3v)/2
    p1.borrowing_sub(&t3m).0,         //  p + 1 - (t-3v)/2
    p1.carrying_add(&t3m).0,          //  p + 1 + (t-3v)/2
];
// Tìm bậc nào chia hết cho r, rồi tìm b tương ứng
```

## Tham số đầu vào của hệ thống

Trước khi đi vào chi tiết thuật toán, phần này giải thích ý nghĩa và cơ sở lựa chọn của 7 tham số đầu vào trong cài đặt thực tế (`cocks_pinch.rs`):

```rust
let k                    = 18u64;
let d                    = U1024::from(3);
let target_r_bits        = 512;
let target_p_bits        = 1024;
let max_attempts         = 100_000u64;
let min_scalar_two_adicity = 32u32;
let min_base_two_adicity   = 32u32;
```

### `k = 18` — Bậc nhúng (Embedding Degree)

Bậc nhúng $k$ xác định **trường mở rộng** $\mathbb{F}_{p^k}$ nơi phép ghép cặp Weil/Tate được tính toán. Giá trị $k = 18$ được chọn vì:

- **Cân bằng bảo mật:** Với $r \approx 2^{512}$ và $p \approx 2^{1024}$, kích thước trường mở rộng là $p^k \approx 2^{1024 \times 18} = 2^{18432}$ bit. Theo tiêu chuẩn NFS hiện tại, bài toán DLP trên $\mathbb{F}_{p^{18}}$ ở mức bảo mật $\geq 256$ bit — tương đương với mức bảo mật của khóa $r \approx 2^{512}$.
- **Hỗ trợ Đa thức Cyclotomic bậc 18:** $\Phi_{18}(T) = T^6 - T^3 + 1$ cho phép sinh $r$ hiệu quả, có cấu trúc NTT-friendly tự nhiên khi $T \equiv 0 \pmod{2^k}$ (xem §3.3.1).
- **Thực tế:** $k = 18$ là bậc nhúng phổ biến trong họ đường cong KSS18, phù hợp với mức bảo mật hậu lượng tử cao hơn các đường cong BLS12 (dùng trong Ethereum 2.0).

### `d = 3` — Biệt thức CM ($|D|$)

Biệt thức CM $D = -3$ được chọn vì những ưu điểm nổi bật:

- **Đa thức Hilbert bậc 1:** $H_{-3}(x) = x$, nên $j$-invariant bằng 0 và phương trình đường cong có dạng cực kỳ đơn giản $y^2 = x^3 + b$. Không cần giải đa thức bậc cao.
- **Phổ biến trong thực tế:** secp256k1 (Bitcoin), BLS12-381 (Ethereum), và nhiều đường cong quan trọng khác đều dùng $D = -3$.
- **Điều kiện CM đơn giản:** Phương trình $4p = t^2 + 3v^2$ dễ giải hơn với hầu hết các giá trị $(t, v)$ nguyên, tăng xác suất tìm được $p$ nguyên tố trong lưới nâng.

### `target_r_bits = 512` — Kích thước bậc nhóm $r$

Tham số này xác định **mức bảo mật** của bài toán logarit rời rạc trên đường cong (ECDLP):

- Với $r \approx 2^{512}$, thuật toán Pollard-rho tốt nhất cần $\approx 2^{256}$ phép tính, đạt mức bảo mật **256-bit** — vượt tiêu chuẩn NIST SP 800-57 cho ứng dụng đến năm 2030+ và phù hợp với kịch bản hậu lượng tử (post-quantum).
- Đây cũng là kích thước của **khóa riêng** (private key scalar) và **kích thước chữ ký** trong các giao thức Schnorr và ECDSA trên đường cong này.

### `target_p_bits = 1024` — Kích thước trường cơ sở $p$

Kích thước trường cơ sở tác động đến hai yếu tố:

- **Bảo mật DLP trên $\mathbb{F}_{p^k}$:** Với $p \approx 2^{1024}$ và $k = 18$, kích thước trường mở rộng là $2^{18432}$ bit. Theo ước lượng NFS/TNFS, điều này cho mức bảo mật $\geq 250$ bit — phù hợp với ứng dụng yêu cầu bảo mật dài hạn.
- **Hiệu năng:** Kích thước 1024 bit làm cho mỗi phép nhân trường tốn gấp đôi so với 512 bit về mặt thời gian CPU, nhưng vẫn trong giới hạn thực tế với phép nhân Montgomery đa độ chính xác.
- **Tỉ số $\rho$:** $\rho = \log_2 p / \log_2 r = 1024/512 = 2$. Đây là tỉ số điển hình của Cocks-Pinch (so với $\rho = 1.5$ của BLS12 hay $\rho = 1$ của BN).

### `max_attempts = 100_000` — Số lần thử tối đa

Giới hạn vòng lặp tìm kiếm an toàn. Trong thực nghiệm, thuật toán CP cải tiến thường tìm được kết quả trong **100–6000 lần thử** (tùy cấu hình NTT), do đó `100_000` là giới hạn rất thoải mái đảm bảo không bao giờ bị timeout trong điều kiện bình thường. Nếu vượt giới hạn này (không bao giờ xảy ra trong thực tế), hệ thống báo lỗi thay vì chạy mãi mãi.

### `min_scalar_two_adicity = 32` — Two-adicity tối thiểu của $r - 1$

Tham số này ràng buộc **cấu trúc NTT-friendly của trường vô hướng $\mathbb{F}_r$**:

$$2^{32} \mid (r - 1) \quad \Longleftrightarrow \quad r = d \cdot 2^{32} + 1 \text{ với } d \text{ lẻ}$$

Ý nghĩa thực tế: trường $\mathbb{F}_r$ chứa một căn nguyên thủy $2^{32}$-th của đơn vị, cho phép thực hiện NTT trên các đa thức bậc lên đến $2^{32} \approx 4 \times 10^9$. Đây là yêu cầu cốt lõi để tạo chứng minh ZK hiệu quả:

- Trong Groth16/PLONK, phép nhân đa thức $A(x) \cdot B(x)$ với mạch có $2^{20}$ ràng buộc cần NTT bậc $\geq 2^{21}$ — thỏa mãn với $2^{32}$.
- BLS12-381 (chuẩn công nghiệp) có $r$ two-adicity = 32; hệ thống này đạt $\geq 33$, **vượt chuẩn BLS12-381**.

Giá trị 32 đạt được **không cần rejection sampling** nhờ ràng buộc $T \equiv 0 \pmod{2^{11}}$ (vì $v_2(r-1) = 3 \cdot v_2(T) \geq 3 \times 11 = 33 \geq 32$).

### `min_base_two_adicity = 32` — Two-adicity tối thiểu của $p - 1$

Tương tự, tham số này ràng buộc **cấu trúc NTT-friendly của trường cơ sở $\mathbb{F}_p$**:

$$2^{32} \mid (p - 1) \quad \Longleftrightarrow \quad p = d \cdot 2^{32} + 1$$

Đây cũng là yêu cầu của thuật toán Miller trong phép ghép cặp: các biểu thức trung gian (line evaluations) được tính trong $\mathbb{F}_{p^k}$ và có thể được tăng tốc bằng NTT nếu $p$ có cấu trúc NTT. Ngoài ra:

- $p = d \cdot 2^{32} + 1$ kháng TNFS tốt hơn $p$ tùy ý (xem §3.3), do cấu trúc $p-1$ không có nhân tử nhỏ ngẫu nhiên mà thuật toán rây có thể khai thác.
- Giá trị này đạt được bằng cách mở rộng lưới nâng $(h_t, h_y)$ trong hàm `try_lift_to_prime`.

### Tổng hợp: Đặc trưng đường cong mục tiêu

Từ 7 tham số trên, đường cong được xây dựng có đặc trưng:

| Thuộc tính | Giá trị | Ý nghĩa |
|---|---|---|
| Phương trình | $y^2 = x^3 + b$ | $D=-3$, $j=0$, dạng tối giản |
| Bậc nhúng | $k = 18$ | Phép ghép cặp trong $\mathbb{F}_{p^{18}}$ |
| Kích thước $r$ | 512 bit | Bảo mật ECDLP 256-bit |
| Kích thước $p$ | 1024 bit | Bảo mật DLP $\geq 250$-bit |
| Two-adicity $r$ | $\geq 33$ | NTT/FFT trên $\mathbb{F}_r$ đến bậc $2^{33}$ |
| Two-adicity $p$ | $\geq 32$ | NTT/FFT trên $\mathbb{F}_p$ đến bậc $2^{32}$ |
| Dạng $r$ | $d \cdot 2^{33} + 1$ | NTT-friendly scalar field |
| Dạng $p$ | $d \cdot 2^{34} + 1$ | NTT-friendly base field (kháng TNFS) |

## Thuật toán Cocks-Pinch truyền thống


### Vấn đề: Xây dựng ngược từ $r$

Phương pháp CM truyền thống xuất phát từ $p$ được chọn trước, đòi hỏi giải phương trình $4p = t^2 + |D|v^2$ — một bài toán biểu diễn số nguyên bởi dạng toàn phương (quadratic form) không hề dễ trong không gian lớn.

**Thuật toán Cocks-Pinch (CP)** đảo chiều bài toán: **bắt đầu từ $r$ rồi xây dựng $p$**. Đây là cách tiếp cận tự nhiên hơn khi mục tiêu là đảm bảo $r$ có kích thước an toàn (ví dụ: 512 bit) với bậc nhúng $k$ cho trước.

### Điều kiện bậc nhúng

Bậc nhúng $k$ của đường cong là **số nguyên dương nhỏ nhất** sao cho $r \mid p^k - 1$, hay tương đương $p \equiv 1 \pmod{r}$ khi $k=1$, hoặc tổng quát hơn $p$ là nghiệm của $\Phi_k(x) \equiv 0 \pmod{r}$.

Điều kiện cụ thể: $r \mid \Phi_k(p)$, trong đó $\Phi_k$ là đa thức cyclotomic. Điều này có nghĩa là tồn tại $u$ nguyên tố cùng nhau với $k$ sao cho:

$$p \equiv \rho^i \pmod{r} \quad \text{với } \rho \text{ là nghiệm nguyên thủy của } \Phi_k(x) \equiv 0 \pmod{r}$$

### Thuật toán CP cho $k = 18$

Với $k = 18$ và $D = -3$, bậc nhóm $r = \Phi_{18}(T) = T^6 - T^3 + 1$ với $T$ nguyên tùy ý. Các bước:

**Bước 1 — Sinh $r$ từ $T$:**

$$r = \Phi_{18}(T) = T^6 - T^3 + 1$$

Kiểm tra tính nguyên tố của $r$ bằng thuật toán Miller-Rabin.

**Bước 2 — Tính $\sqrt{-D} \pmod{r}$:**

Cần $\beta = \sqrt{-3} \pmod{r}$. Do $r \equiv 1 \pmod{3}$ (do cấu trúc của $\Phi_{18}$), phần tử này luôn tồn tại. Dùng thuật toán Tonelli–Shanks.

**Bước 3 — Tính $t_0, y_0$ modulo $r$:**

Với mỗi $i$ thỏa $\gcd(i, k) = 1$ và $1 \leq i < k$:

$$t_0 = T^i + 1 \pmod{r}, \quad y_0 = \frac{t_0 - 2}{\beta} \pmod{r}$$

**Bước 4 — Nâng (lift) lên số nguyên:**

Tìm $t, y \in \mathbb{Z}$ với $t \equiv t_0 \pmod{r}$, $y \equiv y_0 \pmod{r}$ sao cho:

$$p = \frac{t^2 + 3y^2}{4}$$

là số nguyên và là số nguyên tố. Để làm điều này, thử các dịch chuyển nhỏ:

$$t = t_0 + h_t \cdot r, \quad y = y_0 + h_y \cdot r, \quad h_t, h_y \in \{-20, \ldots, 20\}$$

cho đến khi $\frac{t^2 + 3y^2}{4}$ là số nguyên tố đúng kích thước mục tiêu.

Trong cài đặt (`cocks_pinch.rs`), hàm `try_lift_to_prime` thực hiện tìm kiếm này:

```rust
for ht in -half_range..=half_range {
    for hy in -half_range..=half_range {
        let t = apply_lift(lp.t0, r, ht as i32);
        let y = apply_lift(lp.y0, r, hy as i32);
        // p = (t² + 3y²) / 4
        let numerator = t² + 3y²;
        if numerator % 4 != 0 { continue; }
        let p = numerator / 4;
        if is_prime(&p) { return Some(CurveParams { p, r, t, y, .. }); }
    }
}
```

### Phân tích độ phức tạp trung bình

Mật độ số nguyên tố lân cận $N$ là khoảng $1/\ln N$, tức $1/1024\ln 2 \approx 1/709$. Với lưới $(h_t, h_y) \in [-20, 20]^2$ tạo ra $41 \times 41 = 1681$ ứng viên $p$ mỗi lần, tỉ lệ thành công mỗi lần sinh $r$ là khoảng $1681/709 \approx 2.4$ ứng viên $p$ nguyên tố. Trong thực tế, thường cần khoảng **100–500 lần sinh $r$** để tìm được bộ tham số hợp lệ.

## Thuật toán Cocks-Pinch Cải tiến

### Động lực: Tấn công rây trường số tháp (TNFS)

Bảo mật của phép ghép cặp phụ thuộc vào độ khó của **bài toán logarit rời rạc** (DLP) trên trường mở rộng $\mathbb{F}_{p^k}$. Năm 2016, Barbulescu và Duquesne chỉ ra rằng thuật toán **Tower Number Field Sieve (TNFS)** — một biến thể của NFS — có thể giảm đáng kể độ phức tạp tấn công DLP trên $\mathbb{F}_{p^k}$ khi $k$ composite và $p$ có cấu trúc đặc biệt. Điều này **phá vỡ ước lượng bảo mật ban đầu** của các đường cong như BN256 (từ ~128 bit xuống còn ~100 bit hiệu quả).

Để kháng lại TNFS, cần đảm bảo trường cơ sở của đường cong có **cấu trúc tốt** ở cả hai trường: trường vô hướng $\mathbb{F}_r$ (phục vụ tính toán ZK proof) và trường cơ sở $\mathbb{F}_p$ (phục vụ phép ghép cặp).

### Yêu cầu NTT-friendly

Một số nguyên tố $q$ được gọi là **NTT-friendly** (hoặc FFT-friendly) nếu $q - 1$ chia hết cho một lũy thừa đủ lớn của 2, tức là:

$$2^s \mid (q - 1) \quad \text{với } s \text{ đủ lớn}$$

Số $s$ được gọi là **số hạng hai-adicity** (two-adicity) của $q$. Ý nghĩa: trường $\mathbb{F}_q$ chứa một căn nguyên thủy $2^s$-th của đơn vị, cho phép áp dụng **Biến đổi Lý thuyết số (NTT)** — tức FFT trên trường hữu hạn — để nhân đa thức bậc cao trong $O(n \log n)$ thay vì $O(n^2)$.

Đây là yếu tố *quyết định* hiệu năng trong:
- Sinh chứng minh ZK (Groth16, PLONK): tính $H(x) = (A(x) \cdot B(x) - C(x)) / Z(x)$
- Các cam kết đa thức (KZG, FRI)
- Thuật toán MSM (Multi-scalar multiplication) biến thể NTT

**Tương quan với TNFS:** Một trường $\mathbb{F}_p$ với two-adicity cao có $p-1 = d \cdot 2^s$, nghĩa là $p = d \cdot 2^s + 1$. Cấu trúc này khiến cho tháp trường (tower field extension) $\mathbb{F}_{p^k}$ có đặc điểm tốt hơn từ góc độ kháng TNFS: các thuật toán rây cần khai thác cấu trúc phân tích của $p-1$ để tìm quan hệ, do đó khi $p-1$ có cấu trúc **không phân tích tùy tiện** mà theo dạng chuẩn $d \cdot 2^s + 1$, sự khai thác thông tin này trở nên khó hơn.

### Cải tiến 1: NTT-friendly $r$ qua ràng buộc $T$

**Nhận xét then chốt:** Vì $r = \Phi_{18}(T) = T^6 - T^3 + 1$, ta có:

$$r - 1 = T^3(T^3 - 1)$$

Nếu $T \equiv 0 \pmod{2^k}$, thì $T^3 \equiv 0 \pmod{2^{3k}}$, và do đó:

$$v_2(r-1) = v_2(T^3(T^3 - 1)) = 3k$$

(vì $T^3 \equiv 0 \pmod{2^{3k}}$ và $T^3 - 1 \equiv -1 \pmod{2}$ là lẻ).

**Kết luận:** Để đảm bảo $\text{two-adicity}(r-1) \geq s$, chỉ cần **chọn $T \equiv 0 \pmod{2^{\lceil s/3 \rceil}}$**. Đây là ràng buộc *không cần rejection sampling* — mọi $T$ thỏa mãn điều kiện này đều cho $r$ với two-adicity ít nhất $s$.

Trong cài đặt:

```rust
// Chọn T là bội số của 2^ceil(s/3): đảm bảo two_adicity(r-1) >= s
let t_align = min_scalar_two_adicity.div_ceil(3);
let step = U1024::ONE.shl(t_align as usize);
// t_val luôn là bội số của step
let t_val = t_base + U1024::rand(&t_steps) * step;
let r = cyclotomic_phi18(&t_val);
// Đảm bảo r thỏa mãn: two_adicity(r-1) = 3 * v₂(T) >= s
```

Với `min_scalar_two_adicity = 32`, ta cần $\lceil 32/3 \rceil = 11$, tức $T \equiv 0 \pmod{2^{11}}$. Điều này **không làm giảm không gian tham số** đáng kể — vẫn còn $2^{85}/2^{11} = 2^{74}$ ứng viên $T$ trong dải hợp lệ.

### Cải tiến 2: NTT-friendly $p$ qua mở rộng lưới nâng

Sau khi có $t_0, y_0 \pmod{r}$, tham số $p$ được xác định bởi:

$$p = \frac{(t_0 + h_t r)^2 + 3(y_0 + h_y r)^2}{4}$$

Vì $r \equiv 0 \pmod{2^{3k}}$ (do $T \equiv 0 \pmod{2^k}$), các bit thấp hơn $3k$ của $p-1$ chỉ phụ thuộc vào $t_0, y_0$ (cố định cho mỗi $r$). Tuy nhiên, các bit từ vị trí $3k$ trở lên bị ảnh hưởng bởi $h_t, h_y$.

Để đạt $\text{two-adicity}(p-1) \geq s_p > 3k$, ta cần mở rộng lưới $(h_t, h_y)$ ra ngoài phạm vi $\pm 20$ mặc định:

$$\text{extra} = \max(0,\, s_p - 3k), \quad \text{half\_range} = 20 + 2^{\text{extra}}$$

Điều này đảm bảo có đủ ứng viên $h_t, h_y$ để **bao phủ mọi tổ hợp bit từ vị trí $3k$ đến $s_p$** trong $p-1$.

```rust
struct LiftParams<'a> {
    t0: &'a U1024,
    y0: &'a U1024,
    target_p_bits: usize,
    min_base_two_adicity: u32,  // s_p
    r_two_adicity: u32,         // 3k
}

// Mở rộng lưới tìm kiếm tỉ lệ với khoảng cách giữa s_p và 3k
let extra = lp.min_base_two_adicity
    .saturating_sub(lp.r_two_adicity)
    .min(10); // giới hạn để lưới không bùng nổ
let half_range = 20i64 + (1i64 << extra);
```

### Phân tích hiệu năng của thuật toán cải tiến

Bảng dưới so sánh thuật toán CP gốc và CP Cải tiến với cùng mục tiêu $(r \approx 2^{512}, p \approx 2^{1024}, k = 18)$:

| Tham số | CP Truyền thống | CP Cải tiến ($s_r = 32, s_p = 32$) |
|---|---|---|
| Ràng buộc trên $T$ | Không có | $T \equiv 0 \pmod{2^{11}}$ |
| two-adicity của $r-1$ | Ngẫu nhiên (~1-3) | $\geq 33$ (đảm bảo) |
| two-adicity của $p-1$ | Ngẫu nhiên (~1) | $\geq 32$ (với lưới mở rộng) |
| Lưới $(h_t, h_y)$ | $[-20, 20]^2$ | $[-21, 21]^2$ (khi $s_p \leq 3k$) |
| Chi phí mỗi lần thử | ~50ms | ~50ms |
| Số lần thử trung bình | ~100–500 | ~3.000–6.000 |
| Thời gian thực tế | ~2–10 giây | ~30–60 giây |
| $r$ hỗ trợ NTT? | Không | Có (bậc $2^{33}$) |
| $p$ hỗ trợ NTT? | Không | Có (bậc $2^{34}$) |

*Kết quả thực nghiệm điển hình:*
```
r two-adicity: 2^33 | (r-1)  →  r = d·2^33 + 1, NTT đến bậc 2^33
p two-adicity: 2^34 | (p-1)  →  p = d·2^34 + 1, NTT đến bậc 2^34
Thời gian tổng: 32.81s
```

### So sánh với BLS12-381

Đường cong BLS12-381 — chuẩn công nghiệp hiện tại trong ZK proof — có:
- $r$ two-adicity = **32** (đủ cho ZK circuits đến $2^{32}$ ràng buộc)
- $p$ two-adicity = **32**

Đường cong được xây dựng trong luận văn này đạt **33–34**, tức là **vượt BLS12-381 về cấu trúc NTT** trong khi kích thước khóa lớn hơn ($p \approx 2^{1024}$ so với $p \approx 2^{381}$), cung cấp mức bảo mật hậu lượng tử cao hơn trong ngữ cảnh phép ghép cặp.

### Giới hạn và hướng mở rộng

Thuật toán cải tiến vẫn có giới hạn thực tế:

- **Two-adicity tối đa đạt được**: Khi $s_p > 3k + 10$, lưới $(h_t, h_y)$ phải có $\text{half\_range} > 2^{10} = 1024$, số lần lặp vượt $10^6$ mỗi ứng viên $r$, khiến tìm kiếm không thực tế. Nếu cần $s_p$ cực cao (>50), cần dùng họ đường cong chuyên dụng thiết kế từ đầu như Pasta curves (Pallas/Vesta).
- **Tỉ số $\rho$**: Thuật toán CP vốn cho tỉ số $\rho = \log p / \log r \approx 2$, không tối ưu bằng các họ đường cong chuyên biệt như BN256 ($\rho = 1$). Đây là sự đánh đổi cố hữu của phương pháp CP.
- **Chỉ $k=18$ và $D=-3$** được cài đặt trong hệ thống hiện tại. Mở rộng sang $k = 12, 24$ đòi hỏi thay đổi đa thức cyclotomic và công thức CM.