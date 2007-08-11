NAME = genoslab-handbook
USE_PDFLATEX=1
-include /usr/share/latex-mk/latex.gmk

LATEX2HTML_FLAGS += -split 2 -style genoslab.css -noaddress -init_file latex2htmlrc

default: pdf

gera-html: html
	cp genoslab.css genoslab-handbook.html_dir

push: ps
	git push

envia: pdf gera-html
	rsync --delete -av genoslab-handbook.html_dir/* genoslab-handbook.pdf genos.mus.br:/var/www/genos.mus.br/handbook/
