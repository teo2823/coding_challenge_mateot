import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/currency_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/fund.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/portfolio_provider.dart';

class SubscribeBottomSheet extends ConsumerStatefulWidget {
  final Fund fund;

  const SubscribeBottomSheet({super.key, required this.fund});

  @override
  ConsumerState<SubscribeBottomSheet> createState() =>
      _SubscribeBottomSheetState();
}

class _SubscribeBottomSheetState extends ConsumerState<SubscribeBottomSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  NotificationMethod _selectedMethod = NotificationMethod.email;
  bool _isLoading = false;
  double? _enteredAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = ref.watch(portfolioProvider.select((s) => s.balance));
    final canAffordMinimum = balance >= widget.fund.minimumAmount;

    final afterBalance = _enteredAmount != null && _enteredAmount! <= balance
        ? balance - _enteredAmount!
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Suscribirse al fondo', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(widget.fund.name, style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),

            // Info de saldo y mínimo
            _SummaryRow(
              label: 'Monto mínimo',
              value: CurrencyFormatter.format(widget.fund.minimumAmount),
              valueColor: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Saldo disponible',
              value: CurrencyFormatter.format(balance),
              valueColor: canAffordMinimum ? AppColors.teal : AppColors.error,
            ),
            if (afterBalance != null) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Saldo tras suscripción',
                value: CurrencyFormatter.format(afterBalance),
                valueColor: theme.colorScheme.onSurface,
              ),
            ],

            const SizedBox(height: 24),

            // Input de monto
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              enabled: canAffordMinimum,
              decoration: InputDecoration(
                labelText: 'Monto a invertir',
                hintText: 'Mín. ${CurrencyFormatter.format(widget.fund.minimumAmount)}',
                prefixText: '\$ ',
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : const Color(0xFFF0F4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _enteredAmount = double.tryParse(val.replaceAll('.', ''));
                });
              },
              validator: (val) => validateAmount(
                double.tryParse((val ?? '').replaceAll('.', '')),
                widget.fund,
                balance,
              ),
            ),

            const SizedBox(height: 24),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 20),

            // Método de notificación
            Text('Método de notificación', style: theme.textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _NotifOption(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  selected: _selectedMethod == NotificationMethod.email,
                  onTap: () =>
                      setState(() => _selectedMethod = NotificationMethod.email),
                ),
                const SizedBox(width: 12),
                _NotifOption(
                  label: 'SMS',
                  icon: Icons.sms_outlined,
                  selected: _selectedMethod == NotificationMethod.sms,
                  onTap: () =>
                      setState(() => _selectedMethod = NotificationMethod.sms),
                ),
              ],
            ),

            const SizedBox(height: 28),

            if (!canAffordMinimum)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saldo insuficiente para suscribirte a este fondo.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (canAffordMinimum)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSubscribe,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirmar suscripción',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(portfolioProvider.notifier).subscribe(
            fund: widget.fund,
            amount: _enteredAmount!,
            notificationMethod: _selectedMethod,
          );
      if (mounted) {
        Navigator.pop(context);
        AppToast.show(
          context,
          type: ToastificationType.success,
          title: 'Suscripción exitosa',
          description: 'Invertiste ${CurrencyFormatter.format(_enteredAmount!)} en ${widget.fund.name}.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(
          context,
          type: ToastificationType.error,
          title: 'Error al suscribirse',
          description: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _NotifOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NotifOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.blue.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.blue : theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.blue : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.blue : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
