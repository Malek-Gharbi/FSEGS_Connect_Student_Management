# Configuration Firestore pour les Actualités

## Structure de la collection `actualites`

Les actualités sont stockées dans Firestore dans la collection `actualites`.

### Structure d'un document

Chaque document dans la collection `actualites` doit avoir la structure suivante :

```javascript
{
  "titre": "Fête de l'Indépendance",
  "description": "Jour férié",
  "datePublication": Timestamp  // Format Firestore Timestamp
}
```

### Exemple de données

```javascript
// Document 1
{
  "titre": "Fête de l'Indépendance",
  "description": "Jour férié",
  "datePublication": Timestamp(2024, 3, 20) // 20 Mars 2024
}

// Document 2
{
  "titre": "Aïd al-Fitr",
  "description": "Jour férié",
  "datePublication": Timestamp(2024, 3, 30) // 30 Mars 2024
}

// Document 3
{
  "titre": "Journée des Martyrs",
  "description": "Jour férié",
  "datePublication": Timestamp(2024, 4, 9) // 09 Avril 2024
}
```

## Comment ajouter des actualités dans Firestore

### Via Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet `fsegs-connect`
3. Allez dans **Firestore Database**
4. Créez une collection nommée `actualites` si elle n'existe pas
5. Ajoutez des documents avec les champs :
   - `titre` (string)
   - `description` (string)
   - `datePublication` (timestamp)

### Via Code (exemple Dart)

```dart
final firestore = FirebaseFirestore.instance;
await firestore.collection('actualites').add({
  'titre': 'Fête de l\'Indépendance',
  'description': 'Jour férié',
  'datePublication': DateTime(2024, 3, 20), // Sera converti en Timestamp
});
```

## Règles de sécurité Firestore

Assurez-vous que vos règles Firestore permettent la lecture :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permettre la lecture de toutes les actualités
    match /actualites/{document=**} {
      allow read: if true;
      allow write: if request.auth != null; // Seulement les utilisateurs authentifiés peuvent écrire
    }
  }
}
```

## Index Firestore (Recommandé)

Pour améliorer les performances du tri par date, créez un index composé :

1. Dans Firebase Console > Firestore > Indexes
2. Cliquez sur "Create Index"
3. Collection ID: `actualites`
4. Fields:
   - `datePublication` (Ascending) → changer en Descending
5. Cliquez sur "Create"

Ou Firebase créera automatiquement l'index quand vous utiliserez `orderBy('datePublication', descending: true)`.

## Fonctionnalités implémentées

✅ Récupération de toutes les actualités depuis Firestore
✅ Tri automatique par date de publication (plus récentes en premier)
✅ Gestion des erreurs avec fallback
✅ Support des différents formats de date Firestore
✅ Affichage avec format de date en français (jour + mois)

## Test

Les actualités sont automatiquement chargées au démarrage de l'application dans `initState()`.

Si aucune actualité n'est trouvée, un message "Aucune actualité disponible" sera affiché.
