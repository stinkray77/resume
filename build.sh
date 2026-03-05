#!/bin/bash
set -e

# 1. Save the current branch so we can return to it later
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 2. Stash any uncommitted changes so branch switching works cleanly
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Stashing uncommitted changes..."
  git stash push -m "build.sh auto-stash"
  STASHED=true
fi

mkdir -p builds

# 3. Compile SWE resume
echo "Compiling SWE Resume..."
git checkout swe-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_SWE_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf

# 4. Compile Quant resume
echo "Compiling Quant Resume..."
git checkout quant-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_Quant_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf

# 5. Return to main to commit the built PDFs
git checkout main
git add builds/
if git diff --cached --quiet; then
  echo "No changes to built PDFs."
else
  git commit -m "Update compiled resumes [$(date '+%Y-%m-%d')]"
  git push origin main
  echo "Pushed builds to GitHub."
fi

# 6. Return to the original branch
git checkout "$CURRENT_BRANCH"

# 7. Restore any stashed changes
if [ "$STASHED" = true ]; then
  git stash pop
fi

echo "========================================"
echo "Success! Resumes saved to 'builds/' and pushed to GitHub."
