import { useState, type FormEvent } from "react";

import { sendMessage } from "./api";

export function ContactForm() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);

    try {
      await sendMessage({ email, message });
      setEmail("");
      setMessage("");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(event) => setEmail(event.target.value)}
        required
      />
      <textarea
        value={message}
        onChange={(event) => setMessage(event.target.value)}
        required
      />
      <button type="submit" disabled={isSubmitting}>
        Send
      </button>
    </form>
  );
}
