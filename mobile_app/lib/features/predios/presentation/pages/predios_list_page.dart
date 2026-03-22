import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/predios_repository.dart';
import '../../domain/models/predio.dart';
import '../widgets/predio_card.dart';
import '../widgets/predios_empty_state.dart';

class PrediosListPage extends StatefulWidget {
  const PrediosListPage({super.key});

  @override
  State<PrediosListPage> createState() => _PrediosListPageState();
}

class _PrediosListPageState extends State<PrediosListPage> {
  final PrediosRepository _repository = PrediosRepository();

  late Future<List<Predio>> _futurePredios;

  List<Predio> _allPredios = [];
  List<Predio> _filteredPredios = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPredios();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadPredios() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    _futurePredios = _repository.getPrediosByProductor(user.uid);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPredios = _allPredios
          .where((p) =>
              p.nombrePredio.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _goToCreatePredio() async {
    final created =
        await Navigator.pushNamed(context, '/predios/create');

    if (created == true) {
      setState(() {
        _loadPredios();
      });
    }
  }

  Future<void> _goToPredioDetail(Predio predio) async {
  final result = await Navigator.pushNamed(
    context,
    '/predios/detail',
    arguments: predio,
  );

  if (!mounted) return;

  if (result is Predio) {
    setState(() {
      final index =
          _allPredios.indexWhere((item) => item.predioId == result.predioId);

      if (index != -1) {
        _allPredios[index] = result;
      }

      final filteredIndex =
          _filteredPredios.indexWhere((item) => item.predioId == result.predioId);

      if (filteredIndex != -1) {
        _filteredPredios[filteredIndex] = result;
      }
    });
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);
    const border = Color(0xFFD7DED3);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Predios'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Subtítulo
            const Text(
              'Fincas registradas',
              style: TextStyle(
                fontSize: 14,
                color: softText,
              ),
            ),

            const SizedBox(height: 14),

            /// Buscador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar predio',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: border),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Lista
            Expanded(
              child: FutureBuilder<List<Predio>>(
                future: _futurePredios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar predios'),
                    );
                  }

                  _allPredios = snapshot.data ?? [];

                  /// Si no hay búsqueda, usar todos
                  if (_searchController.text.isEmpty) {
                    _filteredPredios = _allPredios;
                  }

                  if (_filteredPredios.isEmpty) {
                    return PrediosEmptyState(
                      onCreate: _goToCreatePredio,
                    );
                  }

                  return ListView.builder(
                    itemCount: _filteredPredios.length,
                    itemBuilder: (context, index) {
                      final predio = _filteredPredios[index];

                      return PredioCard(
  predio: predio,
  onTap: () => _goToPredioDetail(predio),
);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FloatingActionButton.extended(
            onPressed: _goToCreatePredio,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Crear predio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}