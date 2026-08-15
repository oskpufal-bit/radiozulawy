# Design System — Radio Żuławy 106.4 FM

Ten dokument opisuje wizualny i techniczny fundament UI aplikacji. Jest
źródłem prawdy dla kolorów, typografii, spacingu, radiusów, gradientów,
cieni i reużywalnych komponentów. Kolejne zadania (moduły biznesowe) powinny
**korzystać z tych tokenów i komponentów**, a nie tworzyć konkurencyjne.

Zweryfikuj wizualnie: uruchom aplikację — startuje na `/dev/design-system`
(`DesignSystemPreviewPage`), czyli katalogu wszystkich komponentów.

## Filozofia wizualna

Nowoczesna aplikacja streamingowa klasy premium z własną tożsamością Radia
Żuławy: ciemne tło o zielono-grafitowym charakterze (nigdy czysta czerń),
żywe zielone akcenty, zaokrąglone powierzchnie, selektywny glassmorphism,
spokojne gradienty, przestronny layout, mocna hierarchia typograficzna.
Inspiracja poziomem dopracowania współczesnych apek muzycznych — nie ich
layoutem.

Aplikacja jest **dark-first** (patrz `lib/app/theme/app_theme.dart`) —
`ThemeData` nie zakłada jednak istnienia tylko trybu ciemnego, więc light
theme można dodać później bez przebudowy.

## Kolory marki i paleta

Bazowe kolory marki: `Brand Dark Green #1A3D1F`, `Brand Green #2D7A35`.
Cała paleta żyje w `lib/app/theme/app_colors.dart` (`AppColors`) — **jedyne**
źródło kolorów w aplikacji:

- `brandDark`, `brandPrimary`, `brandBright` — marka i akcenty (przyciski,
  aktywne stany, live).
- `backgroundPrimary`, `backgroundSecondary` — tło ekranów (zielono-grafitowe,
  nigdy `#000000`).
- `surface`, `surfaceElevated`, `surfaceGlass` — powierzchnie kart/nakładek.
- `textPrimary`, `textSecondary`, `textMuted` — hierarchia tekstu.
- `borderSubtle`, `borderGlass` — subtelne obwódki zamiast ciężkich cieni.
- `success`, `warning`, `error`, `info` — kolory semantyczne.
- `live` — wskaźnik nadawania na żywo (zawsze z tekstem, patrz `LiveBadge`).

Nie twórz drugiej klasy kolorów (`RadioColors`, `CustomColors`, ...) — rozszerz
`AppColors`, jeśli brakuje odcienia.

## Typografia

`lib/app/theme/app_typography.dart` (`AppTypography`) definiuje skalę
(display/headline/title/body/label + caption/overline), używaną przez
`AppTheme` do zbudowania `TextTheme`. Font: **systemowy domyślny** (Roboto na
Androidzie) — stabilny offline, brak zależności sieciowej w runtime. Żaden
styl nie schodzi poniżej `FontWeight.w400`, żeby zachować czytelność dla
użytkowników 40+. Nowy tekst w UI powinien sięgać po `Theme.of(context).textTheme`
albo bezpośrednio po `AppTypography.*`, nie po ręcznie skonstruowany `TextStyle`.

## Spacing

`lib/app/theme/app_spacing.dart` (`AppSpacing`): `xxs(4) / xs(8) / sm(12) /
md(16) / lg(24) / xl(32) / xxl(48)` plus `screenHorizontal(20)` i
`screenVertical(16)` dla marginesów ekranu. Używaj tych stałych zamiast
magicznych liczb w `EdgeInsets`/`SizedBox`, gdy wartość reprezentuje rytm
layoutu. Pojedynczy, oczywisty `SizedBox(height: 4)` w bardzo lokalnym
kontekście nie wymaga eskalacji do abstrakcji.

## Radius

`lib/app/theme/app_radius.dart` (`AppRadius`): `sm(8) / md(12) / card(16) /
lg(24) / full(999)`, każdy też jako gotowy `BorderRadius` (`cardRadius`, itd).
Karty contentowe używają `card`, przyciski i chipy — `full` (pill).

## Cienie / elevation

`lib/app/theme/app_shadows.dart` (`AppShadows`): `low / medium / high` — bardzo
subtelne, bo w ciemnym UI ważniejszy jest kontrast powierzchni i border niż
klasyczny cień. `AppShadows.brandGlow()` daje miękką zieloną poświatę
(używane np. za centralnym przyciskiem "Zgłoś").

## Gradienty

`lib/app/theme/app_gradients.dart` (`AppGradients`): `backgroundPrimary` (tło
ekranów), `heroPlayer` (powierzchnie hero/player), `imageOverlay` (scrim pod
tekstem na zdjęciu), `glow()` (miękka poświata radialna). Zieleń może być
intensywna przy elementach aktywnych, ale całość ma pozostać spokojna —
unikaj neonowych zestawień.

## Blur / Glassmorphism

`lib/app/theme/app_blur.dart` (`AppBlur`: `subtle/standard/strong`) +
`lib/core/widgets/glass_surface.dart` (`GlassSurface`) — jedyny prymityw
blur w aplikacji.

**Stosuj blur dla:** bottom navigation, mini-playera, overlayów/modali,
pojedynczych wyróżnionych kart premium.

**NIE stosuj blur dla:** całych ekranów, list (każdy item), dużych/pełnoekranowych
powierzchni, elementów które rebuildują się często. `BackdropFilter` ma
realny koszt na średniej klasy Androidach — każda dodatkowa instancja to
kolejny przebieg kompozycji.

## Durations / Curves

`lib/app/theme/app_durations.dart`: `AppDurations.fast(150ms) / normal(250ms)
/ slow(400ms)`, `AppCurves.standard / emphasized`. Animacje mają być krótkie i
naturalne — to nie jest rozbudowany framework animacji, tylko wspólne stałe.

## Accessibility

- Kontrast: tekst wtórny (`textSecondary`/`textMuted`) dobrany pod ciemne tło,
  nie schodzi poniżej czytelności WCAG AA na `backgroundPrimary`/`surface`.
- Touch targets: przyciski/ikony ≥ 44dp (`AppPrimaryButton`/`AppSecondaryButton`
  mają wysokość 52dp, `AppIconButton` domyślnie 44dp).
- Skalowanie tekstu: nigdzie nie blokujemy `MediaQuery.textScaler` — layouty
  używają `Column`/`Wrap`/`Expanded`, nie sztywnych wysokości dla tekstu.
- `Semantics`: `LiveBadge`, `AppCategoryChip`, `AppIconButton`,
  `AppBottomNavigation` mają jawne etykiety/role. Informacja nigdy nie jest
  przekazywana wyłącznie kolorem (`LiveBadge` zawsze pokazuje tekst "NA ŻYWO").
- `AppSkeleton`/`LiveBadge` wyłączają animację, gdy platforma zgłasza
  `MediaQuery.disableAnimations` (reduced motion).

## Komponenty

| Komponent | Plik | Przeznaczenie |
|---|---|---|
| `AppBackground` | `core/widgets/app_background.dart` | Tło ekranu (gradient/flat), SafeArea, padding, tryb full-bleed |
| `GlassSurface` | `core/widgets/glass_surface.dart` | Blur + półprzezroczyste tło + border |
| `AppPrimaryButton` | `core/widgets/buttons/app_primary_button.dart` | Główne CTA (loading/disabled/ikona) |
| `AppSecondaryButton` | `core/widgets/buttons/app_secondary_button.dart` | Akcja drugorzędna (outline) |
| `AppIconButton` | `core/widgets/buttons/app_icon_button.dart` | Spójny icon button (share/download/favorite/more/close) |
| `AppSectionHeader` | `core/widgets/app_section_header.dart` | Nagłówek sekcji + opcjonalna akcja "Zobacz wszystkie" |
| `ContentSurface` | `core/widgets/content_surface.dart` | Bazowa karta contentowa (news/podcast/konkurs budują na tym) |
| `AppImageSurface` | `core/widgets/app_image_surface.dart` | Obraz z radius/placeholder/error/gradient overlay (bez API obrazów) |
| `LiveBadge` | `core/widgets/live_badge.dart` | Wskaźnik "NA ŻYWO" (tekst + subtelny puls) |
| `AppCategoryChip` | `core/widgets/app_category_chip.dart` | Chip/tag (selected/unselected/disabled) |
| `LoadingState` / `EmptyState` / `ErrorState` | `core/widgets/states/` | Spójne stany list/ekranów, `ErrorState` z opcjonalnym retry |
| `AppSkeleton` | `core/widgets/app_skeleton.dart` | Lekki shimmer bez zewnętrznej zależności |
| `MiniPlayerShell` | `core/widgets/mini_player_shell.dart` | Wyłącznie warstwa wizualna przyszłego mini-playera (bez audio) |
| `AppBottomNavigation` | `core/widgets/app_bottom_navigation.dart` | Wizualna dolna nawigacja, centralny "Zgłoś" wyniesiony |

## Jak dodawać nowe komponenty

1. Sprawdź, czy potrzebny token już istnieje w `lib/app/theme/` — nie twórz
   nowych stałych kolorów/spacing/radius poza tymi plikami.
2. Nowy reużywalny widget trafia do `lib/core/widgets/` (płasko lub w
   podkatalogu, jeśli grupa komponentów na to zasługuje, jak `buttons/` czy
   `states/`).
3. Widget specyficzny dla jednego ekranu/feature'a zostaje w
   `features/<feature>/presentation/` — nie w `core/`.
4. Preferuj kompozycję istniejących komponentów (`ContentSurface` +
   `AppImageSurface` + `AppSectionHeader`) nad jednym gigantycznym widgetem z
   dziesiątkami parametrów.
5. Dodaj komponent do `DesignSystemPreviewPage`
   (`lib/app/dev/design_system_preview_page.dart`), żeby był widoczny w
   katalogu.
6. Jeśli komponent ma nietrywialne zachowanie (stan, callbacks, disabled),
   dodaj test widgetowy w `test/core/widgets/`.
