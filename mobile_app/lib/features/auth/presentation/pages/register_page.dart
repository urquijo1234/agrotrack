import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/core/widgets/app_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AuthRepository();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su nombre completo';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su correo electrónico';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _repository.register(
        nombreCompleto: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        telefono: _phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada correctamente'),
        ),
      );

      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'No fue posible completar el registro';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido';
          break;
        case 'weak-password':
          message = 'La contraseña es demasiado débil';
          break;
        case 'network-request-failed':
          message = 'Sin conexión. Verifique su red e intente de nuevo';
          break;
        case 'user-null':
          message = 'No fue posible obtener el usuario registrado';
          break;
        default:
          message = 'Ocurrió un error al crear la cuenta';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String message = 'No fue posible guardar la información del productor';

      switch (e.code) {
        case 'permission-denied':
          message = 'No hay permisos para guardar la información del productor';
          break;
        case 'unavailable':
          message = 'Firestore no está disponible en este momento';
          break;
        default:
          message = 'Error al guardar la información del productor';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e, stackTrace) {
  debugPrint('ERROR INESPERADO EN REGISTRO: $e');
  debugPrintStack(stackTrace: stackTrace);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Ocurrió un error inesperado: $e'),
    ),
  );
} finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: text,
        title: const Text(
          'Registro',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AppLogo(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Registrese productor para comenzar.',
                            style: TextStyle(
                              fontSize: 15,
                              color: softText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                AuthTextField(
                  label: 'Nombre completo',
                  controller: _fullNameController,
                  hintText: '',
                  validator: _validateFullName,
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  label: 'Teléfono (opcional)',
                  controller: _phoneController,
                  hintText: '',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  label: 'Correo electrónico',
                  controller: _emailController,
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  hintText: '********',
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                AuthTextField(
                  label: 'Confirmar contraseña',
                  controller: _confirmPasswordController,
                  hintText: '********',
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('¿Ya tiene cuenta? Iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}