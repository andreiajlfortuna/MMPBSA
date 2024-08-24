#set terminal pngcairo  transparent enhanced font "arial,14" fontscale 1.0 size 1000, 1000 
#set bar 1.000000 front
#set encoding iso_8859_1

    set term postscript eps enhanced color solid "Helvetica" 45 size 20,30
 
    set encoding iso_8859_1
set output "BEST_R.eps"

#set key font ",25"
set border 31 lt -1 lw 1

set style line 1 lt rgb "#038EAD" lw 2 pt 7 ps 3  
set style line 2 lt rgb "#024959 " lw 2 pt 7 ps 3  

set style fill solid
 
unset key

set  xlabel " {/Symbol D}G_{bind}(calc) / kcal mol^{-1}"

set ylabel "{/Symbol D}G_{bind}(exp) / kcal mol^{-1}"
#set yrange [0:1.15]
#set xrange [2:10.5]
#set xtics 2.5, 2.5
#
#set output "correlation_range_all_methods.png" 

set multiplot layout 1,3\
              margins 0.15,0.9,0.15,0.7 \
              spacing 0.1,0.2
 
set size square
#set yrange [0:1]

set title "{/:Bold set A}" font "Helvetica, 50"

set yrange [-18:-14]
set xrange [-28:-14]
set ytics 1 
set xtics 3 

f(x)=0.26309 * x + -10.244 

set label 1 "{/:Bold r = 0.85}" at -23, -14.4 right font "Helvetica, 45" #tc rgb "#024959" 

plot f(x) ls 2 , \
'set_A/BEST_R.txt' u 1:2 t "" ls 1 
    

set title "{/:Bold set B}" font "Helvetica, 50" 

unset label 1
unset label 2

set label 1 "{/:Bold r = 0.93}" at -5.5, -7.5 right font "Helvetica, 45" #tc rgb "#024959" 

set yrange [-12:-7]
set xrange [-10:2]
set ytics 1 
set xtics 2 

f(x)=0.24811 * x + -8.4415


plot f(x) ls 2, \
    'set_B/BEST_R.txt' u 1:2 t "" ls 1 

set title "{/:Bold set C}" font "Helvetica, 50" 

set label 1 "{/:Bold r = 0.98}" at -11.5, -4.6 right font "Helvetica, 45" #tc rgb "#024959" 


set yrange [-10:-4]
set xrange [-14:-7]
set ytics 1 
set xtics 1.5

f(x)=0.65479 * x + -0.076329 

plot f(x) ls 2, \
    'set_C/BEST_R.txt' u 1:2 t "" ls 1 
 
#
 
unset multiplot
! epstopdf BEST_R.eps
! pdfcrop --margins 10 BEST_R.pdf
 
