import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
// Importa las rutas desde su nuevo archivo centralizado
import 'package:safepay/core/constants/app_routes.dart';
import 'package:safepay/features/send/providers/send_notifier.dart';
import 'package:safepay/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

// --- WIDGETS AUXILIARES ---

// Tarjeta de Flujo de Pago (User -> Recipient)
class _PaymentFlowCard extends ConsumerWidget {
  final bool isDivided;
  const _PaymentFlowCard({this.isDivided = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendNotifierProvider);
    final senderAlias = state.senderWallet?.alias ?? '@You';
    final recipientAlias = state.mainRecipient?.alias ?? '@Unknown';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Usuario (Saitama o Grupo)
          if (isDivided)
            Row(
              children: [
                _RecipientAvatar(
                    alias: '@group',
                    icon: Icons.group,
                    color: AppColors.nonPhotoBlue),
                const SizedBox(width: 8),
                Text('@group', style: TextStyle(color: AppColors.textPrimary)),
              ],
            )
          else
            Row(
              children: [
                _RecipientAvatar(alias: senderAlias, color: AppColors.veronica),
                const SizedBox(width: 8),
                Text(senderAlias,
                    style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),

          // Flecha de Flujo
          Expanded(
            child: Icon(Icons.arrow_forward, color: AppColors.textSecondary),
          ),

          // Destinatario Principal
          _RecipientAvatar(
              alias: recipientAlias,
              icon: Icons.cloud,
              color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(recipientAlias, style: TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// Avatar de Destinatario/Participante
class _RecipientAvatar extends StatelessWidget {
  final String alias;
  final IconData? icon;
  final Color color;

  const _RecipientAvatar({required this.alias, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white)
          : Center(
              child: Text(alias[1].toUpperCase(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}

// Selector de Tipo de Pago (Single, Recurrent, Divided)
class _PaymentTypeSelector extends ConsumerWidget {
  const _PaymentTypeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType =
        ref.watch(sendNotifierProvider.select((state) => state.type));
    final notifier = ref.read(sendNotifierProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: PaymentType.values.map((type) {
        final isSelected = selectedType == type;
        return InkWell(
          onTap: () => notifier.setPaymentType(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type.name.substring(0, 1).toUpperCase() + type.name.substring(1),
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// --- PANTALLAS DE DETALLE DE TIPO DE PAGO ---

// 1. Single Payment Details (Página 20, primera parte)
class _SingleDetails extends ConsumerWidget {
  const _SingleDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nota Gasless (Página 20)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bulutBubble,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'You currently have the Gasless option activated so this Safe will not charge you for emissions',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// 2. Recurrent Payment Details (Página 20, centro)
class _RecurrentDetails extends ConsumerStatefulWidget {
  const _RecurrentDetails();

  @override
  ConsumerState<_RecurrentDetails> createState() => __RecurrentDetailsState();
}

class __RecurrentDetailsState extends ConsumerState<_RecurrentDetails> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendNotifierProvider);
    final notifier = ref.read(sendNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Frequency',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: RecurrenceFrequency.values.map((freq) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<RecurrenceFrequency>(
                  value: freq,
                  groupValue: state.frequency,
                  onChanged: (val) => notifier.setFrequency(val!),
                  activeColor: AppColors.accent,
                ),
                Text(freq.name.substring(0, 1).toUpperCase() +
                    freq.name.substring(1)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Duration',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: state.isUntilCancelled,
              onChanged: (_) =>
                  notifier.setDurationType(isUntilCancelled: true),
              activeColor: AppColors.accent,
            ),
            const Text('Until Cancelled'),
            const Spacer(),
            Radio<bool>(
              value: false,
              groupValue: state.isUntilCancelled,
              onChanged: (_) =>
                  notifier.setDurationType(isUntilCancelled: false),
              activeColor: AppColors.accent,
            ),
            const Text('Set Cycles'),
            // Aquí iría un campo para ingresar el número de ciclos si `isUntilCancelled` es false
          ],
        ),
        const SizedBox(height: 16),
        const Text('Start Date',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: state.startDate == null,
              onChanged: (_) => notifier.setStartDate(null),
              activeColor: AppColors.accent,
            ),
            const Text('Start Now'),
            const Spacer(),
            Radio<bool>(
              value: false,
              groupValue: state.startDate != null,
              onChanged: (_) async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                notifier.setStartDate(date);
              },
              activeColor: AppColors.accent,
            ),
            Text(
                'Custom Date ${state.startDate != null ? '(${DateFormat('dd/MM/yy').format(state.startDate!)})' : ''}'),
          ],
        ),
      ],
    );
  }
}

// 3. Divided Payment Details (Páginas 21, 22)
class _DividedDetails extends ConsumerWidget {
  const _DividedDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendNotifierProvider);
    final notifier = ref.read(sendNotifierProvider.notifier);
    final recentContacts =
        ref.read(sendNotifierProvider.notifier).recentContacts;

    // Lista de participantes (excluyendo el usuario principal)
    final availableSafers = recentContacts
        .where((c) => c.alias != state.senderWallet?.alias)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Choose safers',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        // Lista de selección de Safers
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _RecipientAvatar(
                  alias: 'Add', icon: Icons.add, color: AppColors.textPrimary),
              ...availableSafers.map((safer) {
                final isSelected =
                    state.safers.any((s) => s.alias == safer.alias);
                return GestureDetector(
                  onTap: () => isSelected
                      ? notifier.removeSafer(safer)
                      : notifier.addSafer(safer),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        _RecipientAvatar(
                            alias: safer.alias,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.disabled),
                        if (isSelected)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(Icons.check_circle,
                                color: AppColors.success, size: 18),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Text('%',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: state.isSplitEqual,
              onChanged: (val) => notifier.toggleSplitType(true),
              activeColor: AppColors.accent,
            ),
            const Text('Equal'),
            const Spacer(),
            Radio<bool>(
              value: false,
              groupValue: state.isSplitEqual,
              onChanged: (val) => notifier.toggleSplitType(false),
              activeColor: AppColors.accent,
            ),
            const Text('Different'),
          ],
        ),

        // Vista de Reparto (Página 22)
        if (state.safers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: state.safers.map((safer) {
                final amount = state.isSplitEqual
                    ? notifier.equalSplitAmount
                    : state.customSplit[safer.alias] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      _RecipientAvatar(
                          alias: safer.alias, color: AppColors.veronica),
                      const SizedBox(width: 16),
                      if (state.isSplitEqual)
                        Text(
                          '${CurrencyFormatter.formatYield(amount)} USDC',
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.textPrimary),
                        )
                      else
                        // Campo de entrada para split diferente
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Monto de ${safer.alias}',
                              suffixText: 'USDC',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (value) {
                              notifier.setCustomSplit(
                                  safer.alias, double.tryParse(value) ?? 0.0);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const Text(
          'This payment will be made when the rest of the safers accept',
          style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// --- WIDGET PRINCIPAL ---

class SendSafeDetailsScreen extends ConsumerStatefulWidget {
  const SendSafeDetailsScreen({super.key});

  @override
  ConsumerState<SendSafeDetailsScreen> createState() =>
      _SendSafeDetailsScreenState();
}

class _SendSafeDetailsScreenState extends ConsumerState<SendSafeDetailsScreen> {
  final TextEditingController _conceptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Iniciar con Single por defecto, si no hay tipo seleccionado
    if (ref.read(sendNotifierProvider).type == null) {
      ref
          .read(sendNotifierProvider.notifier)
          .setPaymentType(PaymentType.single);
    }
    _conceptController.addListener(() {
      ref
          .read(sendNotifierProvider.notifier)
          .setConcept(_conceptController.text);
    });
  }

  @override
  void dispose() {
    _conceptController.dispose();
    super.dispose();
  }

  // Contenido de la sección de detalles
  Widget _buildDetailsContent(PaymentType type) {
    switch (type) {
      case PaymentType.single:
        return const _SingleDetails();
      case PaymentType.recurrent:
        return const _RecurrentDetails();
      case PaymentType.divided:
        return const _DividedDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendNotifierProvider);
    final isComplete = ref.watch(areDetailsCompleteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const Text('Send a Safe',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flujo de Pago (Página 20)
                    _PaymentFlowCard(
                        isDivided: state.type == PaymentType.divided),

                    // Concepto (Página 20)
                    const Text('Concept',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _conceptController,
                      decoration: InputDecoration(
                        hintText: 'Write a concept',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        counterText: '${state.concept.length}/60',
                      ),
                      maxLength: 60,
                    ),

                    const SizedBox(height: 24),

                    // Tipo de Pago (Página 20)
                    const Text('Payment Type',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const _PaymentTypeSelector(),

                    const SizedBox(height: 24),

                    // Contenido Dinámico de Detalles
                    _buildDetailsContent(state.type),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botón Continuar (Página 21 - Divided usa flecha, Recurrent/Single usa Send)
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isComplete
                        ? () => context.pushNamed(AppRoutes.sendAuthName)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.disabled,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.type == PaymentType.divided
                        ? const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 24)
                        : Text(
                            'Send ${CurrencyFormatter.formatYield(state.amount)} USDC',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
