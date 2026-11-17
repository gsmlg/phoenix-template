import { registerAll } from "@duskmoon-dev/elements";
import { AppearancePreference, synchronizeTheme } from "./theme.js";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

registerAll();
synchronizeTheme();

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...DuskmoonHooks, AppearancePreference },
});

liveSocket.connect();
window.liveSocket = liveSocket;

