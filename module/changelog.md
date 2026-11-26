## 🚀 TEESimulator 5.0 — this fork's first release

This is [@Tsukiinome](https://github.com/Tsukiinome)'s own line of
[JingMatrix/TEESimulator](https://github.com/JingMatrix/TEESimulator): same in-process reference
KeyMint TA, same profiles-and-WebUI design, built on top of upstream's v4.0 with enough added on
top — below — that it gets its own number from here rather than trailing upstream's as a patch
release.

## ✨ What's new on top of upstream v4.0

- **🔁 Automatic backup keybox.** Give a profile a second keybox. Every config push, the daemon
  runs the same health check the WebUI's inspector does (parses, chains to a Google root, not on
  the revocation list) and silently switches to the backup if the primary ever fails it — a keybox
  Google revokes degrades your profile instead of breaking it. The profile list and editor show
  which one is actually in use.
- **⚡ One-tap "load current" for patch levels.** A button next to each patch/OS field writes the
  device's real, currently-harvested value straight into the field — no more typing a date by hand.
- **📥 Deeper TrickyStore migration.** First install now adopts, from TrickyStore's own files under
  `/data/adb/tricky_store`: the keybox, the app list (`target.txt`), and — new in this release —
  the global patch-level override (`security_patch.txt`). Switching over should mean flipping a
  module on, not re-entering everything by hand.

## 💬 Feedback

Please open issues on this fork's repository. Upstream's own highlights (reference KeyMint TA,
profiles, Android 10–17 support, patch mode by default) all still apply unchanged — see
[JingMatrix/TEESimulator](https://github.com/JingMatrix/TEESimulator) for the full story of 4.0,
the base this release is built on.
