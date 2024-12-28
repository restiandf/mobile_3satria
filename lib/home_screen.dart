import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_app/theme/colors.dart';
import 'package:monitoring_app/controllers/auth_controller.dart';
import 'package:monitoring_app/controllers/penjualan_controller.dart';
import './login_page.dart';
import 'package:monitoring_app/penjualan_screen.dart';

class HomeScreen extends StatefulWidget {
  final String authToken;

  const HomeScreen({super.key, required this.authToken});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userRole = '';
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  final AuthController _authController = AuthController();

  // Data states
  Map<String, dynamic> _targetData = {};
  num _totalTargetBulanIni = 0;
  num _penjualanBulanIni = 0;
  num _penjualanBulanSebelumnya = 0;
  num _penjualanTahunIni = 0;
  List<dynamic> _dataTarget = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _fetchData();
  }

  void _getUserDetails() async {
    try {
      final userData = await _authController.getUserProfile(widget.authToken);
      print('Response dari API: $userData'); // untuk debugging

      if (mounted) {
        setState(() {
          _userName = userData['name'] ?? 'User';
          _userRole = userData['role'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error mengambil detail user: $e');
      setState(() {
        _userName = 'User';
        _userRole = 'User';
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mengambil data dashboard menggunakan getDashboardData
      final dashboardData =
          await _apiService.getDashboardData(widget.authToken);

      if (mounted) {
        setState(() {
          // Set target data
          _dataTarget = dashboardData['data_target'] ?? [];
          _totalTargetBulanIni =
              dashboardData['total_jumlah_target_bulan_ini'] ?? 0;

          // Set penjualan data
          _penjualanBulanIni = dashboardData['penjualan_bulan_ini'] ?? 0;
          _penjualanBulanSebelumnya =
              dashboardData['penjualan_bulan_sebelumnya'] ?? 0;
          _penjualanTahunIni = dashboardData['penjualan_tahun_ini'] ?? 0;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan avatar dan greeting
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, Color(0xFF7986CB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
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
                          Icons.account_circle_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, $_userName! 👋',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$_userRole',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        Colors.white,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.waving_hand_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Selamat datang di Aplikasi 3 Satria',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Target Bulan Ini Card
                _buildCard(
                  'Target Bulan Ini',
                  [
                    _buildDataRow('Total Target',
                        'Rp ${_formatNumber(_totalTargetBulanIni)}'),
                    _buildDataRow('Penjualan Bulan Ini',
                        'Rp ${_formatNumber(_penjualanBulanIni)}'),
                    _buildDataRow('Pencapaian',
                        '${_calculatePercentage(_penjualanBulanIni, _totalTargetBulanIni)}%'),
                  ],
                ),

                const SizedBox(height: 5),

                // Perbandingan Penjualan Card
                _buildCard(
                  'Perbandingan Penjualan',
                  [
                    _buildDataRow(
                        'Bulan Ini', 'Rp ${_formatNumber(_penjualanBulanIni)}'),
                    _buildDataRow('Bulan Sebelumnya',
                        'Rp ${_formatNumber(_penjualanBulanSebelumnya)}'),
                    _buildDataRow('Total Tahun Ini',
                        'Rp ${_formatNumber(_penjualanTahunIni)}'),
                  ],
                ),

                const SizedBox(height: 5),

                // Langsung ke tabel
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Data Target',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Indikator scroll untuk tabel
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.swipe, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geser ke kanan untuk melihat data lengkap',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabel dengan indicator scroll
                Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DataTable(
                          horizontalMargin: 15,
                          columnSpacing: 30,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontSize: 16,
                          ),
                          dataTextStyle: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                          headingRowHeight: 60,
                          dataRowHeight: 55,
                          dividerThickness: 0.5,
                          showBottomBorder: true,
                          columns: const [
                            DataColumn(
                              label: Text('No'),
                              numeric: true,
                              tooltip: 'Nomor urut',
                            ),
                            DataColumn(
                              label: Text('Produk'),
                              tooltip: 'Nama produk',
                            ),
                            DataColumn(
                              label: Text('Bulan'),
                              tooltip: 'Bulan periode',
                            ),
                            DataColumn(
                              label: Text('Tahun'),
                              tooltip: 'Tahun periode',
                            ),
                            DataColumn(
                              label: Text('Target'),
                              numeric: true,
                              tooltip: 'Jumlah target penjualan',
                            ),
                            DataColumn(
                              label: Text('Terjual'),
                              numeric: true,
                              tooltip: 'Jumlah terjual',
                            ),
                            DataColumn(
                              label: Text('Nominal Target'),
                              numeric: true,
                              tooltip: 'Nilai target dalam Rupiah',
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            _dataTarget.length,
                            (index) => DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (index % 2 == 0)
                                    return Colors.grey.withOpacity(0.05);
                                  return null;
                                },
                              ),
                              cells: [
                                // Nomor
                                DataCell(
                                  Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Produk
                                DataCell(
                                  Text(
                                    _dataTarget[index]['namaProduk']
                                            ?.toString() ??
                                        '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                // Bulan & Tahun
                                DataCell(Text(
                                    _dataTarget[index]['bulan']?.toString() ??
                                        '-')),
                                DataCell(Text(
                                    _dataTarget[index]['tahun']?.toString() ??
                                        '-')),
                                // Target
                                DataCell(
                                  Text(
                                    _dataTarget[index]['target']?.toString() ??
                                        '0',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Terjual
                                DataCell(
                                  Text(
                                    _dataTarget[index]['terjual']?.toString() ??
                                        '0',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Nominal Target
                                DataCell(
                                  Text(
                                    'Rp ${_formatNumber(_dataTarget[index]['jumlah_target'] ?? 0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Indikator scroll di sisi kanan
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_right,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern (opsional)
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          title.contains('Target')
                              ? Icons.track_changes
                              : Icons.trending_up,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...children
                      .map((child) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                              child: child,
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _getIconForLabel(label),
              size: 20,
              color: AppColors.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'total target':
        return Icons.flag;
      case 'penjualan bulan ini':
        return Icons.shopping_cart;
      case 'pencapaian':
        return Icons.emoji_events;
      case 'bulan ini':
        return Icons.calendar_today;
      case 'bulan sebelumnya':
        return Icons.history;
      case 'total tahun ini':
        return Icons.bar_chart;
      default:
        return Icons.info_outline;
    }
  }

  String _formatNumber(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  String _calculatePercentage(num achieved, num target) {
    if (target == 0) return '0';
    return ((achieved / target) * 100).toStringAsFixed(1);
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Konfirmasi Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            actions: <Widget>[
              // Tombol Batal
              TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Logout
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('auth_token');

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Color _getSelectedColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primaryColor;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(),
          PenjualanScreen(authToken: widget.authToken),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            // Home Item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: _selectedIndex == 0
                      ? AppColors.primaryColor
                      : Colors.grey,
                ),
              ),
              label: 'Home',
            ),
            // Penjualan Item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.point_of_sale,
                  color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                ),
              ),
              label: 'Penjualan',
            ),
            // Logout Item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: _selectedIndex == 2 ? Colors.red : Colors.grey,
                ),
              ),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: _getSelectedColor(_selectedIndex),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
