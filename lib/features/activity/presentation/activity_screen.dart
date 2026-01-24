import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/constants/app_routes.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/features/activity/providers/activity_notifier.dart';
import 'package:safepay/features/activity/presentation/widgets/wallet_card.dart';
import 'package:safepay/features/activity/presentation/widgets/transaction_list_item.dart'; // Para CustomBottomNavBar

// Simulación de la ilustración "Nothing to see here" (Pág 12)
class NothingToSeeIllustration extends StatelessWidget {
  const NothingToSeeIllustration({super.key});
  @override
  Widget build(BuildContext context) {
    // Usamos el color de la nube púrpura 9747FF (Veronica) para el avatar/ilustración
    return const Icon(Icons.cloud_off_rounded,
        size: 80, color: AppColors.veronica);
  }
}

// --- WIDGET PRINCIPAL ---

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  // Muestra el modal de Historial Completo (Pág 13)
  void _showFullActivity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullActivityModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityNotifierProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Icono de Notificaciones (Campana - Pág 24)
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppColors.textPrimary),
            onPressed: () {
              // Redirección al placeholder de notificaciones
              context.pushNamed(AppRoutes.notificationsName);
            },
          ),
        ],
      ),

      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Tarjeta de Billetera y Acciones (Pág 12/16)
                      const WalletCard(),

                      // 2. Título de Actividad Reciente
                      GestureDetector(
                        onTap: () => _showFullActivity(context),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),

                      // 3. Lista de Actividad Reciente o Vista Vacía
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: recentTransactions.isEmpty
                            ? const _EmptyActivityView()
                            : Column(
                                children: recentTransactions.map((tx) {
                                  return TransactionListItem(transaction: tx);
                                }).toList(),
                              ),
                      ),

                      const SizedBox(height: 80), // Espacio para la NavBar
                    ],
                  ),
                ),

      // 4. Barra de Navegación Inferior
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// Vista de "Actividad Vacía" (Página 12)
class _EmptyActivityView extends StatelessWidget {
  const _EmptyActivityView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const NothingToSeeIllustration(), // Placeholder para la ilustración de la nube
          const SizedBox(height: 16),
          Text(
            'YOUR WALLET IS READY! IT\'S BULUT TIME',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- MODAL DE HISTORIAL COMPLETO (Página 13, 14, 15) ---

class FullActivityModal extends ConsumerStatefulWidget {
  const FullActivityModal({super.key});

  @override
  ConsumerState<FullActivityModal> createState() => _FullActivityModalState();
}

class _FullActivityModalState extends ConsumerState<FullActivityModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Send', 'Receive', 'Subscriptions'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filtra las transacciones según la pestaña seleccionada
  List<TransactionModel> _getFilteredTransactions(String tab) {
    final allTransactions = ref.watch(activityNotifierProvider).transactions;

    switch (tab) {
      case 'Send':
        return allTransactions
            .where((tx) =>
                tx.type == TransactionType.sent ||
                tx.type == TransactionType.withdrawal)
            .toList();
      case 'Receive':
        return allTransactions
            .where((tx) =>
                tx.type == TransactionType.received ||
                tx.type == TransactionType.deposit ||
                tx.type == TransactionType.yieldGain)
            .toList();
      case 'Subscriptions':
        // Simulación: transacciones recurrentes (por su counterparty o tipo)
        return allTransactions
            .where((tx) =>
                tx.counterpartyAlias.contains('Lighthouse') ||
                tx.type == TransactionType.yieldGain)
            .toList();
      case 'All':
      default:
        return allTransactions;
    }
  }

  void _showInfographic() {
    // Muestra el modal de Infografía (Pág 15)
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        contentPadding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        content: _InfographicContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Column para asegurar que el TabBarView tome la altura restante
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
          // Header del Modal (Título, Icono de Info, Botón Cerrar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Spacer(),
                const Text('Activity',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                // Icono de Información (Pág 15)
                IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: _showInfographic,
                ),
                const Spacer(),
                // Botón Cerrar
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),

          // TabBar (Filtros - Pág 13)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.primary, // Verde agua si seleccionado
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),

          // Contenido de las Pestañas (Lista de Transacciones o Vista Vacía)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                final filteredTxs = _getFilteredTransactions(tab);

                return filteredTxs.isEmpty
                    ? const _EmptyTabView(
                        tabName: 'NOTHING TO SEE HERE') // Pág 14
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        itemCount: filteredTxs.length,
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

// Vista de Pestaña Vacía (Página 14)
class _EmptyTabView extends StatelessWidget {
  final String tabName;
  const _EmptyTabView({required this.tabName});

  @override
  Widget build(BuildContext context) {
    // Reutilizamos la ilustración, aunque el diseño de Pág 14 es solo texto.
    // Usaremos el diseño de Pág 12 (con la ilustración) ya que es más atractivo.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NothingToSeeIllustration(),
          const SizedBox(height: 16),
          Text(
            tabName,
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

// Contenido de la Infografía (Página 15)
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
            const Text('Infographic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const Divider(),
        _InfographicRow(
          icon: Icon(Icons.attach_money, color: AppColors.textPrimary),
          label: 'Single payment',
        ),
        _InfographicRow(
          icon: Icon(Icons.autorenew, color: AppColors.textPrimary),
          label: 'Subscription',
        ),
        _InfographicRow(
          icon: Icon(Icons.add, color: AppColors.primary),
          label: 'Income',
        ),
      ],
    );
  }
}

class _InfographicRow extends StatelessWidget {
  final Widget icon;
  final String label;

  const _InfographicRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 16),
          Text('→ $label', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
