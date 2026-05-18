.PHONY: all clean convert pdf presentation watch help

# Default target
all: convert pdf presentation

# Convert Markdown to LaTeX
convert:
	@echo "Converting Markdown to LaTeX..."
	@./build/build.sh

# Compile PDF from LaTeX
pdf:
	@echo "Compiling PDF..."
	pdflatex -interaction=nonstopmode main.tex
	pdflatex -interaction=nonstopmode main.tex

# Full build with bibliography
full: convert
	pdflatex -interaction=nonstopmode main.tex
	bibtex main || true
	pdflatex -interaction=nonstopmode main.tex
	pdflatex -interaction=nonstopmode main.tex

# Build presentation (uses XeLaTeX for custom fonts)
presentation:
	@echo "Building presentation..."
	cd presentation && xelatex -interaction=nonstopmode presentation.tex
	cd presentation && xelatex -interaction=nonstopmode presentation.tex
	@echo "✅ presentation/presentation.pdf done"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fls *.fdb_latexmk
	rm -f chapter/*.aux
	rm -f presentation/*.aux presentation/*.log presentation/*.nav presentation/*.out presentation/*.snm presentation/*.toc

# Watch for changes (requires fswatch or inotifywait)
watch:
	@echo "Watching for changes in content/..."
	@while true; do \
		inotifywait -e modify content/*.md 2>/dev/null || fswatch -1 content/*.md; \
		$(MAKE) convert; \
	done

# Help
help:
	@echo "UET Thesis Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make convert      - Convert Markdown to LaTeX"
	@echo "  make pdf          - Compile LaTeX to PDF"
	@echo "  make all          - Convert, compile thesis + presentation"
	@echo "  make full         - Full build with bibliography"
	@echo "  make presentation - Build presentation PDF (uses XeLaTeX)"
	@echo "  make clean        - Remove generated files"
	@echo "  make watch        - Watch for changes and auto-convert"
