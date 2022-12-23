
set terminal dumb 82,21
set xdata time
set timefmt "%Y/%m/%d"

set format x "%b\n'%y"
set format y "$%'.0f"

set grid
set key right top

plot "PlotAss.txt" u 1:2 smooth unique w lp pt 1 lt 2 lw 2 title "Total", "PlotFunds.txt" u 1:2 smooth unique w lp pt 2 lt 1 lw 2 title "Funds", "PlotCash.txt" u 1:2 smooth unique w lp pt 3 lt -1 lw 2 title "Indeed"
