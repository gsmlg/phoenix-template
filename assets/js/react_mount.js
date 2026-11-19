import { createElement as h, useLayoutEffect } from "react";
import { createRoot } from "react-dom/client";
import ReviewChat from "./react_chat.js";
import ProjectForm from "./react_form.js";
import ProjectSchemaForm from "./react_schema_form.js";

const demos = { chat: ReviewChat, projectForm: ProjectForm, schemaForm: ProjectSchemaForm };

function ReadyDemo({ children, onReady }) {
  useLayoutEffect(onReady, [onReady]);
  return children;
}

export function mountReactDemo(host, demo, props, showError) {
  const shadow = host.attachShadow({ mode: "open" });
  const stylesheet = document.createElement("link");
  stylesheet.rel = "stylesheet";
  stylesheet.href = host.dataset.reactStylesheet;
  const fallback = document.createElement("slot");
  const container = document.createElement("div");
  const root = createRoot(container);

  // Keep the server-rendered skeleton visible until the styled demo commits.
  stylesheet.onload = () => {
    root.render(h(ReadyDemo, { onReady: () => fallback.remove() }, h(demos[demo], props)));
  };
  stylesheet.onerror = showError;
  shadow.append(stylesheet, fallback, container);

  return {
    unmount() {
      stylesheet.onload = null;
      stylesheet.onerror = null;
      root.unmount();
    },
  };
}
