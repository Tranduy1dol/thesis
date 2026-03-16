---
title: Tổng quan và Giới thiệu bài toán
chapter: 0
---

Chương này cung cấp cái nhìn tổng quan về bối cảnh của Hệ mật mã khóa công khai, thực trạng của các tiêu chuẩn Đường cong Elliptic hiện hành, và phân tích những rủi ro bảo mật cốt lõi về cả mặt toán học lẫn triển khai phần mềm. Từ đó, chương làm nổi bật tính cấp thiết của bài toán xây dựng đường cong Elliptic bậc siêu cao bằng ngôn ngữ an toàn bộ nhớ.

# Hệ mật mã khóa công khai và Đường cong Elliptic

Sự ra đời của Mật mã khóa công khai (Public Key Cryptography - PKC), đánh dấu bởi công trình của Diffie và Hellman năm 1976 [@DiffieHellman1976], là một bước ngoặt trong lịch sử an toàn thông tin. Mô hình mã hóa sử dụng khóa bất đối xứng — một khóa công khai để mã hóa/xác minh và một khóa riêng tư để giải mã/ký số — đã giải quyết triệt để bài toán phân phối khóa qua kênh truyền không an toàn mà hệ mật mã khóa đối xứng truyền thống không thể làm được.

Tuy nhiên, các hệ mật mã khóa công khai thế hệ đầu như RSA đòi hỏi kích thước khóa rất lớn để đạt mức bảo mật cao. Để đạt mức 128-bit bảo mật đối xứng (mức tối thiểu được khuyến cáo hiện nay theo NIST SP 800-57 [@NIST80057]), hệ thống RSA cần sử dụng khóa dài tới 3072-bit. Nhu cầu tối ưu hóa này dẫn tới sự ra đời của Hệ mật mã Đường cong Elliptic (Elliptic Curve Cryptography - ECC), được đề xuất độc lập bởi Koblitz [@Koblitz1987] và Miller [@Miller1985] vào giữa thập niên 1980. Sức mạnh vượt trội của ECC nằm ở tỷ lệ giữa kích thước khóa và độ an toàn: ECC chỉ yêu cầu khóa 256-bit để đạt mức bảo mật 128-bit tương đương RSA 3072-bit. Kích thước khóa nhỏ hơn đáng kể giúp ECC tiêu thụ ít tài nguyên tính toán, băng thông và điện năng hơn, biến nó trở thành tiêu chuẩn vàng cho các giao thức mạng hiện đại như TLS, mạng tiền điện tử (Bitcoin, Ethereum), và các hệ thống chữ ký số điện tử [@Rosing2024].

# Thực trạng các tiêu chuẩn ECC và Vấn đề tự chủ mật mã

Mặc dù ECC mang lại lợi ích lớn về hiệu năng, việc triển khai ECC trong thực tế bộc lộ một vấn đề nghiêm trọng về chủ quyền công nghệ. Hiện nay, hầu hết các hệ thống phần mềm đều tái sử dụng các đường cong được định nghĩa và sinh sẵn bởi các tổ chức quốc tế, điển hình như Viện Tiêu chuẩn và Công nghệ Quốc gia Hoa Kỳ (NIST, ví dụ tập tham số P-256) hoặc Tổ chức SECG (ví dụ secp256k1).

Việc sử dụng các hằng số toán học (các hệ số $p, a, b$) được sinh ra từ các "hạt giống" (seed) không giải thích được rõ ràng tiềm ẩn nguy cơ bị cài cắm "cửa hậu" (backdoor). Nguy cơ này không chỉ nằm trên lý thuyết mà đã trở thành hiện thực với sự kiện cơ quan tình báo NSA bị cáo buộc can thiệp và cài backdoor vào tiêu chuẩn thuật toán sinh số ngẫu nhiên Dual_EC_DRBG [@DualECDRBG]. Sự kiện này đặt ra yêu cầu bức thiết về năng lực **"Tự chủ mật mã"** — nơi các hệ thống quốc gia có khả năng tự thiết kế, đánh giá và làm chủ các tham số đường cong bằng các phương pháp toán học minh bạch, không phụ thuộc vào các thư viện "hộp đen" từ nước ngoài.

# Giới hạn bảo mật và nhu cầu đường cong bậc siêu cao

Xét về giới hạn an toàn trước máy tính cổ điển: khóa ECC 256-bit dù vẫn an toàn ở thời điểm hiện tại nhưng chỉ đạt biên độ an toàn 128-bit đối xứng. Thuật toán tấn công hiệu quả nhất là Pollard's $\rho$ [@PollardRho1978] với độ phức tạp $O(\sqrt{r})$, trong đó $r$ là bậc nhóm con nguyên tố.

Khóa luận này đặt mục tiêu đẩy cấp độ bảo mật lên bậc cực hạn: đường cong trên trường nguyên tố **1024-bit**. Với bậc nhóm $r \approx 2^{512}$, hệ thống cung cấp mức bảo mật xấp xỉ **256-bit đối xứng** — tương đương AES-256 và vượt xa chuẩn tối thiểu NIST. Tại mức này, thuật toán Pollard's $\rho$ cần $O(2^{256})$ phép toán nhóm, khiến mọi cuộc tấn công cổ điển trở thành bất khả thi tuyệt đối trong các giới hạn vật lý của vũ trụ.

Đây là sự đánh đổi có chủ ý: hiệu năng chậm hơn đáng kể so với đường cong 256-bit nhưng đổi lại biên an toàn vượt trội, phù hợp với kịch bản bảo mật dài hạn và các ứng dụng ký ngoại tuyến.

# Vai trò của ngôn ngữ lập trình trong an toàn mật mã

Trong lịch sử ngành an toàn thông tin, những sự cố bảo mật nghiêm trọng nhất của các thư viện mật mã lớn thường không xuất phát từ sai sót trong toán học lý thuyết, mà bắt nguồn từ lỗ hổng quản lý bộ nhớ của ngôn ngữ C/C++. Các lỗi tràn bộ đệm (buffer overflow), truy cập vùng nhớ đã giải phóng (use-after-free), hay đọc quá giới hạn vùng nhớ đã gây ra hàng loạt thảm họa bảo mật, nổi tiếng nhất là sự cố Heartbleed năm 2014 trong thư viện OpenSSL [@CVE_Heartbleed]. Theo thống kê từ Microsoft, khoảng 70% các bản vá lỗi bảo mật cốt lõi của họ có nguyên nhân trực tiếp từ nhóm lỗi an toàn bộ nhớ [@MicrosoftMemorySafety].

Thực tế triển khai hệ thống xử lý số nguyên lớn (BigInt) kích thước 1024-bit bằng C/C++ là thách thức cực đoan về quản lý bộ nhớ. Khóa luận này khắc phục điểm yếu kiến trúc đó bằng ngôn ngữ lập trình hệ thống **Rust**. Với cơ chế Ownership (quyền sở hữu) và Borrow Checker (kiểm tra mượn tĩnh) tại thời điểm biên dịch, trình biên dịch Rust loại bỏ hoàn toàn các lỗi an toàn bộ nhớ mà không cần bộ thu gom rác (Garbage Collector). Cách tiếp cận này giúp thư viện mật mã đạt tốc độ thực thi ngang ngửa C/C++ trong khi được bảo hành tuyệt đối về an toàn bộ nhớ.

# Phát biểu bài toán và Phạm vi nghiên cứu

Dựa trên những phân tích trên, khóa luận đặt ra mục tiêu thiết kế và cài đặt từ đầu (from scratch) một thư viện mã nguồn mở cho Hệ mật mã Đường cong Elliptic với các đặc điểm:

1. **Về mặt toán học**: Chủ động sinh mới đường cong Elliptic trên trường nguyên tố 1024-bit bằng phương pháp Nhân phức (CM) và thuật toán Cocks-Pinch cải tiến [@CocksPinch2001], tự chủ hoàn toàn các tham số mật mã.
2. **Về mặt kiến trúc phần mềm**: Mã nguồn phân tầng theo ba lớp biệt lập:
   - *Lớp Số nguyên lớn* (`U1024`): Kiểu dữ liệu 1024-bit với phép toán tối ưu phần cứng.
   - *Lớp Trường hữu hạn* (`PrimeField`): Số học modulo Montgomery bảo mật.
   - *Lớp Tọa độ điểm* (`AffinePoint`): Biểu diễn hình học trên đường cong.
3. **Về mặt ứng dụng**: Cài đặt, kiểm thử và đánh giá hiệu năng hai sơ đồ chữ ký số tiêu chuẩn (ECDSA [@FIPS186_4] và Schnorr [@Schnorr1989]) trên đường cong 1024-bit tự sinh.
4. **Về mặt công nghệ**: Toàn bộ hệ thống viết bằng Rust, đảm bảo an toàn bộ nhớ tuyệt đối và hiệu năng ở cấp ngôn ngữ hệ thống.
