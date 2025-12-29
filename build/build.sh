#!/bin/bash
# Build script for UET Thesis
# Converts Markdown files to LaTeX using Pandoc

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🔄 Converting Markdown to LaTeX..."

# Chapter mapping: markdown file -> output tex file
declare -A CHAPTERS=(
    ["content/00-introduction.md"]="chapter/00-introduction.tex"
    ["content/01-chapter1.md"]="chapter/01-chapter1.tex"
    ["content/02-chapter2.md"]="chapter/02-chapter2.tex"
    ["content/03-chapter3.md"]="chapter/03-chapter3.tex"
    ["content/04-chapter4.md"]="chapter/04-chapter4.tex"
    ["content/05-chapter5.md"]="chapter/05-chapter5.tex"
    ["content/06-conclusion.md"]="chapter/06-conclusion.tex"
)

for md_file in "${!CHAPTERS[@]}"; do
    tex_file="${CHAPTERS[$md_file]}"
    if [ -f "$md_file" ]; then
        echo "  📝 $md_file → $tex_file"
        pandoc "$md_file" \
            --from markdown+yaml_metadata_block+implicit_figures+table_captions+pipe_tables \
            --to latex \
            --template=templates/pandoc/chapter.latex \
            --citeproc \
            --bibliography=references.bib \
            --csl=https://raw.githubusercontent.com/citation-style-language/styles/master/ieee.csl \
            --output "$tex_file"
    else
        echo "  ⚠️  Skipping $md_file (not found)"
    fi
done

echo "✅ Markdown conversion complete!"
echo ""
echo "To compile PDF, run:"
echo "  pdflatex main.tex"
echo "  bibtex main"
echo "  pdflatex main.tex"
echo "  pdflatex main.tex"
