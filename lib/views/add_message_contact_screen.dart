import 'package:flutter/material.dart';
import '../controllers/message_contact_controller.dart';
import '../models/message_contact.dart';
import '../services/firebase_auth_service.dart';
import '../main.dart'; // For AppColors

class AddMessageContactScreen extends StatefulWidget {
  const AddMessageContactScreen({super.key});

  @override
  State<AddMessageContactScreen> createState() => _AddMessageContactScreenState();
}

class _AddMessageContactScreenState extends State<AddMessageContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = MessageContactController();
  final _authService = FirebaseAuthService();

  final _objetController = TextEditingController();
  final _bodyController = TextEditingController();
  
  String? _selectedDestinataire;
  bool _isLoading = false;

  final List<String> _destinataires = [
    'Service de scolarité',
    'Service des examens',
    'Service des emplois du temps',
    'Service des certificats',
    'Bureau d’ordre',
    'Service des archives',
    'Service des stages',
    'Service médical universitaire',
    'Cellule de réclamation',
  ];

  @override
  void dispose() {
    _objetController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDestinataire == null) {
      if (_selectedDestinataire == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un destinataire')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final message = MessageContact(
        userId: user.uid,
        objet: _objetController.text,
        body: _bodyController.text,
        destinataire: _selectedDestinataire!,
        dateEnvoi: DateTime.now(),
      );

      await _controller.sendMessage(message);

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
                      _buildLabel('Destinataire'),
                      _buildDropdown(),
                      const SizedBox(height: 20),
                      
                      _buildLabel('Objet'),
                      _buildTextField(_objetController, 'Objet du message', Icons.subject),
                      
                      _buildLabel('Message'),
                      _buildTextField(_bodyController, 'Écrivez votre message ici...', Icons.message, maxLines: 8),
                      
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
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Envoyer le message',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const Positioned(
             bottom: 30,
             left: 24,
             child: Text(
               'Nouveau Message',
               style: TextStyle(
                 color: Colors.white,
                 fontSize: 28,
                 fontWeight: FontWeight.bold,
               ),
             ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: Icon(Icons.send_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
          ),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 15.0) : 0),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
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
          value: _selectedDestinataire,
          isExpanded: true,
          hint: const Text('Choisir un service'),
          items: _destinataires.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDestinataire = newValue;
            });
          },
        ),
      ),
    );
  }
}
