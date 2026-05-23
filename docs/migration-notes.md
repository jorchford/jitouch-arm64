# Migration Notes

This project started as a practical investigation into why Jitouch still feels unusually responsive compared with broader tools such as BetterTouchTool.

## Findings

- The historical Jitouch download was x86_64-only.
- On Apple Silicon it runs through Rosetta, and a local crash report showed `translated: true` and `cpuType: X86-64`.
- The open-source `v2.82.1` source builds cleanly as `arm64 + x86_64` with modern Xcode.
- Both Jitouch and modern gesture tools can observe low-level trackpad activity, but Jitouch's recognizers are more specialized and more permissive for hand posture.

## Packaging Change

The original app distribution expected users to install a preference pane. For this fork, the app is packaged as a normal drag-to-Applications app:

```text
Jitouch.app
  Contents/MacOS/Jitouch
  Contents/Resources/Jitouch.prefPane
```

The preference pane is kept for settings, but the outer `Jitouch.app` is the only runtime app.

## Duplicate App Cleanup

During local testing, Spotlight showed many `Jitouch` results because Xcode build products, old extracted downloads, mounted DMGs, and nested preference-pane apps were all indexed.

The release package now removes the historical nested `Jitouch.app` from the embedded preference pane.

The clean installed state should be:

```text
/Applications/Jitouch.app
/Applications/Jitouch.app/Contents/Resources/Jitouch.prefPane
```
