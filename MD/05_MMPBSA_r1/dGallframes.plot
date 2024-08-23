set term postscript eps enhanced color solid "Helvetica" 20 size 10,10
set encoding iso_8859_1
set output "dG_allframes_epsin_1.eps"

set border 31 lt -1 lw 1

set style line 1 lt rgb "#FF0000" lw 3 pt 2 ps 1 # Cl
set style line 2 lt rgb "#0000FF" lw 3 pt 2 ps 1 # Br
set style line 3 lt rgb "#000000" lw 3 pt 2 ps 1 # I
set label 1 at  2000, -25 left font "Helvetica, 18"

set size square

set grid
set key

set  xlabel "frame"
set  xtics 200
set  xrange [1:1000]

set  ylabel "dGbind"
set  ytics 10

set multiplot layout 3,2


#set  yrange [-35:-25]
#plot 'pb1_rstd_epsin_1'  u 1:2 t "{/:Bold pb1 rstd}" 
#plot 'pb1_ropt_epsin_1'  u 1:2 t "{/:Bold pb1 ropt}" 

#set  yrange [-28:-32]
set label 1 at  2000, -32 left font "Helvetica, 18"
plot 'pb2_rstd_epsin_1'   u 1:2 t "{/:Bold pb2 rstd}" 
plot 'pb2_ropt_epsin_1'   u 1:2 t "{/:Bold pb2 ropt}" 



#set  yrange [-10:-5]
set label 1 at  2000, -7 left font "Helvetica, 18"
plot 'pb3_rstd_epsin_1'   u 1:2 t "{/:Bold pb3 rstd}"   
plot 'pb3_ropt_epsin_1'   u 1:2 t "{/:Bold pb3 ropt}" 


#
! epstopdf dG_allframes_epsin_1.eps
unset multiplot


set output "dG_allframes_epsin_4.eps"

set border 31 lt -1 lw 1

set style line 1 lt rgb "#FF0000" lw 3 pt 2 ps 1 # Cl
set style line 2 lt rgb "#0000FF" lw 3 pt 2 ps 1 # Br
set style line 3 lt rgb "#000000" lw 3 pt 2 ps 1 # I
set label 1 at  2000, -25 left font "Helvetica, 18"
set size square
set grid
set key

set  xlabel "frame"
set  xtics 200
set  xrange [1:1000]

set  ylabel "dGbind"
set  ytics 10

set multiplot layout 3,2


#set  yrange [-35:-25]
#plot 'pb1_rstd_epsin_4'  u 1:2 t "{/:Bold pb1 rstd}" 
#plot 'pb1_ropt_epsin_4'  u 1:2 t "{/:Bold pb1 ropt}" 

#set  yrange [-28:-32]
set label 1 at  2000, -32 left font "Helvetica, 18"
plot 'pb2_rstd_epsin_4'   u 1:2 t "{/:Bold pb2 rstd}" 
plot 'pb2_ropt_epsin_4'   u 1:2 t "{/:Bold pb2 ropt}" 



#set  yrange [-10:-5]
set label 1 at  3000, -7 left font "Helvetica, 18"
plot 'pb3_rstd_epsin_4'   u 1:2 t "{/:Bold pb3 rstd}"   
plot 'pb3_ropt_epsin_4'   u 1:2 t "{/:Bold pb3 ropt}" 


#
! epstopdf dG_allframes_epsin_4.eps
unset multiplot
