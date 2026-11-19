import { registerAll } from "@duskmoon-dev/elements";
import { AppearancePreference, synchronizeTheme } from "./theme.js";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

registerAll();
synchronizeTheme();

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

const MountReactForm = {
  async mounted() {
    try {
      const { mountReactForm } = await import("./react_form.js");
      if (this.formRemoved) return;

      this.reactRoot = mountReactForm(this.el, values => this.pushEvent("react-form-submit", values));
    } catch {
      if (!this.formRemoved) {
        this.el.querySelector("[role='status']").textContent = "Could not load the React form. Refresh to retry.";
      }
    }
  },

  destroyed() {
    this.formRemoved = true;
    this.reactRoot?.unmount();
  },
};

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...DuskmoonHooks, AppearancePreference, MountReactForm },
});

liveSocket.connect();
window.liveSocket = liveSocket;

