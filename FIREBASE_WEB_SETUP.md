# Configuration Firebase pour le Web

## Configuration effectuée

✅ **Fichiers créés/modifiés :**
- `lib/firebase_options.dart` - Options Firebase pour toutes les plateformes
- `web/index.html` - Scripts Firebase et configuration
- `lib/main.dart` - Initialisation Firebase avec options

## Important : App ID Web

L'App ID web dans `firebase_options.dart` est actuellement :
```
appId: '1:402880677062:web:8ce4d4a09e87aefd44c3c7'
```

**Pour obtenir le vrai App ID web :**

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet `fsegs-connect`
3. Allez dans **Project Settings** (⚙️)
4. Dans l'onglet **General**, trouvez la section **Your apps**
5. Si une app web n'existe pas, cliquez sur **Add app** > **Web** (</>)
6. Copiez l'**App ID** (format: `1:402880677062:web:xxxxx`)
7. Remplacez l'App ID dans `lib/firebase_options.dart` ligne 48

## Vérification

Pour tester sur Edge (web) :
```bash
flutter run -d chrome
# ou
flutter run -d edge
```

## Dépannage

Si vous rencontrez des erreurs :
1. Vérifiez que l'App ID web est correct dans Firebase Console
2. Vérifiez que les règles Firestore autorisent les lectures
3. Vérifiez la console du navigateur pour les erreurs JavaScript
4. Assurez-vous que `firebase_core` et `cloud_firestore` sont à jour

## Notes

- Les scripts Firebase dans `index.html` utilisent la version **compat** pour une meilleure compatibilité avec Flutter
- L'initialisation Firebase dans `main.dart` utilise `DefaultFirebaseOptions.currentPlatform` qui détecte automatiquement la plateforme
- Pour le web, Firebase est initialisé à la fois via les scripts HTML et via FlutterFire
