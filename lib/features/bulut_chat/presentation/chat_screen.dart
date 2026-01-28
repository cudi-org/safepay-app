import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart'; // Source of AppRoutes and CustomBottomNavBar

import 'package:safepay/features/bulut_chat/presentation/widgets/chat_message_bubble.dart';
import 'package:safepay/features/bulut_chat/providers/chat_notifier.dart';
import 'package:safepay/features/bulut_chat/models/chat_message_model.dart';

// El chat se implementa dentro de un widget de Shell para la navegación inferior

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha al provider para obtener la lista de mensajes
    final chatMessages = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background, // Fondo blanco para el chat
      // 1. App Bar (Personalizado - Página 28)
      appBar: const _CustomAppBar(), // Añadido 'const'

      // 2. Cuerpo del Chat
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false, // El ListView crece hacia abajo
              itemCount: chatMessages.length,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                // Usa el WIDGET importado 'ChatMessageBubble'
                return ChatMessageBubble(message: message);
              },
            ),
          ),

          // 3. Barra de Entrada de Mensajes (Input Bar)
          const _MessageInputBar(), // Ref se obtiene internamente
        ],
      ),

      // 4. Barra de Navegación Inferior (Página 28)
      // Esta es la clase que 'activity_screen.dart' necesita importar
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

// === WIDGETS AUXILIARES DE LA PANTALLA ===

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar(); // Añadido 'const'

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      toolbarHeight: 120, // Altura para el diseño curvo
      flexibleSpace: Stack(
        children: [
          // Fondo Verde Agua
          Container(color: AppColors.primary),

          // Curva de la Nube (Blanco)
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _CloudClipperInverse(), // Curva Inversa
              child: Container(height: 50, color: AppColors.background),
            ),
          ),

          // Contenido del App Bar (Logo y Opciones)
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_queue, // Añadido 'const'
                      size: 40,
                      color: Colors.white), // Logo de Nube
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, // Añadido 'const'
                        color: Colors.white,
                        size: 30),
                    onPressed: () {
                      // Opciones adicionales (e.g., Settings en el chat)
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}

// Clipper para la curva de la nube (Inversa para el App Bar)
class _CloudClipperInverse extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Barra de Entrada de Mensajes (Página 28)
class _MessageInputBar extends ConsumerStatefulWidget {
  const _MessageInputBar(); // No necesita 'ref' aquí

  @override
  ConsumerState<_MessageInputBar> createState() => __MessageInputBarState();
}

class __MessageInputBarState extends ConsumerState<_MessageInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      // Usamos 'ref' (disponible en ConsumerState) para leer el notifier
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
      _controller.clear();
      // Desenfocar el teclado después de enviar (opcional)
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 8 + MediaQuery.of(context).padding.bottom), // SafeArea
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono para la galería/archivos (88)
          const Icon(Icons.keyboard, color: AppColors.textSecondary),
          const SizedBox(width: 8),

          // Campo de Texto
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type your message',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          // Botón de Enviar (Avión de papel)
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: _sendMessage,
          ),

          // Botón de Micrófono
          const Icon(Icons.mic, color: AppColors.primary),
        ],
      ),
    );
  }
}

// La barra de navegación se importa desde features/home/presentation/widgets/custom_bottom_nav_bar.dart
