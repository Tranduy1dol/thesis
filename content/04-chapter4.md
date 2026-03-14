---
title: Sơ đồ chữ ký số
chapter: 4
toc-title: SƠ ĐỒ CHỮ KÝ SỐ
---

Chương này trình bày ba sơ đồ chữ ký số được xây dựng trên nền tảng đường cong elliptic đã sinh ở Chương 3: **Schnorr**, **ECDSA**, và **chữ ký tổng hợp BLS**. Với mỗi sơ đồ, chúng ta đi qua lý thuyết cốt lõi, phân tích cấu trúc dữ liệu và cài đặt thực tế bằng Rust. Kết quả đo hiệu năng và phân tích bảo mật được trình bày riêng tại **Chương 5**.


# Cặp khóa (KeyPair)

Mọi sơ đồ chữ ký đều dùng chung cấu trúc cặp khóa:

```rust
pub struct KeyPair<C: SWCurveConfig> {
    pub private_key: U1024,        // d in [1, r-1], bí mật
    pub public_key:  AffinePoint<C>, // Q = [d]G, công khai
}
```

- **Khóa riêng** `d`: một số nguyên ngẫu nhiên trong $[1, r-1]$, sinh bởi CSPRNG (`U1024::rand`).
- **Khóa công khai** `Q = [d]G`: tính bằng phép nhân vô hướng. Với $r \approx 2^{512}$, tính $Q$ từ $d$ là tính khả thi (mili giây), nhưng bài toán ngược (tính $d$ từ $Q$) là ECDLP — độ phức tạp $O(2^{256})$.

Cặp khóa được lưu/đọc từ file nhị phân 128 byte (big-endian) với quyền `0600` trên Unix:

```rust
impl<C: SWCurveConfig> KeyPair<C> {
    pub fn generate() -> Self {
        let private_key = U1024::rand(&C::ORDER);
        let public_key  = C::generator().mul(&private_key);
        Self { private_key, public_key }
    }
    pub fn save(&self, path: &str) -> io::Result<()> {
        fs::write(path, self.private_key.to_be_bytes())?;
        fs::set_permissions(path, Permissions::from_mode(0o600))?;
        Ok(())
    }
}
```

## Hàm băm mở rộng

Vì $r \approx 2^{512}$ và SHA-256 chỉ cho 256 bit, hệ thống dùng **4 lần SHA-256** với tiền tố khác nhau để sinh 1024 bit, rồi cắt lấy 512 bit thấp khi cần:

```rust
pub fn hash_message(message: &[u8]) -> U1024 {
    let mut buf = [0u8; 128];
    for i in 0..4 {
        let mut h = Sha256::new();
        h.update([i as u8]);
        h.update(message);
        buf[i*32..(i+1)*32].copy_from_slice(&h.finalize());
    }
    U1024::from_be_bytes(&buf)
}
```

Cấu trúc này tương đương với **SHA-1024** tùy chỉnh, đảm bảo đầu ra đủ lớn để tránh đụng độ có nghĩa với độ bảo mật $r \approx 2^{512}$.

# Chữ ký Schnorr

## Lý thuyết

Schnorr là sơ đồ chữ ký Sigma-protocol dựa trên giả thuyết logarit rời rạc (DL). Nó được ưa chuộng vì độ đơn giản của chứng minh bảo mật (trong mô hình Oracle ngẫu nhiên) và hỗ trợ tổng hợp tự nhiên.

**Ký:** Cho khóa riêng $d \in [1, r-1]$ và thông điệp $m$:
1. Chọn ngẫu nhiên $k \xleftarrow{R} [1, r-1]$
2. Tính điểm $R = [k]G$
3. Tính thách thức $e = H(R_x \| R_y \| m) \pmod{r}$
4. Tính $s = k + e \cdot d \pmod{r}$
5. Chữ ký: $\sigma = (R, s)$

**Xác minh:** Cho khóa công khai $Q$ và chữ ký $(R, s)$:
1. Tính $e = H(R_x \| R_y \| m)$
2. Kiểm tra $[s]G = R + [e]Q$

Tính đúng đắn: $[s]G = [k + ed]G = [k]G + [e][d]G = R + [e]Q$ [ok]

## Cấu trúc dữ liệu

```rust
pub struct SchnorrSignature<C: SWCurveConfig> {
    pub r_point: AffinePoint<C>,  // R = [k]G  (điểm 256 byte: 2x128 byte tọa độ)
    pub s:       U1024,           // s in [0, r-1], 128 byte
}
```

Kích thước chữ ký: $2 \times 128 + 128 = \mathbf{384}$ byte (R gồm hai tọa độ $x, y$ mỗi tọa độ 128 byte, cộng thêm $s$ 128 byte).

## Cài đặt

```rust
pub fn sign(private_key: &U1024, message: &[u8]) -> Self {
    let k = U1024::rand(&C::ORDER);
    let r_point = C::generator().mul(&k);
    let e       = Self::challenge_hash(&r_point, message); // H(Rx‖Ry‖m) mod r
    let s       = (k_field + e * d_field).to_u1024();     // s = k + e.d mod r
    Self { r_point, s }
}

pub fn verify(&self, public_key: &AffinePoint<C>, message: &[u8]) -> bool {
    let e  = Self::challenge_hash(&self.r_point, message);
    let v1 = C::generator().mul(&self.s);              // [s]G
    let v2 = self.r_point.add(&public_key.mul(&e.to_u1024())); // R + [e]Q
    v1 == v2
}
```

Hàm `challenge_hash` nối $R_x, R_y, m$ rồi gọi `hash_message`, đảm bảo thách thức phụ thuộc vào toàn bộ ngữ cảnh — tránh tấn công forgery kiểu Pohlig-Hellman trên nonce.

## Bảo mật

- **Unforgeability (EUF-CMA):** Chứng minh được trong Random Oracle Model dưới giả thuyết DL. Kẻ tấn công cần giải ECDLP hoặc bẻ hàm băm.
- **Nguy cơ nonce tái sử dụng:** Nếu $k$ bị tái sử dụng cho hai thông điệp khác nhau, kẻ công phá có thể tính $d = (s_1 - s_2)/(e_1 - e_2) \pmod{r}$. Cài đặt dùng CSPRNG (`rand::thread_rng`) cho mỗi lần ký.

# Chữ ký ECDSA

## Lý thuyết

ECDSA (Elliptic Curve Digital Signature Algorithm) là chuẩn IEEE P1363 và FIPS 186-4. Nó khác Schnorr ở chỗ $r$ trong chữ ký là **tọa độ $x$ của điểm $R$** lấy modulo $n$, thay vì bản thân điểm $R$.

**Ký:** Cho khóa riêng $d$ và thông điệp $m$:
1. $k \xleftarrow{R} [1, r-1]$
2. $R = [k]G$
3. $r_{\text{sig}} = R_x \pmod{n}$ (nếu $r_{\text{sig}} = 0$, thử lại)
4. $e = H(m)$
5. $s = k^{-1}(e + r_{\text{sig}} \cdot d) \pmod{n}$ (nếu $s = 0$, thử lại)
6. Chữ ký: $\sigma = (r_{\text{sig}}, s)$

**Xác minh:**
1. Kiểm tra $r_{\text{sig}}, s \in [1, n-1]$
2. $e = H(m)$, $w = s^{-1} \pmod{n}$
3. $u_1 = ew$, $u_2 = r_{\text{sig}} \cdot w$, cả hai tính mod $n$
4. $P = [u_1]G + [u_2]Q$
5. Hợp lệ khi $P \neq \mathcal{O}$ và $P_x \pmod{n} = r_{\text{sig}}$

## Cấu trúc dữ liệu

```rust
pub struct EcdsaSignature {
    pub r: U1024,  // r_sig = R.x mod n, 128 byte
    pub s: U1024,  // s in [1, n-1],     128 byte
}
```

Kích thước chữ ký: $128 + 128 = \mathbf{256}$ byte — nhỏ hơn Schnorr vì không lưu điểm $R$ đầy đủ.

## Cài đặt

```rust
pub fn sign<C: SWCurveConfig>(private_key: &U1024, message: &[u8]) -> Self {
    let k     = U1024::rand(&C::ORDER);
    let r_pt  = C::generator().mul(&k);
    let e     = FieldElem::<C::ScalarField>::new(hash_message(message));
    let r     = FieldElem::<C::ScalarField>::new(r_pt.x.to_u1024());
    let k_inv = FieldElem::<C::ScalarField>::new(k).inv();
    let d     = FieldElem::<C::ScalarField>::new(*private_key);
    let s     = k_inv * (e + r * d);
    Self { r: r.to_u1024(), s: s.to_u1024() }
}

pub fn verify<C: SWCurveConfig>(&self, public_key: &AffinePoint<C>, message: &[u8]) -> bool {
    // Kiểm tra r, s in [1, n-1]
    if self.r.is_zero() || self.s.is_zero() { return false; }
    if self.r >= C::ORDER || self.s >= C::ORDER { return false; }

    let e = FieldElem::new(hash_message(message));
    let w = FieldElem::new(self.s).inv();      // w = s^{-1}
    let u1 = (e * w).to_u1024();
    let u2 = (FieldElem::new(self.r) * w).to_u1024();

    let p = C::generator().mul(&u1).add(&public_key.mul(&u2));
    !p.is_infinite && FieldElem::<C::ScalarField>::new(p.x.to_u1024()).to_u1024() == self.r
}
```

## So sánh Schnorr và ECDSA

| Tiêu chí | Schnorr | ECDSA |
|---|---|---|
| Chuẩn hóa | ISO/IEC 14888-3 | FIPS 186-4, IEEE P1363 |
| Kích thước chữ ký | 384 byte ($2 \times 128 + 128$) | 256 byte ($2 \times 128$) |
| Phép nhân vô hướng ký | 1 | 1 |
| Phép nhân vô hướng xác minh | 2 (tuần tự) | 2 (tuần tự) |
| Bảo mật chứng minh | RO Model, DL | Heuristic, DL + hash |
| Hỗ trợ tổng hợp | Có (MuSig, FROST) | Không |
| Rủi ro nonce tái sử dụng | Lộ khóa riêng | Lộ khóa riêng |

# Chữ ký tổng hợp BLS

## Lý thuyết (tổng quan)

Chữ ký BLS (Boneh-Lynn-Shacham, 2001) là sơ đồ **tổng hợp phi tương tác**: $n$ người ký với $n$ khóa riêng khác nhau có thể tạo ra **một chữ ký duy nhất** đại diện cho tất cả, và xác minh chỉ cần một phép ghép cặp thay vì $n$ phép.

**Nền tảng:** Dùng phép ghép cặp song tuyến $e: \mathbb{G}_1 \times \mathbb{G}_2 \to \mathbb{G}_T$ với:
- $\mathbb{G}_1 = E(\mathbb{F}_p)$, $\mathbb{G}_2 = E'(\mathbb{F}_{p^2})$ (hoặc tương đương)
- $\mathbb{G}_T \subset \mathbb{F}_{p^k}^*$

**Ký:** Người thứ $i$ với khóa riêng $d_i$:
$$\sigma_i = [d_i] H(m) \in \mathbb{G}_1$$
trong đó $H: \{0,1\}^* \to \mathbb{G}_1$ là hàm băm lên nhóm điểm.

**Tổng hợp:** $\sigma = \sigma_1 + \sigma_2 + \cdots + \sigma_n$ (phép cộng điểm, không cần tương tác)

**Xác minh tổng hợp:**
$$e(\sigma, G_2) = e(H(m), Q_1 + Q_2 + \cdots + Q_n)$$
trong đó $Q_i = [d_i]G_2$ là khóa công khai của người $i$.

Tính đúng đắn:
$$e\!\left(\sum_i [d_i]H(m),\, G_2\right) = e\!\left(H(m),\, \sum_i [d_i]G_2\right) = e(H(m), \sum Q_i) \checkmark$$

## Vai trò của đường cong KSS18

Đường cong được xây dựng trong luận văn này (họ Kachisa-Schaefer-Scott với $k = 18$) cung cấp nền tảng để cài đặt BLS:

- **$\mathbb{G}_1 \subset E(\mathbb{F}_p)$**: nhóm điểm trên trường cơ sở, kích thước $r$.
- **$\mathbb{G}_T \subset \mathbb{F}_{p^{18}}^*$**: nhóm đích của phép ghép cặp, bậc $r$, kích thước trường 18432 bit — đủ để kháng cả NFS lẫn TNFS.

Phép ghép cặp Optimal Ate (trên KSS18) chạy vòng lặp Miller với $O(\log r)$ bước, mỗi bước thực hiện phép tính trong $\mathbb{F}_{p^{18}}$. Cấu trúc NTT-friendly của $p$ ($\text{two-adicity}(p-1) \geq 32$) giúp tăng tốc các phép nhân trong tháp trường.

> **Lưu ý:** Cài đặt phép ghép cặp đầy đủ (vòng lặp Miller + phép lũy thừa lần cuối) nằm ngoài phạm vi của luận văn này và là hướng phát triển tiếp theo. Chương này tập trung vào Schnorr và ECDSA trên $\mathbb{G}_1$.

# Cài đặt hệ thống ký (`curve1024-sig`)

Binary `curve1024-sig` cung cấp giao diện dòng lệnh kiểu GPG cho toàn bộ vòng đời khóa:

```
curve1024-sig keygen [-o <file>]
curve1024-sig sign   -f <file> [-k <key>] [--scheme schnorr|ecdsa]
curve1024-sig verify -f <file> [-k <pub>]
curve1024-sig export-pub [-k <priv>] [-o <pub>]
```

Các tham số được đọc từ `config/curve1024.toml` thông qua `build.rs` để sinh hằng số tĩnh — đảm bảo zero-cost abstraction và không có chi phí khởi tạo runtime.
