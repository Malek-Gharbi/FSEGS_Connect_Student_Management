import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/message_contact_controller.dart';
import '../models/message_contact.dart';
import '../services/firebase_auth_service.dart';
import '../main.dart'; // For AppColors
import 'add_message_contact_screen.dart';
import 'message_detail_screen.dart';

class MessageContactScreen extends StatefulWidget {
  const MessageContactScreen({super.key});

  @override
  State<MessageContactScreen> createState() => _MessageContactScreenState();
}

class _MessageContactScreenState extends State<MessageContactScreen> {
  final _controller = MessageContactController();
  final _authService = FirebaseAuthService();
  
  List<MessageContact> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _messages = await _controller.getMessagesByUser(user.uid);
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'répondu': return Colors.green;
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
              child: RefreshIndicator(
                onRefresh: _loadMessages,
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement
                  : _messages.isEmpty
                    ? _buildEmptyState() // Affiche un état vide si aucun message n'est trouvé
                    : _buildMessagesList(), // Affiche la liste des messages
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMessageContactScreen(), // Ouvre l'écran d'ajout de message
            ),
          );
          if (result == true) _loadMessages(); // recharge la liste des messages
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.edit, color: Colors.white),
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

          Positioned(
             bottom: 50,
             left: 24,
             right: 140,
             child: const Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Contact Admin',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 26,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 SizedBox(height: 4),
                 Text(
                   'Envoyez vos demandes aux services administratifs',
                   style: TextStyle(
                     color: Colors.white70,
                     fontSize: 14,
                   ),
                 ),
               ],
             ),
          ),

          Positioned(
            bottom: 0,
            right: 10,
            child: Image.asset(
              'assets/images/contact.png.png',
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.mail_outline_rounded, size: 150, color: Colors.white.withOpacity(0.15)),
            ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mail_outline, size: 80, color: AppColors.primaryBlue.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun message envoyé',
            style: TextStyle(
              color: Color(0xFF10537F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contactez un service administratif',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final dateStr = DateFormat('dd MMM').format(message.dateEnvoi);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageDetailScreen(message: message),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: _getStatutColor(message.statut).withOpacity(0.1),
              child: Icon(
                message.statut == 'répondu' ? Icons.reply : Icons.send_rounded,
                color: _getStatutColor(message.statut),
                size: 20,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message.destinataire,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  message.objet,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  message.body,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}
