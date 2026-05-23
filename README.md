# jitouch-arm64

An Apple Silicon friendly build of Jitouch, packaged as a normal drag-to-Applications macOS app.

Jitouch is still one of the most forgiving multi-touch gesture engines ever made for the Mac. Three-finger tap, One-Fix Left-Tap, One-Fix Right-Tap, tab gestures, middle click, and character gestures feel unusually responsive because the app reads raw trackpad contacts through Apple's private `MultitouchSupport` framework and runs its own hand-shape recognizers.

This fork keeps that feel and modernizes the distribution:

- universal `arm64 + x86_64` binaries built from source
- a single `Jitouch.app` that users can drag to `/Applications`
- self-managed LaunchAgent for login startup
- embedded preference pane for settings without installing a separate `.prefPane`
- no nested runtime app in the final package, so Spotlight does not show a row of duplicate Jitouch icons
- ad-hoc signed local release artifacts, with public checksums

## Download

Download the latest DMG from:

https://github.com/constansino/jitouch-arm64/releases/latest

The release also includes a ZIP copy and SHA-256 checksums.

Current builds are ad-hoc signed and not notarized. On first launch, macOS may ask for manual approval in Privacy & Security. The goal of this package is a clean native build and simple install path; a Developer ID notarized build can be added later.

## Why This Exists

The original Intel-only Jitouch builds can run through Rosetta on Apple Silicon, but the app remains an x86_64 binary. Rosetta can cache translated code, but it does not turn the app into a native ARM application.

This project rebuilds Jitouch from source as a universal binary. On Apple Silicon, macOS runs the `arm64` slice directly.

The other reason is feel. Many modern automation tools are powerful, but Jitouch's gesture model is narrower and more physical:

- it accepts rotated or horizontal hand posture
- it filters resting thumb and palm-like contacts
- it treats One-Fix gestures as first-class gestures, not as generic tap variants
- it has short state machines for common gestures such as Three-Finger Tap
- it stays small because it does not ship a broad automation platform around the recognizer

## Jitouch vs BetterTouchTool

BetterTouchTool is a large general automation system. Jitouch is a small gesture recognizer.

| Area | Jitouch ARM64 | BetterTouchTool |
| --- | --- | --- |
| Primary goal | Trackpad and Magic Mouse gestures | General macOS automation |
| Gesture model | Raw contact stream plus custom hand-shape recognizers | Broad trigger/action framework |
| Three-finger tap feel | Short, forgiving state machine | Can be affected by system/BTT gesture conflicts |
| Resting thumb | Explicitly filtered | Depends on trigger and recognition settings |
| One-Fix gestures | Built in | Usually approximated through other triggers |
| App bundle size on this test Mac | 1.9 MB | 184 MB |
| Main executable size on this test Mac | 319 KB | 98 MB |
| Linked-library listing on this test Mac | 28 `otool -L` lines | 236 `otool -L` lines |

These numbers are not a universal benchmark, but they explain the shape of the tools: BTT is intentionally huge and capable; Jitouch is intentionally tiny and tactile.

## Install

1. Download `Jitouch-arm64-universal.dmg` from the latest GitHub Release.
2. Drag `Jitouch.app` to `/Applications`.
3. Open `Jitouch.app`.
4. In macOS, allow Jitouch in Privacy & Security -> Accessibility.

Jitouch creates this LaunchAgent automatically when it is opened from `/Applications` or `~/Applications`:

```text
~/Library/LaunchAgents/com.jitouch.Jitouch.plist
```

The LaunchAgent points at the outer app:

```text
/Applications/Jitouch.app/Contents/MacOS/Jitouch
```

## Uninstall

```bash
launchctl unload "$HOME/Library/LaunchAgents/com.jitouch.Jitouch.plist" 2>/dev/null
killall Jitouch 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.jitouch.Jitouch.plist"
rm -rf /Applications/Jitouch.app
```

You may also remove Jitouch from Privacy & Security -> Accessibility.

## Build

Requirements:

- macOS with Xcode
- Apple Silicon or Intel Mac

Build a local ad-hoc signed app plus DMG/ZIP release artifacts:

```bash
./scripts/build-single-app.sh
```

Outputs:

```text
build/package/Jitouch.app
release/Jitouch-arm64-universal.dmg
release/Jitouch-app-drag-to-Applications.zip
release/SHA256SUMS
```

For public distribution, sign with a Developer ID certificate and notarize the DMG.

## What Changed From Upstream

This fork is based on `JitouchApp/Jitouch` tag `v2.82.1`.

Main packaging changes:

- the app can create its own LaunchAgent when launched from Applications
- the menu opens an embedded preference pane
- the embedded preference pane points startup back to the outer app when bundled inside `Jitouch.app`
- release packaging removes the preference pane's historical nested `Jitouch.app` copy to avoid duplicate Spotlight results

The gesture recognizer itself is preserved.

## Links

- Product homepage: https://jitouch-arm64.vercel.app
- Latest release: https://github.com/constansino/jitouch-arm64/releases/tag/v2.82.1-arm64.1
- Migration writeup: https://aiya.de5.net/t/topic/200

## License

Copyright (c) Supasorn Suwajanakorn and Sukolsak Sakshuwong. All rights reserved.  
Modified work copyright (c) Aaron Kollasch. All rights reserved.

Licensed under the [GNU General Public License v3.0](LICENSE).
