---
title: Cài đặt và Đánh giá
chapter: 5
toc-title: CÀI ĐẶT VÀ ĐÁNH GIÁ
---

Chương này trình bày kết quả thực nghiệm toàn diện của hệ thống: tham số đường cong được sinh ra, kết quả kiểm thử đơn vị và tích hợp, đo hiệu năng thực tế với Criterion, và phân tích so sánh mức độ bảo mật với các đường cong chuẩn trên thị trường.

## Tham số đường cong được sinh ra

Sau khi chạy thuật toán Cocks-Pinch cải tiến với các đầu vào $k=18$, $d=3$, `target_r_bits=512`, `target_p_bits=1024`, `min_scalar_two_adicity=32`, `min_base_two_adicity=32`, hệ thống sinh ra đường cong với các tham số được lưu trong `config/curve1024.toml`:

### Trường cơ sở và trường vô hướng

| Tham số | Giá trị |
|---|---|
| Kích thước $p$ | 1024 bit |
| Kích thước $r$ | 512 bit |
| two-adicity $(p-1)$ | **34** — NTT đến bậc $2^{34}$ |
| two-adicity $(r-1)$ | **33** — NTT đến bậc $2^{33}$ |
| Bậc nhúng $k$ | **18** |
| CM discriminant $D$ | $-3$ (họ KSS) |

Hai trường đều thỏa điều kiện NTT-friendly ($\text{two-adicity} \geq 32$), đảm bảo có thể thực hiện biến đổi NTT hiệu quả trong các ứng dụng ZK proof.

### Phương trình đường cong

$$y^2 = x^3 + 5 \pmod{p}$$

Hệ số $a = 0$, $b = 5$ (Short Weierstrass). Với $a = 0$, công thức nhân đôi điểm đơn giản hóa rõ rệt:
$$\lambda = \frac{3x_1^2}{2y_1}$$
không cần tính $a$ tại mỗi bước — tiết kiệm 1 phép nhân trường mỗi lần `double()`.

### Điểm sinh

Điểm sinh $G = (x, y) \in E(\mathbb{F}_p)$ với:

```
x = 0x07ba566379f7fa8d4ecd750604d301b18502c40e2f424c0733acb5111f37a3d
     e59db085670df8316de6129f2ad09f6b86af70e33165c363cfe12c4370c371d
     21e15315b6c6fc1c0f90311464d68b5d3f567ca49915e36f7090f005d5227cf
     e790c35156512fb95a2097d808b54ea1adaf226816c6aa27a0bb870bf4b9d1a10a8

y = 0x9487acd554d3ef9e9a2a6ceaddb12532e14d5ee1a9a2ee38be3fcbfa3211998
     b1c38a460b9f2594685164785cc3eef1de1b99ce7b6357f30f585a7d3bdd18f
     676dd22f2f264a76815a83a882f746f9fbd7e8835784e0f6e5e84313e3b89f5
     4e64805a0a77013c9464e3f401342c493785f1e861f1fd9de922042dc5448e7e776
```

Điểm $G$ được xác minh qua kiểm thử `test_generator_is_on_curve` và `test_generator_order_is_r`.

## Kết quả kiểm thử

Toàn bộ bộ kiểm thử gồm **36 test** chia thành hai lớp: kiểm thử đơn vị trong thư viện và kiểm thử tích hợp ngoài crate.

### Kiểm thử đơn vị (17 tests — `cargo test --lib`)

| Nhóm | Test | Kết quả |
|---|---|---|
| `u1024` | test_basics, test_shifts, test_arithmetic, test_bytes_and_rand | OK |
| `prime_field` | test_basics, test_arithmetic, test_pow, test_zero_one, test_bytes, test_from_montgomery, test_conditionally_selectable | OK |
| `affine` | test_curve_point, test_negation, test_point_addition, test_point_multiplication | OK |
| `signature::schnorr` | test_valid_schnorr_signature | OK |
| `signature::ecdsa` | test_valid_ecdsa_signature | OK |

Tổng thời gian: **95.40 giây** (debug build — `test_point_multiplication` và các test chữ ký chiếm phần lớn do phép nhân vô hướng 1024-bit chưa tối ưu trong debug mode).

### Kiểm thử tích hợp (19 tests — `cargo test --tests`)

**Tham số đường cong (`curve_params.rs` — 4 tests, 0.00s):**

| Test | Mô tả | Kết quả |
|---|---|---|
| `test_modulus_bit_length` | $|p| = 1024$ bit | OK |
| `test_order_bit_length` | $|r| = 512$ bit | OK |
| `test_base_field_ntt_two_adicity` | two-adicity$(p-1) \geq 32$ | OK |
| `test_scalar_field_ntt_two_adicity` | two-adicity$(r-1) \geq 32$ | OK |

**Luật nhóm (`group_law.rs` — 6 tests, 18.34s):**

| Test | Mô tả | Kết quả |
|---|---|---|
| `test_generator_is_on_curve` | $G$ nằm trên đường cong | OK |
| `test_generator_order_is_r` | $[r]G = \mathcal{O}$ | OK |
| `test_point_double_equals_add_self` | $2G = G + G$ | OK |
| `test_identity_element` | $G + \mathcal{O} = G$, $\mathcal{O} + G = G$ | OK |
| `test_point_negation` | $G + (-G) = \mathcal{O}$ | OK |
| `test_scalar_mul_matches_repeated_add` | $G + 2G = [3]G$ | OK |

**Bảo mật MOV (`attack_mov.rs` — 2 tests, 0.00s):**

| Test | Mô tả | Kết quả |
|---|---|---|
| `test_mov_attack_resistance` | $k=18 > 6$, $|F_{p^{18}}| = 18432$ bit | OK |
| `test_mov_weak_curve_simulation` | Mô phỏng đường cong yếu $k=1$ | OK |

**Bảo mật Anomalous (`attack_anomalous.rs` — 2 tests, 0.00s):**

| Test | Mô tả | Kết quả |
|---|---|---|
| `test_anomalous_attack_resistance` | $r \neq p$, $|p| > |r|$ | OK |
| `test_anomalous_weak_curve_simulation` | Mô phỏng đường cong $t=1$ | OK |

**Chữ ký (`signatures.rs` — 5 tests, 128.83s):**

| Test | Mô tả | Kết quả |
|---|---|---|
| `test_schnorr_sign_verify_roundtrip` | Ký + xác minh đúng khóa | OK |
| `test_schnorr_rejects_wrong_message` | Từ chối thông điệp bị sửa | OK |
| `test_schnorr_rejects_wrong_key` | Từ chối khóa sai | OK |
| `test_ecdsa_sign_verify_roundtrip` | Ký + xác minh đúng khóa | OK |
| `test_ecdsa_rejects_wrong_message` | Từ chối thông điệp bị sửa | OK |

**Tổng kết: 36/36 test PASSED, 0 FAILED.**

## Kết quả đo hiệu năng (Criterion, `--release`)

Benchmark chạy với `cargo bench` (release build, tối ưu LLVM O3), 10 mẫu mỗi phép đo, phần cứng thông thường không có AVX-512.

### Sinh khóa

| Phép đo | Min | Mean | Max |
|---|---|---|---|
| `KeyPair::generate` | 1.629 s | **1.687 s** | 1.757 s |

Sinh khóa = 1 phép nhân vô hướng $[d]G$ với $d \approx 2^{512}$ bit.

### Chữ ký

| Phép đo | Min | Mean | Max | Ghi chú |
|---|---|---|---|---|
| `ECDSA/sign` | 1.524 s | **1.606 s** | 1.711 s | 1 phép nhân vô hướng |
| `ECDSA/verify` | 2.847 s | **3.140 s** | 3.459 s | 2 phép nhân vô hướng |
| `Schnorr/sign` | 1.473 s | **1.551 s** | 1.641 s | 1 phép nhân vô hướng |
| `Schnorr/verify` | 2.656 s | **2.831 s** | 3.025 s | 2 phép nhân vô hướng |

Quan sát:
- **Ký ~ 1.55–1.61 s** (1 phép nhân vô hướng): Schnorr nhanh hơn ECDSA ~3% do không cần nghịch đảo $k^{-1}$.
- **Xác minh ~ 2.83–3.14 s** (2 phép nhân vô hướng tuần tự): chi phí gần gấp đôi ký, đúng với dự kiến lý thuyết.

### Phép nhân vô hướng $[k]G$

| Scalar $k$ | Min | Mean | Max |
|---|---|---|---|
| $k = 1$ | 1.061 s | **1.124 s** | 1.205 s |
| $k = 2$ | 1.190 s | **1.329 s** | 1.489 s |
| $k = 3$ | 1.143 s | **1.184 s** | 1.225 s |
| $k = 4$ | 1.167 s | **1.240 s** | 1.321 s |

Phép nhân vô hướng là **bottleneck** chi phối toàn bộ hệ thống. Với Double-and-add trên 1024 bit, mỗi lần nhân thực hiện đúng 1024 lần `double` và trung bình 512 lần `add`. Mỗi `add`/`double` cần 1 nghịch đảo trong $\mathbb{F}_p$ (= $a^{p-2}$, ~1536 phép nhân Montgomery).

## Phân tích bảo mật và so sánh

### Kích thước tham số

| Sơ đồ | Khóa riêng | Khóa công khai | Chữ ký |
|---|---|---|---|
| Schnorr/ECDSA trên secp256k1 | 32 B | 64 B | 64 B |
| Schnorr/ECDSA trên P-384 | 48 B | 96 B | 96 B |
| **Schnorr trên Curve1024** | **128 B** | **256 B** | **384 B** |
| **ECDSA trên Curve1024** | **128 B** | **256 B** | **256 B** |

### So sánh với đường cong chuẩn

| Đường cong | $|p|$ | $|r|$ | $k$ | two-adicity $r$ | two-adicity $p$ | Bảo mật |
|---|---|---|---|---|---|---|
| secp256k1 | 256 | 256 | — | 1 | — | 128 bit |
| P-384 | 384 | 384 | — | 1 | — | 192 bit |
| BLS12-381 | 381 | 255 | 12 | 32 | — | 128 bit |
| **Curve1024 (luận văn)** | **1024** | **512** | **18** | **33** | **34** | **256 bit** |

Curve1024 là đường cong pairing-friendly duy nhất trong bảng đạt two-adicity $\geq 32$ trên **cả hai trường** $\mathbb{F}_r$ và $\mathbb{F}_p$, cung cấp nền tảng NTT đầy đủ cho ZK proof. Mức bảo mật 256 bit tương đương AES-256.

## Hướng tối ưu hóa tiếp theo

Hiệu năng hiện tại (~1.5 s/ký, release) có thể cải thiện đáng kể thông qua:

1. **Sliding Window / NAF**: giảm ~30% số lần cộng điểm so với Double-and-add.
2. **Tọa độ Jacobian/Projective**: loại bỏ 1 phép nghịch đảo per `add`/`double` — nghịch đảo đắt gấp ~200x so với nhân Montgomery. Chỉ cần 1 nghịch đảo duy nhất khi chuyển về Affine ở bước cuối.
3. **Montgomery ladder**: constant-time scalar multiplication, loại bỏ timing side-channel hoàn toàn.
4. **AVX-512 / SIMD**: vector hóa phép nhân 64×64-bit limb trong Montgomery trên phần cứng x86-64 hiện đại.
5. **Multi-Scalar Multiplication (MSM — Pippenger)**: cho xác minh Schnorr $[s]G + [e]Q$, giảm ~50% công việc so với 2 phép nhân tuần tự.

Ước tính kết hợp Jacobian + Sliding Window có thể đưa thời gian ký xuống dưới **500 ms** mà không thay đổi logic bảo mật.
