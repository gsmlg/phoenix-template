import { registerAll } from "@duskmoon-dev/elements";
import { AppearancePreference, synchronizeTheme } from "./theme.js";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "duskmoon_phoenix/hooks";

registerAll();
synchronizeTheme();

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

function reactDemoHook(demo, event) {
  return {
    async mounted() {
      const showError = () => {
        this.el.querySelector("[role='status']").textContent = "Could not load this React demo. Refresh to retry.";
      };

      try {
        // TODO(upstream): duskmoon-dev/duskmoon-bundler#42
        // WORKAROUND(upstream): Keep the demos in one lazy entry until hashed split imports resolve correctly.
        const { mountReactDemo } = await import("./react_mount.js");
        if (this.demoRemoved) return;

        const props = JSON.parse(this.el.dataset.reactProps || "{}");
        this.reactRoot = mountReactDemo(this.el, demo, {
          ...props,
          submit: values => this.pushEvent(event, values),
        }, showError);
      } catch {
        if (!this.demoRemoved) showError();
      }
    },

    destroyed() {
      this.demoRemoved = true;
      this.reactRoot?.unmount();
    },
  };
}

const ConfirmationDialog = {
  mounted() {
    this.cancelOnEscape = event => {
      event.preventDefault();
      this.js().push(this.el, "cancel_remove");
    };
    this.el.addEventListener("cancel", this.cancelOnEscape);
    this.el.showModal();
  },

  destroyed() {
    this.el.removeEventListener("cancel", this.cancelOnEscape);
    this.el.close();
    const focusTarget = this.el.ownerDocument.querySelector(this.el.dataset.returnFocus);
    focusTarget?.focus({ preventScroll: true });
  },
};

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    ...DuskmoonHooks,
    AppearancePreference,
    ConfirmationDialog,
    MountReactForm: reactDemoHook("projectForm", "react-form-submit"),
    MountReactChat: reactDemoHook("chat", "react-chat-send"),
    MountReactSchemaForm: reactDemoHook("schemaForm", "react-schema-submit"),
  },
});

liveSocket.connect();
window.liveSocket = liveSocket;

