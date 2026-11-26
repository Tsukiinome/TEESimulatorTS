// Read-only device status for the Status tab. It comes from the daemon's
// GET /status endpoint, reached through the same transport seam as the key
// manager (data/keyadmin.js) so the token+HTTP details live in exactly one file.
//
// The daemon's /status is richer than probing the device directly: it reports the
// live lib{hook, api} it learns from the interceptor's hello, so "active" reflects
// what actually attached rather than a guess from /proc maps. If the daemon isn't
// reachable we return a well-formed "unreachable" snapshot the view can explain,
// never a thrown error.

import { keyAdmin } from "./keyadmin.js";

// getStatus() -> {
//   daemonRunning, reachable, hookActive, hook, api, harvest, activeKeyboxes, keyboxExpiry, error?
// }
export async function getStatus() {
  try {
    const res = await keyAdmin("status"); // { ok, harvest, lib:{ hook, api }, activeKeyboxes, keyboxExpiry }
    const lib = (res && res.lib) || {};
    const hook = lib.hook || "unknown";
    return {
      daemonRunning: true,
      reachable: true,
      hook,
      api: lib.api || "",
      hookActive: !!(hook && hook !== "unknown"),
      harvest: (res && res.harvest) || null,
      // { profileId: { keybox, usingFallback, primaryHealthy } }, straight from the daemon — see
      // config-controller.js's keyboxStatusFor. Was silently dropped here before, so the "using
      // backup keybox" / "keybox unhealthy" chips never actually showed up in the WebUI.
      activeKeyboxes: (res && res.activeKeyboxes) || null,
      // { filename: notAfterMillis | null }, one entry per keybox any profile currently names.
      keyboxExpiry: (res && res.keyboxExpiry) || null,
    };
  } catch (e) {
    return {
      daemonRunning: false,
      reachable: false,
      hook: "unknown",
      api: "",
      hookActive: false,
      harvest: null,
      activeKeyboxes: null,
      keyboxExpiry: null,
      error: e && e.message ? e.message : String(e),
    };
  }
}
