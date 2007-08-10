NAME = genoslab-handbook
-include /usr/share/latex-mk/latex.gmk

default: ps

push: ps
	git push

envia: html
	rsync -av genoslab-handbook.html_dir/* genos.mus.br:/var/www/genos.mus.br/handbook/
