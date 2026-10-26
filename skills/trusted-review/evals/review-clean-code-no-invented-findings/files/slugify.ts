/**
 * Turn a title into an ASCII URL slug
 *
 * Lowercases, strips accents that Unicode splits off a base letter (é, ñ), and joins words with single hyphens.
 * Any other character, including letters such as ß or ø and non-Latin scripts, counts as a word separator.
 * Returns an empty string when nothing is left.
 *
 * @example slugify("Héllo, World!") // "hello-world"
 * @example slugify("Straße") // "stra-e"
 */
export function slugify(title: string): string {
  return title
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
