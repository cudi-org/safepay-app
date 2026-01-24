import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/features/activity/providers/activity_notifier.dart';
import 'package:safepay/features/activity/presentation/widgets/transaction_list_item.dart';
import 'package:safepay/features/activity/presentation/activity_screen.dart' show NothingToSeeIllustration;

enum ActivityFilter { all, send, receive, subscriptions }

class FullActivityModal extends ConsumerStatefulWidget {
  const FullActivityModal({super.key});

  @override
  ConsumerState<FullActivityModal> createState() => _FullActivityModalState();
}

class _FullActivityModalState extends ConsumerState<FullActivityModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ActivityFilter> _filters = ActivityFilter.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFilterTitle(ActivityFilter filter) {
    switch (filter) {
      case ActivityFilter.all:
        return 'All';
      case ActivityFilter.send:
        return 'Send';
      case ActivityFilter.receive:
        return 'Receive';
      case ActivityFilter.subscriptions:
        return 'Subscriptions';
    }
  }

  List<TransactionModel> _getFilteredTransactions(ActivityFilter filter) {
    final allTransactions = ref.watch(activityNotifierProvider).transactions;

    switch (filter) {
      case ActivityFilter.send:
        return allTransactions
            .where((tx) =>
                tx.type == TransactionType.sent ||
                tx.type == TransactionType.withdrawal)
            .toList();
      case ActivityFilter.receive:
        return allTransactions
            .where((tx) =>
                tx.type == TransactionType.received ||
                tx.type == TransactionType.deposit ||
                tx.type == TransactionType.yieldGain)
            .toList();
      case ActivityFilter.subscriptions:
        // Lógica simulada basada en el README: Suscripciones recurrentes
        return allTransactions
            .where((tx) =>
                tx.isSubscription || // Asumiendo que añadiremos este campo o usaremos lógica de counterparty
                tx.counterpartyAlias.toLowerCase().contains('lighthouse') ||
                tx.counterpartyAlias.toLowerCase().contains('spotify') ||
                tx.type == TransactionType.yieldGain)
            .toList();
      case ActivityFilter.all:
      default:
        return allTransactions;
    }
  }

  void _showInfographic() {
    // Usamos showModalBottomSheet para una apariencia más premium y consistente
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const _InfographicContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Spacer(), // Balancear el título
                const Text('Activity',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                // Infografía
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: _showInfographic,
                  tooltip: 'Meaning of icons',
                ),
                const Spacer(),
                // Close Button
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                 color: Colors.grey.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                labelColor: Colors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelColor: AppColors.textSecondary,
                tabs: _filters
                    .map((f) => Tab(text: _getFilterTitle(f)))
                    .toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _filters.map((filter) {
                final filteredTxs = _getFilteredTransactions(filter);

                if (filteredTxs.isEmpty) {
                  return const _EmptyTabView(tabName: 'Nothing here yet');
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  itemCount: filteredTxs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TransactionListItem(
                        transaction: filteredTxs[index], isRecent: false);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabView extends StatelessWidget {
  final String tabName;
  const _EmptyTabView({required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NothingToSeeIllustration(),
          const SizedBox(height: 16),
          Text(
            tabName.toUpperCase(),
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 100), // Visual balance
        ],
      ),
    );
  }
}

class _InfographicContent extends StatelessWidget {
  const _InfographicContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Meaning of icons',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfographicRow(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: const Icon(Icons.arrow_upward, color: AppColors.textPrimary, size: 20),
          ),
          label: 'Single payment sent',
          description: 'One-time transfer to another wallet.',
        ),
        _InfographicRow(
           icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
             child: const Icon(Icons.arrow_downward, color: AppColors.primary, size: 20),
           ),
          label: 'Income received',
          description: 'Funds received from external sources.',
        ),
        _InfographicRow(
           icon: Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: AppColors.veronica.withOpacity(0.1),
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.autorenew, color: AppColors.veronica, size: 20),
           ),
          label: 'Subscription',
          description: 'Recurring payments managed by smart contracts.',
        ),
      ],
    );
  }
}

class _InfographicRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String description;

  const _InfographicRow({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
