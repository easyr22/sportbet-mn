import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/auth_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});
  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  int _step = 0; // 0=enter email, 1=enter code+new pw
  final _emailCtl = TextEditingController();
  final _codeCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  final _pw2Ctl = TextEditingController();
  bool _hidePw = true;
  bool _loading = false;
  String? _error, _info;

  @override
  void dispose() {
    _emailCtl.dispose(); _codeCtl.dispose(); _pwCtl.dispose(); _pw2Ctl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() { _error = null; _info = null; _loading = true; });
    final email = _emailCtl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() { _error = 'Имэйл хаяг буруу байна'; _loading = false; });
      return;
    }
    final res = await AuthService.forgotPassword(email);
    if (!mounted) return;
    if (res['success'] == true) {
      String info = '✉️  $email рүү сэргээх код илгээлээ';
      if (res['devCode'] != null) {
        info = '⚠️ Имэйл илгээх боломжгүй.\nТуршилтын код: ${res['devCode']}';
      }
      setState(() { _info = info; _step = 1; _loading = false; });
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа'; _loading = false; });
    }
  }

  Future<void> _reset() async {
    setState(() { _error = null; _loading = true; });
    if (_codeCtl.text.trim().length != 6) {
      setState(() { _error = '6 оронтой код'; _loading = false; }); return;
    }
    if (_pwCtl.text.length < 4) {
      setState(() { _error = 'Нууц үг 4+ тэмдэгт'; _loading = false; }); return;
    }
    if (_pwCtl.text != _pw2Ctl.text) {
      setState(() { _error = 'Нууц үг таарахгүй байна'; _loading = false; }); return;
    }
    final res = await AuthService.resetPassword(
      _emailCtl.text.trim(), _codeCtl.text.trim(), _pwCtl.text);
    if (!mounted) return;
    if (res['success'] == true) {
      if (context.mounted) await context.read<BetProvider>().refreshBalance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.accent,
          content: Text('✅ Нууц үг шинэчлэгдлээ. Та амжилттай нэвтэрлээ.'),
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      }
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.lock_reset, color: AppColors.orange, size: 22),
              const SizedBox(width: 8),
              Text(_step == 0 ? 'НУУЦ ҮГ СЭРГЭЭХ' : 'ШИНЭ НУУЦ ҮГ',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            if (_step == 0) ..._step0() else ..._step1(),
            if (_info != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: Text(_info!, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
              ),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : (_step == 0 ? _sendCode : _reset),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_step == 0 ? 'КОД ИЛГЭЭХ' : 'НУУЦ ҮГ ШИНЭЧЛЭХ'),
            ),
            if (_step == 1) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: _loading ? null : () => setState(() { _step = 0; _info = null; _error = null; }),
                child: const Text('← Имэйл солих', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _step0() => [
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text('Бүртгэлтэй имэйл хаягаа оруул. Сэргээх код илгээх болно.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ),
    _input(_emailCtl, 'Имэйл хаяг', Icons.email_outlined, keyboard: TextInputType.emailAddress, onSubmit: _sendCode),
  ];

  List<Widget> _step1() => [
    Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg, borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.email, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(_emailCtl.text.trim(),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    ),
    const SizedBox(height: 10),
    _input(_codeCtl, '6 оронтой код', Icons.pin_outlined, keyboard: TextInputType.number),
    const SizedBox(height: 10),
    _input(_pwCtl, 'Шинэ нууц үг', Icons.lock_outline, obscure: _hidePw,
        suffix: IconButton(
          icon: Icon(_hidePw ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary, size: 18),
          onPressed: () => setState(() => _hidePw = !_hidePw),
        )),
    const SizedBox(height: 10),
    _input(_pw2Ctl, 'Шинэ нууц үг давтах', Icons.lock_outline, obscure: _hidePw, onSubmit: _reset),
  ];

  Widget _input(TextEditingController ctl, String label, IconData icon,
      {bool obscure = false, TextInputType? keyboard, VoidCallback? onSubmit, Widget? suffix}) {
    return TextField(
      controller: ctl,
      obscureText: obscure,
      keyboardType: keyboard,
      onSubmitted: (_) => onSubmit?.call(),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        suffixIcon: suffix,
        filled: true, fillColor: AppColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
