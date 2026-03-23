import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/widgets/app_logo.dart';
import '../../../../core/services/sqlite_service.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../eventos_agricolas/data/repositories/eventos_repository.dart';
import '../../../lotes/domain/models/lote.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthRepository _authRepository = AuthRepository();
  final DashboardRepository _dashboardRepo = DashboardRepository();
  final EventosRepository _eventosRepo = EventosRepository();

  int _currentIndex = 0; 

  String _nombreProductor = 'Productor';
  int _prediosCount = 0;
  int _lotesCount = 0;
  int _informesCount = 0; 
  List<Lote> _lotesRecientes = [];
  List<Lote> _todosLotesActivos = []; // NUEVO: Para el selector rápido
  
  bool _isLoading = true;
  bool _isOffline = false;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;
  bool _isLoggingOut = false;
  
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _setupConnectivity();
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  void _setupConnectivity() {
    Connectivity().checkConnectivity().then(_updateConnection);
    _connectivitySub = Connectivity().onConnectivityChanged.listen(_updateConnection);
  }

  void _updateConnection(List<ConnectivityResult> result) {
    if (!mounted) return;
    final isOffline = result.contains(ConnectivityResult.none);
    setState(() => _isOffline = isOffline);
    if (!isOffline && _pendingSyncCount > 0 && !_isSyncing) {
      _syncNow();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final data = await _dashboardRepo.getProductor(user.uid);
        final predios = await _dashboardRepo.countPredios(user.uid);
        final lotes = await _dashboardRepo.countLotesActivos(user.uid);
        final recientes = await _dashboardRepo.getLotesRecientes(user.uid);
        final todosActivos = await _dashboardRepo.getActiveLotes(user.uid); // Carga para el selector
        final pending = await _eventosRepo.getPendingSyncCount();

        if (mounted) {
          setState(() {
            _nombreProductor = data?.nombreCompleto.split(' ')[0] ?? 'Productor';
            _prediosCount = predios;
            _lotesCount = lotes;
            _lotesRecientes = recientes;
            _todosLotesActivos = todosActivos;
            _pendingSyncCount = pending;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncNow() async {
    if (_isOffline) return;
    setState(() => _isSyncing = true);
    try {
      await _eventosRepo.syncPendingEvents();
      final count = await _eventosRepo.getPendingSyncCount();
      if (mounted) setState(() => _pendingSyncCount = count);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await SqliteService().clearDatabase();
      await _authRepository.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No fue posible cerrar sesión')));
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  // ==========================================================
  // NUEVO: LÓGICA DEL SELECTOR RÁPIDO DE LOTES
  // ==========================================================
  void _seleccionarLoteParaEvento(String rutaDestino) {
    if (_todosLotesActivos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes lotes activos. Crea uno en "Predios" primero.')),
      );
      return;
    }

    // ¡Súper UX! Si solo tiene un lote, no le preguntamos, lo mandamos directo.
    if (_todosLotesActivos.length == 1) {
      Navigator.pushNamed(context, rutaDestino, arguments: _todosLotesActivos.first).then((_) => _checkSyncAfterReturn());
      return;
    }

    // Si tiene varios, mostramos un BottomSheet elegante
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿A qué lote desea registrar el evento?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _todosLotesActivos.length,
                    itemBuilder: (context, index) {
                      final lote = _todosLotesActivos[index];
                      return ListTile(
                        leading: const Icon(Icons.landscape, color: Color(0xFF2E7D32)),
                        title: Text(lote.nombreLote, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${lote.especieVegetalActual} · ${lote.areaHectareas} ha'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context); // Cierra el modal
                          Navigator.pushNamed(context, rutaDestino, arguments: lote).then((_) => _checkSyncAfterReturn());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkSyncAfterReturn() async {
    final count = await _eventosRepo.getPendingSyncCount();
    if (mounted) setState(() => _pendingSyncCount = count);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const primary = Color(0xFF2E7D32);
    const text = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppLogo(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Inicio', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 20)),
            Text('Resumen del productor', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: text),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(primary),
                  const SizedBox(height: 16),

                  if (_isOffline || _pendingSyncCount > 0) _buildOfflineCard(),
                  if (_isOffline || _pendingSyncCount > 0) const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Acciones rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/predios'),
                        child: const Text('Ver todo', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  const Text('Lotes recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 12),
                  ..._lotesRecientes.map((lote) => _buildLoteCard(lote, primary)),
                  if (_lotesRecientes.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay lotes registrados.'))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/predios');
          if (index == 2 || index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo próximamente disponible')));
          }
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.landscape_outlined), label: 'Predios'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Informes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  // --- WIDGETS PRIVADOS ---

  Widget _buildHeaderCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_pendingSyncCount > 0 ? Icons.sync : Icons.sync_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _pendingSyncCount > 0 ? '$_pendingSyncCount cambios pendientes' : 'Sincronizado',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _isLoggingOut ? null : _logout,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: _isLoggingOut 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Hola, $_nombreProductor', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
            'Hoy puede registrar actividades del lote y completar el informe ICA vigente.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatBox('Predios', _prediosCount.toString()),
              const SizedBox(width: 12),
              _buildStatBox('Lotes\nactivos', _lotesCount.toString()),
              const SizedBox(width: 12),
              _buildStatBox('Informes\nICA', _informesCount.toString()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineCard() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/sync_queue'), // ¡Navega a la cola!
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOffline ? 'Modo de demostración offline' : 'Sincronización pendiente',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Si no hay internet, sus datos quedan guardados. Toque aquí para ver la cola.', // Texto actualizado
                    style: TextStyle(color: Colors.orange.shade800, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        // Textos y estilos EXACTOS a tu imagen de referencia
        _buildActionCard('Registrar siembra', 'Guarde fecha, especie, variedad y área sembrada.', Icons.grass, () => _seleccionarLoteParaEvento('/eventos/crear_siembra')),
        _buildActionCard('Registrar insumo', 'Agregue dosis, método, responsable y motivo.', Icons.science_outlined, () => _seleccionarLoteParaEvento('/eventos/crear_insumo')),
        _buildActionCard('Registrar cosecha', 'Documente cantidad, área y destino de producción.', Icons.shopping_basket_outlined, () => _seleccionarLoteParaEvento('/eventos/crear_cosecha')),
        _buildActionCard('Crear informe ICA', 'Inicie el flujo trisemestral del lote.', Icons.description_outlined, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')))),
      ],
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, VoidCallback onTap) {
    const iconBg = Color(0xFFF4F7F2); // Fondo verde muy claro
    const iconColor = Color(0xFF2E7D32); // Verde AgroTrack
    const titleColor = Color(0xFF001F3F); // Azul marino muy oscuro

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD7DED3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: titleColor)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildLoteCard(Lote lote, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7DED3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lote.nombreLote, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lote.estadoLote == 'ACTIVO' ? const Color(0xFFEAF4E7) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lote.estadoLote, 
                  style: TextStyle(color: lote.estadoLote == 'ACTIVO' ? primary : Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${lote.especieVegetalActual} · ${lote.areaHectareas} ha',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/lotes/detail', arguments: lote),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Abrir lote'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ver informe'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}