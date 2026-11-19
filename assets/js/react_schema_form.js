import { createElement as h, useRef, useState } from "react";
import { JsonSchemaForm } from "@duskmoon-dev/components/json-schema-form";

export default function ProjectSchemaForm({ schema, submit }) {
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const pending = useRef(false);

  async function save(values) {
    if (pending.current) return;
    pending.current = true;
    setSubmitting(true);

    try {
      const reply = await submit(values);
      setErrors(reply.errors ?? {});
    } catch {
      setErrors({ "": "Could not submit the project. Try again." });
    } finally {
      pending.current = false;
      setSubmitting(false);
    }
  }

  return h("fieldset", { disabled: submitting },
    h(JsonSchemaForm, {
      schema,
      errors,
      onErrorsChange: setErrors,
      onSubmit: save,
    }),
  );
}
