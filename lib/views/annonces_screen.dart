import 'package:flutter/material.dart';
import 'package:fsegs_connect/controllers/annonces_controller.dart';
import 'package:fsegs_connect/models/annonce.dart';
import 'package:fsegs_connect/main.dart'; // For AppColors
import 'package:intl/intl.dart';

class AnnoncesScreen extends StatefulWidget {
  const AnnoncesScreen({super.key});

  @override
  State<AnnoncesScreen> createState() => _AnnoncesScreenState();
}

class _AnnoncesScreenState extends State<AnnoncesScreen> {
  final AnnonceController _controller = AnnonceController();
  List<Annonce> _annonces = [];
  bool _isLoading = true;
  DateTime? _selectedDate; // If null, show all (or handle as "All" logic if desired, or just load initial batch)

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  Future<void> _loadAnnonces() async {
    setState(() => _isLoading = true);
    try {
      List<Annonce> list;
      if (_selectedDate != null) {
        list = await _controller.getAnnoncesByDate(_selectedDate!);
      } else {
        list = await _controller.getAnnonces();
      }
      if (mounted) {
        setState(() {
          _annonces = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching annonces: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadAnnonces();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadAnnonces();
    }
  }

  void _clearFilter() {
    setState(() => _selectedDate = null);
    _loadAnnonces();
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
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _annonces.isEmpty
                      ? _buildEmptyState()
                      : _buildAnnoncesList(),
            ),
          ],
        ),
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
                   'Annonces',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 Text(
                   'Restez informé des \n dernières nouvelles',
                   style: TextStyle(
                     color: Colors.white.withOpacity(0.8),
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
              'assets/images/Annonces.png',
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.notifications, size: 80, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           // Today Button
           ElevatedButton.icon(
             onPressed: _filterToday,
             icon: const Icon(Icons.today, size: 18),
             label: const Text("Aujourd'hui"),
             style: ElevatedButton.styleFrom(
               backgroundColor: (_selectedDate != null && 
                   _selectedDate!.year == DateTime.now().year && 
                   _selectedDate!.month == DateTime.now().month && 
                   _selectedDate!.day == DateTime.now().day) 
                   ? AppColors.yellowGreen 
                   : Colors.white,
               foregroundColor: (_selectedDate != null && 
                   _selectedDate!.year == DateTime.now().year && 
                   _selectedDate!.month == DateTime.now().month && 
                   _selectedDate!.day == DateTime.now().day)
                   ? Colors.white 
                   : AppColors.primaryBlue,
               elevation: 2,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
             ),
           ),
           
           // Date Picker Button / "Dropdown" style
           InkWell(
             onTap: _selectDate,
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.calendar_month, size: 18, color: AppColors.primaryBlue),
                   const SizedBox(width: 8),
                   Text(
                     _selectedDate == null 
                         ? 'Filtrer par date' 
                         : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                     style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.w500),
                   ),
                   const SizedBox(width: 5),
                   const Icon(Icons.arrow_drop_down, color: AppColors.darkBlue),
                 ],
               ),
             ),
           ),
           
           if (_selectedDate != null)
             IconButton(
               icon: const Icon(Icons.close, size: 20, color: Colors.grey),
               onPressed: _clearFilter,
               tooltip: 'Effacer le filtre',
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            _selectedDate != null 
              ? 'Aucune annonce pour cette date.' 
              : 'Aucune annonce disponible.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnoncesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _annonces.length,
      itemBuilder: (context, index) {
        final annonce = _annonces[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16), // Padding inside the card
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              left: BorderSide(color: AppColors.primaryBlue, width: 4), // Notification style accent
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      annonce.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('dd MMM - HH:mm').format(annonce.datePublication),
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                annonce.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
