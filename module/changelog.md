## 🏷️ TEESimulatorTS 5.0.1

Renames the module itself — and the zip it ships as — from `TEESimulator` to `TEESimulatorTS`, to
match this fork's repository name: it now shows as **TEESimulatorTS** in KernelSU/Magisk's module
list, and future release/canary zips read `TEESimulatorTS-...` instead of `TEESimulator-...`. Pure
naming change, no behavior difference from 5.0.

## ✨ Still on top of upstream v4.0 (first added in 5.0)

- **🔁 Automatic backup keybox.** Give a profile a second keybox. Every config push, the daemon
  runs the same health check the WebUI's inspector does (parses, chains to a Google root, not on
  the revocation list) and silently switches to the backup if the primary ever fails it — a keybox
  Google revokes degrades your profile instead of breaking it. The profile list and editor show
  which one is actually in use.
- **⚡ One-tap "load current" for patch levels.** A button next to each patch/OS field writes the
  device's real, currently-harvested value straight into the field — no more typing a date by hand.
- **📥 Deeper TrickyStore migration.** First install now adopts, from TrickyStore's own files under
  `/data/adb/tricky_store`: the keybox, the app list (`target.txt`), and the global patch-level
  override (`security_patch.txt`). Switching over should mean flipping a module on, not
  re-entering everything by hand.

## 💬 Feedback

Please open issues on this fork's repository. Upstream's own highlights (reference KeyMint TA,
profiles, Android 10–17 support, patch mode by default) all still apply unchanged — see
[JingMatrix/TEESimulator](https://github.com/JingMatrix/TEESimulator) for the full story of 4.0,
the base this release is built on.
