import { createElement as h, useLayoutEffect, useRef, useState } from "react";
import { Chat } from "@duskmoon-dev/components";

export default function ReviewChat({ submit }) {
  const [draft, setDraft] = useState("");
  const [turns, setTurns] = useState([]);
  const [error, setError] = useState(null);
  const transcript = useRef(null);

  useLayoutEffect(() => {
    const log = transcript.current;
    log.scrollTop = log.scrollHeight;
  }, [turns]);

  async function send({ value }) {
    setError(null);
    try {
      const reply = await submit({ message: value });
      if (reply.error) {
        setError(reply.error);
        return false;
      }
      setTurns(current => [...current, reply]);
      return true;
    } catch {
      setError("Could not send the message. Try again.");
      return false;
    }
  }

  function message(text, fromUser, key) {
    return h(Chat, { key, placement: fromUser ? "end" : "start" },
      h(Chat.Header, null, fromUser ? "You" : "Demo assistant"),
      h(Chat.Bubble, { color: fromUser ? "primary" : "neutral", style: { whiteSpace: "pre-wrap" } }, text),
    );
  }

  return h("div", { style: { display: "grid", gap: "1rem", maxWidth: "48rem" } },
    h("div", {
      ref: transcript,
      role: "log",
      "aria-label": "Conversation",
      tabIndex: 0,
      style: { minHeight: "12rem", maxHeight: "24rem", overflowY: "auto" },
    },
      message("Ready to review a release? Send a message to try the conversation.", false, "welcome"),
      ...turns.flatMap(({ message: text, reply }, index) => [
        message(text, true, `user-${index}`),
        message(reply, false, `assistant-${index}`),
      ]),
    ),
    h(Chat.Composer, {
      value: draft,
      onValueChange: setDraft,
      onSubmit: send,
      error,
      textareaProps: { "aria-label": "Message", placeholder: "Write a message", maxLength: 500 },
    }, h(Chat.ComposerHint, null, "Ctrl or ⌘ + Enter to send")),
  );
}
