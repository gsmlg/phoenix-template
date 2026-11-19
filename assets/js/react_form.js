import { createElement as h, useState } from "react";
import { createRoot } from "react-dom/client";
import { Button, Form, Input } from "@duskmoon-dev/components";

const nameRules = [{ required: true, message: "Enter a project name." }];

function ProjectForm({ initialName, submit }) {
  const [submitting, setSubmitting] = useState(false);
  const [nameError, setNameError] = useState(false);
  const [submitError, setSubmitError] = useState("");

  async function save(values) {
    if (submitting) return;

    setSubmitting(true);
    setSubmitError("");

    try {
      const reply = await submit(values);
      if (reply.error) setSubmitError(reply.error);
    } catch {
      setSubmitError("Could not reach the server. Try again.");
    } finally {
      setSubmitting(false);
    }
  }

  return h(Form, {
    layout: "vertical",
    initialValues: { name: initialName, description: "" },
    onFinish: save,
    onFinishFailed: () => {
      setNameError(true);
      setSubmitError("");
    },
    disabled: submitting,
    noValidate: true,
    "aria-label": "Project details",
  },
    h(Form.Item, {
      name: "name",
      label: "Project name",
      rules: nameRules,
      help: nameError
        ? h("span", { id: "react-project-name-error", role: "alert" }, nameRules[0].message)
        : undefined,
    }, h(Input, {
      required: true,
      maxLength: 60,
      "aria-invalid": nameError || undefined,
      "aria-describedby": nameError ? "react-project-name-error" : undefined,
      onChange: () => setNameError(false),
    })),
    h(Form.Item, { name: "description", label: "Description (optional)" },
      h(Input.TextArea, { rows: 3, maxLength: 200 }),
    ),
    h("div", null,
      h(Button, { type: "submit", color: "primary", isLoading: submitting, disabled: submitting },
        "Submit project",
      ),
    ),
    submitError && h("div", { role: "alert", className: "form-error-list" }, submitError),
  );
}

export function mountReactForm(host, submit) {
  const shadow = host.attachShadow({ mode: "open" });
  const stylesheet = document.createElement("link");
  stylesheet.rel = "stylesheet";
  stylesheet.href = host.dataset.reactStylesheet;
  const container = document.createElement("div");
  shadow.append(stylesheet, container);

  const root = createRoot(container);
  root.render(h(ProjectForm, { initialName: host.dataset.projectName, submit }));
  return root;
}
