NAME = genoslab-handbook
USE_PDFLATEX=1
-include /usr/share/latex-mk/latex.gmk

#LATEX2HTML_FLAGS += -split 2 -style genoslab.css -noaddress -init_file latex2htmlrc -show_section_numbers -dir html

default: pdf

gera-html: 
	cp genoslab.css $(NAME)
	latex2html -split 2 -style genoslab.css -noaddress -init_file latex2htmlrc -show_section_numbers 

push: ps
	git push

cleanall: clean
	rm -rf $(NAME)

gera-remote: pdf gera-html

#	rsync --delete -av $(NAME)/* genoslab-handbook.pdf /var/www/genos.mus.br/handbook/

envia: gera-html pdf
	rsync --delete -av genoslab-handbook.html_dir/* genoslab-handbook.pdf genos.mus.br:/var/www/genos.mus.br/handbook/
