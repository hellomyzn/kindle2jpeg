script?=kindle2jpeg.scpt
b?=Untitled Bookname
p?=0

.PHONY: run
run:
	osascript "$(script)" -b "$(b)" -p "$(p)"