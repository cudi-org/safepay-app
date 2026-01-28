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
    // Ilustración estilo "Bulut" (Nube con personaje)
    // Como placeholder, usamos un diseño compuesto
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.nonPhotoBlue.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        Icon(Icons.cloud, size: 80, color: AppColors.nonPhotoBlue),
        Positioned(
          bottom: 20,
          child: Icon(Icons.person, size: 40, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// --- CURVED HEADER PAINTER ---
class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // Start from bottom-left (minus curve)

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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
      extendBodyBehindAppBar:
          true, // Permite que el cuerpo suba detrás del AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // El icono de notificación debe ser oscuro según el diseño, pero sobre fondo verde...
        // En el diseño parece negro/oscuro.
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, // Filled icon
                color: AppColors.textPrimary),
            onPressed: () {
              context.pushNamed(AppRoutes.notificationsName);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Fondo Curvo Verde
          ClipPath(
            clipper: _HeaderCurveClipper(),
            child: Container(
              height: 280, // Altura suficiente para el overlap
              width: double.infinity,
              color: AppColors.primary,
            ),
          ),

          // 2. Contenido Scrolleable (Tarjeta + Lista)
          state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: () => _refreshActivity(ref),
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          10,
                      bottom: 100, // Espacio para NavBar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Tarjeta de Billetera (Overlapping)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: WalletCard(),
                        ),

                        // 2. Título de Actividad Reciente
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
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
                              // Flecha oculta si está vacío, o siempre visible
                              if (recentTransactions.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _showFullActivity(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // 3. Lista de Actividad Reciente o Vista Vacía
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: recentTransactions.isEmpty
                              ? const _EmptyActivityView()
                              : Column(
                                  children: recentTransactions.map((tx) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child:
                                          TransactionListItem(transaction: tx),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
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
          const SizedBox(height: 40),
          const NothingToSeeIllustration(),
          const SizedBox(height: 24),
          const Text(
            'YOUR WALLET IS READY!\nIT\'S BULUT TIME',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textPrimary, // Texto Oscuro
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          // El diseño muestra el texto principal en mayúsculas y espaciado.
          // El subtítulo "Start by..." no aparece en el diseño proporcionado, pero lo mantenemos sutil.
        ],
      ),
    );
  }
}
