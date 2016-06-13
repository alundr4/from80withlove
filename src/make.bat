echo [objects] > link.txt
echo main.o >> link.txt
..\bin\wla-65816 -vo main.asm
..\bin\wlalink -r link.txt from-80s-with-love.sfc
del /f link.txt