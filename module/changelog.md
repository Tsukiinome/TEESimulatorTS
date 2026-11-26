## 🚀 TEESimulatorTS 5.1

## ✨ What's new

- **⏳ Early keybox-expiry warning.** A profile's keybox (or backup) now shows a "expires in N
  days" chip on the profile list — and in the editor, under whichever field it is — starting 14
  days before its certificate actually expires. Previously the only way to notice was opening the
  keybox inspector by hand; now it's visible on an ordinary visit to the WebUI, well before the
  fallback switch (or an outright attestation failure) would otherwise be your first sign.
- **🔁 Automatic backup keybox now also triggers on expiry, not just revocation.** The health
  check the fallback feature relies on previously only failed a keybox for a broken chain, an
  untrusted root, or a revoked serial — an *expired* certificate slipped through as "healthy" and
  kept signing with it. It's now treated exactly like a revoked one, so expiry alone is enough to
  fall over to a healthy backup (or to show "keybox unhealthy" with none set).
- **🐛 Fixed:** the "using backup keybox" / "keybox unhealthy" chips and hints never actually
  appeared — the daemon's `/status` response carried the data correctly, but the WebUI's status
  reader silently dropped the field before it reached the profile list or editor. Both now show up
  as originally intended.

## 📦 Also still here (5.0 / 5.0.1)

- Automatic backup keybox, one-tap "load current" for patch levels, deeper TrickyStore migration
  on first install, and the `TEESimulatorTS` naming/packaging from 5.0.1 — see this fork's
  repository for the full history.

## 💬 Feedback

Please open issues on this fork's repository. Upstream's own highlights (reference KeyMint TA,
profiles, Android 10–17 support, patch mode by default) all still apply unchanged — see
[JingMatrix/TEESimulator](https://github.com/JingMatrix/TEESimulator) for the full story of 4.0,
the base this release is built on.
