// --- Écran des Absences ---
// Permet de suivre le nombre d'absences par matière. 
// Utilise des codes couleurs (Rouge, Orange, Vert) pour alerter l'étudiant selon la gravité.

import 'package:flutter/material.dart';
import 'package:fsegs_connect/controllers/absence_controller.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';
import 'package:fsegs_connect/main.dart'; // For AppColors

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  final _authService = FirebaseAuthService();
  final _absenceController = AbsenceController();
  
  List<AbsenceDisplayItem> _allAbsences = []; // Full list fetched
  List<AbsenceDisplayItem> _filteredAbsences = []; // List to display
  
  bool _isLoading = true;
  String _selectedSemester = 'Tous';
  String _selectedStatus = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyLocalFilters();
      });
    });
  }

  // Charge les données d'absences depuis le service distant
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final data = await _absenceController.getAbsencesForStudent(
          user.uid, 
          semestreFilter: _selectedSemester
        );
        
        if (mounted) {
          setState(() {
            _allAbsences = data;
            _applyLocalFilters();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading absences: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Applique les filtres de recherche et de statut localement
  void _applyLocalFilters() {
    // Controller helper handled standard logic, but let's do it here or call controller
    _filteredAbsences = _absenceController.filterAbsences(
      _allAbsences, 
      _searchQuery, 
      _selectedStatus
    );
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
              child: SingleChildScrollView( // pour permettre le scroll
                child: Column(
                  children: [
                   const SizedBox(height: 20),
                   _buildSearchBar(),
                   const SizedBox(height: 15),
                   _buildFilters(),
                   const SizedBox(height: 20),
                   _isLoading 
                     ? const Center(child: CircularProgressIndicator())
                     : _buildGrid(),
                   const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
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
             bottom: 25,
             left: 20,
             right: 140, // Éviter l'image
             child: const Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Absences',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 Text(
                   'Suivi de présence',
                   style: TextStyle(
                     color: Colors.white70,
                     fontSize: 16,
                   ),
                 ),
               ],
             ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: Image.asset(
              'assets/images/Absences.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.access_time_filled, size: 80, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.1),
               blurRadius: 10,
               offset: const Offset(0, 5),
             ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher une matière...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  // Section des puces de filtrage (Semestre et Statut d'alerte)
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semester Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['Tous', 'S1', 'S2'].map((semester) {
              final isSelected = _selectedSemester == semester;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(semester == 'Tous' ? 'Tout Sem' : semester),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1D9BB1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF10537F),
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.white,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                         _selectedSemester = semester;
                      });
                      _loadData(); // Re-fetch because this changes list content fundamentally
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        // Status Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['Tous', '> 4', '2 - 4', '0 Absences'].map((status) {
              final isSelected = _selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: const Color(0xFFF7B940),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                     color: isSelected ? Colors.white : Colors.grey[700],
                     fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                  onSelected: (bool selected) {
                     setState(() {
                       _selectedStatus = selected ? status : 'Tous'; // Toggle off returns to Tous? Or prevent verify false.
                       if (!selected) _selectedStatus = 'Tous';
                       _applyLocalFilters();
                     });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    if (_filteredAbsences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("Aucun résultat trouvé.")),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75, // Taller cards
        ),
        itemCount: _filteredAbsences.length,
        itemBuilder: (context, index) {
          final item = _filteredAbsences[index];
          final absences = item.data?.absences ?? 0;
          final presences = item.data?.presences ?? 0;
          
          return _buildAbsenceCard(item.matiere.nom, absences, presences);
        },
      ),
    );
  }

  // Widget de carte individuelle pour chaque matière avec indicateurs colorés
  Widget _buildAbsenceCard(String matiereNom, int absences, int presences) {
    // Logic for styling
    // > 4 : Red
    // > 2 && < 4 (i.e. 3? and 4? prompt said <4 & >2, later said range 2-4. I will treat >=3 && <=4 as Warning)
    // 0 : Green
    
    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black87;
    String statusMessage = "";
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    if (absences > 4) {
      borderColor = Colors.red.shade200;
      cardColor = Colors.red.shade50;
      statusMessage = "Limite atteinte !";
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
    } else if (absences > 2) { // Covers 3 and 4
      borderColor = Colors.orange.shade200;
      cardColor = Colors.orange.shade50;
      statusMessage = "Attention !";
      statusColor = Colors.orange.shade800;
      statusIcon = Icons.priority_high_rounded;
    } else if (absences == 0) {
      borderColor = Colors.green.shade200;
      cardColor = Colors.green.shade50;
      statusMessage = "Parfait";
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
    } else {
      // 1 or 2 absences
      borderColor = Colors.blue.shade100;
      cardColor = Colors.white;
      statusMessage = "Normal";
      statusColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Expanded(
            child: Text(
              matiereNom,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Stats Row
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 children: [
                   const Icon(Icons.person_off, size: 20, color: Colors.redAccent),
                   Text('$absences', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const Text('Abs', style: TextStyle(fontSize: 10, color: Colors.grey)),
                 ],
               ),
               Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
               Column(
                 children: [
                   const Icon(Icons.person, size: 20, color: Colors.green),
                   Text('$presences', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const Text('Prés', style: TextStyle(fontSize: 10, color: Colors.grey)),
                 ],
               ),
             ],
          ),
          
          const SizedBox(height: 10),
          Divider(color: statusColor.withOpacity(0.2)),
          
          // Status Msg
          Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
