import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:fsegs_connect/controllers/diplome_controller.dart';
import 'package:fsegs_connect/models/diplome.dart';
import 'package:fsegs_connect/main.dart'; // For AppColors
import 'package:intl/intl.dart';

class DiplomesScreen extends StatefulWidget {
  const DiplomesScreen({super.key});

  @override
  State<DiplomesScreen> createState() => _DiplomesScreenState();
}

class _DiplomesScreenState extends State<DiplomesScreen> {
  final DiplomeController _controller = DiplomeController();
  List<Diplome> _allDiplomes = [];
  List<Diplome> _filteredDiplomes = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _loadDiplomes();
    _searchController.addListener(_filterDiplomes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDiplomes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDiplomes = _allDiplomes.where((d) {
        final matchesQuery = d.titre.toLowerCase().contains(query) ||
            d.etablissement.toLowerCase().contains(query);
        final matchesDate = _filterDate == null ||
            (d.dateObtention.year == _filterDate!.year &&
                d.dateObtention.month == _filterDate!.month &&
                d.dateObtention.day == _filterDate!.day);
        return matchesQuery && matchesDate;
      }).toList();
    });
  }

  Future<void> _loadDiplomes() async {
    setState(() => _isLoading = true);
    final list = await _controller.loadDiplomes();
    if (mounted) {
      setState(() {
        _allDiplomes = list;
        _filteredDiplomes = list; // Init filtered list
        _filterDiplomes(); // Apply filters if any
        _isLoading = false;
      });
    }
  }

  Future<void> _showDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _filterDate = picked;
        _filterDiplomes();
      });
    }
  }

  Future<void> _showDiplomeForm({Diplome? diplome}) async {
    final titleCtrl = TextEditingController(text: diplome?.titre ?? '');
    final etabCtrl = TextEditingController(text: diplome?.etablissement ?? '');
    DateTime selectedDate = diplome?.dateObtention ?? DateTime.now();
    String? selectedFilePath = diplome?.pdfPath;
    String? pickedNewPath;

    await showDialog( // pour afficher un dialog de modification d'un diplome ou de creation d'un nouveau diplome
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    diplome == null ? 'Ajouter un Diplôme' : 'Modifier Diplôme',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Titre du diplôme',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.school, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: etabCtrl,
                    decoration: InputDecoration(
                      labelText: 'Établissement',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.apartment, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) {
                        setState(() => selectedDate = d);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date d\'obtention',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (!kIsWeb) ...[
                    // File picking only on non-web or handle differently
                    OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _controller.pickPdfFile();
                        if (path != null) {
                          setState(() => pickedNewPath = path);
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        (pickedNewPath != null)
                            ? 'Fichier sélectionné'
                            : (selectedFilePath != null ? 'Changer le PDF' : 'Ajouter un PDF (Optionnel)'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.yellowGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (titleCtrl.text.isEmpty || etabCtrl.text.isEmpty) return;

                          if (diplome == null) {
                            await _controller.addDiplome(
                              titre: titleCtrl.text,
                              etablissement: etabCtrl.text,
                              date: selectedDate,
                              filePath: pickedNewPath ?? selectedFilePath,
                            );
                          } else {
                            final updated = Diplome(
                              id: diplome.id,
                              titre: titleCtrl.text,
                              etablissement: etabCtrl.text,
                              dateObtention: selectedDate,
                              pdfPath: pickedNewPath ?? selectedFilePath,
                            );
                            await _controller.updateDiplome(updated, newFilePath: pickedNewPath);
                          }

                          if (mounted) {
                            Navigator.of(ctx).pop();
                            _loadDiplomes();
                          }
                        },
                        child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDiplome(int id) async {
     // Show confirmation dialog? Or just simple confirm
     bool confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(
       title: const Text('Confirmer la suppression'),
       content: const Text('Voulez-vous vraiment supprimer ce diplôme ?'),
       actions: [
         TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
         TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
       ],
     )) ?? false;

     if (confirm) {
       await _controller.deleteDiplome(id);
       _loadDiplomes();
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
            const SizedBox(height: 20),
            _buildActionRow(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDiplomes.isEmpty
                      ? _buildEmptyState()
                      : _buildDiplomesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded( // pour que le champ de recherche prenne toute la largeur de la ligne
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.lightBlue1.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // pour que le champ de recherche prenne toute la largeur de la ligne
                  suffixIcon: _filterDate != null // pour afficher un bouton de suppression de la date de filtre
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _filterDate = null;
                            _filterDiplomes();
                          });
                        },
                      )
                    : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
             icon: Icon(Icons.filter_list, color: _filterDate != null ? AppColors.yellowGreen : AppColors.primaryBlue),
             onPressed: _showDateFilter,
             tooltip: "Filtrer par date",
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            onPressed: () => _showDiplomeForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellowGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), // Pill shape
            ),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            'Aucun diplôme trouvé.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
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
             bottom: 25,
             left: 20,
             right: 140, // Éviter l'image
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Mes Diplômes',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 Text(
                   'Certifications & Accréditations',
                   style: TextStyle(
                     color: Colors.white.withOpacity(0.8),
                     fontSize: 16,
                   ),
                 ),
               ],
             ),
          ),
          
          Positioned(
            bottom: 0, // Align exactly at bottom like in NotesScreen
            right: 20, // Same padding
            child: Image.asset(
              'assets/images/diplomes.png',
              height: 140, // Match height of NotesScreen image
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 80, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiplomesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredDiplomes.length,
      itemBuilder: (context, index) {
        final dip = _filteredDiplomes[index];
        return Container( // Used Container for custom decoration to match image perfectly if needed, but Card is easier
          margin: const EdgeInsets.only(bottom: 15), // pour ajouter un margin en bas
          decoration: BoxDecoration(
            color: AppColors.primaryBlue, // #1D9BB1
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon placeholder (Graduation Cap)
                    Container(
                      padding: const EdgeInsets.all(10),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.2), 
                      //   borderRadius: BorderRadius.circular(15)
                      // ),
                      child: const Icon(Icons.school, size: 50, color: AppColors.darkBlue), // Using dark blue outline as in image concept
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dip.titre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dip.etablissement, // Used as ID or Subtitle
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Date d\'obtention : ${DateFormat('dd/MM/yy').format(dip.dateObtention)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _showDiplomeForm(diplome: dip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.yellowGreen, // #C3D540
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text('Modifier', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _deleteDiplome(dip.id!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent, // Red for delete
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
}
