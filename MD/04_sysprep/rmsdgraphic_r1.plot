
set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_protein_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot "rmsd_protein_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "r1"

! ps2pdf RMSD_protein_r1.eps
 


set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_ligand_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot "rmsd_ligand_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "r1"

! ps2pdf RMSD_ligand_r1.eps
 


set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_CA_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot "rmsd_CA_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "r1"

! ps2pdf RMSD_CA_r1.eps
 

set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_CA_xray_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot "rmsd_CA_xray_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "r1"  

! ps2pdf RMSD_CA_xray_r1.eps


set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_protein_xray_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot "rmsd_protein_xray_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "r1"

! ps2pdf RMSD_protein_xray_r1.eps



set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_comparison_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot \
    "rmsd_CA_xray_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "CA_xray", \
    "rmsd_CA_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#ff80ff" title "CA_1frame", \

! ps2pdf RMSD_comparison_r1.eps


set term postscript enhanced color solid "Times, 22" 
set encoding iso_8859_1
set border 31 lt -1 lw 3
set output "RMSD_bindingsite_comp_r1.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ps)"
set xrange [0:]
 
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot \
    "rmsd_binding_site_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#6495ED" title "CA_xray", \
    "rmsd_binding_site_xray_r1.xvg" u 1:2 w l lt 1 lw 2 lc rgb "#ff80ff" title "CA_1frame", \

! ps2pdf RMSD_bindingsite_comp_r1.eps


 
