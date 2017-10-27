all:
	pandoc -i --mathml -V history=true -V transition=none -t revealjs -s main.md --css=changes.css -o main.html
