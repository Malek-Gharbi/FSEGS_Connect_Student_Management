// --- Écran des Demandes de Documents ---
// Permet à l'étudiant de voir la liste de ses demandes de documents (Certificat, Relevé de notes, etc.)
// et d'en créer de nouvelles via un bouton flottant.

import 'package:flutter/material.dart';
import 'package:fsegs_connect/controllers/demande_document_controller.dart';
import 'package:fsegs_connect/models/demande_document.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/services/firestore_service.dart';
import 'package:fsegs_connect/models/etudiant.dart';
import 'package:fsegs_connect/main.dart';
import 'add_demande_document_screen.dart';

class DemandeDocumentScreen extends StatefulWidget {
  const DemandeDocumentScreen({super.key});

  @override
  State<DemandeDocumentScreen> createState() => _DemandeDocumentScreenState();
}

class _DemandeDocumentScreenState extends State<DemandeDocumentScreen> {
  final _controller = DemandeDocumentController();
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();
  
  List<DemandeDocument> _demandes = [];
  bool _isLoading = true;
  Etudiant? _currentEtudiant;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charge les demandes de l'utilisateur et ses informations de base
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Charger les informations de l'étudiant
    try {
      final infoDocs = await _firestoreService.getAll('etudiants');
      for (var doc in infoDocs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['email'] == user.email) {
          _currentEtudiant = Etudiant.fromMap(doc.id, data);
          break;
        }
      }
    } catch (e) {
      debugPrint('Warning: Could not load etudiant info: $e');
    }

    // Charger les demandes (Indépendant de l'info étudiant)
    try {
      _demandes = await _controller.getDemandesByUser(user.uid);
    } catch (e) {
      debugPrint('Error loading demandes: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Retourne une couleur associée au statut de la demande (Vert=Accepté, Rouge=Refusé, etc.)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepté': return Colors.green;
      case 'refusé': return Colors.red;
      case 'lu': return Colors.blue;
      case 'envoyé': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _demandes.isEmpty
                  ? _buildEmptyState()
                  : _buildDemandesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentEtudiant == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDemandeDocumentScreen(etudiant: _currentEtudiant!),
            ),
          );
          if (result == true) _loadData();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Pattern décoratif
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Titre et Description
          Positioned(
             bottom: 50,
             left: 24,
             right: 140, // Éviter l'image à droite
             child: const Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Mes Documents',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 SizedBox(height: 4),
                 Text(
                   'Suivez vos demandes en \n temps réel',
                   style: TextStyle(
                     color: Colors.white70,
                     fontSize: 14,
                   ),
                 ),
               ],
             ),
          ),

          // Image Docs.png
          Positioned(
            bottom: 0,
            right: 10,
            child: Image.asset(
              'assets/images/Docs.png',
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.description, size: 100, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }

  // État d'affichage lorsque aucune demande n'est encore créée
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_outlined, size: 80, color: AppColors.primaryBlue.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune demande effectuée',
            style: TextStyle(
              color: Color(0xFF10537F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Appuyez sur le bouton + pour commencer',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Construit la liste défilante des demandes sous forme de cartes
  Widget _buildDemandesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _demandes.length,
      itemBuilder: (context, index) {
        final demande = _demandes[index];
        final dateStr = '${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year}';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icône de document
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Color(0xFF1D9BB1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Détails de la demande
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            demande.typeDocument,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10537F),
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Envoyé le $dateStr',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(demande.statut).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        demande.statut.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(demande.statut),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Barre d'action si modifiable
              if (demande.statut == 'envoyé')
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBFE),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.05)),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDemandeDocumentScreen(
                              etudiant: _currentEtudiant!,
                              existingDemande: demande,
                            ),
                          ),
                        );
                        if (result == true) _loadData();
                      },
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_note, size: 20, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            const Text(
                              'Modifier mes informations',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
