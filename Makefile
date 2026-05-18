.PHONY: all clean convert pdf full watch help

# Default target
all: convert pdf

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

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fls *.fdb_latexmk *.lol
	rm -f chapter/*.aux

# Watch for changes (requires inotifywait or fswatch)
watch:
	@echo "Watching for changes in content/..."
	@while true; do \
		inotifywait -e modify content/*.md 2>/dev/null || fswatch -1 content/*.md; \
		$(MAKE) all; \
	done

# Help
help:
	@echo "KSE Paper Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make convert  - Convert Markdown to LaTeX"
	@echo "  make pdf      - Compile LaTeX to PDF"
	@echo "  make all      - Convert and compile (default)"
	@echo "  make full     - Full build with bibliography"
	@echo "  make clean    - Remove generated files"
	@echo "  make watch    - Watch for changes and auto-convert"
