# Firebase — Monitoring & Analytics setup

Questa app integra **Firebase Crashlytics, Analytics, Performance Monitoring e
Cloud Messaging (FCM)**. Il codice Dart è già cablato; mancano solo i file di
configurazione generati dal tuo account Firebase.

> ⚠️ Finché non esegui `flutterfire configure`, il file
> `lib/firebase_options.dart` è un **placeholder** che lancia un errore a
> runtime. L'app compila ma non parte finché la configurazione non è completata.

## 1. Prerequisiti (una tantum)

CLI già presenti sulla macchina (`flutterfire`, `firebase`). Se serve
autenticarsi:

```
firebase login
```

## 2. Crea/collega il progetto e genera i file

Dalla root del repo:

```
flutterfire configure \
  --project=<FIREBASE_PROJECT_ID> \
  --platforms=android,ios \
  --android-package-name=com.kilocal.app \
  --ios-bundle-id=com.kilocal.app
```

Il comando:

- crea (o riusa) il progetto Firebase e le app Android/iOS per `com.kilocal.app`;
- genera **`lib/firebase_options.dart`** (sovrascrive il placeholder);
- scarica **`android/app/google-services.json`**;
- scarica **`ios/Runner/GoogleService-Info.plist`** e lo aggiunge al target Xcode.

Se non hai ancora un progetto, ometti `--project` e la CLI ti farà scegliere
"Create a new project".

## 3. Verifica build

```
flutter pub get
flutter run                 # debug: collection Crashlytics/Analytics/Perf DISABILITATA
flutter run --release       # collection ABILITATA
```

Per forzare la raccolta anche in debug (test dashboard):

```
flutter run \
  --dart-define=FIREBASE_MONITORING_IN_DEBUG=true \
  --dart-define=FIREBASE_ANALYTICS_IN_DEBUG=true
```

## 4. Push notifications — passi specifici piattaforma

Il codice FCM è pronto (`lib/core/push/push_notification_service.dart`), ma le
notifiche push richiedono configurazione lato piattaforma **che non può essere
fatta da codice**:

### iOS (obbligatorio per le push)
1. In **Apple Developer**: abilita la capability *Push Notifications* per l'App ID
   `com.kilocal.app` e crea una **APNs Authentication Key** (`.p8`).
2. In **Firebase Console → Project Settings → Cloud Messaging → Apple app**:
   carica la key `.p8` (Key ID + Team ID).
3. In **Xcode → Runner → Signing & Capabilities**: aggiungi *Push Notifications*
   e *Background Modes → Remote notifications* (quest'ultimo è già dichiarato in
   `ios/Runner/Info.plist`).
4. Le push non funzionano sul simulatore iOS senza token APNs: testa su device.

### Android
- Nessun passo aggiuntivo: `google-services.json` + il permesso
  `POST_NOTIFICATIONS` (Android 13+, già in `AndroidManifest.xml`) bastano.
- Il permesso runtime viene richiesto da `PushNotificationService.init()`.

## 5. Crashlytics — symbol upload (release)

Il plugin Gradle `com.google.firebase.crashlytics` è già applicato. Per
de-obfuscare gli stack trace native/Dart in release, gli symbol vengono caricati
automaticamente dal build Gradle; per i simboli Flutter usa:

```
flutter build appbundle --release
# i symbol Dart vengono caricati dallo split-debug-info se configurato
```

## Cosa è già cablato nel codice

| Componente | File |
|-----------|------|
| Bootstrap (init + error hooks + zona guarded) | `lib/app/bootstrap.dart` |
| Crashlytics + Performance (astrazione + impl) | `lib/core/monitoring/monitoring_service.dart`, `firebase_monitoring_service.dart` |
| Analytics (astrazione + impl + catalogo eventi) | `lib/core/monitoring/analytics_service.dart`, `firebase_analytics_service.dart`, `analytics_events.dart` |
| Performance HTTP tracing su Dio | `lib/core/monitoring/performance_interceptor.dart` |
| FCM push | `lib/core/push/push_notification_service.dart` |
| Registrazioni DI | `lib/app/di.dart` |

### Eventi analytics già emessi
- `login` (LoginCubit)
- `onboarding_started`, `onboarding_completed`, `survey_submitted` (SurveyCubit)
- `path_step_opened` (PathDetailCubit)
- user id impostato su Crashlytics + Analytics al login e pulito al logout (UserCubit)

Altri eventi (benefit, materiali, momenti) sono già definiti in
`analytics_events.dart` e vanno solo agganciati quando si toccano quei flussi.
