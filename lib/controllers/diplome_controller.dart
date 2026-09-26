import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fsegs_connect/models/diplome.dart';
import 'package:fsegs_connect/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

class DiplomeController {
  final DatabaseService _dbService = DatabaseService.instance;
//récupérer toutes les diplomes en utilisant le service de base de données (SQLite)
  Future<List<Diplome>> loadDiplomes() async {
    return await _dbService.readAllDiplomes();
  }
//ajouter un diplome
  Future<void> addDiplome({
    required String titre,
    required String etablissement,
    required DateTime date,
    String? filePath,
  }) async {
    String? localPath;
    
    // Si un fichier est sélectionné, on le copie dans le dossier de l'app pour persistence 
    if (filePath != null && !kIsWeb) {
      try {
        final File selectedFile = File(filePath);
        if (await selectedFile.exists()) {
           final Directory appDir = await getApplicationDocumentsDirectory();
           final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(filePath)}'; // Unique name
           final String newPath = path.join(appDir.path, 'diplomes', fileName);
           
           // Assurer que le dossier existe
           final Directory diplomeDir = Directory(path.join(appDir.path, 'diplomes'));
           if (!await diplomeDir.exists()) {
             await diplomeDir.create(recursive: true);
           }
           
           await selectedFile.copy(newPath);
           localPath = newPath;
        } else {
           debugPrint('Selected file does not exist: $filePath');
        }
      } catch (e) {
        debugPrint('Error copying file: $e');
      }
    }
//faire un objet diplome
    final newDiplome = Diplome(
      titre: titre,
      etablissement: etablissement,
      dateObtention: date,
      pdfPath: localPath,
    );
//ajouter le diplome dans la base de données
    await _dbService.create(newDiplome);
  }
//mettre à jour un diplome
  Future<void> updateDiplome(Diplome diplome, {String? newFilePath}) async {
    String? finalPath = diplome.pdfPath;

    if (newFilePath != null && !kIsWeb) {
      try {
        final File selectedFile = File(newFilePath);
        if (await selectedFile.exists()) {
           final Directory appDir = await getApplicationDocumentsDirectory();
           final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(newFilePath)}';
           final String newPath = path.join(appDir.path, 'diplomes', fileName);
           
           final Directory diplomeDir = Directory(path.join(appDir.path, 'diplomes'));
           if (!await diplomeDir.exists()) {
             await diplomeDir.create(recursive: true);
           }

           await selectedFile.copy(newPath);
           finalPath = newPath;
        }
      } catch (e) {
        debugPrint('Error updating file: $e');
      }
    }

    final updated = Diplome(
      id: diplome.id,
      titre: diplome.titre,
      etablissement: diplome.etablissement,
      dateObtention: diplome.dateObtention,
      pdfPath: finalPath,
    );

    await _dbService.update(updated);
  }

  Future<void> deleteDiplome(int id) async {
    await _dbService.delete(id);
  }

  Future<String?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.path != null) {
          debugPrint('File picked: ${file.path}');
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  Future<void> openPdf(String path) async {
    await OpenFile.open(path);
  }
}
