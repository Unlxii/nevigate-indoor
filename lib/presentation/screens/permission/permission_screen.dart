import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  final List<PermissionInfo> _requiredPermissions = [
    PermissionInfo(
      permission: Permission.bluetoothScan,
      title: 'สแกน Bluetooth',
      description: 'ใช้สำหรับค้นหาอุปกรณ์ UWB (ESP WD-1000)',
      icon: Icons.bluetooth_searching,
    ),
    PermissionInfo(
      permission: Permission.bluetoothConnect,
      title: 'เชื่อมต่อ Bluetooth',
      description: 'ใช้สำหรับเชื่อมต่อกับอุปกรณ์ UWB',
      icon: Icons.bluetooth_connected,
    ),
    PermissionInfo(
      permission: Permission.locationWhenInUse,
      title: 'ตำแหน่งที่ตั้ง',
      description: 'ใช้สำหรับระบุตำแหน่งของคุณภายในอาคาร',
      icon: Icons.location_on,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statuses = <Permission, PermissionStatus>{};
    for (var permInfo in _requiredPermissions) {
      statuses[permInfo.permission] = await permInfo.permission.status;
    }
    
    if (mounted) {
      setState(() {
        _permissionStatuses = statuses;
      });
      
      // ถ้าทุก permission ได้รับอนุญาตแล้ว ไปหน้าหลักเลย
      if (_allPermissionsGranted()) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  bool _allPermissionsGranted() {
    return _permissionStatuses.values.every((status) => status.isGranted);
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    for (var permInfo in _requiredPermissions) {
      final status = await permInfo.permission.request();
      _permissionStatuses[permInfo.permission] = status;
    }

    setState(() {
      _isLoading = false;
    });

    if (_allPermissionsGranted()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ได้รับสิทธิ์การใช้งานทั้งหมดแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        
        // รอ 1 วินาที แล้วไปหน้าหลัก
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาอนุญาตสิทธิ์ทั้งหมดเพื่อใช้งานแอป'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สิทธิ์การใช้งาน'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'สิทธิ์ที่จำเป็น',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'แอปต้องการสิทธิ์เหล่านี้เพื่อทำงานนำทางในอาคาร',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Permission List
            ..._requiredPermissions.map((permInfo) {
              final status = _permissionStatuses[permInfo.permission];
              return _buildPermissionCard(permInfo, status);
            }).toList(),

            const SizedBox(height: 32),

            // Action Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_allPermissionsGranted())
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/main');
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('เริ่มใช้งาน'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _requestAllPermissions,
                    icon: const Icon(Icons.check),
                    label: const Text('อนุญาตทั้งหมด'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('เปิดการตั้งค่า'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/main');
                    },
                    child: const Text('ข้ามไปก่อน (ฟีเจอร์บางส่วนอาจไม่ทำงาน)'),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'หมายเหตุ: ตอนนี้ใช้ Mock Authentication สิทธิ์เหล่านี้จะใช้งานจริงเมื่อเชื่อมต่ออุปกรณ์ UWB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(PermissionInfo permInfo, PermissionStatus? status) {
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isGranted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'อนุญาตแล้ว';
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'ปฏิเสธถาวร';
    } else if (isDenied) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'ปฏิเสธ';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = 'รอการอนุญาต';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              permInfo.icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permInfo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permInfo.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionInfo {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;

  PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
  });
}
