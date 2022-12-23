#NoTrayIcon

$year = @YEAR
$month = @MON
$day = @MDAY
$date = $year & "/" & $month & "/" & $day

If $CmdLineRaw == "" Then
	ConsoleWrite("Ledger CLI Inserting Tool - ALBANESE Lab " & Chr(184) & " 2018-2021" & @CRLF) ;
	ConsoleWrite("Input new entries in Ledger format." & @CRLF & @CRLF) ;
	ConsoleWrite("Usage: insert <payee> <comment> <source:account> <amount> <target:account>" & @CRLF)
ElseIf $CmdLine[0] < 5 Then
	ConsoleWrite("Usage: insert <payee> <comment> <source:account> <amount> <target:account>" & @CRLF)
Else
	$payee = $CmdLine[1]
	If $CmdLine[2] == "-n" Then
		$comment = ''
	Else
		$comment = ";" & $CmdLine[2]
	EndIf
	$account1 = $CmdLine[3]
	$amount = $CmdLine[4]
	$amount = StringReplace($amount, "'", '"')
	$amount2 = "                                                " & $amount
	$account2 = $CmdLine[5]

	$pLength = StringLen($amount)
	$iLength = StringLen($account1)
	$sLength = StringTrimLeft($amount2, $pLength)
	$sLength = StringTrimLeft($sLength, $iLength)

	ConsoleWrite(@CRLF & $date & "  " & $payee & " " & $comment & @CRLF & "    " & $account1 & $sLength & @CRLF & "    " & $account2 & @CRLF)
EndIf