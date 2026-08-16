# Audio — Radio Żuławy 106.4 FM (live playback)

Ten dokument opisuje techniczny fundament odtwarzania radia na żywo:
audio stack, podział odpowiedzialności, przepływ od UI do playera, background
playback, `RadioPlaybackState`, konfigurację URL streamu, lifecycle i sposób
testowania. Dopełnia `docs/ARCHITECTURE.md` i `docs/NAVIGATION.md` (nie
duplikuje ich treści).

Ten dokument opisuje audio engine, nie UI — finalny layout Radio Live
(hero player, dane audycji, "Co dalej") jest opisany w `docs/RADIO_UI.md`.
Brak tu jeszcze prawdziwych metadanych ICY i prawdziwego API ramówki/bieżącej
audycji (dziś dev placeholder, patrz "Poza zakresem" niżej).

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
    ├── radio_providers.dart           # Riverpod: handler/repository/controller/
    │                                   # currentShow/schedulePreview
    ├── radio_playback_controller.dart # Notifier<RadioPlaybackState>, API UI
    ├── radio_home_screen.dart         # finalny ekran Radio Live — patrz docs/RADIO_UI.md
    └── widgets/                       # RadioHeroPlayer i pozostałe podwidgety ekranu