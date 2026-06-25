# iOS — Live Activity del Timer (Dynamic Island)

Guida per completare la parte iOS del timer allenamento. La logica Dart e Android
è già implementata (`SystemTimerService`, `MainActivity.kt`). Su iOS serve creare a
mano una **Widget Extension** in Xcode: questi passi non sono automatizzabili da
fuori Xcode senza rischiare di corrompere `project.pbxproj`.

Plugin usato: [`live_activities`](https://pub.dev/packages/live_activities) `^2.4.9`.

> ⚠️ **Fix Xcode 16.2.** L'upstream 2.4.9 ha una trailing comma in
> `LiveActivitiesPlugin.swift:234` che compila solo su Xcode 16.3+/Swift 6.1.
> Su Xcode 16.2 dà `Unexpected ',' separator`. È stato creato un **fork locale
> patchato** in `third_party/live_activities/` e un `dependency_overrides` in
> `pubspec.yaml` che lo usa al posto della versione pub. Quando l'upstream
> rilascia il fix, rimuovi l'override e la cartella. **Dopo il primo override va
> rifatto `pod install`** così il pod punta al path locale.
Requisiti: **iOS 16.1+** per le Live Activity, **iPhone 14 Pro+** per la Dynamic
Island. Sui device più vecchi il plugin riporta `areActivitiesEnabled() == false`
e l'app resta con la sola **pill in-app** (fallback già gestito nel codice Dart).

## App Group condiviso

Il codice Dart usa questo App Group (vedi `system_timer_service.dart`):

```
group.com.kilocal.liveactivities
```

Va creato su Apple Developer e abilitato come capability **sia su Runner sia
sull'estensione**. Se scegli un id diverso, aggiorna `_iosAppGroupId`.

## Passi in Xcode

1. Apri `ios/Runner.xcworkspace`.
2. **File ▸ New ▸ Target… ▸ Widget Extension**. Nome es. `TimerWidget`.
   - Spunta "Include Live Activity". NON spuntare "Include Configuration App
     Intent" se non serve.
3. Per **entrambi** i target (`Runner` e `TimerWidget`):
   - Signing & Capabilities ▸ **+ Capability ▸ App Groups** ▸ aggiungi
     `group.com.kilocal.liveactivities`.
4. **(NON necessario)** ~~Push Notifications su `Runner`~~. Gli update remoti
   sono **disattivati** nel servizio Dart (`iOSEnableRemoteUpdates: false` in
   `system_timer_service.dart`), quindi **non serve** la capability Push
   Notifications. Il widget fa il countdown da solo a partire da `endDate`.
   Aggiungila solo se in futuro vorrai aggiornare la Live Activity da remoto.
5. `Info.plist` di **Runner** ▸ aggiungi:
   ```xml
   <key>NSSupportsLiveActivities</key>
   <true/>
   ```
6. Imposta il deployment target dell'estensione a **16.1** (o superiore).
7. **Podfile** — è stato copiato dal template Flutter in `ios/Podfile` (la
   generazione automatica non scattava in questo ambiente). Esegui
   `flutter pub get` dalla root, poi `cd ios && pod install`.

8. **Dependency cycle Runner ↔ extension (GIÀ FIXATO).** Aggiungendo la Widget
   Extension, Xcode mette la phase "Embed Foundation Extensions" *dopo* lo script
   "Thin Binary" di Flutter, creando un ciclo ("Cycle inside Runner …"). Fix
   applicato in `project.pbxproj`: "Embed Foundation Extensions" è stato spostato
   **prima** di "Thin Binary" nelle buildPhases del target Runner. Se in futuro
   ri-generi il target o l'ordine torna sbagliato, rifai lo spostamento.

## Codice dell'estensione — ✅ GIÀ FATTO

I file Swift dell'estensione sono già stati scritti e sono coerenti con il plugin
`live_activities` 2.4.9 (verificati contro `example/ios/extension-example`):

- `ios/TimerWidget/TimerWidgetLiveActivity.swift` — `LiveActivitiesAppAttributes`
  + lettura `label`/`endDate` da `UserDefaults(suiteName: "group.com.kilocal.liveactivities")`
  via `prefixedKey`. UI lockscreen + Dynamic Island col countdown nativo
  (`Text(timerInterval:countsDown:)`, niente bisogno di update remoti).
- `ios/TimerWidget/TimerWidgetBundle.swift` — `@main`, espone solo
  `TimerWidgetLiveActivity()`.
- `ios/TimerWidget/Info.plist` — `NSSupportsLiveActivities = true` +
  `NSExtensionPointIdentifier = com.apple.widgetkit-extension`.
- I file template di Xcode non usati (`TimerWidget.swift`, `TimerWidgetControl.swift`,
  `AppIntent.swift`) sono stati **rimossi** (il control widget richiedeva iOS 18).

Lo store/App Group e le chiavi (`label`, `endDate` epoch millis) combaciano con
`system_timer_service.dart`. Non serve toccare il codice Swift, solo finire la
config in Xcode (App Group + signing del target).

## Verifica

1. Build su un iPhone reale (le Live Activity non sempre girano in simulatore) con
   iOS 16.1+, idealmente 14 Pro+ per la Dynamic Island.
2. Avvia il timer dalla schermata step: deve comparire la pill in-app **e** la
   Live Activity (Dynamic Island / lockscreen).
3. Su device < 16.1: deve comparire **solo** la pill (nessun crash).

## Mappa del codice Dart già pronto

- `lib/features/path/data/system_timer_service.dart` — astrae Android (Intent) e
  iOS (`live_activities`). `start(duration, label:)` / `stop()`.
- `lib/features/path/presentation/widgets/path_timer_pill.dart` —
  `PathTimerController` chiama il servizio in `start`/`stop`; la pill è la UI.
- `android/.../MainActivity.kt` — MethodChannel `kilocal/system_timer`,
  `ACTION_SET_TIMER`.
- `AndroidManifest.xml` — permesso `SET_ALARM` + query `SET_TIMER`.
