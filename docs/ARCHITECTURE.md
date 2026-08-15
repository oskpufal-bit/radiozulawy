# Architektura — Radio Żuławy 106.4 FM

Ten dokument opisuje fundament techniczny aplikacji i zasady, których powinni
trzymać się kolejni agenci/deweloperzy rozwijający projekt.

## Struktura katalogów

```text
lib/
├── app/            # kompozycja aplikacji: bootstrap, konfiguracja, router, theme
│   ├── bootstrap/  # start aplikacji (WidgetsFlutterBinding, DI, runApp) — testowalny
│   ├── config/     # AppConfig / AppEnvironment (wartości środowiskowe)
│   ├── router/      # centralna konfiguracja go_router
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
│   │                  # stany, GlassSurface, MiniPlayerShell, ...) — patrz
│   │                  # docs/DESIGN_SYSTEM.md
│   └── providers.dart # DI: sharedPreferences/localStorage/secureStorage/dio/apiClient
│
├── features/       # moduły biznesowe, feature-first
│   └── <feature>/
│       ├── data/         # źródła danych, repozytoria (implementacje)
│       ├── domain/       # modele i kontrakty repozytoriów (gdy potrzebne)
│       └── presentation/ # ekrany, widgety, providery Riverpod danego feature'a
│
└── main.dart       # wyłącznie wywołuje bootstrap()
```

`core/audio` i pozostałe podkatalogi `features/*` (news, podcasts, contests,
submissions, schedule, notifications, more) celowo **nie istnieją jeszcze** —
zgodnie z zasadą projektu nie tworzymy pustych katalogów na zapas. Twórz
katalog feature'a dopiero w zadaniu, które faktycznie go implementuje, trzymając
się układu `data/domain/presentation` powyżej (pomijaj warstwy, których dany
feature nie potrzebuje).

## Kierunek zależności

`features/*` → `core/*` → `app/*` (config) — nigdy odwrotnie.

- `core/` nie może importować niczego z `features/`.
- `app/` może importować `core/` i `features/` (bo składa je w całość), ale
  `core/` i `features/` nie mogą importować z `app/` **poza** `app/config`
  (odczyt konfiguracji jest dozwolony — patrz `AppConfig`).
- Feature'y nie importują się nawzajem bezpośrednio. Współdzielenie idzie przez
  `core/`.

## State management — Riverpod

`core/providers.dart` zawiera fundamentalne providery (SharedPreferences, Dio,
ApiClient, LocalStorage, SecureStorage). Providery specyficzne dla feature'a
(player state, news state, download state, ...) mają żyć w
`features/<feature>/presentation/` lub `features/<feature>/data/` — nie
w `core/`.

Używamy zwykłych providerów (`Provider`, `FutureProvider`, `NotifierProvider`)
bez code generation (`riverpod_annotation` + `build_runner`), żeby nie dokładać
zależności build_runner na tym etapie. Jeśli w przyszłości pojawi się
uzasadniona potrzeba code-gen, można to wprowadzić świadomie w dedykowanym
zadaniu.

## Routing — go_router

`app/router/app_router.dart` eksponuje `appRouterProvider`. Obecnie jest jedna
trasa (`/`, ekran startowy radia). Docelowo:

- bottom navigation → `StatefulShellRoute` w tym samym pliku (lub rozbite na
  `app/router/` gdy urośnie),
- zagnieżdżone trasy feature'ów (artykuł, odcinek podcastu, formularz
  zgłoszenia) jako dzieci odpowiednich `GoRoute`,
- deep linki z powiadomień mapowane na te same trasy.

Ścieżki tras trzymamy jako stałe w `AppRoutes`, nie jako magiczne stringi
rozrzucone po kodzie.

`initialLocation` obecnie wskazuje na `AppRoutes.devDesignSystem`
(`/dev/design-system`) — tymczasowo, na czas etapu Design Systemu (patrz
`docs/DEV_PLACEHOLDERS.md`). Kolejny etap (navigation shell) powinien
przywrócić realny ekran startowy jako `initialLocation`.

## Design System

`lib/app/theme/` zawiera design tokens (kolory, typografia, spacing, radius,
cienie, gradienty, blur, durations) i `AppTheme`. `lib/core/widgets/` zawiera
reużywalne komponenty zbudowane na tych tokenach (przyciski, karty, stany,
`GlassSurface`, `MiniPlayerShell`, `AppBottomNavigation`, ...). To jest
**jedyne** źródło prawdy dla stylu UI — nowe ekrany komponują te tokeny/
widgety zamiast definiować własne kolory/spacing/radius. Pełny opis:
`docs/DESIGN_SYSTEM.md`. Katalog komponentów można obejrzeć pod
`/dev/design-system` (`DesignSystemPreviewPage`, `lib/app/dev/`).

## Networking — Dio

`core/network/dio_client.dart` tworzy skonfigurowany `Dio` (base URL z
`AppConfig`, timeouty, logging tylko w debug). `core/api/ApiClient` to
wyższa warstwa, która łapie wyjątki i zamienia je na `AppFailure`
(`core/errors`). Feature'y powinny zależeć od `ApiClient`, nie bezpośrednio od
`Dio`.

**Zasada logowania:** interceptor loguje tylko metodę, ścieżkę i status
(`core/network/network_logging_interceptor.dart`). Nigdy nie loguj nagłówków,
body requestu/response, tokenów ani treści zgłoszeń użytkownika.

## Obsługa błędów

`core/errors/app_failure.dart` definiuje `sealed class AppFailure` z wariantami:
`NoConnectionFailure`, `TimeoutFailure`, `ServerFailure`, `InvalidResponseFailure`,
`UnknownFailure`. `failure_mapper.dart` mapuje `DioException`/inne wyjątki na te
warianty. UI powinno używać `switch` po `AppFailure`, nie sprawdzać typów
wyjątków transportowych.

## Storage

- `LocalStorage` (SharedPreferences) — ustawienia, onboarding, cache,
  metadane pobranych podcastów. Nic wrażliwego.
- `SecureStorage` (flutter_secure_storage) — tokeny, dane uwierzytelniające.
  Obecnie nieużywane (brak jeszcze logowania), ale przygotowane jako osobny,
  bezpieczny kanał, żeby nikt "z przyzwyczajenia" nie wrzucił tokenu do
  SharedPreferences.

## Konfiguracja środowiska

`app/config/app_config.dart` — wszystkie adresy/URL-e idą przez
`--dart-define` (np. `--dart-define=API_BASE_URL=...`), nigdy hardcode w
feature'ach. Brak zdefiniowanej wartości → bezpieczny placeholder deweloperski
pod domeną `*.dev-placeholder.invalid` (`.invalid` to zarezerwowana wg RFC 2606
domena, która nigdy się nie rozwiąże — appka nie wykona przypadkowego requestu
do prawdziwego hosta). Pełny rejestr placeholderów: `docs/DEV_PLACEHOLDERS.md`.

`AppEnvironment` (`dev`/`staging`/`prod`) sterowane przez `--dart-define=APP_ENV=...`,
domyślnie `dev`.

## Placeholdery deweloperskie

Każdy nowy placeholder (URL, klucz, mock) musi zostać zarejestrowany w
`docs/DEV_PLACEHOLDERS.md` w momencie jego wprowadzenia — to jest żywy dokument
aktualizowany przez kolejne zadania, nie tylko na tym etapie.

## Kluczowe decyzje architektoniczne

- **Feature-first**, nie layer-first — łatwiej skalować i przydzielać zadania
  kolejnym agentom bez konfliktów w tych samych katalogach.
- **Riverpod bez code-gen** na tym etapie — mniej zależności, prostszy setup.
- **go_router** jako jedyny mechanizm nawigacji, przygotowany pod deep linki.
- **Dio + ApiClient + AppFailure** jako jedyna droga komunikacji sieciowej —
  feature'y nigdy nie łapią `DioException` bezpośrednio.
- **`.invalid` placeholdery zamiast fikcyjnych, ale rozwiązywalnych domen** —
  eliminuje ryzyko przypadkowych requestów sieciowych podczas developmentu.
- **Panel administracyjny (`radiozulawy.pl/madminpanel`) nie jest częścią tego
  repozytorium** i nie powinien być tu implementowany.
