# Rejestr placeholderów deweloperskich

Żywy dokument. Każde zadanie, które wprowadza nowy development placeholder
(URL, klucz, mock, dane testowe), musi dopisać tu wiersz. Przed wydaniem
produkcyjnym wszystkie wiersze ze statusem `OPEN` muszą zostać zamknięte.

| ID | Obszar | Placeholder | Lokalizacja w kodzie | Co trzeba dostarczyć przed produkcją | Status |
|----|--------|-------------|------------------------|----------------------------------------|--------|
| PH-001 | Stream radia | `https://stream.dev-placeholder.invalid/radiozulawy.mp3` | `lib/app/config/app_config.dart` (`radioStreamUrl`) | Prawdziwy adres streamu Icecast/Shoutcast Radia Żuławy | OPEN |
| PH-002 | API ogólne | `https://api.dev-placeholder.invalid` | `lib/app/config/app_config.dart` (`apiBaseUrl`) | Adres bazowy dedykowanego API (konkursy, konfiguracja appki) | OPEN |
| PH-003 | WordPress REST API | `https://cms.dev-placeholder.invalid/wp-json/wp/v2` | `lib/app/config/app_config.dart` (`wordpressApiUrl`) | Adres WordPress REST API na `radiozulawy.pl` (aktualności) | OPEN |
| PH-004 | Zgłoszenia | `https://api.dev-placeholder.invalid/submissions` | `lib/app/config/app_config.dart` (`submissionsApiUrl`) | Adres backendu obsługującego zgłoszenia (panel `radiozulawy.pl/madminpanel`) | OPEN |
| PH-005 | Polityka prywatności | `https://dev-placeholder.invalid/polityka-prywatnosci` | `lib/app/config/app_config.dart` (`privacyPolicyUrl`) | Finalny link do polityki prywatności (treść dostarczona później) | OPEN |
| PH-006 | Regulamin | `https://dev-placeholder.invalid/regulamin` | `lib/app/config/app_config.dart` (`termsUrl`) | Finalny link do regulaminu / zgody RODO (treść dostarczona później) | OPEN |
| PH-007 | Środowisko builda | `APP_ENV` domyślnie `dev` | `lib/app/config/app_environment.dart`, `lib/app/config/app_config.dart` | Ustawić `--dart-define=APP_ENV=prod` (i pozostałe zmienne) w pipeline release | OPEN |
| PH-008 | Router — ekran startowy | `initialLocation: AppRoutes.devDesignSystem` (`/dev/design-system`) | `lib/app/router/app_router.dart` | Przywrócić realny ekran startowy (`AppRoutes.radio` lub navigation shell) po zaimplementowaniu właściwych modułów biznesowych; usunąć/odlinkować `DesignSystemPreviewPage` z produkcyjnego flow | CLOSED — App Shell (etap 3) przywrócił `initialLocation: AppRoutes.radio`; `/dev/design-system` pozostaje osiągalny bezpośrednim wpisaniem trasy, ale nie jest linkowany z bottom navigation |
| PH-009 | Radio — uprawnienie powiadomień | `POST_NOTIFICATIONS` zadeklarowane w manifeście, ale appka nie prosi jeszcze o nie w runtime (Android 13+) | `android/app/src/main/AndroidManifest.xml`, `lib/features/radio/data/radio_audio_handler.dart` (`docs/AUDIO.md`) | Dodać runtime request `POST_NOTIFICATIONS` (np. przy pierwszym `play()`) — bez niego media notification może nie być widoczna na Androidzie 13+, choć playback/background audio i tak działa | OPEN |
| PH-010 | Radio UI — bieżąca audycja | Statyczny `devCurrentShow` ("Dzień dobry Żuławy" / "Redakcja Radia Żuławy" / 08:00–10:00) | `lib/features/radio/data/dev_show_schedule_data.dart`, wystawiane przez `currentShowProvider` (`presentation/radio_providers.dart`) | Repozytorium/API dostarczające prawdziwe metadane bieżącej audycji (docelowo ICY metadata i/lub ramówka), podpięte w miejscu `currentShowProvider` bez zmian w widgetach (`docs/RADIO_UI.md`) | OPEN |
| PH-011 | Radio UI — podgląd ramówki | Statyczna lista `devSchedulePreview` (4 pozycje) | `lib/features/radio/data/dev_show_schedule_data.dart`, wystawiane przez `schedulePreviewProvider` (`presentation/radio_providers.dart`) | Repozytorium/API prawdziwej ramówki, podpięte w miejscu `schedulePreviewProvider` bez zmian w `SchedulePreview` (`docs/RADIO_UI.md`); pełny ekran `/schedule` nadal jest placeholderem (`AppDetailPage`) | OPEN |

## Jak dostarczyć realne wartości

Wszystkie powyższe wartości są sterowane przez `--dart-define`, np.:

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://api.radiozulawy.pl \
  --dart-define=WORDPRESS_API_URL=https://radiozulawy.pl/wp-json/wp/v2 \
  --dart-define=RADIO_STREAM_URL=https://stream.radiozulawy.pl/live