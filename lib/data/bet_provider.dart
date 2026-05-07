import 'package:flutter/foundation.dart';
import '../models/bet_item.dart';
import '../services/api_service.dart';

class BetProvider extends ChangeNotifier {
  final List<BetItem> _betSlip = [];
  double _balance = 50000.0;
  double _stake = 1000.0;
  BetSlipMode _mode = BetSlipMode.accumulator;
  bool _betPlaced = false;
  bool _backendConnected = false;

  List<BetItem> get betSlip => List.unmodifiable(_betSlip);
  double get balance => _balance;
  double get stake => _stake;
  BetSlipMode get mode => _mode;
  int get betCount => _betSlip.length;
  bool get betPlaced => _betPlaced;
  bool get backendConnected => _backendConnected;

  BetProvider() {
    _syncBalanceFromBackend();
  }

  Future<void> _syncBalanceFromBackend() async {
    final serverBalance = await ApiService.fetchBalance();
    if (serverBalance != null) {
      _balance = serverBalance;
      _backendConnected = true;
      notifyListeners();
    }
  }

  double get totalOdds {
    if (_betSlip.isEmpty) return 0;
    if (_mode == BetSlipMode.accumulator) {
      return _betSlip.fold(1.0, (acc, item) => acc * item.odds);
    }
    return _betSlip.isNotEmpty ? _betSlip.first.odds : 0;
  }

  double get potentialWin => _stake * totalOdds;

  bool isSelected(String eventId, String marketId, String optionLabel) {
    return _betSlip.any((b) =>
        b.eventId == eventId &&
        b.id == marketId &&
        b.optionLabel == optionLabel);
  }

  void toggleBet(BetItem item) {
    final existingIndex = _betSlip.indexWhere(
      (b) => b.eventId == item.eventId && b.id == item.id,
    );
    if (existingIndex >= 0) {
      if (_betSlip[existingIndex].optionLabel == item.optionLabel) {
        _betSlip.removeAt(existingIndex);
      } else {
        _betSlip[existingIndex] = item;
      }
    } else {
      _betSlip.add(item);
    }
    _betPlaced = false;
    notifyListeners();
  }

  void removeFromSlip(String betId, String eventId) {
    _betSlip.removeWhere((b) => b.id == betId && b.eventId == eventId);
    notifyListeners();
  }

  void clearSlip() {
    _betSlip.clear();
    _betPlaced = false;
    notifyListeners();
  }

  void setStake(double value) {
    _stake = value;
    notifyListeners();
  }

  void setMode(BetSlipMode mode) {
    _mode = mode;
    notifyListeners();
  }

  bool placeBet() {
    // Sync version (kept for compat); fires backend call without waiting
    if (_betSlip.isEmpty || _stake > _balance || _stake <= 0) return false;
    _balance -= _stake;
    final stakeCopy = _stake;
    final oddsCopy = totalOdds;
    final selsCopy = _betSlip.map((b) => {
          'eventId': b.eventId,
          'marketId': b.id,
          'homeTeam': b.homeTeam,
          'awayTeam': b.awayTeam,
          'league': b.league,
          'marketName': b.marketName,
          'optionLabel': b.optionLabel,
          'odds': b.odds,
        }).toList();
    _betSlip.clear();
    _betPlaced = true;
    notifyListeners();
    // Async backend sync
    ApiService.placeBet(stake: stakeCopy, totalOdds: oddsCopy, selections: selsCopy)
        .then((res) {
      if (res != null && res['balance'] != null) {
        _balance = (res['balance'] as num).toDouble();
        notifyListeners();
      }
    });
    return true;
  }

  // ──────────── Deposit ────────────
  Future<DepositResult> depositFromBackend(double amount) async {
    final result = await ApiService.deposit(amount);
    if (result == null) {
      return DepositResult(success: false, message: 'Сервертэй холбогдож чадсангүй');
    }
    if (result['error'] != null) {
      return DepositResult(success: false, message: result['error'] as String);
    }
    _balance = (result['balance'] as num).toDouble();
    _backendConnected = true;
    notifyListeners();
    return DepositResult(success: true, message: '₮${amount.toStringAsFixed(0)} амжилттай нэмэгдлээ!');
  }

  // Local fallback (no backend)
  void deposit(double amount) {
    _balance += amount;
    notifyListeners();
  }

  // ──────────── Withdraw ────────────
  Future<DepositResult> withdrawFromBackend(double amount) async {
    if (amount > _balance) {
      return DepositResult(success: false, message: 'Үлдэгдэл хүрэлцэхгүй байна');
    }
    final result = await ApiService.withdraw(amount);
    if (result == null) {
      return DepositResult(success: false, message: 'Сервертэй холбогдож чадсангүй');
    }
    if (result['error'] != null) {
      return DepositResult(success: false, message: result['error'] as String);
    }
    _balance = (result['balance'] as num).toDouble();
    _backendConnected = true;
    notifyListeners();
    return DepositResult(success: true, message: '₮${amount.toStringAsFixed(0)} амжилттай гаргалаа!');
  }

  Future<void> refreshBalance() async {
    await _syncBalanceFromBackend();
  }
}

class DepositResult {
  final bool success;
  final String message;
  const DepositResult({required this.success, required this.message});
}
