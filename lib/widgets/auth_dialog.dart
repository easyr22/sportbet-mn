import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/auth_service.dart';

class AuthDialog extends StatefulWidget {
  final bool startOnRegister;
  const AuthDialog({super.key, this.startOnRegister = false});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late bool _isRegister = widget.startOnRegister;
  final _userCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  final _pw2Ctl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userCtl.dispose(); _pwCtl.dispose(); _pw2Ctl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _error = null; _loading = true; });
    final u = _userCtl.text.trim();
    final p = _pwCtl.text;
    if (_isRegister && p != _pw2Ctl.text) {
      setState(() { _error = 'Нууц үг таарахгүй байна'; _loading = false; });
      return;
    }
    final res = _isRegister
        ? await AuthService.register(u, p)
        : await AuthService.login(u, p);
    if (!mounted) return;
    if (res['success'] == true) {
      // Refresh provider state
      if (context.mounted) {
        await context.read<BetProvider>().refreshBalance();
      }
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа гарлаа'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _isRegister ? 'БҮРТГҮҮЛЭХ' : 'НЭВТРЭХ',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(controller: _userCtl, label: 'Хэрэглэгчийн нэр', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _Field(controller: _pwCtl, label: 'Нууц үг', icon: Icons.lock_outline, obscure: true),
            if (_isRegister) ...[
              const SizedBox(height: 12),
              _Field(controller: _pw2Ctl, label: 'Нууц үг давтах', icon: Icons.lock_outline, obscure: true),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.liveRed.withOpacity(0.4)),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.liveRed, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isRegister ? 'БҮРТГҮҮЛЭХ' : 'НЭВТРЭХ'),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isRegister = !_isRegister; _error = null;
                }),
                child: Text(
                  _isRegister ? 'Аль хэдийн бүртгэлтэй юу? Нэвтрэх' : 'Бүртгэлгүй юу? Бүртгүүлэх',
                  style: const TextStyle(color: AppColors.blueLight, fontSize: 12),
                ),
              ),
            ),
            if (_isRegister)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '🎁 Шинэ хэрэглэгчид 50,000₮ урамшуулал!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  const _Field({required this.controller, required this.label, required this.icon, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
