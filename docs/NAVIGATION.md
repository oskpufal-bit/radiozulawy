# Nawigacja — App Shell

Ten dokument opisuje szkielet nawigacyjny aplikacji: `AppShell`, pięć
głównych gałęzi, hierarchię tras i zasady dodawania nowych ekranów. Dopełnia
`docs/ARCHITECTURE.md` (nie duplikuje jego treści) i zakłada znajomość
Design Systemu (`docs/DESIGN_SYSTEM.md`).

## App Shell

`lib/app/shell/app_shell.dart` (`AppShell`) to widget przekazywany jako
`builder` do `StatefulShellRoute.indexedStack` w
`lib/app/router/app_router.dart`. Otrzymuje `StatefulNavigationShell` i:

- renderuje aktywną gałąź jako `Scaffold.body`,
- pokazuje `AppBottomNavigation` (`core/widgets/app_bottom_navigation.dart`)
  jako `bottomNavigationBar`, nad nią zarezerwowany slot na globalny
  mini-player (patrz niżej),
- mapuje 4 zwykłe pozycje bottom navigation (Radio/Newsy/Podcasty/Więcej) na
  indeksy gałęzi `[0, 1, 3, 4]` — gałąź `2` (Zgłoś) nie ma odpowiednika w
  zwykłej nawigacji, bo to wyniesiony przycisk centralny (`onReportTap` →
  `navigationShell.goBranch(2)`),
- normalizuje przycisk "wstecz" na Androidzie (patrz "Back button" niżej).

## Pięć głównych gałęzi

Każda gałąź to osobny `StatefulShellBranch` z własnym `Navigator` i własnym
stanem (scroll position, ewentualny stack podekranów), zachowywanym przy
przełączaniu zakładek — to `StatefulShellRoute.indexedStack` daje "za darmo".

| # | Gałąź | Ścieżka | Ekran | Feature |
|---|-------|---------|-------|---------|
| 0 | Radio (domyślna) | `/` | `RadioHomeScreen` | `features/radio` |
| 1 | Newsy | `/news` | `NewsPage` | `features/news` |
| 2 | Zgłoś | `/submit` | `SubmitPage` | `features/submit` |
| 3 | Podcasty | `/podcasts` | `PodcastsPage` | `features/podcasts` |
| 4 | Więcej | `/more` | `MorePage` | `features/more` |

Tapnięcie już aktywnej zakładki resetuje ją do lokalizacji początkowej
(`goBranch(index, initialLocation: true)`) — standardowa konwencja bottom
navigation.

## Trasy szczegółowe wewnątrz gałęzi

`/news/:slug` i `/podcasts/:id` są dziećmi swoich `GoRoute` w obrębie gałęzi
— pushowane na **Navigatorze danej gałęzi**, więc bottom navigation zostaje
widoczna, a powrót (`context.pop()`) przywraca poprzedni kontekst listy
(scroll, filtry). To domyślne zachowanie go_router dla zagnieżdżonych tras w
`StatefulShellRoute` — nic dodatkowego nie trzeba pisać, żeby np. wejść w
artykuł, wrócić, przełączyć się na Radio, wrócić do Newsów i zastać tę samą
pozycję.

Obie trasy używają wspólnego `AppDetailPage`
(`core/widgets/app_detail_page.dart`) — lekkiego, reużywalnego "detail
screen shell" (ikona + tytuł + opis + przycisk wstecz z fallbackiem, gdy
trasa zostanie otwarta bezpośrednio np. z przyszłego deep linku). Docelowe
ekrany artykułu/odcinka zastąpią to realną treścią.

## Trasy pełnoekranowe ("Więcej")

`Ramówka`, `Konkursy`, `Ustawienia`, `O radiu`, `Kontakt`, `Polityka
prywatności` (`/schedule`, `/contests`, `/settings`, `/about`, `/contact`,
`/privacy`) są zdefiniowane **poza** `StatefulShellRoute`, z
`parentNavigatorKey` wskazującym na root `Navigator` aplikacji
(`_rootNavigatorKey` w `app_router.dart`). Dzięki temu pushują się nad całym
shellem — bottom navigation znika, tak jak w większości aplikacji zachowują
się ekrany ustawień/prawne. Wszystkie sześć również korzysta z
`AppDetailPage`.

To świadoma różnica względem `/news/:slug` i `/podcasts/:id`: te ostatnie są
treścią przeglądaną w kontekście zakładki (bottom nav ma sens), podczas gdy
"Więcej" prowadzi do ekranów narzędziowych, które nie muszą pokazywać
nawigacji głównej.

## Route constants i granica architektury

`AppRoutes` (w `app_router.dart`) jest jedynym źródłem prawdy dla ścieżek —
ale zgodnie z kierunkiem zależności z `docs/ARCHITECTURE.md`
(`features/* → core/* → app/*(config)`, nigdy odwrotnie), feature'y **nie
importują** `app/router` (importowałyby z powrotem plik, który sam je
importuje). Dlatego np. `NewsPage` nawiguje przez `context.go('/news/$slug')`
z literalną ścieżką lokalną dla swojego feature'a, zamiast importować
`AppRoutes.newsArticle(...)`. To nie jest niespójność — to świadomy
kompromis: `AppRoutes` centralizuje ścieżki dla `app/` (router, `AppShell`,
przyszłe deep linki), a każdy feature zna tylko własny, jednoinstancyjny
prefiks ścieżki.

## Mini-player slot

`AppShell` rezerwuje miejsce nad `AppBottomNavigation` dla globalnego
mini-playera (`core/widgets/mini_player_shell.dart`). Widoczność sterowana
jest realnym stanem audio: `radioPlaybackControllerProvider`
(`features/radio`, patrz `docs/AUDIO.md`) —
`RadioPlaybackState.isSessionActive` (loading/buffering/playing/paused).

Dodatkowo mini-player jest ukrywany na gałęzi Radio
(`navigationShell.currentIndex == 0`): `RadioHomeScreen` ma już własny, duży
hero player pokazujący dokładnie ten sam stan (patrz `docs/RADIO_UI.md`), więc
pokazywanie obu naraz byłoby zbędnym zdublowaniem tej samej kontrolki
play/pause. Na pozostałych czterech gałęziach mini-player pojawia się/znika
przez `AnimatedSwitcher`, gdy sesja audio startuje/kończy się.

## Back button (Android)

System back:

1. **Podekran w obrębie gałęzi** (np. `/news/:slug`) — go_router sam
   propaguje pop do aktywnego `Navigator`a gałęzi przed czymkolwiek innym
   (`GoRouterDelegate._findCurrentNavigators`), więc to działa bez
   dodatkowego kodu w `AppShell`.
2. **Root gałęzi innej niż Radio** (np. `/news`, `/more`, ...) — `AppShell`
   owija zawartość w `PopScope` z `canPop: navigationShell.currentIndex ==
   0`; gdy nie ma nic do popnięcia w bieżącej gałęzi, `onPopInvokedWithResult`
   przełącza z powrotem na gałąź Radio zamiast zamykać aplikację.
3. **Root gałęzi Radio** — `canPop` jest `true`, więc dochodzi do
   standardowego zachowania systemowego (zwykle zamknięcie aplikacji).

`goBranch` nigdy nie stackuje głównych zakładek — przełączanie zakładek nie
tworzy nowych wpisów na stosie, więc nie ma ryzyka nieskończonego
"odkładania" zakładek.

## Przejścia (transitions)

Przełączanie głównych zakładek (`IndexedStack` pod spodem) nie ma żadnej
animacji — to celowe (patrz zadanie: "główne zakładki nie powinny wykonywać
ciężkiej animacji"). Wszystkie trasy szczegółowe (`/news/:slug`,
`/podcasts/:id`, sześć tras "Więcej") używają wspólnego, subtelnego fade
(`_fadeTransitionPage` w `app_router.dart`, `AppDurations.normal`).

## Dev route

`/dev/design-system` (`DesignSystemPreviewPage`) pozostaje poza shellem, nie
jest linkowany z bottom navigation — reachable tylko przez bezpośrednie
wejście na trasę. Patrz `docs/DEV_PLACEHOLDERS.md` (PH-008).

## Deep link readiness

Struktura tras (`/news/:slug`, `/podcasts/:id`, ...) jest już gotowa pod
przyszłe mapowanie z deep linków (`radiozulawy://news/123` → `/news/123`).
Ten etap **nie konfiguruje** natywnego odbioru linków (Android
`intent-filter`, iOS Universal Links) ani Firebase Dynamic/App Links — to
osobne zadanie, gdy pojawią się realne dane (domena, konfiguracja Firebase).

## Jak dodać nowy ekran

- **Nowa zakładka główna** — wymaga przebudowy `AppShell`/bottom navigation
  (5 pozycji jest świadomym, docelowym układem tego etapu); nie dodawaj
  szóstej zakładki bez rozmowy o layoucie.
- **Nowy podekran w istniejącej zakładce** (np. `/news/:slug/comments`) —
  dodaj `GoRoute` jako dziecko odpowiedniego `GoRoute` gałęzi w
  `app_router.dart`; dziedziczy Navigator gałęzi za darmo.
- **Nowy ekran pełnoekranowy** (jak "Więcej") — dodaj `GoRoute` na
  najwyższym poziomie `routes` w `appRouterProvider`, z
  `parentNavigatorKey: _rootNavigatorKey`.
- Każdy nowy ekran komponuje Design System (`docs/DESIGN_SYSTEM.md`) —
  `AppBackground` jako bazę, resztę z `core/widgets/`. Nie twórz nowego
  globalnego `AppBar`/layoutu — apka celowo nie wymusza jednego wzorca
  nagłówka dla wszystkich ekranów (Radio/Newsy/Podcasty/Zgłoś mają różne
  potrzeby hero/header).