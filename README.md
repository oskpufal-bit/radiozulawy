# Radio Żuławy 106.4 FM

Oficjalna aplikacja mobilna Radia Żuławy 106.4 FM — obejmująca Elbląg,
Malbork, Żuławy, Powiśle, Mierzeję Wiślaną i okolice. Docelowo: radio na
żywo, aktualności, podcasty, konkursy, zgłaszanie zdarzeń, ramówka i
powiadomienia.

Projekt jest we wczesnej fazie developmentu — obecnie zbudowany jest
fundament techniczny (architektura, DI, routing, networking, storage), a
funkcjonalności biznesowe powstają w kolejnych zadaniach.

## Wymagania

- Flutter `3.44.4` (channel stable)
- Dart SDK `^3.12.2` (dołączony do powyższego Fluttera)

## Uruchomienie

```bash
flutter pub get
flutter run
```

Domyślnie aplikacja startuje z bezpiecznymi placeholderami deweloperskimi
(brak realnego API/streamu — patrz niżej). Żeby wskazać realne środowisko,
użyj `--dart-define`, np.:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.radiozulawy.pl \
  --dart-define=RADIO_STREAM_URL=https://stream.radiozulawy.pl/live
```

## Dokumentacja

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — struktura projektu, zasady
  dependency direction, jak dodawać nowe feature'y.
- [`docs/DEV_PLACEHOLDERS.md`](docs/DEV_PLACEHOLDERS.md) — rejestr wszystkich
  wartości deweloperskich (URL-e, klucze), które trzeba uzupełnić przed
  produkcją.

## Integracje zewnętrzne

Adresy API (WordPress, backend konkursów/zgłoszeń), stream radia oraz linki
prawne są na tym etapie **development placeholderami** (domena
`*.dev-placeholder.invalid`, celowo nierozwiązywalna) — patrz
`docs/DEV_PLACEHOLDERS.md`. Panel administracyjny (`radiozulawy.pl/madminpanel`)
to osobny, niezależny system i nie jest częścią tego repozytorium.