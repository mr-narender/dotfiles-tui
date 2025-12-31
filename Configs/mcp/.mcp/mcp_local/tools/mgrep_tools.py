import difflib
import pathlib


def search_file(
    path: str,
    query: str,
    min_probability: float = 0.5,
    max_results: int = 20,
) -> str:
    """
    Approximate text search that returns lines meeting a similarity probability.
    This is a lightweight, dependency-free stand‑in for mgrep-style fuzzy search.
    """
    if not query.strip():
        raise ValueError("query must not be empty")
    if not 0.0 <= min_probability <= 1.0:
        raise ValueError("min_probability must be between 0.0 and 1.0")
    if max_results < 1:
        raise ValueError("max_results must be at least 1")

    p = pathlib.Path(path).expanduser()
    if not p.is_file():
        raise FileNotFoundError(f"File not found: {p}")

    text = p.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    # Use a small multi-line window to better match longer queries.
    window_size = max(1, min(5, len(query) // 80 + 1))

    def score(candidate: str) -> float:
        return difflib.SequenceMatcher(None, query, candidate).ratio()

    results = []
    for idx, _ in enumerate(lines):
        # Evaluate the current line and a short window starting at this line.
        candidates = [lines[idx]]
        if window_size > 1:
            chunk = " ".join(lines[idx : idx + window_size])
            if chunk:
                candidates.append(chunk)

        best_score = 0.0
        best_text = ""
        for cand in candidates:
            s = score(cand)
            if s > best_score:
                best_score = s
                best_text = cand

        if best_score >= min_probability:
            snippet = best_text.strip()
            if len(snippet) > 240:
                snippet = snippet[:237] + "..."
            results.append((best_score, idx + 1, snippet))

    if not results:
        return f"(no matches >= {min_probability:.2f})"

    results.sort(key=lambda r: (-r[0], r[1]))
    results = results[:max_results]

    formatted = [
        f"{p}:{line_no}:{score * 100:.1f}%: {snippet}"
        for score, line_no, snippet in results
    ]
    return "\n".join(formatted)
