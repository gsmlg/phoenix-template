import "@duskmoon-dev/elements/el-button/register";
import "@duskmoon-dev/elements/el-alert/register";
import { synchronizeTheme } from "./theme.js";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

synchronizeTheme();

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...DuskmoonHooks },
});

liveSocket.connect();
window.liveSocket = liveSocket;

