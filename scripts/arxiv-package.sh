#!/bin/bash
# Package the SRCT paper for arXiv upload.
# Requires: pdflatex, bibtex (TeX Live or similar)
#
# arXiv processes LaTeX sources, so we include:
#   - srct-paper.tex   (main source)
#   - srct-paper.bib   (bibliography)
#   - srct-paper.bbl   (pre-compiled bibliography — arXiv won't run bibtex)
#
# Output: srct-arxiv.zip (ready for upload to arxiv.org)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PAPER_DIR="$(cd "$SCRIPT_DIR/../../research" && pwd)"
OUT_DIR="$PAPER_DIR/arxiv-submission"
ZIP_FILE="$PAPER_DIR/../srct-arxiv.zip"

echo "=== arXiv Packaging ==="
echo "  Paper dir: $PAPER_DIR"
echo "  Output:    $ZIP_FILE"

# Clean
rm -rf "$OUT_DIR" "$ZIP_FILE"
mkdir -p "$OUT_DIR"

# Copy sources
cp "$PAPER_DIR/srct-paper.tex" "$OUT_DIR/"
cp "$PAPER_DIR/srct-paper.bib" "$OUT_DIR/"

# Compile to produce .bbl (arXiv needs this — it doesn't run bibtex)
echo "[1/3] pdflatex + bibtex for .bbl..."
(
  cd "$OUT_DIR"
  pdflatex -interaction=nonstopmode srct-paper.tex > /dev/null 2>&1 || true
  bibtex srct-paper > /dev/null 2>&1 || true
  pdflatex -interaction=nonstopmode srct-paper.tex > /dev/null 2>&1 || true
  pdflatex -interaction=nonstopmode srct-paper.tex > /dev/null 2>&1 || true
)

# Verify the .bbl exists
if [ ! -f "$OUT_DIR/srct-paper.bbl" ]; then
  echo "ERROR: Failed to generate srct-paper.bbl"
  exit 1
fi

# Verify the build
echo "[2/3] Verifying..."
WARNINGS=$(grep -c "Warning" "$OUT_DIR/srct-paper.log" 2>/dev/null || echo 0)
UNDEFINED=$(grep -c "Citation.*undefined" "$OUT_DIR/srct-paper.log" 2>/dev/null || echo 0)
PAGES=$(grep "Output written" "$OUT_DIR/srct-paper.log" 2>/dev/null | grep -o "[0-9]\+ pages" || echo "unknown")

if [ "$UNDEFINED" -gt 0 ]; then
  echo "WARNING: $UNDEFINED undefined citations found. Review srct-paper.log."
fi

# Clean auxiliary files (arXiv only needs .tex, .bib, .bbl)
rm -f "$OUT_DIR"/*.aux "$OUT_DIR"/*.log "$OUT_DIR"/*.out "$OUT_DIR"/*.blg "$OUT_DIR"/*.pdf

# Package
echo "[3/3] Creating zip..."
ZIP_DIR="$PAPER_DIR/.."
(cd "$OUT_DIR/.." && zip -r "$ZIP_FILE" arxiv-submission/ > /dev/null)

# Report
echo ""
echo "=== Done ==="
echo "  Files included:"
ls -la "$OUT_DIR/"
echo ""
echo "  arXiv zip: $ZIP_FILE"
ls -lh "$ZIP_FILE"
echo ""
echo "  Upload this zip to https://arxiv.org/submit"
echo "  After upload, verify the TeX processing in your arXiv account."
echo "  Once published, update CITATION.cff in the srct repo with the arXiv ID."
