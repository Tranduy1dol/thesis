---
title: Cơ sở toán học
chapter: 2
toc-title: CƠ SỞ TOÁN HỌC
---

# Chương 2: Cơ sở toán học

Chương này trình bày các khái niệm toán học nền tảng được sử dụng trong toàn bộ luận văn: cấu trúc trường hữu hạn, đường cong elliptic Short Weierstrass và các phép toán nhóm trên nó, cùng với các kỹ thuật số học tối ưu (Montgomery, Fermat) được cài đặt trực tiếp trong thư viện `curve1024`.

## Trường hữu hạn $\mathbb{F}_p$

### Định nghĩa

**Trường số nguyên tố** $\mathbb{F}_p$ là tập $\{0, 1, \ldots, p-1\}$ với phép cộng và nhân lấy modulo $p$, trong đó $p$ là số nguyên tố. Đây là trường hữu hạn nhỏ nhất có đặc số $p$.

Các tính chất quan trọng:

- **Đóng kín**: kết quả của mọi phép toán đều thuộc $\mathbb{F}_p$.
- **Nghịch đảo nhân**: mọi phần tử $a \neq 0$ có nghịch đảo $a^{-1}$ sao cho $a \cdot a^{-1} \equiv 1 \pmod{p}$.
- **Theo Định lý nhỏ Fermat**: $a^{p-1} \equiv 1 \pmod{p}$ với mọi $a \neq 0$, do đó $a^{-1} = a^{p-2} \pmod{p}$.

### Cài đặt: `PrimeFieldConfig` và `PrimeFieldElement`

Trong thư viện `curve1024`, trường $\mathbb{F}_p$ được biểu diễn qua trait `PrimeFieldConfig` (mang các hằng số tĩnh) và struct `PrimeFieldElement<C>` (phần tử trường):

```rust
pub trait PrimeFieldConfig {
    const MODULUS: U1024;  // p: số nguyên tố trường
    const R2:      U1024;  // R² mod p, dùng cho Montgomery
    const N_PRIME: U1024;  // -p⁻¹ mod 2^1024, dùng cho REDC
}

pub struct PrimeFieldElement<C: PrimeFieldConfig> {
    value: U1024,          // biểu diễn Montgomery: a·R mod p
}
```

Thiết kế này cho phép trình biên dịch mở inline toàn bộ hằng số tại thời gian biên dịch (zero-cost abstraction): hai trường khác nhau $\mathbb{F}_p$ và $\mathbb{F}_r$ dùng chung code nhưng có tham số riêng biệt không thể nhầm lẫn.

### Các phép toán cơ bản

**Cộng và trừ** thực hiện bằng cộng/trừ số nguyên rồi hiệu chỉnh modulo:

```rust
// Cộng: (a + b) mod p
fn add(self, rhs: Self) -> Self {
    let (sum, carry) = self.value.carrying_add(&rhs.value);
    let (sub, borrow) = sum.borrowing_sub(&C::MODULUS);
    // Chọn kết quả không cần phép chia
    conditional_select(sum, sub, carry || !borrow)
}
```

Phép cộng không cần phép chia đầy đủ — chỉ cần một phép trừ có điều kiện. Chi phí: $O(n)$ với $n$ là số limb (16 limb × 64 bit = 1024 bit).

**Nhân** dùng phép nhân Montgomery (xem §2.4).

**Nghịch đảo** dùng lũy thừa Fermat: $a^{-1} = a^{p-2} \pmod{p}$, thực hiện bởi hàm `pow` với phép nhân bình phương liên tiếp (square-and-multiply):

```rust
pub fn inv(&self) -> Self {
    self.pow(C::MODULUS - 2)  // a^(p-2) mod p
}
```

## Đường cong elliptic Short Weierstrass

### Định nghĩa

Trên $\mathbb{F}_p$ với $p > 3$, **đường cong elliptic dạng Short Weierstrass** là tập hợp:

$$E(\mathbb{F}_p) = \{(x, y) \in \mathbb{F}_p \times \mathbb{F}_p \mid y^2 = x^3 + ax + b\} \cup \{\mathcal{O}\}$$

trong đó $\mathcal{O}$ là **điểm vô cực** (point at infinity) — phần tử đặc biệt không thuộc mặt phẳng affine, đóng vai trò phần tử đơn vị của nhóm.

**Điều kiện không suy biến:** Biệt thức $\Delta = -16(4a^3 + 27b^2) \neq 0$, đảm bảo đường cong không có điểm kỳ dị (cusp hay node). Kiểm tra này được thực hiện ngầm qua quá trình CM: với $D = -3$, luôn có $a = 0$ và điều kiện thu gọn thành $b \neq 0$.

### Cấu trúc nhóm

Tập $E(\mathbb{F}_p)$ tạo thành một **nhóm Abel hữu hạn** với phép cộng điểm. Bậc của nhóm $\#E(\mathbb{F}_p) = p + 1 - t$ (định lý Hasse), trong đó $|t| \leq 2\sqrt{p}$ là vết Frobenius.

Trong cài đặt:

```rust
pub struct AffinePoint<C: SWCurveConfig> {
    pub x:           FieldElement<C::BaseField>,
    pub y:           FieldElement<C::BaseField>,
    pub is_infinite: bool,
}
```

## Phép cộng điểm (Point Addition)

### Quy tắc hình học

Phép cộng trên $E$ được định nghĩa bằng quy tắc "dây-cung và tiếp tuyến":

- **Phần tử đơn vị:** $P + \mathcal{O} = \mathcal{O} + P = P$ với mọi $P$.
- **Phần tử nghịch đảo:** $-( x, y) = (x, -y)$, vì $P + (-P) = \mathcal{O}$.
- **Cộng hai điểm phân biệt** $P_1 \neq \pm P_2$: vẽ đường thẳng qua $P_1, P_2$, điểm giao thứ ba với đường cong là $R'$, phản chiếu qua trục $x$ cho $P_3 = P_1 + P_2 = -R'$.
- **Nhân đôi** $P + P = 2P$: dùng đường tiếp tuyến tại $P$.

### Công thức đại số

Cho $P_1 = (x_1, y_1)$ và $P_2 = (x_2, y_2)$ trên $y^2 = x^3 + ax + b$, điểm tổng $P_3 = (x_3, y_3)$:

**Cộng hai điểm phân biệt** ($P_1 \neq P_2$):
$$\lambda = \frac{y_2 - y_1}{x_2 - x_1}, \quad x_3 = \lambda^2 - x_1 - x_2, \quad y_3 = \lambda(x_1 - x_3) - y_1$$

**Nhân đôi** ($P_1 = P_2$):
$$\lambda = \frac{3x_1^2 + a}{2y_1}, \quad x_3 = \lambda^2 - 2x_1, \quad y_3 = \lambda(x_1 - x_3) - y_1$$

Mỗi công thức cần **1 phép nghịch đảo** (tính $\lambda$), 2–3 phép nhân, và 4–6 phép cộng/trừ trong $\mathbb{F}_p$.

### Cài đặt

```rust
pub fn add(&self, rhs: &Self) -> Self {
    if self.is_infinite { return *rhs; }
    if rhs.is_infinite  { return *self; }
    if self.neg() == *rhs { return Self::infinite(); }
    if *self == *rhs  { return self.double(); }

    let lambda = (rhs.y - self.y) * (rhs.x - self.x).inv();
    let x3 = lambda.square() - self.x - rhs.x;
    let y3 = lambda * (self.x - x3) - self.y;
    Self::new(x3, y3)
}

pub fn double(&self) -> Self {
    if self.is_infinite || self.y.is_zero() { return Self::infinite(); }
    let three = FieldElement::new(U1024::from(3));
    let two   = FieldElement::new(U1024::from(2));
    let lambda = (three * self.x.square() + C::COEFF_A) * (two * self.y).inv();
    let x3 = lambda.square() - self.x - self.x;
    let y3 = lambda * (self.x - x3) - self.y;
    Self::new(x3, y3)
}
```

Hàm `new` gọi `assert!(point.is_on_curve())` để đảm bảo mọi điểm kết quả đều hợp lệ — bắt lỗi nhanh trong quá trình phát triển.

## Phép nhân vô hướng (Scalar Multiplication)

### Thuật toán Double-and-Add

Phép nhân vô hướng $[k]P = P + P + \cdots + P$ ($k$ lần) được tính hiệu quả bằng **Double-and-Add** (tương tự binary exponentiation), với độ phức tạp $O(\log k)$ thay vì $O(k)$:

```
Input: P ∈ E(F_p), k ∈ [0, r-1]
Output: [k]P

R ← O (điểm vô cực)
B ← P
for i = 0 to 1023:
    if bit i của k bằng 1:
        R ← R + B
    B ← 2B
return R
```

Với $k \approx 2^{512}$ (1024 bit), thuật toán thực hiện tối đa 1024 lần nhân đôi và trung bình 512 lần cộng điểm.

### Cài đặt

```rust
pub fn mul(&self, scalar: &U1024) -> Self {
    let mut result = Self::infinite();
    let mut base   = *self;
    for i in 0..1024 {
        let limb_idx = i / 64;
        let bit_idx  = i % 64;
        if (scalar.0[limb_idx] >> bit_idx) & 1 == 1 {
            result = result.add(&base);
        }
        base = base.double();
    }
    result
}
```

Mỗi lần gọi `mul` thực hiện đúng 1024 lần `double` và tối đa 1024 lần `add`. Chi phí tính toán chủ yếu đến từ phép nghịch đảo trong $\mathbb{F}_p$ (mỗi lần `add`/`double` cần 1 nghịch đảo, tức $p^{p-2}$ — một lũy thừa 1024-bit).

### Tầm quan trọng

Phép nhân vô hướng là hàm cốt lõi của mọi sơ đồ mật mã ECC:

| Thao tác | Ký hiệu | Ứng dụng |
|---|---|---|
| Sinh khóa công khai | $Q = [d]G$ | Từ khóa riêng $d$ |
| Cam kết ký (Schnorr/ECDSA) | $R = [k]G$ | Nonce commitment |
| Xác minh Schnorr | $[s]G$ và $[e]Q$ | Hai lần nhân vô hướng |
| Xác minh ECDSA | $[u_1]G + [u_2]Q$ | Hai lần nhân vô hướng |

## Tối ưu số học: Phép nhân Montgomery

### Vấn đề

Phép nhân thông thường $a \cdot b \pmod{p}$ đòi hỏi một phép chia đầy đủ để lấy số dư — rất đắt với số 1024-bit. Montgomery đề xuất thực hiện phép nhân trong **không gian Montgomery** để tránh phép chia.

### Biến đổi Montgomery

Chọn $R = 2^{1024}$ (cơ số nguyên tố cùng nhau với $p$). **Dạng Montgomery** của $a$ là $\hat{a} = a \cdot R \pmod{p}$.

Phép nhân Montgomery (**REDC**) tính $\hat{a} \cdot \hat{b} \cdot R^{-1} \pmod{p}$ từ $\hat{a}$ và $\hat{b}$, chỉ dùng phép chia cho $R$ (shift phải 1024 bit — rất rẻ) thay vì chia cho $p$.

| Phép tính | Thông thường | Montgomery |
|---|---|---|
| $a \cdot b \pmod{p}$ | cần chia cho $p$ | shift + trừ có điều kiện |
| Chi phí | $O(n^2)$ + chia | $O(n^2)$ không chia |

**Quy trình REDC** (với ba hằng số biên dịch: $R^2 \bmod p$, $-p^{-1} \bmod R$):
1. Nhân $\text{lo}, \text{hi} = \hat{a} \cdot \hat{b}$
2. $m = \text{lo} \cdot N' \bmod R$ với $N' = -p^{-1} \bmod R$
3. $t = (\text{hi}, \text{lo}) + m \cdot p$ (chỉ giữ phần trên $R$)
4. Nếu $t \geq p$: $t \leftarrow t - p$

```rust
fn reduce(lo: &U1024, hi: &U1024) -> U1024 {
    let (m, _)       = lo.widening_mul(&C::N_PRIME);   // m = lo · N' mod R
    let (mn_lo, mn_hi) = m.widening_mul(&C::MODULUS);  // m · p
    let (_, carry_lo)  = lo.carrying_add(&mn_lo);
    let (t, carry_hi)  = hi.carrying_add(&mn_hi);
    // Bước hiệu chỉnh cuối: trừ p nếu cần
    let (sub, borrow) = t.borrowing_sub(&C::MODULUS);
    if carry_hi || carry_lo { sub } else if !borrow { sub } else { t }
}
```

### Chuyển đổi vào/ra không gian Montgomery

- **Chuyển vào:** `PrimeFieldElement::new(a)` tính $a \cdot R^2 \cdot R^{-1} = a \cdot R \pmod{p}$.
- **Chuyển ra:** `to_u1024()` gọi `reduce(value, 0)` = $\hat{a} \cdot R^{-1} = a \pmod{p}$.

Trong thực tế, hầu hết tính toán diễn ra trong không gian Montgomery — chỉ chuyển ra khi cần so sánh hay xuất kết quả, giúp loại bỏ hoàn toàn phép chia trong vòng lặp tính toán chính.

## Lũy thừa nhanh (Square-and-Multiply)

Hàm `pow` thực hiện lũy thừa $a^e \pmod{p}$ bằng phương pháp **square-and-multiply** với bảo vệ timing side-channel qua `conditional_select`:

```rust
pub fn pow(&self, exp: U1024) -> Self {
    let mut res  = Self::one();
    let mut base = *self;
    for i in 0..16 {           // 16 limb × 64 bit = 1024 bit
        let mut limb = exp.0[i];
        for _ in 0..64 {
            let bit     = (limb & 1) as u8;
            let product = res * base;
            // Chọn res hoặc product dựa trên bit, không dùng nhánh if
            res  = Self::conditional_select(&res, &product, bit.into());
            base = base.square();
            limb >>= 1;
        }
    }
    res
}
```

`conditional_select` từ crate `subtle` đảm bảo cả hai nhánh thực hiện cùng số lệnh, loại bỏ thông tin qua thời gian thực thi (constant-time execution).

Nghịch đảo $a^{-1} = a^{p-2}$ dùng `pow` với $e = p - 2$: 1024 lần bình phương và ~512 lần nhân (trung bình), tổng $\approx 1536$ phép nhân Montgomery.
