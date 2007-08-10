NAME = genos-handbook
-include /usr/share/latex-mk/latex.gmk

default: ps

push: ps
	git push
