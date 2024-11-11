class UserInfo {
  final String? avatar;
  final String? phoneNumber;
  final String url;

  UserInfo({this.avatar, this.phoneNumber, required this.url});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      avatar: json['avatar'],
      phoneNumber: json['phoneNumber'],
      url: json['url'],
    );
  }
}

class Product {
  final String name;
  final List<String> urls;
  final String whatsappLink;

  Product({required this.name, required this.urls, required this.whatsappLink});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      urls: List<String>.from(json['urls']),
      whatsappLink: json['whatsappLink'],
    );
  }
}

class UserProduct {
  final UserInfo userInfo;
  final Product product;

  UserProduct({required this.userInfo, required this.product});

  factory UserProduct.fromJson(Map<String, dynamic> json) {
    return UserProduct(
      userInfo: UserInfo.fromJson(json['userInfo']),
      product: Product.fromJson(json['product']),
    );
  }
}
