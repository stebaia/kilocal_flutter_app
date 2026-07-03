# Kilocal App — Stato di avanzamento

**Data:** 3 luglio 2026
**Progetto:** App Flutter Kilocal (iOS + Android)

Questo documento risponde punto per punto a "cosa è incluso" e integra gli aspetti aggiuntivi richiesti (Strumenti, Hypercare, Sicurezza, Monitoring & Analytics).

Legenda stato:
- ✅ **Fatto** — implementato e collegato
- 🟡 **In corso / parziale** — presente ma da completare o collegare
- ⚪ **Da fare** — non ancora avviato

---

## Cosa è incluso

| # | Voce | Stato | Note |
|---|------|:----:|------|
| 1 | App Flutter nativa iOS/Android, UI conforme al Figma | 🟡 | Basi solide (Clean Architecture, GoRouter, tema). Schermate principali costruite dai design; rifinitura visiva in corso su alcune sezioni. |
| 2 | Accesso utente: registrazione, login, recupero password | ✅ | Tutti e tre presenti e collegati alle API (`login`, `register`, `password-forgotten`). |
| 3 | Attivazione tramite codice prodotto | ⚪ | **Non ancora implementata.** Nessun flusso di inserimento/validazione codice a oggi. Da pianificare (serve conferma endpoint backend). |
| 4 | Onboarding con survey iniziale e finale | 🟡 | Flusso survey CMS-driven **implementato e verificato in lettura** su staging (5 survey pubbliche). L'invio delle risposte è cablato, ma restano **6 domande aperte al backend** prima di considerarlo chiuso. |
| 5 | Home con momenti, statistiche e benefit personalizzati | 🟡 | Home + Momenti + Benefit + Statistiche presenti. Momenti e Benefit collegati alle API. Statistiche v1 (mese corrente) sbloccata via `GET /path/me/progress`; il selettore di intervallo temporale non ha ancora copertura backend. Filtro Benefit (Attivi/Passati/Coming soon) **bloccato**: mancano campi data/status lato GraphQL. |
| 6 | Sezione Percorso collegata al prodotto attivato | 🟡 | Schermate Percorso costruite (step, aree, materiali extra, timeframe). La "dinamicizzazione" completa dipende dal collegamento al prodotto attivato → legata al punto 3 (attivazione) e a 4 domande aperte al backend. |
| 7 | Diario personale dell'utente | 🟡 | Schermata Diario presente lato UI; **manca il collegamento alle API** (persistenza backend da definire). |
| 8 | Profilo e impostazioni | ✅ | Schermate Profilo e Impostazioni presenti. Alcune card CMS del profilo dipendono da sezioni auth-gated ancora da sbloccare lato backend. |
| 9 | Notifiche push e centro notifiche in-app | 🟡 | **Centro notifiche in-app**: presente e collegato alle API. **Push**: infrastruttura non ancora integrata (nessun provider push configurato — vedi Monitoring qui sotto per Firebase). Da predisporre. |
| 10 | Build di rilascio e assistenza alla pubblicazione sui due store | ⚪ | Da eseguire a valle del completamento funzionale. Configurazione ambienti via `--dart-define` già predisposta (staging/prod). |

---

## Aspetti aggiuntivi da integrare

### A) Strumenti (Promemoria, Timer, Glossario, Gallery)

Non erano citati nel perimetro originale. Stato attuale:

| Strumento | Stato | Note |
|-----------|:----:|------|
| Timer | 🟡 | Esiste un **timer** all'interno della sezione Percorso (pillola timer + sheet). Non è ancora uno "strumento" autonomo trasversale. |
| Promemoria | ⚪ | Da fare. |
| Glossario | ⚪ | Da fare. |
| Gallery | ⚪ | Da fare. |

**Proposta:** aggiungere una sezione "Strumenti" dedicata che raccolga Promemoria, Timer, Glossario e Gallery come funzionalità di primo livello, riutilizzando il timer già esistente nel Percorso.

---

### B) Hypercare post go-live — **40 giorni**

Da aggiungere esplicitamente al perimetro: **periodo di Hypercare di 40 giorni** successivo al go-live, con:
- monitoraggio attivo di crash ed errori,
- correzione rapida di bug bloccanti/critici emersi in produzione,
- supporto al team nella fase di stabilizzazione.

---

### C) Sicurezza

Requisiti richiesti e stato attuale nel codice:

| Requisito | Stato | Dettaglio |
|-----------|:----:|-----------|
| Token in secure storage (non in chiaro) | ✅ | Access token e refresh token salvati in **`flutter_secure_storage`** (Keychain su iOS, Keystore su Android), non in SharedPreferences/NSUserDefaults. |
| Nessun dato sensibile loggato nelle build di rilascio | ✅ | Il `LoggingInterceptor` (unica fonte di log di rete) è registrato in `DioClient` solo se `kDebugMode`, e in aggiunta ogni chiamata di log è internamente guardata da `kDebugMode` (defense-in-depth): in release non viene emesso alcun dato sensibile. La dipendenza inutilizzata `pretty_dio_logger` è stata rimossa. |
| Scadenza e refresh del token JWT gestiti correttamente | ✅ | Interceptor dedicato: su `401` esegue **refresh single-shot** e ritenta la richiesta; se il refresh fallisce, pulisce la sessione e reindirizza al login. |
| Nessuna chiave API/credenziale hardcoded | ✅ | Nessun segreto nel codice sorgente. Le base URL sono configurabili via `--dart-define` con default per ambiente. |

**Nota:** tutti i requisiti di sicurezza sono ora coperti: token in secure storage, refresh JWT single-shot, nessuna credenziale hardcoded e nessun log sensibile nelle build di rilascio.

---

### D) Monitoring & Analytics

**Stato attuale:** 🟢 **integrato e verificato.** Stack Firebase completo cablato in Clean Architecture (astrazioni + implementazioni Firebase + DI), progetto Firebase `kilokal-app-flutter` configurato via `flutterfire configure`. **Build verificati:** Android `flutter build apk --debug` ✅ e iOS simulator `flutter build ios --debug --simulator` ✅; app avviata su simulatore iPhone 16 con Firebase inizializzato (log `[Firebase/Crashlytics] Version 12.14.0`). Resta da fare solo la configurazione APNs lato Apple Developer per le push iOS. Guida operativa: **`docs/firebase-setup.md`**.

| Strumento | Scopo | Stato |
|-----------|-------|:----:|
| **Firebase Crashlytics** | Crash reporting (crash e non-fatal errors) in tempo reale. | ✅ codice: hook `FlutterError` + `PlatformDispatcher` + `runZonedGuarded` in `bootstrap.dart`. |
| **Firebase Analytics** | Tracciamento eventi chiave (login, onboarding completato, survey inviata, path step, ecc.). | ✅ codice: `AnalyticsService` + catalogo eventi tipizzato, eventi già emessi dai cubit. |
| **Firebase Performance Monitoring** | Latenze di rete (trace HTTP su Dio) + trace custom. | ✅ codice: `PerformanceInterceptor` + `MonitoringService.startTrace`. |
| **Firebase Cloud Messaging (FCM)** | Infrastruttura per le **notifiche push** (copre anche il punto 9). | ✅ codice: `PushNotificationService` (permessi, token, handler foreground/background/terminated). Richiede APNs su iOS. |

**Collection disabilitata in debug** (Crashlytics/Analytics/Performance) per non inquinare le dashboard; abilitata automaticamente in release. Override via `--dart-define`.

Passi rimanenti (non eseguibili da codice): vedi `docs/firebase-setup.md` §4 (APNs iOS).

> 🔧 **DEBITO TECNICO — aggiornare Xcode (da fare più avanti).** Le versioni Firebase sono state **volutamente bloccate** (`firebase_core: 4.9.0` → Firebase iOS SDK 12.13.0) perché le release più recenti (firebase_core 4.11 → iOS SDK 12.15) richiedono **Swift tools 6.1 = Xcode 16.3+**, mentre la macchina è su **Xcode 16.2**. Downgrade scelto per rispettare il SAL corrente.
>
> Il downgrade ha richiesto anche un `dependency_override` su **`firebase_core_platform_interface: 7.0.1`**: la 7.1.0 aggiunge un 15° campo (`recaptchaSiteKey`) al pigeon `FirebaseOptions`, ma il codice nativo iOS di `firebase_core 4.9.0` ne invia 14 → `RangeError` a `Firebase.initializeApp`. Inoltre la deployment target iOS è stata alzata a **15.0** (richiesta da `firebase_performance`).
>
> Quando si aggiorna Xcode a **16.3+**:
> 1. Rimuovere i pin in `pubspec.yaml` (incluso l'override `firebase_core_platform_interface`) e tornare alle versioni Firebase più recenti (`flutter pub upgrade firebase_core firebase_crashlytics firebase_analytics firebase_performance firebase_messaging`).
> 2. Valutare la rimozione del fork `live_activities` in `third_party/` e del relativo `dependency_override` (esiste solo perché l'upstream compila su Xcode 16.3+).
> 3. Ripulire lo stato SPM: `flutter clean` + eliminare `ios/.../swiftpm/Package.resolved` e la DerivedData di Runner, poi `flutter pub get`.
>
> Nota minore: la build phase Xcode "FlutterFire: upload-crashlytics-symbols" è stata patchata per **saltare su simulatore** e quando lo script non è presente (evitava un fallimento su debug/simulator); il caricamento simboli resta attivo per le build device/release.

---

## Riepilogo per priorità

**Da avviare (⚪):**
1. Attivazione tramite codice prodotto (punto 3) — sblocca la personalizzazione del Percorso.
2. Strumenti: Promemoria, Glossario, Gallery.
3. Build di rilascio e pubblicazione store.

**Da completare (🟡):**
4. Collegamento API del Diario.
5. Chiusura survey (6 domande aperte al backend).
6. Filtro Benefit e selettore intervallo Statistiche (dipendenze backend).
7. Firebase: provisioning progetto (`flutterfire configure`) + APNs iOS — codice pronto, vedi `docs/firebase-setup.md`.

**Già coperto (✅):**
- Accesso utente completo (registrazione/login/recupero password).
- Sicurezza token + refresh JWT + assenza di segreti hardcoded.

---

> ⚠️ Diversi punti "parziali" dipendono da **conferme/endpoint lato backend** (attivazione prodotto, survey, filtro benefit, timeframe statistiche, card profilo auth-gated). Queste dipendenze sono già tracciate e vanno chiuse per completare le rispettive feature.
