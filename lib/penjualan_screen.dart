import 'package:flutter/material.dart';
import 'controllers/tambah_penjualan_controller.dart';
import 'model/penjualan.dart';
import 'package:intl/intl.dart';
// import 'constants/app_colors.dart';

class PenjualanScreen extends StatefulWidget {
  final String authToken;

  const PenjualanScreen({
    Key? key,
    required this.authToken,
  }) : super(key: key);

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final PenjualanController _controller = PenjualanController();
  List<Penjualan> penjualanList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPenjualan();
  }

  Future<void> _loadPenjualan() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _controller.getPenjualan(widget.authToken);

      if (!mounted) return;

      setState(() {
        penjualanList = data.map((item) => Penjualan.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (!mounted) return;

      setState(() {
        penjualanList = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPenjualan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan style yang sama
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.point_of_sale,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Data Penjualan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tabel dengan style yang sama
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.blue.withOpacity(0.1),
                        ),
                        dataRowHeight: 60,
                        headingRowHeight: 60,
                        horizontalMargin: 20,
                        columnSpacing: 30,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Area',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Produk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Terjual',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Tanggal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Aksi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                        rows: penjualanList.map((penjualan) {
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.blue.withOpacity(0.05);
                                }
                                return null;
                              },
                            ),
                            cells: [
                              DataCell(Text(
                                penjualan.salesArea,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                              DataCell(Text(
                                penjualan.namaProduk,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                              DataCell(Text(
                                penjualan.terjual.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                              DataCell(Text(
                                penjualan.createdAt != null
                                    ? DateFormat('dd/MM/yyyy HH:mm').format(
                                        DateTime.parse(penjualan.createdAt!))
                                    : '-',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              )),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () => _showEditDialog(penjualan),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () =>
                                        _showDeleteConfirmation(penjualan.id),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Tambah Data',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    // Simpan context dalam variabel lokal
    final currentContext = context;

    showDialog(
      context: currentContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Tutup dialog konfirmasi
                Navigator.pop(dialogContext);

                // Tampilkan loading indicator
                showDialog(
                  context: currentContext,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Proses hapus data
                await _controller.deletePenjualan(
                    id.toString(), widget.authToken);

                // Tutup loading indicator
                if (mounted) {
                  Navigator.pop(currentContext);
                }

                // Refresh data
                if (mounted) {
                  await _loadPenjualan();
                }

                // Tampilkan snackbar sukses
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil dihapus'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Tutup loading indicator jika masih terbuka
                if (mounted) {
                  Navigator.pop(currentContext);
                }

                // Tampilkan error
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus data: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Penjualan penjualan) {
    if (!mounted) return;

    // Simpan context di awal
    final currentContext = context;

    // Inisialisasi state
    String selectedArea = penjualan.salesArea;
    String selectedProduk = penjualan.idProduk.toString();
    String terjualValue = penjualan.terjual.toString();

    // Daftar area
    final List<String> areaList = [
      'Ciruas',
      'Kragilan',
      'Kibin',
      'Lebakwangi',
      'Binuang',
      'Tanara',
      'Tirtayasa',
      'Carenang',
    ];

    showDialog<void>(
      context: currentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_document,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Data Penjualan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      decoration: InputDecoration(
                        labelText: 'Area Penjualan',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.blue.shade500, width: 2),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 241, 244, 255),
                        prefixIcon: Icon(Icons.location_on,
                            color: Colors.blue.shade700),
                      ),
                      items: areaList.map((String area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedArea = value ?? selectedArea;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Produk Dropdown
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _controller.getProdukList(widget.authToken),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Tidak ada data produk');
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedProduk,
                          decoration: InputDecoration(
                            labelText: 'Nama Produk',
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade700),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade700),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.blue.shade500, width: 2),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 241, 244, 255),
                            prefixIcon: Icon(Icons.inventory_2,
                                color: Colors.blue.shade700),
                          ),
                          items: snapshot.data!.map((produk) {
                            return DropdownMenuItem<String>(
                              value: produk['id'].toString(),
                              child: Text(produk['namaProduk'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedProduk = value ?? selectedProduk;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Terjual TextField
                    TextFormField(
                      initialValue: terjualValue,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Terjual',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.blue.shade500, width: 2),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 241, 244, 255),
                        prefixIcon: Icon(Icons.shopping_cart,
                            color: Colors.blue.shade700),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        terjualValue = value;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            foregroundColor: Colors.red.shade400,
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final terjual = int.tryParse(terjualValue);
                              if (terjual == null || terjual <= 0) {
                                ScaffoldMessenger.of(currentContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Jumlah terjual harus berupa angka positif'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Tutup keyboard jika masih terbuka
                              FocusScope.of(dialogContext).unfocus();

                              // Tampilkan loading
                              showDialog(
                                context: dialogContext,
                                barrierDismissible: false,
                                builder: (BuildContext loadingContext) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              // Proses update data
                              await _controller.updatePenjualan(
                                penjualan.id,
                                selectedArea,
                                terjual,
                                int.parse(selectedProduk),
                                widget.authToken,
                              );

                              // Tutup loading dialog
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              // Tutup form dialog
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              // Refresh data dan tampilkan snackbar
                              if (mounted) {
                                await _loadPenjualan();
                                ScaffoldMessenger.of(currentContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text('Data berhasil diperbarui'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Tutup loading jika terjadi error
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(currentContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal memperbarui data: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDialog() {
    if (!mounted) return;

    // Simpan context di awal
    final currentContext = context;

    // Fungsi untuk menampilkan snackbar
    void showSnackBar(String message, {bool isError = false}) {
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }

    // Inisialisasi state
    String? selectedArea;
    String? selectedProduk;
    String terjualValue = '';

    // Daftar area
    final List<String> areaList = [
      'Ciruas',
      'Kragilan',
      'Kibin',
      'Lebakwangi',
      'Binuang',
      'Tanara',
      'Tirtayasa',
      'Carenang',
    ];

    showDialog<void>(
      context: currentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Data Penjualan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      decoration: InputDecoration(
                        labelText: 'Area Penjualan',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.blue.shade500, width: 2),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 241, 244, 255),
                        prefixIcon: Icon(Icons.location_on,
                            color: Colors.blue.shade700),
                      ),
                      items: areaList.map((String area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedArea = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Produk Dropdown
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _controller.getProdukList(widget.authToken),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Tidak ada data produk');
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedProduk,
                          decoration: InputDecoration(
                            labelText: 'Nama Produk',
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade700),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade700),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.blue.shade500, width: 2),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 241, 244, 255),
                            prefixIcon: Icon(Icons.inventory_2,
                                color: Colors.blue.shade700),
                          ),
                          items: snapshot.data!.map((produk) {
                            return DropdownMenuItem<String>(
                              value: produk['id'].toString(),
                              child: Text(produk['namaProduk'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedProduk = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Terjual TextField
                    TextFormField(
                      initialValue: terjualValue,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Terjual',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.blue.shade500, width: 2),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 241, 244, 255),
                        prefixIcon: Icon(Icons.shopping_cart,
                            color: Colors.blue.shade700),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        terjualValue = value;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            foregroundColor: Colors.red.shade400,
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (selectedArea == null ||
                                  selectedProduk == null) {
                                showSnackBar('Mohon lengkapi semua data',
                                    isError: true);
                                return;
                              }

                              final terjual = int.tryParse(terjualValue);
                              if (terjual == null || terjual <= 0) {
                                showSnackBar(
                                    'Jumlah terjual harus berupa angka positif',
                                    isError: true);
                                return;
                              }

                              // Tutup keyboard
                              FocusScope.of(dialogContext).unfocus();

                              // Tambah data
                              await _controller.addPenjualan(
                                authToken: widget.authToken,
                                salesArea: selectedArea!,
                                idProduk: selectedProduk!,
                                terjual: terjual,
                              );

                              // Tutup dialog
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              // Refresh data
                              if (mounted) {
                                await _loadPenjualan();
                                // Tampilkan snackbar sukses
                                showSnackBar('Data berhasil ditambahkan');
                              }
                            } catch (e) {
                              // Tampilkan error
                              showSnackBar('Gagal menambah data: $e',
                                  isError: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
