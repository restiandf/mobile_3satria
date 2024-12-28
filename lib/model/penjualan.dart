class Penjualan {
  final int id;
  final String salesArea;
  final int idProduk;
  final int terjual;
  final String name;
  final String namaProduk;
  final String? createdAt;

  Penjualan({
    required this.id,
    required this.salesArea,
    required this.idProduk,
    required this.terjual,
    required this.name,
    required this.namaProduk,
    this.createdAt,
  });

  factory Penjualan.fromJson(Map<String, dynamic> json) {
    return Penjualan(
      id: json['id'] ?? 0,
      salesArea: json['salesArea'] ?? '',
      idProduk: json['idProduk'] ?? 0,
      terjual: json['terjual'] ?? 0,
      name: json['name'] ?? '',
      namaProduk: json['namaProduk'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_area': salesArea,
      'id_produk': idProduk,
      'terjual': terjual,
      'name': name,
      'nama_produk': namaProduk,
      'created_at': createdAt,
    };
  }
}
