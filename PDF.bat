@ECHO OFF


: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
: ConvertCSV.bat
: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


tool\busybox echo ""|busybox unix2dos > JointCSV.txt

tool\limport -f Main.txt -date-format "2006-01-02" Assets:Wallet "Finances - Cash.csv"|tool\ledger -f - -columns 58 print|tool\busybox unix2dos >> JointCSV.txt

tool\limport -f Main.txt -date-format "2006-01-02" Assets:Checking "Finances - Card.csv"|tool\ledger -f - -columns 58 print|tool\busybox unix2dos >> JointCSV.txt

tool\limport -f Main.txt -date-format "2006-01-02" -set-search Assets:Checking Paypal "Finances - Paypal.csv"|tool\ledger -f - -columns 58 print|tool\busybox unix2dos >> JointCSV.txt

tool\limport -f Main.txt -date-format "2006-01-02" -neg -set-search Assets:Checking Assets:Wallet "Finances - Withdraw.csv"|tool\ledger -f - -columns 58 print|tool\busybox unix2dos >> JointCSV.txt

: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:FOR /F %%F in ('tool\uuid') do (set uuid=%%F) 
:tool\qrcode %uuid% > plot\qrcode.png

FOR /F "tokens=*" %%F in ('tool\busybox date -R') do (set "data=%%F") 
FOR /F %%F in ('tool\roman') do (set "doy=%%F") 

:tool\busybox echo "%doy%. %data%" >>networth.tmp
:tool\busybox echo "%doy%. %data%" >csv.tmp

tool\busybox echo "" >>networth.tmp

:tool\gcal --islamic-civil-holidays -qbr -n- -X . | tool\busybox sed 1,5d | tool\busybox sed 10,18d | tool\boxes -s 80 >>networth.tmp

tool\gcal --islamic-civil-holidays -qbr -n- -X . | tool\busybox sed 1,5d | tool\busybox head -n 12 | tool\boxes -s 80 >>networth.tmp

tool\busybox echo "" >>networth.tmp

tool\busybox echo "***************/ ASSETS /**************" >> Bal1.txt
tool\busybox bash ledger -empty -columns 39 -depth 2 bal Ass >> Bal1.txt

tool\busybox echo ""  >> Bal1.txt

tool\busybox echo "***************/ INDEED /**************" >> Bal1.txt
tool\busybox bash ledger -empty -columns 39 bal Checking Wallet >> Bal1.txt

tool\busybox echo "***************/ FUNDS /***************" >> Bal2.txt
tool\busybox bash ledger -empty -columns 39 bal Funds >> Bal2.txt

tool\busybox echo ""  >> Bal2.txt

tool\busybox echo "/*************/ SUMMARY /*************/" >> Bal2.txt
tool\busybox bash ledger -columns 39 bal Ass|tool\busybox tail -n 1|tool\busybox awk "{print $1}"|tool\busybox sed "s/$/ Total:/"|tool\busybox awk "{print $2,$1}" > Bal3.txt

tool\busybox bash ledger -columns 39 bal Wallet Cash|tool\busybox tail -n 1|tool\busybox awk "{print $1}"|tool\busybox sed "s/$/ Money:/"|tool\busybox awk "{print $2,$1}" >> Bal3.txt

tool\busybox bash ledger -columns 39 bal Checking Bank|tool\busybox tail -n 1|tool\busybox awk "{print $1}"|tool\busybox sed "s/$/ Bank:/"|tool\busybox awk "{print $2,$1}" >> Bal3.txt

tool\boxes -s 39 Bal3.txt|tool\busybox tail -n +2 >> Bal2.txt

tool\pr -tm -w82 Bal1.txt Bal2.txt|tool\busybox expand >> networth.tmp
del Bal1.txt Bal2.txt Bal3.txt

:tool\busybox echo "" >>networth.tmp

:tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

:tool\busybox bash ledger -columns 80 reg Ass | tool\busybox tail -n 16 >>networth.tmp

FOR /F %%F in ('tool\busybox date "+%%Y/%%m/%%d"') do (set today=%%F) 
tool\busybox date "+%%Y/%%m/%%d" | tool\busybox awk -F "/" "{$1--}1" OFS="/" >date.tmp
set /p lastyear=<date.tmp
del date.tmp

:tool\ledger -f journal.txt -b "%lastyear%" reg Ass|tool\busybox awk "{print $1,$NF}" >PlotAss.txt
:tool\ledger -f journal.txt -b "%lastyear%" reg Check Wallet|tool\busybox awk "{print $1,$NF}" >PlotCash.txt
:tool\ledger -f journal.txt -b "%lastyear%" reg Funds|tool\busybox awk "{print $1,$NF}" >PlotFunds.txt

tool\ledger -f journal.txt reg Ass|tool\busybox awk "{print $1,$NF}"|tool\date.exe -start %lastyear% -end %today%>PlotAss.txt
tool\ledger -f journal.txt reg Check Wallet|tool\busybox awk "{print $1,$NF}"|tool\date.exe -start %lastyear% -end %today%>PlotCash.txt
tool\ledger -f journal.txt reg Funds|tool\busybox awk "{print $1,$NF}"|tool\date.exe -start %lastyear% -end %today% >PlotFunds.txt

:tool\date.exe -start %lastyear% -end %today% -input PlotAss0.txt > PlotAss.txt
:tool\date.exe -start %lastyear% -end %today% -input PlotCash0.txt > PlotCash.txt
:tool\date.exe -start %lastyear% -end %today% -input PlotFunds0.txt > PlotFunds.txt

tool\gnuplot plot\PlotTerm.txt|tool\busybox tail -n +2|tool\busybox head -n -1 >>networth.tmp
del PlotAss.txt PlotFunds.txt PlotCash.txt
:del PlotAss0.txt PlotFunds0.txt PlotCash0.txt


:tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

tool\busybox bash ledger -columns 80 reg Ass | tool\busybox tail -n 20 >>networth.tmp

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp


tool\ledger -f journal.txt reg Inc|tool\busybox awk "{print $1,$NF}"|tool\busybox sed "s/-//"|tool\date.exe -start %lastyear% -end %today%>Plot-Inc.txt
tool\ledger -f journal.txt reg Exp|tool\busybox awk "{print $1,$NF}"|tool\date.exe -start %lastyear% -end %today% >Plot-Exp.txt 


tool\gnuplot plot\CashPlotTerm.txt|tool\busybox tail -n +2 >>networth.tmp
del Plot-Inc.txt Plot-Exp.txt

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp


tool\busybox bash ledger -columns 80 -empty -depth 2 bal Inc Exp >>networth.tmp

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

:tool\busybox bash ledger -columns 80 reg Inc Exp | tool\busybox tail -n 13 >>networth.tmp
tool\busybox bash ledger -columns 80 reg Inc Exp | tool\busybox tail -n 30 >>networth.tmp

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

tool\busybox bash ledger -columns 80 -depth 1 bal Inc Exp Ass >>networth.tmp
:tool\busybox bash ledger -columns 74 -depth 1 bal Inc Exp Ass|tool\boxes -s 80 >>networth.tmp

tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

:tool\busybox bash ledger -columns 80 -depth 1 bal Silver Product >>networth.tmp

:tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp


tool\gosttk -digest "*.txt" >>networth.tmp


tool\busybox echo "--------------------------------------------------------------------------------"  >>networth.tmp

tool\busybox bash ledger -columns 80 stats >>networth.tmp

tool\busybox bash ledger -columns 58 print | tool\busybox unix2dos >Conjoint.txt
tool\wc Conjoint.txt >>networth.tmp

tool\busybox echo "-----------------------------------------------" >>networth.tmp


FOR /F "tokens=*" %%F in ('tool\gosttk -cmac -pbkdf2 -key "nucnmaio" ^< Journal.txt') do (set "cmac=%%F")
tool\busybox echo "CMAC : %cmac%" >>networth.tmp
tool\busybox shred -zu Conjoint.txt

FOR /F %%F in ('tool\uuid') do (set uuid=%%F) 
tool\qrcode %uuid% > plot\qrcode.png
tool\busybox echo "UUID : %uuid%" >>networth.tmp


tool\txt2pdf -l "ELECTRONICALLY ISSUED DOCUMENT - Lab, %doy%." -f networth.tmp -q plot\qrcode.png -t "TRIAL BALANCE" -s "FINANCIAL TRACKING SYSTEM" -n -p -a "nucnmaio" >Balance.pdf

tool\busybox shred -zu networth.tmp



