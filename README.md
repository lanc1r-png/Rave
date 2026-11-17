# Raven

A local-first audiobook player for iPhone with an iOS 26 Liquid Glass interface.

## Features

- **Local library**: add folders of audio files (mp3, m4a, m4b, aac, wav, flac) from the Files app
- **Remembers your place**: progress per book and chapter, background playback, lock screen controls
- **Bookmarks**: save a position, rename or delete it, tap to jump back
- **Finished mark**: books are marked as listened automatically at the end, or by hand
- **Bedtime mode**: sleep timer with a fade-out
- **Home screen widget**: "Continue listening" with cover and progress
- **Languages**: English and Russian

## Building

Open `Raven.xcodeproj` in Xcode 26 and run, or let GitHub Actions build an unsigned IPA
(`.github/workflows/build.yml`).

The app and the widget share data through the App Group `group.com.Imaginebowl.Raven`.
If you change the bundle identifiers, update the group in `Configuration/*.entitlements`,
`Raven/Services/WidgetSync.swift` and `RavenWidget/WidgetSnapshot.swift`.
