
// Affiche les notes de l'étudiant par matière et permet de calculer la moyenne semestrielle ou annuelle.

import 'package:flutter/material.dart';
import 'package:fsegs_connect/models/matiere.dart';
import 'package:fsegs_connect/models/etudiant_matiere.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/controllers/notes_controller.dart';
import 'package:fsegs_connect/main.dart'; // For AppColors

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _authService = FirebaseAuthService();
  final _notesController = NotesController();
  
  List<NoteDisplayItem> _notesList = [];
  bool _isLoading = true;
  double _moyenne = 0.0;
  bool _showMoyenne = false;
  
  // Variable d'état pour le filtrage par semestre ('Tous', 'S1', 'S2')
  String _selectedSemester = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Récupère les notes depuis le contrôleur en appliquant le filtre de semestre
  Future<void> _loadNotes() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _showMoyenne = false;
        });
      }

      final user = _authService.currentUser;
      if (user != null) {
        // Pass the selected semester filter to the controller
        final notes = await _notesController.getNotesForStudent(
          user.uid, 
          semestreFilter: _selectedSemester
        );
        
        if (mounted) {
          setState(() {
            _notesList = notes;
            _isLoading = false;
          });
        }
      } else {
         if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement notes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback / Demo data usage in case of error
           _loadDemoData();
        });
      }
    }
  }
// en cas d'erreur, charge des données de demo
  void _loadDemoData() {
    final m1 = Matiere(id: '101', ref: 'M001', nom: 'Développement Mobile', regime: 'Mixte', coefficient: 3.0, semestre: 'S1');
    final m2 = Matiere(id: '102', ref: 'M002', nom: 'Cloud Computing', regime: 'Mixte', coefficient: 2.0, semestre: 'S1');
    final mS2 = Matiere(id: '201', ref: 'M201', nom: 'Big Data', regime: 'Mixte', coefficient: 3.0, semestre: 'S2');

    List<NoteDisplayItem> demoList = [];

    // Simple manual filtering for demo data
    if (_shouldInclude('S1')) {
       demoList.add(NoteDisplayItem(matiere: m1, note: EtudiantMatiere(etudiantId: '1', matiereId: '101', noteControle: 14.5, noteSynthese: 16.0, absences: 0, presences: 10)));
       demoList.add(NoteDisplayItem(matiere: m2, note: null));
    }
    if (_shouldInclude('S2')) {
       demoList.add(NoteDisplayItem(matiere: mS2, note: EtudiantMatiere(etudiantId: '1', matiereId: '201', noteControle: 12.0, noteSynthese: 13.0, absences: 1, presences: 12)));
    }

    _notesList = demoList;
  }
  
  bool _shouldInclude(String semestre) {
    if (_selectedSemester == 'Tous') return true;
    return _selectedSemester == semestre;
  }

  // Calcule la moyenne via le contrôleur
  void _calculerMoyenne() {
    if (_notesList.isEmpty) return;

    final avg = _notesController.calculateAverage(_notesList, _selectedSemester);

    setState(() {
      _moyenne = avg;
      _showMoyenne = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 15),

              // Filter Chips
              _buildFilterChips(),

              const SizedBox(height: 10),
              
              // Liste des notes
              _isLoading 
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ))
                : _buildNotesList(),
                
              const SizedBox(height: 20),
              
              // Bouton Calculer Moyenne
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                    onPressed: _calculerMoyenne,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC3D540), // Yellow Green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _selectedSemester == 'Tous' 
                          ? 'Calculer Moyenne Annuelle' 
                          : 'Calculer Moyenne Semestrielle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                   ),
                ),
              ),
              
              // Affichage Moyenne
              if (_showMoyenne)
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D9BB1), Color(0xFF10537F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D9BB1).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedSemester == 'Tous' 
                            ? 'Moyenne Annuelle' 
                            : 'Moyenne Semestrielle ($_selectedSemester)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _moyenne.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _moyenne >= 10 ? 'Admis(e) 🎉' : 'Ajourné(e)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
               const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Barre de sélection du semestre (Tous, S1, S2)
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        // Use standard loops or map to avoid list type issues
        children: ['Tous', 'S1', 'S2'].map((semester) {
          final isSelected = _selectedSemester == semester;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                semester == 'Tous' ? 'Tout' : semester,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF10537F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1D9BB1),
              backgroundColor: Colors.white,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedSemester = semester;
                  });
                  _loadNotes(); // Reload notes with new filter
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Background patterns
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
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
          
          Positioned(
             bottom: 20,
             left: 20,
             right: 140, // Éviter l'image
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Mes Notes',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 Text(
                   'Consultation des résultats',
                   style: TextStyle(
                     color: Colors.white.withOpacity(0.8),
                     fontSize: 16,
                   ),
                 ),
               ],
             ),
          ),
          
          // Image decoratif
          Positioned(
            bottom: 0,
            right: 20,
            child: Image.asset(
              'assets/images/notes.png',
              height: 140, // Adjust size as needed based on bg height
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.note, size: 80, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Construit la liste des cartes de notes
  Widget _buildNotesList() {
    if (_notesList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("Aucune note disponible pour ce semestre."),
        ),
      );
    }
// affiche la liste des notes
    return ListView.builder(
      shrinkWrap: true, // Permet de ne pas faire défiler la liste
      physics: const NeverScrollableScrollPhysics(), // Empêche le défilement
      padding: const EdgeInsets.symmetric(horizontal: 20), // Ajoute un padding horizontal
      itemCount: _notesList.length,
      itemBuilder: (context, index) {
        final item = _notesList[index];
        final matiere = item.matiere;
        final note = item.note;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        matiere.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10537F),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF2F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Coef: ${matiere.coefficient}',
                        style: const TextStyle(
                          color: Color(0xFF1D9BB1),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (note != null) ...[ // si la note est disponible
                      Expanded(
                        child: _buildNoteItem('Contrôle', note.noteControle),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      Expanded(
                        child: _buildNoteItem('Examen/Synth', note.noteSynthese),
                      ),
                    ] else
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Pas de notes',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteItem(String label, double? note) {
    // Determine color based on note
    Color getColor(double n) {
      if (n >= 16) return Colors.green[700]!;
      if (n >= 10) return const Color(0xFF1D9BB1);
      if (n >= 8) return Colors.orange;
      return Colors.red;
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          note != null ? note.toStringAsFixed(2) : '-',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: note != null ? getColor(note) : Colors.black,
          ),
        ),
      ],
    );
  }
}
