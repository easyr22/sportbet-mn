import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'forgot_password_dialog.dart';

class AuthDialog extends StatefulWidget {
  final bool startOnRegister;
  const AuthDialog({super.key, this.startOnRegister = false});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late bool _isRegister = widget.startOnRegister;
  int _step = 0;
  final _emailCtl = TextEditingController();
  final _userCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  final _pw2Ctl = TextEditingController();
  final _codeCtl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _info;
  bool _biometricAvailable = false;
  bool _biometricSaved = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final avail = await BiometricService.isAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable = avail;
        _biometricSaved = BiometricService.hasSavedCredentials();
      });
    }
  }

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
      // Offer to enable biometric for this account
      if (_biometricAvailable && !_biometricSaved && mounted) {
        await _offerBiometricEnroll();
      }
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа гарлаа'; _loading = false; });
    }
  }

  Future<void> _offerBiometricEnroll() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(children: [
          Icon(Icons.fingerprint, color: AppColors.accent),
          SizedBox(width: 8),
          Text('Биометрээр хадгалах уу?', style: TextStyle(color: Colors.white, fontSize: 16)),
        ]),
        content: const Text(
          'Дараа дахин нэвтрэхэд Face ID / хурууны хээ ашиглах уу?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Үгүй', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Тийм', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (yes == true) {
      await BiometricService.register(_userCtl.text.trim());
    }
  }

  Future<void> _biometricLogin() async {
    setState(() { _error = null; _loading = true; });
    final res = await BiometricService.authenticate();
    if (!mounted) return;
    if (!res.ok) {
      setState(() {
        _loading = false;
        if (res.error == 'no_credentials') {
          _error = 'Биометр бүртгэлгүй. Эхлээд нууц үгээр нэвтэрнэ үү.';
        } else if (res.error?.contains('Cancelled') == true) {
          _error = 'Биометр цуцлагдлаа';
        } else {
          _error = 'Биометр алдаа гарлаа';
        }
      });
      return;
    }
    // Biometric verified — auto-login the saved username (no password needed since device already verified user)
    if (res.username != null) {
      // Use stored token if available, otherwise prompt password once
      _userCtl.text = res.username!;
      setState(() {
        _info = '✅ Биометр амжилттай. ${res.username} рүү нэвтрэх...';
        _loading = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _sendCode() async {
    setState(() { _error=null; _info=null; _loading=true; });
    final email = _emailCtl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() { _error='Имэйл хаяг буруу'; _loading=false; }); return;
    }
    if (_userCtl.text.trim().length < 3) {
      setState(() { _error='Хэрэглэгчийн нэр 3+ тэмдэгт'; _loading=false; }); return;
    }
    if (_pwCtl.text.length < 4) {
      setState(() { _error='Нууц үг 4+ тэмдэгт'; _loading=false; }); return;
    }
    if (_pwCtl.text != _pw2Ctl.text) {
      setState(() { _error='Нууц үг таарахгүй'; _loading=false; }); return;
    }
    final res = await AuthService.sendCode(email);
    if (!mounted) return;
    if (res['success'] == true) {
      String info = '✉️  $email рүү код илгээлээ';
      if (res['devCode'] != null) {
        info = '⚠️ Имэйл боломжгүй.\nТуршилтын код: ${res['devCode']}';
      }
      setState(() { _info = info; _step = 1; _loading=false; });
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа'; _loading=false; });
    }
  }

  Future<void> _verifyAndRegister() async {
    setState(() { _error=null; _loading=true; });
    if (_codeCtl.text.trim().length != 6) {
      setState(() { _error='6 оронтой код'; _loading=false; }); return;
    }
    final res = await AuthService.register(
      _emailCtl.text.trim(), _userCtl.text.trim(),
      _pwCtl.text, _codeCtl.text.trim(),
    );
    if (!mounted) return;
    if (res['success'] == true) {
      if (context.mounted) await context.read<BetProvider>().refreshBalance();
      if (_biometricAvailable && mounted) {
        await _offerBiometricEnroll();
      }
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() { _error = res['error'] ?? 'Алдаа'; _loading=false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isRegister) ..._loginForm(),
                    if (_isRegister && _step == 0) ..._registerForm(),
                    if (_isRegister && _step == 1) ..._codeForm(),
                    if (_info != null) _alertBox(_info!, AppColors.accent),
                    if (_error != null) _alertBox(_error!, AppColors.liveRed),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor: AppColors.surfaceHov,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(_submitLabel()),
                      ),
                    ),
                    if (!_isRegister && _biometricAvailable && _biometricSaved) ...[
                      const SizedBox(height: 12),
                      _biometricButton(),
                    ],
                    if (_isRegister && _step == 1) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: _loading ? null : () => setState(() { _step=0; _info=null; _error=null; }),
                          child: const Text('← Буцах', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(_isRegister ? 'аль хэдийн бүртгэлтэй?' : 'бүртгэлгүй?',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ),
                        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _isRegister = !_isRegister; _step = 0; _error = null; _info = null;
                        }),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.blueLight, width: 1.5),
                          foregroundColor: AppColors.blueLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        child: Text(_isRegister ? 'НЭВТРЭХ' : 'БҮРТГҮҮЛЭХ'),
                      ),
                    ),
                    if (_isRegister && _step == 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent.withOpacity(0.15), AppColors.orange.withOpacity(0.15)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 6),
                            Text('Шинэ хэрэглэгчид 50,000₮ урамшуулал!',
                                style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = _isRegister
        ? (_step == 0 ? 'БҮРТГҮҮЛЭХ' : 'КОД БАТАЛГААЖУУЛАХ')
        : 'НЭВТРЭХ';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueDark, AppColors.blue, AppColors.accent],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 22, 16, 22),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Sport', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    const Text('Bet', style: TextStyle(color: Color(0xFFFFCC00), fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(2)),
                      child: const Text('MN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _alertBox(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }

  Widget _biometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _biometricLogin,
        icon: const Icon(Icons.fingerprint, size: 22, color: AppColors.accent),
        label: const Text('Face ID / Хурууны хээ',
            style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            showDialog(context: context, builder: (_) => const ForgotPasswordDialog());
          }
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 28)),
        child: const Text('Нууц үгээ мартсан уу?',
            style: TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ),
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
          Expanded(child: Text(_emailCtl.text.trim(),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
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
      decoration: InputDecoration(
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
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
