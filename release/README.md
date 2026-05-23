# Release Artifacts

Release binaries are uploaded to GitHub Releases instead of committed to git.

Expected files for the latest local build:

```text
Jitouch-arm64-universal.dmg
Jitouch-app-drag-to-Applications.zip
SHA256SUMS
```

Use `./scripts/build-single-app.sh` to regenerate them.
