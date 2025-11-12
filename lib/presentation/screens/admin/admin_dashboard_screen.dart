import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/entities/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final authRepository = context.read<AuthRepository>();
      final users = await authRepository.getAllUsers();
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildUsersList(),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ไม่มีผู้ใช้ในระบบ',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin ? Colors.orange : Colors.blue,
          child: Icon(
            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          user.displayName ?? user.email,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
                _buildStatusBadge(user.isActive),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_role',
              child: Text(
                user.isAdmin ? 'เปลี่ยนเป็นผู้ใช้ทั่วไป' : 'เปลี่ยนเป็นผู้ดูแล',
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Text(
                user.isActive ? 'ปิดการใช้งาน' : 'เปิดการใช้งาน',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final isAdmin = role == UserRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'ผู้ดูแล' : 'ผู้ใช้',
        style: TextStyle(
          color: isAdmin ? Colors.orange : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ใช้งาน' : 'ปิดการใช้งาน',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleUserAction(String action, UserModel user) async {
    try {
      final authRepository = context.read<AuthRepository>();
      
      if (action == 'toggle_role') {
        final newRole = user.isAdmin ? UserRole.client : UserRole.admin;
        
        final confirmed = await _showConfirmDialog(
          title: 'เปลี่ยนสิทธิ์ผู้ใช้',
          message: 'คุณต้องการเปลี่ยนสิทธิ์ของ ${user.email} '
                  'เป็น${newRole == UserRole.admin ? "ผู้ดูแล" : "ผู้ใช้ทั่วไป"}ใช่หรือไม่?',
        );
        
        if (confirmed) {
          await authRepository.updateUserRole(user.id, newRole);
          await _loadUsers();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('เปลี่ยนสิทธิ์สำเร็จ')),
            );
          }
        }
      } else if (action == 'toggle_status') {
        final confirmed = await _showConfirmDialog(
          title: user.isActive ? 'ปิดการใช้งาน' : 'เปิดการใช้งาน',
          message: 'คุณต้องการ${user.isActive ? "ปิด" : "เปิด"}การใช้งานของ ${user.email} ใช่หรือไม่?',
        );
        
        if (confirmed) {
          final updatedUser = user.copyWith(isActive: !user.isActive);
          await authRepository.updateUserProfile(updatedUser);
          await _loadUsers();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  user.isActive ? 'ปิดการใช้งานสำเร็จ' : 'เปิดการใช้งานสำเร็จ',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
