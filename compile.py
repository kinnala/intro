import os;
import numpy as np;

os.system('nasmw -f win32 -s -O9 -o intro.obj intro.asm');
os.system('crinkler.exe /OUT:intro.exe /SUBSYSTEM:WINDOWS /PRINT:LABELS /PRINT:IMPORTS /ENTRY:entry /REPORT:crinkrep.html /TINYHEADER /TINYIMPORT /ORDERTRIES:500 intro.obj user32.lib winmm.lib kernel32.lib d3d9.lib d3dx9.lib');
