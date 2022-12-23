; ====================================================
; ============ AHK LEDGER INSERTION TOOL =============
; ====================================================
; AutoHotKey version: 1.1.35.0
; Language:           English
; Author:             Pedro F. Albanese
; Modified:           -
;
; ----------------------------------------------------------------------------
; Script Start
; ----------------------------------------------------------------------------

::<now>::
	FormatTime, CurrentDateTime,, yyyy/M/d h:mm tt ; It will look like 2022/11/26 3:53 PM
	SendInput %CurrentDateTime%
return

::<today>::
	FormatTime, CurrentDate,, yyyy/M/d
	SendInput %CurrentDate%
return

::<time>::
	FormatTime, CurrentTime,, h:mm tt
	SendInput %CurrentTime%
return

::<insert>::
	InputBox, Payee, Payee Text, Please enter a Payee., , 340, 180
	InputBox, Comment, Comment Text, Please enter a Comment., , 340, 180
	InputBox, Source, Source Text, Please enter a Source Account., , 340, 180
	InputBox, Amount, Amount Number, Please enter a Amount., , 340, 180
	InputBox, Target, target Text, Please enter a Target Account., , 340, 180

	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec(ComSpec " /U /C Insert.exe " Payee " " Comment " " Source " " Amount " " Target)
	While, !objExec.StdOut.AtEndOfStream
		result := objExec.StdOut.ReadAll()
	Send % StrReplace(result, "`r")
