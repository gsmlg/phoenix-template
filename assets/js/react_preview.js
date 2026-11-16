import { createElement as h, useState } from "react";
import { createRoot } from "react-dom/client";
import { Badge, Button, Card } from "@duskmoon-dev/components";

function Preview() {
  const [approved, setApproved] = useState(0);
  const complete = approved === 3;

  return h(Card, { appearance: "outline", padding: "lg" },
    h("div", { className: "space-y-5" },
      h("div", { className: "flex flex-wrap items-start justify-between gap-3" },
        h("div", null,
          h("p", { className: "text-xs font-semibold uppercase tracking-widest text-on-surface-variant" }, "React preview"),
          h("h3", { className: "mt-2 text-lg font-semibold" }, "Approval queue"),
        ),
        h(Badge, { color: complete ? "success" : "info", appearance: "tonal" }, complete ? "Complete" : "In review"),
      ),
      h("p", { id: "react-approval-count", className: "text-3xl font-semibold tabular-nums", "aria-live": "polite" }, `${approved} of 3 approved`),
      h("p", { className: "text-sm text-on-surface-variant" }, "A synthetic review queue. Approvals stay in this preview and reset on reload."),
      h("div", { className: "flex flex-wrap gap-3" },
        h(Button, {
          id: "react-approve",
          color: "primary",
          disabled: complete,
          onClick: () => setApproved(value => Math.min(value + 1, 3)),
        }, complete ? "Queue complete" : "Approve item"),
        h(Button, {
          id: "react-reset",
          color: "neutral",
          appearance: "outline",
          onClick: () => setApproved(0),
        }, "Reset queue"),
      ),
    ),
  );
}

function synchronizeParentTheme() {
  if (window.parent === window) return () => {};

  let parentRoot;
  try {
    if (window.parent.location.origin !== window.location.origin) return () => {};
    parentRoot = window.parent.document.documentElement;
  } catch {
    return () => {};
  }

  const synchronize = () => {
    const theme = parentRoot.getAttribute("data-theme");
    if (theme === "sunshine" || theme === "moonlight") {
      document.documentElement.setAttribute("data-theme", theme);
    }
  };

  synchronize();
  const observer = new MutationObserver(synchronize);
  observer.observe(parentRoot, { attributes: true, attributeFilter: ["data-theme"] });
  return () => observer.disconnect();
}

const stopThemeSynchronization = synchronizeParentTheme();
window.addEventListener("pagehide", stopThemeSynchronization, { once: true });

createRoot(document.getElementById("react-preview")).render(h(Preview));
