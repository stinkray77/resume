#!/bin/bash
set -e

# 1. Save the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 2. Stash uncommitted changes so branch switching works cleanly
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Stashing uncommitted changes..."
  git stash push -m "build.sh auto-stash"
  STASHED=true
fi

# 3. Stage PDFs in /tmp - builds/ is tracked on main and removed on checkout
TMP_SWE=$(mktemp /tmp/swe_resume.XXXXXX.pdf)
TMP_QUANT=$(mktemp /tmp/quant_resume.XXXXXX.pdf)

# 4. Compile SWE resume
echo "Compiling SWE Resume..."
git checkout swe-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf "$TMP_SWE"
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf

# 5. Compile Quant resume
echo "Compiling Quant Resume..."
git checkout quant-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf "$TMP_QUANT"
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf

# 6. Return to main, copy PDFs into builds/, commit, and push
git checkout main
mkdir -p builds
cp "$TMP_SWE"   builds/Ray_Chua_SWE_Resume.pdf
cp "$TMP_QUANT" builds/Ray_Chua_Quant_Resume.pdf
rm -f "$TMP_SWE" "$TMP_QUANT"

git add builds/
if git diff --cached --quiet; then
  echo "No changes to built PDFs."
else
  git commit -m "Update compiled resumes [$(date +%Y-%m-%d)]"
  git push origin main
  echo "Pushed builds to GitHub."
fi

# 7. Return to the original branch
git checkout "$CURRENT_BRANCH"

# 8. Restore stashed changes
if [ "$STASHED" = true ]; then
  git stash pop
fi

echo "========================================"
echo "Success! Resumes saved to builds/ and pushed to GitHub."
