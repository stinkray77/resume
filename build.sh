#!/bin/bash
set -e

mkdir -p builds
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Stash uncommitted changes to avoid checkout conflicts
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -m "build.sh auto-stash"
  STASHED=true
fi

# Build and push SWE resume
echo "Compiling SWE Resume..."
git checkout swe-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_SWE_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf
git push origin swe-profile

# Build and push Quant resume
echo "Compiling Quant Resume..."
git checkout quant-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_Quant_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf
git push origin quant-profile

# Return to main, commit PDFs, push
git checkout main
git add builds/
if ! git diff --cached --quiet; then
  git commit -m "Update compiled resumes [$(date +%Y-%m-%d)]"
  git push origin main
fi

# Restore original branch and stash
git checkout "$CURRENT_BRANCH"
if [ "$STASHED" = true ]; then
  git stash pop
fi

echo "========================================"
echo "Done! Resumes are in builds/"
