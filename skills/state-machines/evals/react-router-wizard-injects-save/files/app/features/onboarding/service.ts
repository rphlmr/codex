export type ApplicantDetails = {
  name: string;
  email: string;
};

export type Draft = {
  id: string;
};

export async function createDraft(details: ApplicantDetails): Promise<Draft> {
  const response = await fetch("/api/onboarding/drafts", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(details),
  });

  if (!response.ok) {
    throw new Error(`Draft request failed with ${response.status}`);
  }

  return response.json();
}

export async function submitApplication(
  draftId: string,
  documents: string[],
): Promise<void> {
  const response = await fetch(`/api/onboarding/drafts/${draftId}/submit`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ documents }),
  });

  if (!response.ok) {
    throw new Error(`Submit request failed with ${response.status}`);
  }
}
