#!/bin/bash
# Build script for KSE Conference Paper
# Converts Markdown sections to LaTeX using Pandoc

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Converting Markdown to LaTeX..."

# Paper sections: content/*.md → chapter/*.tex
declare -A SECTIONS=(
    ["content/01-introduction.md"]="chapter/01-introduction.tex"
    ["content/02-preliminaries.md"]="chapter/02-preliminaries.tex"
    ["content/03-improved-cp.md"]="chapter/03-improved-cp.tex"
    ["content/04-readability.md"]="chapter/04-readability.tex"
    ["content/05-evaluation.md"]="chapter/05-evaluation.tex"
    ["content/06-related-work.md"]="chapter/06-related-work.tex"
    ["content/07-conclusion.md"]="chapter/07-conclusion.tex"
)

# Convert abstract: content/00-abstract.md → chapter/00-abstract.tex
if [ -f "content/00-abstract.md" ]; then
    echo "  content/00-abstract.md → chapter/00-abstract.tex"
    # Split on --- separator: paragraph before is abstract, after is keywords
    abstract=$(sed '/^---$/,$d' "content/00-abstract.md" | sed '/^$/N;/^\n$/d')
    keywords=$(sed '1,/^---$/d' "content/00-abstract.md" | sed '/^$/d')
    pandoc -f markdown -t latex --wrap=none <<< "$abstract" > /tmp/abstract_body.tex
    sed -i 's/\\citep{/\\cite{/g; s/\\citet{/\\cite{/g' /tmp/abstract_body.tex
    pandoc --template=templates/pandoc/abstract.latex \
        --variable="abstract=$(cat /tmp/abstract_body.tex)" \
        --variable="keywords=$keywords" \
        -o "chapter/00-abstract.tex" <<< ""
fi

for md_file in "${!SECTIONS[@]}"; do
    tex_file="${SECTIONS[$md_file]}"
    if [ -f "$md_file" ]; then
        echo "  $md_file → $tex_file"
        pandoc "$md_file" \
            --from markdown+yaml_metadata_block+implicit_figures+table_captions+pipe_tables \
            --to latex \
            --template=templates/pandoc/paper-section.latex \
            --lua-filter=build/ieee-tables.lua \
            --shift-heading-level-by=1 \
            --natbib \
            --output "$tex_file"
        # IEEEtran uses \cite, not \citep/\citet
        sed -i 's/\\citep{/\\cite{/g; s/\\citet{/\\cite{/g' "$tex_file"
    else
        echo "  Skipping $md_file (not found)"
    fi
done

echo "Done! Run 'make pdf' or 'make full' to compile."
