#NoTrayIcon
#RequireAdmin
#include <AutoItConstants.au3>
#include <Array.au3>
#include <File.au3>

If $CmdLine[0] > 1 then
	Switch StringUpper($CmdLine[1])
		Case "DELETESHADOWCOPYBYID"
			If $CmdLine[0] >= 2 then
				DeleteShadowCopyByID($CmdLine[2])
			Else
				ConsoleWrite("The command has few arguments for this option")
				Help()
			EndIf
		Case "CREATESHADOWCOPY"
			If $CmdLine[0] >= 2 then
				CreateShadowCopy($CmdLine[2])
			Else
				ConsoleWrite("The command has few arguments for this option")
				Help()
			EndIf
		Case "UNMOUNTSHADOWCOPY"	
			If $CmdLine[0] >= 2 then
				UnmountShadowCopy($CmdLine[2])
			Else
				ConsoleWrite("The command has few arguments for this option")
				Help()
			EndIf
		Case "MOUNTSHADOWCOPY"	
			If $CmdLine[0] >= 3 then
				MountShadowCopy($CmdLine[2], $CmdLine[3])
			Else
				ConsoleWrite("The command has few arguments for this option")
				Help()
			EndIf
		Case Else
			Help()
	EndSwitch
Else
	Help()
EndIf



Func MountShadowCopy($ShadowID,$PathToMount)
	If FileExists($PathToMount) Then
		;adjust mount path
		$path = ""
		If StringRight($PathToMount, 1) = "\" Then
			$path = $PathToMount & StringGenerator(8)
		Else
			$path = $PathToMount & "\" & StringGenerator(8)
		Endif
		
		;mount shadow copy as junction
		$objWMI = ObjGet('winmgmts:root\cimv2')
		$objClass = $objWMI.ExecQuery('SELECT * FROM Win32_ShadowCopy WHERE ID="' & $ShadowID & '"')
		For $objItem In $objClass
			ShellExecuteWait("CMD.exe", "/C mklink /j " & $path & " " & $objItem.DeviceObject & "\", @TempDir, "", @SW_HIDE)
		Next
		
		;check if is mounted
		If FileExists($path) Then
			ConsoleWrite($path)
		Else
			ConsoleWrite("ERROR: Unable to mount Shadow Copy.")
		EndIf
	Else
		ConsoleWrite("ERROR: The path to mount Shadow Copy does not exists.")
	EndIf
	
EndFunc

Func UnmountShadowCopy($ShadowMountPathLink)
	;delete junction
    If FileExists($ShadowMountPathLink) Then
		DirRemove($ShadowMountPathLink)
        ConsoleWrite("UNMOUNTED")
    Else
        ConsoleWrite("ERROR: Invalid Shadow Copy mount path.")
    EndIf
EndFunc

Func DeleteShadowCopyByID($ShadowID)
	$objWMI = ObjGet('winmgmts:root\cimv2')
	$objClass = $objWMI.ExecQuery('SELECT * FROM Win32_ShadowCopy WHERE ID="' & $ShadowID & '"')
	If $objClass.count > 0 Then
		;delete shadow copy
		For $objItem In $objClass
			$objItem.Delete_
		Next
		
		;check If shadow copy is deleted
		$objClass = $objWMI.ExecQuery('SELECT * FROM Win32_ShadowCopy WHERE ID="' & $ShadowID & '"')
		If $objClass.count = 0 Then
			ConsoleWrite("DELETED")
		else
			ConsoleWrite("ERROR: Shadow Copy can not be deleted.")
		endif
	else
		ConsoleWrite("ERROR: Shadow Copy ID does not exists.")
	endif
EndFunc

Func CreateShadowCopy($Path)
	If FileExists($Path) Then
		;create shadow copy
		$diskLetter = StringLeft($Path, 2)
		$TMPFile = _TempFile("", "", ".txt", Default)
		ShellExecuteWait("CMD.exe", "/C wmic.exe /namespace:\\root\CIMV2 CLASS Win32_ShadowCopy CALL Create Volume=" & $diskLetter & "\ Context=ClientAccessible > " & $TMPFile, @TempDir, "", @SW_HIDE)
		
		;Open the temp file for reading
		$hFileOpen = FileOpen($TMPFile, 0)
		If $hFileOpen = -1 Then
			ConsoleWrite("ERROR: An error occurred when reading the temp file.")
			Return False
		else
			;Read the contents of the temp file
			$sFileRead = FileRead($hFileOpen)

			FileClose($hFileOpen)
			FileDelete($TMPFile)
			
			$retorno = StringSplit($sFileRead, '"')
			ConsoleWrite($retorno[2])
		EndIf
	Else
		ConsoleWrite("ERROR: Invalid path.")
	EndIf
EndFunc

Func StringGenerator($Size)
	$str = ""	
	For $i = 1 To $Size
		$rnd = Random(1, 2, 1)
		If $rnd = 1 Then
			$str = $str & Chr(Random(65, 90, 1)) ;A-Z
		Else
			$str = $str & Chr(Random(48, 57, 1)) ;0-9
		Endif
	Next
	Return $str
EndFunc


Func Help()
	ConsoleWrite(@CRLF &"VSSEasy [option] [parameters]" & @CRLF & @CRLF)
	ConsoleWrite("OPTIONS:" & @CRLF & @CRLF)
	ConsoleWrite("CreateShadowCopy:      Create a shadow copy." & @CRLF)
	ConsoleWrite("DeleteShadowCopyByID:  Delete a shadow copy." & @CRLF)
	ConsoleWrite("MountShadowCopy:       Mounts a shadow copy as a directory where the content is the disk root of the snapshot." & @CRLF)
	ConsoleWrite("UnmountShadowCopy:     Unmount a shadow copy." & @CRLF& @CRLF)
	ConsoleWrite("EXAMPLES:" & @CRLF & @CRLF)
	ConsoleWrite('VSSEasy CreateShadowCopy C:\some\directory' & @CRLF & @CRLF)
	ConsoleWrite('VSSEasy DeleteShadowCopyByID {00000000-0000-0000-0000-000000000000}' & @CRLF & @CRLF)
	ConsoleWrite('VSSEasy MountShadowCopy {00000000-0000-0000-0000-000000000000} C:\some\directory\to\mount' & @CRLF & @CRLF)
	ConsoleWrite('VSSEasy UnmountShadowCopy C:\chosed\directory\to\mount' & @CRLF & @CRLF)
	ConsoleWrite("Made by Andrei Bernardo Simoni")
EndFunc