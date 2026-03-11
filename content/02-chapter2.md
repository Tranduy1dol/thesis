---
title: Cơ sở toán học
chapter: 2
toc-title: CƠ SỞ TOÁN HỌC
---
# Chương 2: Cơ sở toán học và Kiến trúc hệ thống ECC

## 2.1 Định nghĩa Trường hữu hạn (Lớp Prime Field)

Để các phép toán mật mã đảm bảo tính chính xác và an toàn, chúng không được thực hiện trên tập số thực mà phải diễn ra trong một không gian giới hạn gọi là Trường hữu hạn (Finite Field).

### Trường số nguyên tố $\mathbb{F}_p$​

**Trường số nguyên tố** (prime field) $(\mathbb{F}_p​,+,⋅)$ là một cấu trúc toán học được xây dựng dựa trên tập hợp các lớp thặng dư của số nguyên modulo $p$, với $p$ **là một số nguyên tố**.
- **Tập hợp phần tử**: $\mathbb{F}_p$ chứa đúng $p$ phần tử, thường được đại diện bởi các số nguyên $\{0, 1, 2,\cdots, p-1 \}$.
- **Tính chất**: Trường này có đặc tính hữu hạn là $p$.
- **Các phép toán cơ bản** (tương ứng với các subroutine đã cài đặt):
    - **Cộng và Nhân**: Được thực hiện bằng cách tính toán như số nguyên thông thường, sau đó lấy kết quả là **số dư của phép chia cho** $p$.
    - **Nghịch đảo cộng (số đối):** Số đối của $x$ là $−x=p−x \pmod p$. Điều này giúp tránh việc xử lý số âm trong logic lập trình khối số nguyên không dấu (như U1024).
    - **Nghịch đảo nhân:** Với mọi phần tử $x\ne 0$, luôn tồn tại nghịch đảo nhân $x^{-1}$ sao cho $x\cdot x^{−1}=1$. Theo Định lý nhỏ Fermat, $x^{−1}=x^{p−2} \pmod p$.

## 2.2 Định nghĩa Đường cong elliptic (Lớp Affine Point)

### Hình học hệ tọa độ Affine và Điều kiện không suy biến

Trong hệ tọa độ affine, đường cong Short Weierstrass $E_{a,b}(F)$ trên một trường hữu hạn $F$ được định nghĩa là tập hợp các cặp phần tử $(x, y) \in F \times F$ thỏa mãn phương trình:

$$y^2 = x^3 + ax + b$$

trong đó $a$ và $b$ là các hằng số thuộc trường $F$.

Ngoài các cặp $(x, y)$, tập hợp này còn bao gồm một thành phần đặc biệt gọi là **điểm vô cực (point at infinity)**, ký hiệu là $\mathcal{O}$. Điểm này đóng vai trò là phần tử đơn vị (neutral element) trong cấu trúc nhóm của đường cong.

Để phương trình trên xác định một đường cong elliptic hợp lệ, đường cong đó phải **không suy biến**, nghĩa là nó không có các điểm tự cắt hoặc các điểm nhọn (cusps). Điều kiện này được đảm bảo khi **biệt thức (discriminant)** của đường cong khác 0:

$$4a^3 + 27b^2 \neq 0$$

### Tham số đường cong (Domain Parameters) và Tính chuẩn hóa

Trong thực tế triển khai ứng dụng, thay vì tự sinh các thông số ngẫu nhiên, hệ thống cần sử dụng các bộ tham số chuẩn hóa (như SEC 2 v2) để tránh các lỗ hổng bảo mật nghiêm trọng (như tấn công MOV hay đường cong dị thường). Một bộ tham số đường cong đầy đủ bao gồm: $(p, a, b, G, n, h)$. Trong đó $G$ là Điểm cơ sở (Generator Point) và $n$ là bậc (Order) của điểm $G$.

## 2.3 Luật cộng nhóm và Phép tính trên đường cong

### Các thành phần cơ bản và Quy tắc hình học

- **Phần tử đơn vị:** Nhóm có một phần tử đặc biệt gọi là **điểm vô cực**, ký hiệu là $\mathcal{O}$. Điểm này không nằm trên mặt phẳng tọa độ thông thường nhưng đóng vai trò như số 0 trong phép cộng số nguyên: $P \oplus \mathcal{O} = P$ với mọi điểm $P$.
- **Phần tử nghịch đảo:** Mỗi điểm $P = (x, y)$ luôn có một điểm nghịch đảo $-P = (x, -y)$ (đối xứng qua trục hoành) sao cho $P \oplus (-P) = \mathcal{O}$.

Luật cộng điểm được xác định dựa trên hình học của đường cong:
- **Quy tắc dây cung (Chord Rule):** Để cộng hai điểm phân biệt $P$ và $Q$, ta vẽ một đường thẳng đi qua cả hai điểm. Đường thẳng này sẽ cắt đường cong tại một điểm thứ ba là $R'$. Kết quả của phép cộng $P \oplus Q$ là điểm $R$, chính là điểm đối xứng của $R'$ qua trục $x$. Nếu đường thẳng qua $P$ và $Q$ là đường thẳng đứng, kết quả là điểm vô cực $\mathcal{O}$.
- **Quy tắc tiếp tuyến (Tangent Rule):** Để cộng một điểm $P$ với chính nó ($P \oplus P$, hay nhân đôi điểm), ta vẽ tiếp tuyến của đường cong tại $P$. Nếu tiếp tuyến cắt đường cong tại điểm $R'$, kết quả $2P$ là điểm đối xứng của $R'$ qua trục $x$.

### Công thức đại số (Dạng Short Weierstrass)

Với đường cong $y^2 = x^3 + ax + b$, nếu $P_1 = (x_1, y_1)$ và $P_2 = (x_2, y_2)$, điểm tổng $P_3 = (x_3, y_3)$ được tính như sau:
- **Tính hệ số góc $\lambda$:**
    - Nếu $P_1 \neq P_2$: $\lambda = \frac{y_2 - y_1}{x_2 - x_1}$.
    - Nếu $P_1 = P_2$ (nhân đôi): $\lambda = \frac{3x_1^2 + a}{2y_1}$.
- **Tính tọa độ điểm mới:**
    - $x_3 = \lambda^2 - x_1 - x_2$.
    - $y_3 = \lambda(x_1 - x_3) - y_1$.
### Phép nhân vô hướng (Scalar Multiplication)

Phép nhân một điểm $P$ với một số nguyên $k$ (ký hiệu là $[k]P$) được thực hiện bằng cách cộng điểm $P$ với chính nó $k$ lần. Trong thực tế, thuật toán **"Double and Add"** (nhân đôi và cộng) thường được sử dụng để thực hiện phép tính này một cách hiệu quả với độ phức tạp logarit theo giá trị của $k$. Đây là hàm cốt lõi để tạo khóa công khai (Public Key) và xử lý chữ ký số (Schnorr/ECDSA).

## 2.4 Tối ưu hóa hiệu năng tính toán

Khi vận hành trên các trường số cực lớn, phép chia và modulo truyền thống trở thành "nút thắt cổ chai". Việc áp dụng các thuật toán tối ưu là bắt buộc. **Phép nhân Karatsuba** và **phép nhân Montgomery** là hai kỹ thuật tối ưu hóa toán học quan trọng, thường được sử dụng kết hợp trong mật mã học để tăng tốc độ tính toán số học trên các số nguyên lớn và đa thức.
### 1. Phép nhân Karatsuba
Thuật toán Karatsuba tập trung vào việc **giảm số lượng các phép nhân** thành phần cần thiết để có được tích số.
- **Nguyên lý:** Chia việc nhân hai số có $n$ chữ số thành **ba phép nhân** các số có $n/2$ chữ số, thay vì bốn phép nhân như phương pháp thông thường.
- **Độ phức tạp:** Đạt mức **$O(n^{\log_2 3}) \approx O(n^{1.58})$**, nhanh hơn đáng kể so với $O(n^2)$ khi $n$ lớn.

### 2. Phép nhân Montgomery (Áp dụng trong Runtime Field)

Phép nhân Montgomery tập trung vào việc **làm cho phép lấy dư (modulo) nhanh hơn**. Phương pháp này thực hiện **phép nhân modulo** hiệu quả bằng cách **tránh các phép chia thử (trial division)** cho mô-đun $N$ vốn rất tốn kém về mặt tính toán.
- **Biểu diễn N-residue:** Thay vì làm việc với số nguyên $a \pmod N$, số liệu được chuyển sang không gian Montgomery: $aR \pmod N$, trong đó $R$ là cơ số nguyên tố cùng nhau với $N$ (thường chọn $R$ là lũy thừa của 2 để phép modulo và chia $R$ cực kỳ rẻ).
- **Thuật toán REDC:** Lõi của phương pháp, giúp tính nhanh giá trị $TR^{-1} \pmod N$ từ số nguyên $T$.
- **Quy trình:** Tính $T = (aR)(bR) = abR^2$, sau đó dùng REDC để thu được $(abR^2)R^{-1} = abR \pmod N$. Kết quả lưu lại trong không gian Montgomery cho phép tính toán chuỗi cực nhanh.

Việc kết hợp hai thuật toán này, kết hợp cùng các hệ tọa độ tối ưu (như Tọa độ Hình chiếu - Projective Coordinates giúp tính toán không cần phép chia) chính là chìa khóa để triển khai một hệ thống ECC chuẩn công nghiệp vừa đơn giản lại vừa có hiệu suất cao.