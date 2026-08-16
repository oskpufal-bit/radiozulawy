# Audio — Radio Żuławy 106.4 FM (live playback)

Ten dokument opisuje techniczny fundament odtwarzania radia na żywo:
audio stack, podział odpowiedzialności, przepływ od UI do playera, background
playback, `RadioPlaybackState`, konfigurację URL streamu, lifecycle i sposób
testowania. Dopełnia `docs/ARCHITECTURE.md` i `docs/NAVIGATION.md` (nie
duplikuje ich treści).

To jest fundament techniczny — **nie** finalny layout Radio Live. Brak jeszcze
metadanych ICY, aktualnej audycji/prowadzącego i ramówki (patrz "Poza
zakresem" niżej).

## Audio stack

- **`just_audio`** — silnik streamingu (jedyne miejsce tworzenia
  `AudioPlayer`: `RadioAudioHandler`).
- **`audio_service`** — hostuje playback jako foreground service (Android),
  zapewnia system media notification, lock-screen controls i przetrwanie
  backgroundingu/blokady ekranu.

Nie ma dwóch konkurencyjnych audio engine i nigdzie poza `RadioAudioHandler`
nie importuje się `just_audio`.

## Podział odpowiedzialności

```text
lib/features/radio/
├── domain/
│   ├── radio_playback_state.dart   # RadioPlaybackStatus, RadioPlaybackErrorType,
│   │                                # RadioPlaybackState (immutable snapshot)
│   └── radio_repository.dart       # RadioRepository — kontrakt niezależny od
│                                    # audio_service/just_audio
├── data/
│   ├── radio_audio_handler.dart          # RadioAudioHandler(BaseAudioHandler) —
│   │                                      # jedyne miejsce z AudioPlayer,
│   │                                      # jedyne źródło prawdy dla stanu
│   └── audio_service_radio_repository.dart # RadioRepository → RadioAudioHandler
└── presentation/
    ├── radio_providers.dart           # Riverpod: handler/repository/controller
    ├── radio_playback_controller.dart # Notifier<RadioPlaybackState>, API UI
    └── radio_home_screen.dart         # ekran techniczny (play/pause/retry)
```

- **`RadioAudioHandler`** — jedyny właściciel `AudioPlayer`. Tłumaczy
  `just_audio` (`PlayerState`, `errorStream`) na `RadioPlaybackState`, zarządza
  URL-em streamu, mapuje wyjątki na `RadioPlaybackErrorType`, planuje
  ograniczony reconnect i publikuje `PlaybackState`/`MediaItem` do
  `audio_service` (media notification, lock screen).
- **`AudioServiceRadioRepository`** — cienki adapter `RadioAudioHandler` →
  `RadioRepository`, żeby presentation nigdy nie widziało typów
  `audio_service`/`just_audio`.
- **`RadioRepository`** (abstrakcja) — jedyny seam potrzebny do testów: fake w
  `test/features/radio/fake_radio_repository.dart` implementuje ten sam
  interfejs bez dotykania sieci/silnika audio.
- **`RadioPlaybackController`** (`Notifier<RadioPlaybackState>`) — publiczne
  API dla UI: `play()`, `pause()`, `stop()`, `retry()`, `togglePlayback()`.
  Subskrybuje `RadioRepository.watchPlaybackState()` i re-eksponuje jako stan
  Riverpod.

## Przepływ (Presentation → engine)

```text
Presentation (RadioHomeScreen, mini-player w AppShell)
    ↓ ref.watch / ref.read
RadioPlaybackController        (Notifier<RadioPlaybackState>, presentation/)
    ↓
RadioRepository                (abstrakcja, domain/)
    ↓
AudioServiceRadioRepository    (adapter, data/)
    ↓
RadioAudioHandler              (BaseAudioHandler, data/ — jedyny AudioPlayer)
    ↓
just_audio → strumień Icecast/Shoutcast (AppConfig.radioStreamUrl)
```

Widgety **nigdy** nie tworzą/wołają `AudioPlayer` bezpośrednio — zawsze przez
`radioPlaybackControllerProvider`. Jedno źródło prawdy: `RadioAudioHandler`
trzyma jedyny żywy stan sesji; `RadioPlaybackController` go nie duplikuje,
tylko re-emituje.

## RadioPlaybackState

`RadioPlaybackStatus`: `idle / loading / buffering / playing / paused /
stopped / error` — mapowanie z `just_audio` `ProcessingState` w
`RadioAudioHandler._handlePlayerState`. `loading` = pierwsze połączenie,
`buffering` = re-buffering w trakcie sesji; UI może je rozróżnić, ale oba
liczą się jako "sesja aktywna" (`isSessionActive`, użyte przez mini-player do
decyzji o widoczności).

`RadioPlaybackErrorType`: `notConfigured / network / timeout / source /
unknown` — mapowanie surowych wyjątków (`SocketException`,
`TimeoutException`, `PlayerException`/`FormatException`) na kategorie
user-facing w `RadioAudioHandler._mapError`. `RadioPlaybackState.errorMessage`
jest już gotowym, polskim, nietechnicznym komunikatem — UI nigdy nie
renderuje raw exception/stack trace. Szczegóły techniczne trafiają tylko do
`AppLogger` (debug-only).

To jest snapshot sesji **live** — celowo brak `position`/`duration`: radio nie
ma seeka, `play()` zawsze dołącza do bieżącego punktu transmisji.

## Konfiguracja URL streamu

`AppConfig.radioStreamUrl` (`lib/app/config/app_config.dart`), sterowane przez
`--dart-define=RADIO_STREAM_URL=...`. Domyślny placeholder
(`https://stream.dev-placeholder.invalid/radiozulawy.mp3`) celowo wskazuje na
domenę `.invalid` (RFC 2606) — nigdy się nie rozwiąże, więc nieskonfigurowany
build nie wykona przypadkowego requestu. `RadioAudioHandler._isStreamConfigured`
sprawdza to przed każdym `play()`; brak konfiguracji daje kontrolowany
`RadioPlaybackErrorType.notConfigured` zamiast requestu/crasha/wiecznego
loadingu. Rejestr: `docs/DEV_PLACEHOLDERS.md` (PH-001).

Nigdy nie hardcoduj URL-a w controllerze/page/serwisie — jedyne miejsce to
`AppConfig` i jego użycie w `RadioAudioHandler`.

## Background playback

`audio_service` hostuje `RadioAudioHandler` jako foreground media service
(Android) — radio przeżywa zminimalizowanie appki i zablokowany ekran.
Konfiguracja Androida (`android/app/src/main/AndroidManifest.xml`):
permissions `INTERNET`, `WAKE_LOCK`, `FOREGROUND_SERVICE`,
`FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS` (wymagane od
Android 13 do pokazania notyfikacji foreground service), plus deklaracja
`com.ryanheise.audioservice.AudioService` (foregroundServiceType
`mediaPlayback`) i `MediaButtonReceiver`. Audio focus, "becoming noisy"
(odłączenie słuchawek) i przerwania (połączenie telefoniczne, inna appka
audio) są obsługiwane przez `just_audio`/`audio_service`/platformę — nie ma
ręcznej logiki audio focus w tym repo.

## Media notification / system controls

`RadioAudioHandler` publikuje jeden statyczny `MediaItem` ("Radio Żuławy
106.4 FM" / "Na żywo" / "Radio Żuławy", `isLive: true`, bez artworku — brak
lokalnego logo assetu na tym etapie) i `PlaybackState` z akcjami `play`/
`pause`/`stop` (`androidCompactActionIndices: [0, 1]`). Brak `next`/
`previous`/seek — nie mają zastosowania dla live streamu. Aktualizacja
`MediaItem` na podstawie audycji/ICY metadata to zadanie poza zakresem tego
etapu (patrz "Poza zakresem").

## Reconnect

Utrata połączenia w trakcie aktywnej sesji (`playing`/`buffering`/`loading`)
planuje ograniczony automatyczny retry z rosnącym opóźnieniem
(`_reconnectDelays` w `radio_audio_handler.dart`: 2s / 5s / 10s, maks. 3
próby, brak nieskończonej pętli). Użytkownik może w każdej chwili przerwać
przez `stop()`/`retry()` — obie metody anulują zaplanowany timer. Zaplanowany
reconnect wykonuje się tylko, jeśli stan wciąż jest `error` w momencie
odpalenia timera (użytkownik mógł w międzyczasie ręcznie zainterweniować).

## Lifecycle

- `RadioAudioHandler` jest tworzony **raz**, w `bootstrap()`
  (`lib/app/bootstrap/bootstrap.dart`) przez `AudioService.init`, i wstrzykiwany
  do Riverpod jako wartość (`radioAudioHandlerProvider.overrideWithValue`) —
  identyczny wzorzec jak `sharedPreferencesProvider`.
- `radioRepositoryProvider`/`radioPlaybackControllerProvider` żyją tak długo
  jak `ProviderScope` aplikacji (domyślne `Provider`/`NotifierProvider`, bez
  `autoDispose`) — sesja audio przeżywa zmianę zakładki i nie jest tworzona
  ani dispose'owana przez `RadioHomeScreen`.
- Zmiana zakładki / zminimalizowanie appki nie tworzy ani nie niszczy
  playera — jedyny `AudioPlayer` żyje w `RadioAudioHandler` przez cały czas
  działania procesu.

## Autoplay / pamięć sesji

Radio **nie** startuje automatycznie po cold-strzale ani po powrocie do
appki — `RadioPlaybackController.build()` tylko odczytuje bieżący stan
(`repository.currentState`, domyślnie `idle`) i subskrybuje zmiany; nic nie
woła `play()`. Użytkownik musi świadomie nacisnąć Play. Nie zapisujemy
`isPlaying` do żadnego storage.

## Testowalność

Testy jednostkowe/widgetowe nigdy nie dotykają `just_audio`/`audio_service`
ani sieci: `test/features/radio/fake_radio_repository.dart` dostarcza
`FakeRadioRepository implements RadioRepository` (in-memory, z licznikami
wywołań i metodą `emit` do symulacji dowolnego stanu/błędu), podpinany przez
`radioRepositoryProvider.overrideWithValue(...)` w `ProviderContainer`/
`ProviderScope` testu. `RadioAudioHandler` sam w sobie nie ma dedykowanego
testu (kruche przez zależność od `audio_service`/`just_audio` w testowym
środowisku) — jego logika (mapowanie stanów/błędów, reconnect) jest pokryta
pośrednio przez testy `RadioPlaybackController`/`RadioHomeScreen` działające
na fake'u, co jest świadomym wyborem, nie luką.

- `test/features/radio/radio_playback_controller_test.dart` — initial state,
  play/pause/stop/retry, toggle w każdym stanie, błąd `notConfigured`, brak
  pętli retry.
- `test/features/radio/radio_home_screen_test.dart` — idle CTA, play → playing,
  buffering, pause, error state bez crasha + retry.

## Gdzie dodać dynamiczne metadata (przyszłe zadanie)

- Parsowanie ICY metadata (tytuł/artysta bieżącego utworu, jeśli stream to
  udostępnia) → nowy strumień w `RadioAudioHandler`, mapowany na
  aktualizację `MediaItem` (nie zmienia `RadioPlaybackState`, które opisuje
  tylko status sesji).
- Ramówka (bieżąca audycja/prowadzący) → osobny feature/provider, zasilający
  ten sam `MediaItem` i przyszły finalny UI Radio Live; nie miesza się z
  `RadioPlaybackState`.
- Finalny pełnoekranowy UI Radio Live (hero artwork, dane audycji) zastępuje
  `RadioHomeScreen`, korzystając z tego samego `radioPlaybackControllerProvider`.

## Poza zakresem tego etapu

Parsowanie ICY metadata, ramówka, dane prowadzącego/audycji, artwork
audycji, seek/skip (nie mają sensu dla live), analityka, autoplay po cold
start. Patrz też `docs/DEV_PLACEHOLDERS.md` dla `RADIO_STREAM_URL`.
