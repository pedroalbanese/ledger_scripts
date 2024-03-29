
set terminal dumb 82,21
set xdata time
set timefmt "%Y-%m-%d"

set key left top
set grid 

set style fill transparent solid 0.6 noborder
set xzeroaxis linetype 0

set timefmt '%Y/%m/%d'
set format x "%m/%y"
set format y "$%'.0f"

set format x "%b\n'%y"

plot "plot-inc.txt" using 1:2 smooth unique w lp lt 1 pt 1  title "Income","plot-exp.txt" using 1:2 smooth unique w lp lt 2 pt 2 title "Expenses"
