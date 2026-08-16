import 'package:flutter/services.dart';

/// Abstraction over "share this text somewhere", so features (radio, and
/// later news/podcasts/contests — see docs/DESIGN_SYSTEM.md's reuse
/// principle) depend on a small interface instead of a concrete mechanism.
abstract class ShareService {
  Future<void> share(String text);
}

/// Copies [text] to the system clipboard. Deliberately not a real system
/// share sheet yet — no extra dependency required, and it behaves
/// identically in widget tests/CI. Swapping in a real share package (e.g.
/// `share_plus`) later only touches this file, see docs/RADIO_UI.md.
class ClipboardShareService implements ShareService {
  const ClipboardShareService();

  @override
  Future<void> share(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}