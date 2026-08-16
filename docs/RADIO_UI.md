# Radio UI — finalny ekran Radio Live

Ten dokument opisuje finalny ekran Radio Live (`RadioHomeScreen`,
`lib/features/radio/presentation/`): strukturę, separację playback vs
metadata, źródła danych deweloperskich i zachowanie mini-playera. Dopełnia
`docs/AUDIO.md` (audio engine/playback state) i `docs/DESIGN_SYSTEM.md`
(tokeny/komponenty) — nie duplikuje ich treści.

## Struktura ekranu

`RadioHomeScreen` (`radio_home_screen.dart`) komponuje mniejsze widgety z
`lib/features/radio/presentation/widgets/`:

```text
RadioHomeScreen
├── RadioHeader           branding: "Radio Żuławy", "106.4 FM", LiveBadge
├── RadioHeroPlayer        karta hero (gradient, glow gdy playing)
│   ├── RadioArtwork        artwork/placeholder, responsywny rozmiar
│   ├── CurrentShowInfo      "TERAZ" + tytuł + prowadzący + godziny
│   ├── RadioMainControl     centralny play/pause
│   ├── PlaybackStatus       status ("Buforowanie…", "Słuchasz na żywo", …)
│   └── ErrorState           (core/widgets) zamiast powyższych, gdy hasError
├── SchedulePreview        sekcja "Co dalej" (2–4 pozycje) + link do ramówki
└── RadioQuickActions      "Udostępnij" / "Ramówka" (stacked, nie side-by-side)