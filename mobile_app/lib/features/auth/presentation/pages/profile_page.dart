import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/sqlite_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/productor.dart';
import '../../../home/data/repositories/dashboard_repository.dart';
// Asegúrate de que esta ruta apunte a donde tienes tu módulo de predios
import '../../../predios/data/repositories/predios_repository.dart';
import '../../../predios/domain/models/predio.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = AuthRepository();
  final DashboardRepository _dashboardRepo = DashboardRepository();
  final PrediosRepository _prediosRepo = PrediosRepository();
  
  Productor? _productor;
  List<Predio> _predios = [];
  
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Cargamos tanto los datos del productor como su lista de predios
      final productorData = await _dashboardRepo.getProductor(user.uid);
      final prediosData = await _prediosRepo.getPrediosByProductor(user.uid);
      
      if (mounted) {
        setState(() {
          _productor = productorData;
          _predios = prediosData;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Está seguro de que desea salir de AgroTrack?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoggingOut = true);
      try {
        await SqliteService().clearDatabase();
        await _authRepository.logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cerrar sesión')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const text = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: text,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(primary),
                  const SizedBox(height: 24),
                  
                  // Sección de contacto (Sin la cédula)
                  _buildContactSection(),
                  const SizedBox(height: 24),
                  
                  // Nueva sección de Predios
                  const Text('Mis Predios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 12),
                  _buildPrediosList(),
                  
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Color primary) {
    final inicial = _productor?.nombreCompleto[0].toUpperCase() ?? 'P';
    
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: primary,
            child: Text(
              inicial,
              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _productor?.nombreCompleto ?? 'Cargando...',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _productor?.estadoCuenta ?? 'ACTIVO',
              style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7DED3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos de contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone_outlined, 'Teléfono', _productor?.telefono ?? 'No registrado'),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.email_outlined, 'Correo electrónico', _productor?.correo ?? '---'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1F2937))),
          ],
        ),
      ],
    );
  }

  Widget _buildPrediosList() {
    if (_predios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD7DED3), style: BorderStyle.solid),
        ),
        child: const Text(
          'Aún no tiene predios registrados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return Column(
      children: _predios.map((predio) {
        final veredaText = (predio.vereda != null && predio.vereda!.isNotEmpty) 
            ? ' • Vereda: ${predio.vereda}' 
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD7DED3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F7F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.landscape, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predio.nombrePredio,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${predio.municipio}, ${predio.departamento}$veredaText',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}