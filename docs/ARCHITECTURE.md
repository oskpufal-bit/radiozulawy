# Architektura — Radio Żuławy 106.4 FM

Ten dokument opisuje fundament techniczny aplikacji i zasady, których powinni
trzymać się kolejni agenci/deweloperzy rozwijający projekt.

## Struktura katalogów

```text
lib/
├── app/            # kompozycja aplikacji: bootstrap, konfiguracja, router, theme
│   ├── bootstrap/  # start aplikacji (WidgetsFlutterBinding, DI, runApp) — testowalny
│   ├── config/     # AppConfig / AppEnvironment (wartości środowiskowe)
│   ├── router/      # centralna konfiguracja go_router (AppRoutes, appRouterProvider)
│   ├── shell/        # AppShell — StatefulShellRoute + bottom navigation + slot
│   │                 # na globalny mini-player, patrz docs/NAVIGATION.md
│   ├── theme/       # design tokens (kolory, typografia, spacing, radius,
│   │                # cienie, gradienty, blur, durations) + ThemeData —
│   │                # patrz docs/DESIGN_SYSTEM.md
│   └── dev/         # ekrany tylko-deweloperskie (np. DesignSystemPreviewPage),
│                    # nigdy linkowane z właściwego flow aplikacji
│
├── core/           # kod współdzielony między feature'ami, bez logiki biznesowej
│   ├── api/         # ApiClient — generyczny wrapper na Dio zwracający AppFailure
│   ├── network/      # fabryka Dio, interceptory
│   ├── errors/       # AppFailure (sealed class) i mapowanie wyjątków
│   ├── extensions/   # drobne rozszerzenia (np. BuildContext)
│   ├── storage/      # LocalStorage (SharedPreferences), SecureStorage
│   ├── utils/        # AppLogger i inne narzędzia bez zależności biznesowych
│   ├── widgets/       # współdzielone widgety Design Systemu (przyciski, karty,
│   │                  # stany, GlassSurface, MiniPlayerShell, AppDetailPage,
│   │                  # ...) — patrz docs/DESIGN_SYSTEM.md
│   └── providers.dart # DI: sharedPreferences/localStorage/secureStorage/dio/apiClient
│
├── features/       # moduły biznesowe, feature-first
│   ├── radio/        # zakładka startowa — silnik odtwarzania na żywo
│   │                 # (just_audio + audio_service), patrz docs/AUDIO.md
│   ├── news/         # zakładka Newsy — placeholder + `/news/:slug`
│   ├── submit/        # zakładka Zgłoś — placeholder
│   ├── podcasts/      # zakładka Podcasty — placeholder + `/podcasts/:id`
│   ├── more/          # zakładka Więcej — placeholder, linkuje do tras pełnoekranowych
│   └── <feature>/
│       ├── data/         # źródła danych, repozytoria (implementacje)
│       ├── domain/       # modele i kontrakty repozytoriów (gdy potrzebne)
│       └── presentation/ # ekrany, widgety, providery Riverpod danego feature'a
│
└── main.dart       # wyłącznie wywołuje bootstrap()