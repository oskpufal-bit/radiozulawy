package pl.radiozulawy.radiozulawy

import com.ryanheise.audioservice.AudioServiceActivity

// Extends AudioServiceActivity (not FlutterActivity) so audio_service can
// share this activity's FlutterEngine with its background playback service
// — required for the media notification/lock-screen controls to work. See
// docs/AUDIO.md.
class MainActivity : AudioServiceActivity()
