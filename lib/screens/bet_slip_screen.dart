import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import '../models/bet_item.dart';

class BetSlipScreen extends StatefulWidget {
  const BetSlipScreen({super.key});

  @override
  State<BetSlipScreen> createState() => _BetSlipScreenState();
}

class _BetSlipScreenState extends State<BetSlipScreen> {
  final TextEditingController _stakeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<BetProvider>();
    _stakeCtrl.text = provider.stake.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _stakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bet Slip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<BetProvider>().clearSlip(),
            child: const Text(
              'Цэвэрлэх',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
      body: Consumer<BetProvider>(
        builder: (context, provider, _) {
          if (provider.betSlip.isEmpty) {
            return const _EmptySlip();
          }
          return Column(
            children: [
              // Mode toggle
              _ModeToggle(
                mode: provider.mode,
                onChanged: provider.setMode,
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    const SizedBox(height: 12),
                    ...provider.betSlip.map((item) => _BetSlipItem(
                          item: item,
                          onRemove: () =>
                              provider.removeFromSlip(item.id, item.eventId),
                        )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Stake & Summary
              _BetSummary(
                provider: provider,
                stakeCtrl: _stakeCtrl,
                onStakeChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0;
                  provider.setStake(parsed);
                },
                onPlaceBet: () => _placeBet(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  void _placeBet(BetProvider provider) {
    final success = provider.placeBet();
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Bet амжилттай тавигдлаа!'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Дансны үлдэгдэл хүрэлцэхгүй байна'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
}

class _ModeToggle extends StatelessWidget {
  final BetSlipMode mode;
  final ValueChanged<BetSlipMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: '🏆 Акумулятор',
              isSelected: mode == BetSlipMode.accumulator,
              onTap: () => onChanged(BetSlipMode.accumulator),
            ),
          ),
          Expanded(
            child: _Tab(
              label: '1️⃣ Ганц бет',
              isSelected: mode == BetSlipMode.single,
              onTap: () => onChanged(BetSlipMode.single),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BetSlipItem extends StatelessWidget {
  final BetItem item;
  final VoidCallback onRemove;

  const _BetSlipItem({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.league,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close,
                    color: AppColors.textMuted, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${item.homeTeam} - ${item.awayTeam}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.marketName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.orange.withOpacity(0.4)),
                ),
                child: Text(
                  item.optionLabel,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.odds.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BetSummary extends StatelessWidget {
  final BetProvider provider;
  final TextEditingController stakeCtrl;
  final ValueChanged<String> onStakeChanged;
  final VoidCallback onPlaceBet;

  const _BetSummary({
    required this.provider,
    required this.stakeCtrl,
    required this.onStakeChanged,
    required this.onPlaceBet,
  });

  @override
  Widget build(BuildContext context) {
    final quickAmounts = [1000.0, 2000.0, 5000.0, 10000.0, 20000.0];
    final canBet = provider.stake > 0 &&
        provider.stake <= provider.balance &&
        provider.betSlip.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick amount buttons
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickAmounts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final amt = quickAmounts[i];
                return GestureDetector(
                  onTap: () {
                    stakeCtrl.text = amt.toStringAsFixed(0);
                    onStakeChanged(stakeCtrl.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      '₮${amt.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Stake input
          Row(
            children: [
              const Text(
                'Орц дүн:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: stakeCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onStakeChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.card,
                    prefixText: '₮ ',
                    prefixStyle: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.orange),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Нийт odds:',
                  value: provider.totalOdds.toStringAsFixed(2),
                  valueColor: AppColors.orange,
                ),
                const Divider(color: AppColors.divider, height: 16),
                _SummaryRow(
                  label: 'Орц дүн:',
                  value: '₮${provider.stake.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 4),
                _SummaryRow(
                  label: 'Хожих дүн:',
                  value: '₮${provider.potentialWin.toStringAsFixed(0)}',
                  valueColor: AppColors.green,
                  isBig: true,
                ),
                const Divider(color: AppColors.divider, height: 16),
                _SummaryRow(
                  label: 'Дансны үлдэгдэл:',
                  value: '₮${provider.balance.toStringAsFixed(0)}',
                  valueColor: provider.stake > provider.balance
                      ? AppColors.red
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Place bet button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canBet ? onPlaceBet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canBet ? AppColors.orange : AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                canBet
                    ? 'BET ТАВИХ  ₮${provider.stake.toStringAsFixed(0)}'
                    : provider.stake > provider.balance
                        ? 'Үлдэгдэл хүрэлцэхгүй'
                        : 'Орц оруулна уу',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBig;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isBig ? 18 : 13,
            fontWeight: isBig ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptySlip extends StatelessWidget {
  const _EmptySlip();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎫', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Bet Slip хоосон байна',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Тоглолт дээр odds дарж bet нэм',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
