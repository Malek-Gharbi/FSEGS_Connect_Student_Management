import 'package:flutter/material.dart';
import 'package:fsegs_connect/controllers/demande_document_controller.dart';
import 'package:fsegs_connect/models/demande_document.dart';
import 'package:fsegs_connect/models/etudiant.dart';
import 'package:fsegs_connect/main.dart';
import 'package:fsegs_connect/services/firebase_auth_service.dart';

class AddDemandeDocumentScreen extends StatefulWidget {
  final Etudiant etudiant;
  final DemandeDocument? existingDemande;

  const AddDemandeDocumentScreen({super.key, required this.etudiant, this.existingDemande});

  @override
  State<AddDemandeDocumentScreen> createState() => _AddDemandeDocumentScreenState();
}

class _AddDemandeDocumentScreenState extends State<AddDemandeDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = DemandeDocumentController();
  final _authService = FirebaseAuthService();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  final _cinController = TextEditingController();
  final _groupeController = TextEditingController();
  
  String? _selectedDocument;
  bool _isLoading = false;

  final List<String> _documentModels = [
    'attestation de présence',
    'Carte etudiant',
    'attestation d\'incription',
    'Relevé de note',
    'attestation de réussite',
  ];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.etudiant.nom);
    _prenomController = TextEditingController(text: widget.etudiant.prenom);
    _emailController = TextEditingController(text: widget.etudiant.email);
    _telephoneController = TextEditingController(text: widget.etudiant.telephone);
    
    if (widget.existingDemande != null) {
      _cinController.text = widget.existingDemande!.cin;
      _groupeController.text = widget.existingDemande!.groupe;
      _selectedDocument = widget.existingDemande!.typeDocument;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _cinController.dispose();
    _groupeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDocument == null) {
      if (_selectedDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un document')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final demande = DemandeDocument(
        id: widget.existingDemande?.id,
        userId: user.uid,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        cin: _cinController.text,
        groupe: _groupeController.text,
        typeDocument: _selectedDocument!,
        dateDemande: widget.existingDemande?.dateDemande ?? DateTime.now(),
        statut: widget.existingDemande?.statut ?? 'envoyé',
      );

      if (widget.existingDemande != null) {
        await _controller.updateDemande(demande.id!, demande.toMap());
      } else {
        await _controller.createDemande(demande);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoField('Nom & Prénom', '${widget.etudiant.prenom} ${widget.etudiant.nom}'),
                      _buildInfoField('Email', widget.etudiant.email),
                      _buildInfoField('Téléphone', widget.etudiant.telephone),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 20),
                      
                      _buildLabel('Numéro CIN'),
                      _buildTextField(_cinController, 'Votre CIN', Icons.badge, keyboardType: TextInputType.number),
                      
                      _buildLabel('Groupe / Classe'),
                      _buildTextField(_groupeController, 'Ex: L1-BI-G1', Icons.group),
                      
                      _buildLabel('Type de document'),
                      _buildDropdown(),
                      
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.existingDemande != null ? 'Modifier la demande' : 'Envoyer la demande',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            left: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
             bottom: 30,
             left: 24,
             child: Text(
               widget.existingDemande != null ? 'Modifier Demande' : 'Nouvelle Demande',
               style: const TextStyle(
                 color: Colors.white,
                 fontSize: 28,
                 fontWeight: FontWeight.bold,
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10537F))),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10537F)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDocument,
          isExpanded: true,
          hint: const Text('Choisir un modèle'),
          items: _documentModels.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDocument = newValue;
            });
          },
        ),
      ),
    );
  }
}
