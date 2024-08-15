class Customer {
  int? id;
  int? businessId;
  String? name;
  String? phone;
  String? address;
  String? email;
  String? image;

  Customer(
      {this.id,
      this.businessId,
      this.name,
      this.phone,
      this.address,
      this.email,
      this.image});

  factory Customer.fromDatabaseJson(Map<String, dynamic> data) => Customer(
      id: data['id'],
      businessId: data['businessId'],
      name: data['name'],
      phone: data['phone'],
      address: data['address'],
      email: data['email'],
      image: data['image']);

  Map<String, dynamic> toDatabaseJson() => {
        'id': id,
        'businessId': businessId,
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'image': image
      };
}
