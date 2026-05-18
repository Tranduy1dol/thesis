.PHONY: all clean convert pdf presentation watch help

all: convert pdf presentation

convert:
	@echo "Converting Markdown to LaTeX..."
	@./build/build.sh

pdf:
	@echo "Compiling PDF..."
	pdflatex -interaction=nonstopmode main.tex
	pdflatex -interaction=nonstopmode main.tex

full: convert
	pdflatex -interaction=nonstopmode main.tex
	bibtex main || true
	pdflatex -interaction=nonstopmode main.tex
	pdflatex -interaction=nonstopmode main.tex

presentation:
	@echo "Building presentation..."
	cd presentation && pdflatex -interaction=nonstopmode presentation.tex
	cd presentation && pdflatex -interaction=nonstopmode presentation.tex
	@echo "presentation/presentation.pdf done"

clean:
	@echo "Cleaning generated files..."
	rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.fls *.fdb_latexmk
	rm -f chapter/*.aux
	rm -f presentation/*.aux presentation/*.log presentation/*.nav presentation/*.out presentation/*.snm presentation/*.toc

watch:
	@echo "Watching for changes in content/..."
	@while true; do \
		inotifywait -e modify content/*.md 2>/dev/null || fswatch -1 content/*.md; \
		$(MAKE) convert; \
	done

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
