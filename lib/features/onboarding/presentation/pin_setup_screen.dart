import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/features/onboarding/presentation/onboarding_screen.dart';

class _PinInputBox extends StatelessWidget {
  final bool filled;
  const _PinInputBox({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: filled ? AppColors.textPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary,
          width: 1.5,
        ),
      ),
    );
  }
}

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final int pinLength = 6;
  String _pin1 = '';
  String _pin2 = '';
  bool _isConfirming = false;
  bool _pinMatchError = false;

  void _handlePinInput(String text) {
    setState(() {
      if (!_isConfirming) {
        _pin1 = text;
        if (_pin1.length == pinLength) {
          _isConfirming = true;
          _pinMatchError = false;
        }
      } else {
        _pin2 = text;
        if (_pin2.length == pinLength) {
          _validateAndContinue();
        }
      }
    });
  }

  void _validateAndContinue() {
    if (_pin1 == _pin2) {
      context.goNamed(AppRoutes.aliasSetupName);
    } else {
      setState(() {
        _pinMatchError = true;
        _pin1 = '';
        _pin2 = '';
        _isConfirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs no coinciden. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _pin2 : _pin1;
    final title = _isConfirming ? 'Confirm' : 'Create\nyour PIN';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: _CloudClipper(),
            child: Container(
              height: 100,
              color: AppColors.primary.withOpacity(0.01),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pinLength, (index) {
              return _PinInputBox(filled: index < currentPin.length);
            }),
          ),
          if (_pinMatchError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Los PINs deben coincidir. Intenta de nuevo.',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.bold),
              ),
            ),
          const Spacer(),
          _NumericKeypad(
            onPinChanged: _handlePinInput,
            currentPinLength: currentPin.length,
            maxLength: pinLength,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onPinChanged;
  final int currentPinLength;
  final int maxLength;

  const _NumericKeypad({
    required this.onPinChanged,
    required this.currentPinLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    List<String> pinChars = List.generate(currentPinLength, (index) => '1');

    void _handleKeyPress(String key) {
      if (key == 'backspace') {
        if (pinChars.isNotEmpty) {
          pinChars.removeLast();
          onPinChanged(pinChars.join());
        }
      } else if (pinChars.length < maxLength) {
        pinChars.add(key);
        onPinChanged(pinChars.join());
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
              .map((key) => _KeypadButton(
                    text: key,
                    onPressed: () => _handleKeyPress(key),
                  )),
          const SizedBox.shrink(),
          _KeypadButton(text: '0', onPressed: () => _handleKeyPress('0')),
          _KeypadButton(
            icon: Icons.backspace_outlined,
            onPressed: () => _handleKeyPress('backspace'),
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 28, color: AppColors.textPrimary)
            : Text(
                text!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

class AliasSetupScreen extends ConsumerStatefulWidget {
  const AliasSetupScreen({super.key});

  @override
  ConsumerState<AliasSetupScreen> createState() => _AliasSetupScreenState();
}

class _AliasSetupScreenState extends ConsumerState<AliasSetupScreen> {
  final TextEditingController _controller = TextEditingController(text: '@');
  bool _isAliasValid = false;
  bool _isCheckingAlias = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateAlias);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateAlias);
    _controller.dispose();
    super.dispose();
  }

  void _validateAlias() async {
    final text = _controller.text;
    if (text.length <= 2) {
      setState(() => _isAliasValid = false);
      return;
    }
    if (!text.startsWith('@') || text.contains(' ')) {
      setState(() => _isAliasValid = false);
      return;
    }
    setState(() {
      _isCheckingAlias = true;
      _isAliasValid = false;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isCheckingAlias = false;
      _isAliasValid = text.toLowerCase() != '@admin';
    });
  }

  void _confirmAlias() {
    context.goNamed(AppRoutes.biometricsSetupName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    height: constraints.maxHeight * 0.35,
                    width: double.infinity,
                    color: AppColors.primary,
                    child: const Center(
                      child: Text(
                        'Choose your\nP2P alias',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: _CloudClipper(),
                    child: Container(
                      height: 100,
                      color: AppColors.primary.withOpacity(0.01),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This way, your friends and creators can find you and pay you commission-free.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                                height: 1.5),
                          ),
                          const SizedBox(height: 40),
                          TextField(
                            controller: _controller,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z0-9_@]*$')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Alias',
                              hintStyle:
                                  TextStyle(color: AppColors.textSecondary),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.textSecondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _isAliasValid
                                        ? AppColors.success
                                        : AppColors.danger,
                                    width: 2),
                              ),
                              suffixIcon: _isCheckingAlias
                                  ? const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    )
                                  : _isAliasValid
                                      ? Icon(Icons.check_circle,
                                          color: AppColors.success)
                                      : null,
                            ),
                            style: const TextStyle(
                                fontSize: 20, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your alias is not your private key. It's just a username.",
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAliasValid && !_isCheckingAlias
                                  ? _confirmAlias
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.disabled,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Confirm',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
