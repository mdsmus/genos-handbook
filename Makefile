NAME = genoslab-handbook
USE_PDFLATEX=1
-include /usr/share/latex-mk/latex.gmk
include ~/.latexmk

TEXINPUTS=figs:
PDFLATEX=/usr/bin/pdflatex
BIBTEX=/usr//bin/bibtex
MAKEIDX=/usr//bin/makeindex
MAKEGLS=/usr/bin/makeindex

#LATEX2HTML_FLAGS += -split 2 -style genoslab.css -noaddress -init_file latex2htmlrc -show_section_numbers -dir html

latex2html = latex2html -html_version 4.0,unicode -split 3 -style genoslab.css -noaddress -init_file latex2htmlrc -show_section_numbers

gera-html: pdf
	$(latex2html) $(NAME).tex
	cp genoslab.css $(NAME)
	cp -Rv src $(NAME)

push: gera-html
	git push

cleanall: clean
	rm -rf $(NAME)

ver:
	firefox genoslab-handbook/index.html 

gera-remote: pdf gera-html
	rsync --delete -av $(NAME)/* genoslab-handbook.pdf src /var/www/genos.mus.br/handbook/

envia: gera-html pdf
	rsync --delete -av genoslab-handbook.html_dir/* genoslab-handbook.pdf genos.mus.br:/var/www/genos.mus.br/handbook/
