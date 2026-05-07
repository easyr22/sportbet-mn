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
  int _step = 0;        // 0=fill form, 1=enter code (register only)
  final _emailCtl = TextEditingController();
  final _userCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  final _pw2Ctl = TextEditingController();
  final _codeCtl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailCtl.dispose(); _userCtl.dispose(); _pwCtl.dispose();
    _pw2Ctl.dispose(); _codeCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _error=null; _loading=true; });
    final res = await AuthService.login(_userCtl.text.trim(), _pwCtl.text);
    if (!mounted) return;
    if (res['success'] == true) {
      if (context.mounted) await context.read<BetProvider>().refreshBalance();
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа гарлаа'; _loading = false; });
    }
  }

  Future<void> _sendCode() async {
    setState(() { _error=null; _info=null; _loading=true; });
    final email = _emailCtl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() { _error='Имэйл хаяг буруу байна'; _loading=false; }); return;
    }
    if (_userCtl.text.trim().length < 3) {
      setState(() { _error='Хэрэглэгчийн нэр 3+ тэмдэгт байх ёстой'; _loading=false; }); return;
    }
    if (_pwCtl.text.length < 4) {
      setState(() { _error='Нууц үг 4+ тэмдэгт байх ёстой'; _loading=false; }); return;
    }
    if (_pwCtl.text != _pw2Ctl.text) {
      setState(() { _error='Нууц үг таарахгүй байна'; _loading=false; }); return;
    }
    final res = await AuthService.sendCode(email);
    if (!mounted) return;
    if (res['success'] == true) {
      String info = '✉️  $email рүү 6 оронтой код илгээлээ. Имэйлээ шалгана уу.';
      if (res['devCode'] != null) {
        info = '⚠️ Имэйл сервер тохируулагдаагүй байна.\nТуршилтын код: ${res['devCode']}';
      }
      setState(() { _info = info; _step = 1; _loading=false; });
    } else {
      setState(() { _error = res['error'] ?? 'Код илгээхэд алдаа гарлаа'; _loading=false; });
    }
  }

  Future<void> _verifyAndRegister() async {
    setState(() { _error=null; _loading=true; });
    if (_codeCtl.text.trim().length != 6) {
      setState(() { _error='6 оронтой код оруулна уу'; _loading=false; }); return;
    }
    final res = await AuthService.register(
      _emailCtl.text.trim(), _userCtl.text.trim(),
      _pwCtl.text, _codeCtl.text.trim(),
    );
    if (!mounted) return;
    if (res['success'] == true) {
      if (context.mounted) await context.read<BetProvider>().refreshBalance();
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа гарлаа'; _loading=false; });
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
            Row(
              children: [
                Text(
                  _isRegister
                      ? (_step == 0 ? 'БҮРТГҮҮЛЭХ' : 'КОД БАТАЛГААЖУУЛАХ')
                      : 'НЭВТРЭХ',
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
            if (!_isRegister) ..._loginForm(),
            if (_isRegister && _step == 0) ..._registerForm(),
            if (_isRegister && _step == 1) ..._codeForm(),
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
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_submitLabel()),
            ),
            if (_isRegister && _step == 1) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => setState(() { _step=0; _info=null; _error=null; }),
                child: const Text('← Буцах', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isRegister = !_isRegister; _step=0; _error = null; _info=null;
                }),
                child: Text(
                  _isRegister ? 'Аль хэдийн бүртгэлтэй юу? Нэвтрэх' : 'Бүртгэлгүй юу? Бүртгүүлэх',
                  style: const TextStyle(color: AppColors.blueLight, fontSize: 12),
                ),
              ),
            ),
            if (_isRegister && _step == 0)
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

  String _submitLabel() {
    if (!_isRegister) return 'НЭВТРЭХ';
    return _step == 0 ? 'КОД ИЛГЭЭХ' : 'БАТАЛГААЖУУЛАХ';
  }

  void _onSubmit() {
    if (!_isRegister) { _login(); return; }
    if (_step == 0) { _sendCode(); return; }
    _verifyAndRegister();
  }

  List<Widget> _loginForm() => [
    _Field(controller: _userCtl, label: 'Хэрэглэгчийн нэр', icon: Icons.person_outline),
    const SizedBox(height: 12),
    _Field(controller: _pwCtl, label: 'Нууц үг', icon: Icons.lock_outline, obscure: true,
        onSubmitted: () { if (!_loading) _login(); }),
  ];

  List<Widget> _registerForm() => [
    _Field(controller: _emailCtl, label: 'Имэйл хаяг', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
    const SizedBox(height: 12),
    _Field(controller: _userCtl, label: 'Хэрэглэгчийн нэр', icon: Icons.person_outline),
    const SizedBox(height: 12),
    _Field(controller: _pwCtl, label: 'Нууц үг (4+ тэмдэгт)', icon: Icons.lock_outline, obscure: true),
    const SizedBox(height: 12),
    _Field(controller: _pw2Ctl, label: 'Нууц үг давтах', icon: Icons.lock_outline, obscure: true,
        onSubmitted: () { if (!_loading) _sendCode(); }),
  ];

  List<Widget> _codeForm() => [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.email, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_emailCtl.text.trim(),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    _Field(
      controller: _codeCtl,
      label: '6 оронтой код',
      icon: Icons.pin_outlined,
      keyboard: TextInputType.number,
      onSubmitted: () { if (!_loading) _verifyAndRegister(); },
    ),
  ];
}

class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final VoidCallback? onSubmitted;
  const _Field({
    required this.controller, required this.label,
    required this.icon, this.obscure = false, this.keyboard, this.onSubmitted,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboard,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      textInputAction: widget.onSubmitted != null ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _decoration(context),
    );
  }

  InputDecoration _decoration(BuildContext context) => InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(widget.icon, color: AppColors.textSecondary, size: 18),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary, size: 18),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
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
      );
}
