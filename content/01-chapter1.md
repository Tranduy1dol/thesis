---
title: "Tổng quan và Giới thiệu bài toán"
chapter: 1
---

Chương này cung cấp cái nhìn tổng quan về bối cảnh của Hệ mật mã khóa công khai, thực trạng của các tiêu chuẩn Đường cong Elliptic hiện hành, và phân tích những rủi ro bảo mật cốt lõi về cả mặt toán học lẫn triển khai phần mềm. Từ đó, chương làm nổi bật tính cấp thiết của bài toán xây dựng đường cong Elliptic bậc siêu cao bằng ngôn ngữ an toàn bộ nhớ.

## Tổng quan về Hệ mật mã khóa công khai và ECC

Sự ra đời của Mật mã khóa công khai (Public Key Cryptography - PKC), đánh dấu bởi các công trình của Diffie-Hellman và RSA, là một bước ngoặt trong lịch sử an toàn thông tin. Mô hình mã hóa sử dụng khóa bất đối xứng (một khóa công khai để mã hóa/xác minh và một khóa riêng tư để giải mã/ký trí) đã giải quyết triệt để bài toán phân phối khóa qua kênh truyền không an toàn – điều mà hệ mật mã khóa đối xứng truyền thống không thể làm được.

Khi nhu cầu tính toán và trao đổi dữ liệu tăng vọt, Hệ mật mã Đường cong Elliptic (Elliptic Curve Cryptography - ECC) ra đời như một giải pháp thay thế ưu việt cho RSA. Sức mạnh vượt trội của ECC nằm ở tỷ lệ giữa kích thước khóa và độ an toàn. Để đạt được mức độ bảo mật 128-bit (mức tối thiểu được khuyến cáo hiện nay), hệ thống RSA cần sử dụng độ dài khóa lên tới 3072-bit. Trong khi đó, hệ thống ECC chỉ yêu cầu khóa dài 256-bit [@NIST80057]. Kích thước khóa nhỏ hơn đáng kể giúp ECC tiêu thụ ít tài nguyên tính toán, băng thông và điện năng hơn, biến nó trở thành tiêu chuẩn vàng cho các giao thức mạng hiện đại như TLS, mạng tiền điện tử (Bitcoin, Ethereum), và các hệ thống chữ ký số điện tử.

## Thực trạng các tiêu chuẩn ECC và Vấn đề tự chủ mật mã

Mặc dù ECC mang lại lợi ích lớn về hiệu năng, việc triển khai ECC trong thực tế lại bộc lộ một "nỗi đau" về mặt công nghệ và chủ quyền an ninh. Hiện nay, hầu hết các hệ thống phần mềm đều tái sử dụng các đường cong được định nghĩa và sinh sẵn bởi các tổ chức quốc tế, điển hình như Viện Tiêu chuẩn và Công nghệ Quốc gia Hoa Kỳ (NIST, ví dụ tập tham số P-256) hoặc Tổ chức SECG (ví dụ hàm secp256k1).

Việc sử dụng các hằng số toán học (các hệ số $p, a, b$) được sinh ra từ các "hạt giống" (seed) không giải thích được rõ ràng tiềm ẩn nguy cơ hệ thống bị cài cắm "cửa hậu" (backdoor). Nguy cơ này không chỉ nằm trên lý thuyết mà đã trở thành hiện thực với sự kiện cơ quan tình báo NSA bị cáo buộc can thiệp và cài backdoor vào tiêu chuẩn thuật toán sinh số ngẫu nhiên Dual_EC_DRBG [@DualECDRBG]. Sự kiện này đặt ra yêu cầu bức thiết về năng lực **"Tự chủ mật mã"** định hướng tương lai – nơi các hệ thống quốc gia có khả năng tự chủ thiết kế, đánh giá và làm chủ các tham số đường cong bằng các phương pháp toán học minh bạch mà không cần phụ thuộc vào các thư viện "hộp đen" từ nước ngoài.

Bên cạnh đó, xét về giới hạn an toàn của máy tính cổ điển: với sự tiến bộ của phần cứng, khóa 256-bit dù vẫn an toàn ở thời điểm hiện tại nhưng chỉ đạt biên độ an toàn 128-bit. Do đó, cần có những nghiên cứu đón đầu nhằm đánh giá khả năng của các đường cong "bậc siêu cao", ví dụ 1024-bit. Khóa 1024-bit cung cấp mức độ an toàn khổng lồ, xấp xỉ 512-bit, khiến mọi cuộc tấn công bằng thuật toán tốt nhất hiện nay (như Pollard's rho) trở nên hoàn toàn vô vọng trong các giới hạn vật lý của vũ trụ.

## Vai trò của ngôn ngữ lập trình trong an toàn mật mã

Trong lịch sử ngành an toàn thông tin, những sự cố bảo mật tồi tệ nhất của các thư viện mật mã lớn (tiêu biểu như OpenSSL) thường không xuất phát từ sai sót trong toán học lý thuyết, mà bắt nguồn từ các lỗ hổng quản lý bộ nhớ của ngôn ngữ lập trình C/C++. Các lỗi tràn bộ đệm (buffer overflow), truy cập vùng nhớ đã bị giải phóng (use-after-free) hay đọc quá giới hạn vùng nhớ đã gây ra hàng loạt thảm họa bảo mật, nổi tiếng nhất là sự cố rò rỉ bộ nhớ Heartbleed năm 2014 [@CVE_Heartbleed]. Thực tế triển khai một hệ thống xử lý số nguyên lớn (BigInt) có kích thước lên đến 1024-bit bằng C/C++ là một thách thức cực đoan về quản lý an toàn bộ nhớ. Theo số liệu từ quỹ phản ứng sự cố của Microsoft, có tới xấp xỉ 70% các lỗ hổng thực thi mã từ xa cấu thành từ nhóm lỗi an toàn bộ nhớ [@MicrosoftMemorySafety].

Khóa luận này khắc phục hoàn toàn điểm yếu kiến trúc trên thông qua việc ứng dụng ngôn ngữ lập trình hệ thống hiện đại **Rust**. Với cơ chế Ownership (quyền sở hữu) và quy tắc Borrow Checker (kiểm tra mượn tĩnh) nghiêm ngặt tại thời điểm biên dịch (compile-time), trình biên dịch (compiler) của Rust loại bỏ toán toàn các lỗi an toàn bộ nhớ mà không cần tới bộ thu gom rác (Garbage Collector). Cách tiếp cận này giúp thư viện mật mã đạt được tốc độ thực thi (runtime) ngang ngửa với C/C++ trong khi được bảo hành tuyệt đối về mặt bộ nhớ theo đặc tả của ngôn ngữ.

## Phát biểu bài toán và Phạm vi nghiên cứu

Dựa trên những phân tích về lỗ hổng của thư viện mật mã truyền thống và yêu cầu về tính tự chủ, khóa luận đặt ra mục tiêu thiết kế và cài đặt từ đầu (from scratch) một thư viện mã nguồn mở cho Hệ mật mã Đường cong Elliptic với những đặc điểm cơ bản sau:

1. **Về mặt toán học**: Chủ động tính toán, phân tích và sinh mới bề mặt đường cong Elliptic trên trường nguyên tố siêu lớn **1024-bit**, tự chủ hoàn toàn các thuật toán sinh số mà không tái sử dụng hằng số của tổ chức thứ ba.
2. **Về mặt kiến trúc phần mềm**: Mã nguồn được thiết kế phân tầng theo quy tắc đơn giản hóa (Keep It Simple), chia hệ thống thành ba lớp biệt lập, thuận tiện cho việc kiểm định, bao gồm:
   - *Lớp Số nguyên lớn* (`U1024`): Tự định nghĩa kiểu dữ liệu 1024-bit với các phép lặp tối ưu phần cứng.
   - *Lớp Trường hữu hạn* (`Prime Field`): Các phép toán đại số modulo bảo mật.
   - *Lớp Tọa độ điểm* (`Affine Point`): Biểu diễn hình học trên đường cong.
3. **Về mặt ứng dụng**: Cài đặt thành công, kiểm thử tính đúng đắn và đánh giá hiệu năng đo lường đối với kiến trúc chữ ký số tiêu chuẩn (ECDSA / Schnorr) áp dụng trục tiếp lên đường cong sinh tự nhiên 1024-bit vừa xây dựng được.
4. **Về mặt công nghệ**: Toàn bộ hệ thống cơ sở được lập trình bằng ngôn ngữ Rust để đảm bảo hiệu năng tính toán cao ở mức ngôn ngữ hệ thống và sự an toàn bộ nhớ tuyệt đối từ cấp trình biên dịch.
