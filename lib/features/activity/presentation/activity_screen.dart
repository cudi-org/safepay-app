import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/core/constants/app_colors.dart'; // Needed for AppColors
import 'package:safepay/features/activity/providers/activity_notifier.dart'; // Added for activityNotifierProvider
import 'package:safepay/features/activity/presentation/widgets/full_activity_modal.dart';
import 'package:safepay/features/activity/presentation/widgets/wallet_card.dart';
import 'package:safepay/features/activity/presentation/widgets/transaction_list_item.dart';

class NothingToSeeIllustration extends StatelessWidget {
  const NothingToSeeIllustration({super.key});
  @override
  Widget build(BuildContext context) {
    // Usamos el color de la nube púrpura 9747FF (Veronica) para el avatar/ilustración
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.veronica.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.cloud_off_rounded,
          size: 60, color: AppColors.veronica),
    );
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

  Future<void> _refreshActivity(WidgetRef ref) async {
    // Forzamos una recarga del estado
    await ref.read(activityNotifierProvider.notifier).fetchActivity();
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
            icon: const Icon(Icons.notifications_none_rounded,
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
          : RefreshIndicator(
              onRefresh: () => _refreshActivity(ref),
              color: AppColors.primary,
              backgroundColor: AppColors.backgroundLight,
              child: state.errorMessage != null
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Center(child: Text(state.errorMessage!)),
                        )
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Tarjeta de Billetera y Acciones (Pág 12/16)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: WalletCard(),
                          ),

                          // 2. Título de Actividad Reciente
                          GestureDetector(
                            onTap: () => _showFullActivity(context),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 32, 24, 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 3. Lista de Actividad Reciente o Vista Vacía
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: recentTransactions.isEmpty
                                ? const _EmptyActivityView()
                                : Column(
                                    children: recentTransactions.map((tx) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: TransactionListItem(
                                            transaction: tx),
                                      );
                                    }).toList(),
                                  ),
                          ),

                          const SizedBox(height: 100), // Espacio para la NavBar
                        ],
                      ),
                    ),
            ),
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
          const SizedBox(height: 20),
          const NothingToSeeIllustration(), // Placeholder para la ilustración de la nube
          const SizedBox(height: 16),
          const Text(
            'YOUR WALLET IS READY!\nIT\'S BULUT TIME',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding funds or making a request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
