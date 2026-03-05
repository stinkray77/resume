#!/bin/bash

# 1. Create a directory for the final outputs
mkdir -p builds

# 2. Save the name of the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 3. Stash any uncommitted changes to avoid checkout conflicts
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -m "build.sh auto-stash"
  STASHED=true
fi

# 4. Compile SWE resume, push branch
echo "Compiling SWE Resume..."
git checkout swe-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_SWE_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf
git push origin swe-profile

# 5. Compile Quant resume, push branch
echo "Compiling Quant Resume..."
git checkout quant-profile
pdflatex -interaction=nonstopmode resume.tex
cp resume.pdf builds/Ray_Chua_Quant_Resume.pdf
rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz resume.pdf
git push origin quant-profile

# 6. Return to the original branch and restore stash
git checkout "$CURRENT_BRANCH"
if [ "$STASHED" = true ]; then
  git stash pop
fi

echo "========================================"
echo "Success! Your resumes are in the 'builds' folder."
