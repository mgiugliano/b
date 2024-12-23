# Makefile for LaTeX documents

# --- Specify the shell ---
SHELL := /bin/bash

# --- Variables ---
TEX_FILE = book
PDF_FILE = $(TEX_FILE)
LATEX = xelatex
#LATEX = pdflatex
BIBTEX = bibtex
LATEX_OPTIONS = -shell-escape -synctex=1 -interaction=nonstopmode
TEX_DIR = tex
# Adjust STY_DIR to point to the Springer styles directory:
STY_DIR = styles
BUILD_DIR = build

# --- Rules ---
all: $(PDF_FILE).pdf

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Rule to compile the LaTeX document to PDF
$(PDF_FILE).pdf: $(BUILD_DIR) $(TEX_DIR)/$(TEX_FILE).tex
	@echo "Compiling LaTeX document..."
	@TEXINPUTS=".:$(TEX_DIR):$(STY_DIR)//:" \
	BSTINPUTS=".:$(STY_DIR)//:" \
	$(LATEX) $(LATEX_OPTIONS) -output-directory=$(BUILD_DIR) $(TEX_DIR)/$(TEX_FILE).tex
	@count=0; \
	max_iterations=5; \
	while [ "`grep -i 'undefined references\|rerun to get' $(BUILD_DIR)/$(TEX_FILE).log`" != "" ] && [ $$count -lt $$max_iterations ]; do \
		if [ "`grep 'Citation' $(BUILD_DIR)/$(TEX_FILE).log`" != "" ]; then \
			echo "Running BibTeX..."; \
			TEXINPUTS=".:$(TEX_DIR):$(STY_DIR)//:" \
			BSTINPUTS=".:$(STY_DIR)//:" \
			$(BIBTEX) $(BUILD_DIR)/$(TEX_FILE); \
		fi; \
		echo "Recompiling LaTeX document (iteration $$count)..."; \
		TEXINPUTS=".:$(TEX_DIR):$(STY_DIR)//:" \
		BSTINPUTS=".:$(STY_DIR)//:" \
		$(LATEX) $(LATEX_OPTIONS) -output-directory=$(BUILD_DIR) $(TEX_DIR)/$(TEX_FILE).tex; \
		count=$$((count + 1)); \
	done; \
	if [ $$count -eq $$max_iterations ]; then \
		echo "WARNING: Maximum number of iterations ($$max_iterations) reached. References might not be fully resolved." >&2; \
	fi
	@echo ""
	@echo ""
	@echo "Compilation complete."
	cp $(BUILD_DIR)/$(PDF_FILE).pdf .

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.aux *.log *.bbl *.blg *.out *.lof *.lot *.toc *.bak

distclean: clean
	rm -f $(PDF_FILE).pdf

.PHONY: all clean distclean
