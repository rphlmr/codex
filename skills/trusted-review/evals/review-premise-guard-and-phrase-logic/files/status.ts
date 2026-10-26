/** The save status shown in the editor's toolbar. */
export function getSaveStatus(saved: boolean): string {
  return saved ? "Saved" : "Unsaved changes";
}
