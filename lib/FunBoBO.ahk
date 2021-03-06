﻿;定义启动1
FunBoBO_HideOrActivation1(ExePath,tClass) {
	IfWinNotExist,ahk_class %tClass%
	Run,"%ExePath%"
	IfWinActive
	WinMinimize
	else
	WinActivate
	return
}
;定义启动2
FunBoBO_HideOrActivation2(ExePath,tClass) {
    DetectHiddenWindows, on
    IfWinNotExist %ExePath% %tClass%
    { 
   		Run %ExePath% ;
    	WinActivate 
    } 
    	Else IfWinNotActive ahk_class %tClass%
    { 
    	WinActivate
    } 
    Else 
    { 
        WinMinimize 
    } 
}
FunBoBO_RunActivation(ExePath,tClass){
    IfWinExist, AHK_CLASS %tClass%
    {
        WinGet, AC, MinMax, AHK_CLASS %tClass%
        if Ac = -1
            Winactivate, AHK_ClASS %tClass%
        else
            Ifwinnotactive, AHK_CLASS %tClass%
                Winactivate, AHK_CLASS %tClass%
            else
                Winminimize, AHK_CLASS %tClass%
    }
    else
    {
        Run, %ExePath%
        Loop, 4
        {
            IfWinNotActive, AHK_CLASS %tClass%
                WinActivate, AHK_CLASS %tClass%               
            else
                Break
            Sleep, 500
        }
} 
}
;显示函数---------------------------------------
FunBoBO_VimShow(){
    run,%A_ScriptDir%\apps\HuntAniidPeck\hap.exe /hint
    return
}
FunBoBO_ShowLayout(img){
	;ShowLayout:
		Gui,ShowLayout:Add,pic,Center,%A_ScriptDir%\ui\%img% 
		Gui,ShowLayout:+LastFound +AlwaysOnTop -Caption ; +ToolWindow -DPIScale
		Gui,ShowLayout:Show,Center NoActivate
        WinSet, Transparent, 250
		;WinSet, TransColor,f0f0f0 ;去掉灰色边框
	Return
}
;隐藏
FunBoBO_HideLayout(){
	;HideLayout:
	Gui,ShowLayout:Hide
	return
}
;显示图片函数结束---------------------------------------

;在窗口内点击坐标
CoordWinClick(x,y){
	CoordMode, Mouse, Relative
;	WinGetPos, X, Y, W, H, A
	ControlClick, x%x% y%y%,,,,, Pos
	return
}
;无视输入法状态发送字符串
;其实还有一种方法，就是把字符串赋值给粘贴板，然后粘贴
uStr(str)
{
    charList:=StrSplit(str)
	SetFormat, integer, hex
    for key,val in charList
    out.="{U+ " . ord(val) . "}"
	return out
}


;获取当前目录
FunBoBO_CustomFunc_getCurrentDir(ByRef CurWinClass="")
{
    if CurWinClass=
    {
        WinGetClass, CurWinClass, A
        sleep 50
    }
    ;获取当前目录
    ;CurWinClass:=QZData("winclass") ;将获取的class名赋值给用户变量
    ;Curhwnd:=QZData("hWnd")
    if CurWinClass in ExploreWClass,CabinetWClass ;如果当前激活窗口为资源管理器
    {
        DirectionDir:=FunBoBO_Explorer_GetSelected(Curhwnd)
        IfInString,DirectionDir,`;		;我的电脑、回收站、控制面板等退出
            return
    }
    if CurWinClass in WorkerW,Progman    ;如果当前激活窗口为桌面
    {
        DirectionDir:=FunBoBO_Explorer_GetSelected(Curhwnd)
    }
    if (CurWinClass="Shell_TrayWnd") ;如果当前激活窗口为任务栏
        DirectionDir:=""

    if CurWinClass in TTOTAL_CMD ;如果当前激活窗口为TC
    {
        IfWinNotActive ahk_class TTOTAL_CMD
        {
            Postmessage, 1075, 2015, 0,, ahk_class TTOTAL_CMD	;最大化
            WinWait,ahk_class TTOTAL_CMD
            WinActivate
        }
        Postmessage, 1075, 332, 0,, ahk_class TTOTAL_CMD	;光标定位到焦点地址栏
        sleep 300
        ;PostMessage,1075,2029,0,,ahk_class TTOTAL_CMD ;获取路径
        PostMessage,1075,2018,0,,ahk_class TTOTAL_CMD ;获取路径2
        sleep 100
        DirectionDir:=Clipboard
    }
    If(DirectionDir="ERROR")		;错误则退出
        DirectionDir:=""
    
    return DirectionDir
}

FunBoBO_Explorer_GetPath(hwnd="")
{
	if !(window := FunBoBO_Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop
	path := window.LocationURL
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All
	loop
		if RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		else break
	return path
}

FunBoBO_Explorer_GetWindow(hwnd="")
{
	WinGet, Process, ProcessName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
	WinGetClass class, ahk_id %hwnd%

	if (Process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW")
		return "desktop" ; desktop found
}

FunBoBO_Explorer_GetSelected(hwnd="")  
{  
    return FunBoBO_Explorer_Get(hwnd,true)  
}  

FunBoBO_Explorer_Get(hwnd="",selection=false)  
{  
    if !(window := FunBoBO_Explorer_GetWindow(hwnd))  
        return ErrorLevel := "ERROR"  
    if (window="desktop")  
    {  
        ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman  
        if !hwWindow ; #D mode  
            ControlGet, hwWindow, HWND,, SysListView321, A  
        ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%  
        base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop  
        Loop, Parse, files, `n, `r  
        {  
            path := base "\" A_LoopField  
            IfExist %path% ; ignore special icons like Computer (at least for now)  
                ret .= path "`n"  
        }  
    }  
    else  
    {  
        if selection  
            collection := window.document.SelectedItems  
        else  
            collection := window.document.Folder.Items  
        for item in collection  
            ret .= item.path "`n"  
    }  
    return Trim(ret,"`n")  
}  

;   AeScriptFunction调用Ae脚本文件_ByBoBO
;   使用方式
;   getAeScript("路径")
;   文件放置位置必须在本脚本目录下
getAeScript(AeScriptPath){

    WinActivate, ahk_exe AfterFX.exe

    global AeExePath := ini.BOBOPath_Config.AEPath

    RunWait, %AeExePath% -s -r %A_ScriptDir%\%AeScriptPath%,,Hide

    WinActivate, ahk_exe AfterFX.exe

    return
}

;   AeScriptFunction直接调用指令_ByBoBO
;   使用方式
;   getAeScript("指令")
;   文件放置位置必须在本脚本目录下

getAeScriptCommand(AeScriptCommand){

    WinActivate, ahk_exe AfterFX.exe

    global AeExePath := ini.BOBOPath_Config.AEPath

    RunWait, %AeExePath% -s -r %AeScriptCommand%,,Hide

    WinActivate, ahk_exe AfterFX.exe

    return
}


runMax(runPath){
    ;tempStr := "filein """ . A_LoopFileFullPath . """"
    runPath = %A_ScriptDir%\custom\maxScripts\initialize_COM_server.ms
    tempStr := "filein """ . %runPath% . """"
    StringReplace, tempStr, tempStr, `\, `\`\, ALL
    Control, EditPaste, %tempStr%, MXS_Scintilla2, A
    ControlSend, MXS_Scintilla2, {NumpadEnter}, A
    return
}

;;运行函数
getMaxScriptCommands(MaxScriptPath){
    run, %A_ScriptDir%\custom\maxScripts\MXSPyCOM.exe -f %A_ScriptDir%\custom\maxScripts\commands\%MaxScriptPath%
    return
}

;;测试运行函数
get2MaxScript(runPath){
    ;tempStr := "filein """ . A_LoopFileFullPath . """"
    ;runPath = %A_ScriptDir%\custom\maxScripts\initialize_COM_server.ms
    tempStr := "filein """ . %runPath% . """"
    StringReplace, tempStr, tempStr, `\, `\`\, ALL
    Control, EditPaste, %tempStr%, MXS_Scintilla2, A
    ControlSend, MXS_Scintilla2, {NumpadEnter}, A
    return
}

run2MaxScript(runPath){
    ControlFocus, MXS_Scintilla2
    ControlSetText, MXS_Scintilla2, %runPath%
    send, +{Enter}
    Click 1
    Return
}
;;Photoshop运行函数
runPsScript(PsPath){
    app:=ComObjCreate("Photoshop.Application")
    app.DoJavaScriptFile(%PsPath%)
    return
}

; 运行自定义标题
FunBoBO_RunActivationTitle(ExePath,tClass,NewTitle){
    IfWinExist, AHK_CLASS %tClass%
    {
        WinGet, AC, MinMax, AHK_CLASS %tClass%
        if Ac = -1
            Winactivate, AHK_ClASS %tClass%

        else
                Ifwinnotactive, AHK_CLASS %tClass%
                Winactivate, AHK_CLASS %tClass%
            else
                Winminimize, AHK_CLASS %tClass%
    }
    else
    {
        Run, %ExePath%
        Loop, 4
        {
            IfWinNotActive, AHK_CLASS %tClass%
                WinActivate, AHK_CLASS %tClass%        
            else
                Break
            Sleep, 500
        }
    } 

    SetTitleMatchMode, regex

    IfWinExist, ahk_class %tClass%,,2
    WinSetTitle, %NewTitle% ; %N_Title%

return
}

Morse(timeout = 400) {
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   Loop {
      t := A_TickCount
      KeyWait %key%
      Pattern .= A_TickCount-t > timeout
      KeyWait %key%,DT%tout%
      If (ErrorLevel)
         Return Pattern
   }
}

setzh(){
		PostMessage, 0x50, 0, 0x8040804, , A
		if !IME_GET0E1C()
			SendInput, {LShift}
		return
}
seten(){
	if IME_GET0E1C()
		SendInput, {LShift}
return
}

IME_GET0E1C(WinTitle="A"){			;借鉴了某日本人脚本中的获取输入法状态的内容,减少了不必要的切换,切换更流畅了
    ;~ ifEqual WinTitle,,  SetEnv,WinTitle,A
    WinGet,hWnd,ID,%WinTitle%
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)

    ;Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
    DetectSave := A_DetectHiddenWindows
    DetectHiddenWindows,ON
    SendMessage 0x283, 0x005,0,,ahk_id %DefaultIMEWnd%
    DetectHiddenWindows,%DetectSave%
    Return ErrorLevel
}

varExist(ByRef v) { ; 检测变量是否存在
   return &v = &n ? 0 : v = "" ? 2 : 1 
}

ProcessExist(Name){ ; 检测进程
Process,Exist,%Name%
return Errorlevel
}


; 单双长按函数
analyseKeyPress(comboKeyName="",doubleKeySpeed=0.15,longKeyPressTime=0.3){ ;
   ;Param1:Other Key to make combo; similaire to "&"
   ;Param2:Maximum seconds to execute the doubleKey otherWise it will be a singleKey, Put 0 "zero" if you want direct interaction
   ;Param3:Time(in seconds) you must keep the key down to generate a long Key event
   ;return: 0 to 6
   ;0=Long Press of more then 500 miliseconds
   ;1=single Key 
   ;2=doubleKey
   ;3=long key
   ;4=combo Single Key
   ;5=combo double Key
   ;6=combo long Key
   ;https://autohotkey.com/board/topic/55314-double-keylong-key-press-combo-double-key/
      static diff:=0
      GetKeyState,comboKeyState,%comboKeyName%,P
      ifEqual,comboKeyState,D,hotkey,%comboKeyName%,disableComboKeyHotkey
      
     diff-=a_tickCount
     ifGreater,diff,-550,keywait, %A_thisHotkey%
     ifGreater,diff,-550,return 0
     diff:=a_tickCount
      
      keywait, %A_thisHotkey%,t%longKeyPressTime%
      if errorLevel{
         ifEqual,comboKeyState,D,setEnv,KeyPress,6   ;combo Long Key
         else setEnv,KeyPress,3                  ;long key
      }else{
         keywait, %A_thisHotkey%, d t%doubleKeySpeed%
         if errorLevel{
            ifEqual,comboKeyState,D,setEnv,KeyPress,4   ;combo single Key
            else setEnv,KeyPress,1                  ;Single key
         }else{
            ifEqual,comboKeyState,D,setEnv,KeyPress,5   ;combo double Key
            else setEnv,KeyPress,2                  ;double key
         }
      }
      ifEqual,comboKeyState,D,hotkey,%comboKeyName%,%comboKeyName%
      return %keyPress%
   }
   disableComboKeyHotKey:
      return
   Return ;;66


; 单双长按函数2
analyseKeyPressDouble(){

    t := A_PriorHotkey == A_ThisHotkey && A_TimeSincePriorHotkey < 200 ? "off" : -200
    settimer, ae_tappedkey_F12, %t%
    if (t == "off")
    goto ae_double_F12
    return %KeyPress%
    ae_tappedkey_F12:
        {
            KeyPress:= 1

        }
    return

    ae_double_F12:
        {
            KeyPress:= 2
        }

}



/*
[script info]
description = double tap function to send a hotkey or label
author      = davebrny
source      = https://gist.github.com/davebrny/383ab4158e4220f5658223475ad57719
*/

double_tap(single_tap, double_tap, tap_time="T.2") {
    key := LTrim(a_thisHotkey, "~$*")
    key := regExReplace(key, "[\Q^!+#\E]")   ; remove modifiers
    keyWait, % key
    keyWait, % key, D %tap_time%
    if (errorLevel)
         sub_send(single_tap)
    else sub_send(double_tap)
}

sub_send(action) {
    if isLabel(action)
        goSub, % action
    else send, % action
}

GetClickType(double=250,hold=500)	; by Learning one
{
	;Return values: "1" single click, "2" double click, "3" holding key down
	Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W)"), hold /= 1000, double /= 1000
	KeyWait, %Hotkey%, t%hold%
	if ErrorLevel
	return 3
	KeyWait, %Hotkey%, d t%double%
	return (ErrorLevel) ? 1 : 2
}

; Example:
; RButton::MsgBox,,, % GetClickType(),1

; Beautiful popup msg, tooltip美化提示
; To Create PleasantNotification
; PleasantNotify(Title, Messages, width, height, position, time)
; Title - you can use variable, else must be String
; Messages - same as Title
; width - GUI width for PleasantNotify, if omited 700
; height - GUI height for PleasantNotify, if omitted 300
; position - GUI postion for PleasantNotify, it omitted bottom right corner

; position argument syntax is to create a string with the following:
; t=top, vc= vertical center, b=bottom
; l=left, hc=horizontal center, r=right
;https://www.autohotkey.com/boards/viewtopic.php?t=6056
PleasantNotify(title, message, pnW=700, pnH=300, position="b r", time=10) {
    global pn_title, pn_msg, PN_hwnd, w, h
	Notify_Destroy()
	Gui, Notify: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	PN_hwnd := WinExist()
	WinSet, ExStyle, +0x20
	WinSet, Transparent, 0
	Gui, Notify: Color, 0xF2F2F0
	Gui, Notify: Font, c0x07D82F s18 wBold, Segoe UI
	Gui, Notify: Add, Text, % " x" 20 " y" 12 " w" pnW-20 " vpn_title", % title
	Gui, Notify: Font, cBlack s15 wRegular
	Gui, Notify: Add, Text, % " x" 20 " y" 56 " w" pnW-20 " h" pnH-56 " vpn_msg", % message
	RealW := pnW + 50
	RealH := pnH + 20
	Gui, Notify: Show, W%RealW% H%RealH% NoActivate
	WinMove(PN_hwnd, position)
	if A_ScreenDPI = 96
		WinSet, Region,0-0 w%pnW% h%pnH% R40-40,%A_ScriptName%
	/* For Screen text size 125%
	if A_ScreenDPI = 120
		WinSet, Region, 0-0 w800 h230 R40-40, %A_ScriptName%
	*/
	winfade("ahk_id " PN_hwnd,210,5)
	if (time <> "P")
	{
		Closetick := time*1000
		SetTimer, ByeNotify, % Closetick
	}
}

Notify_Destroy() {
	global PN_hwnd
	ByeNotify:
	SetTimer, ByeNotify, Off
    winfade("ahk_id " PN_hwnd,0,5)
    Gui, Notify: Destroy
	return
}

pn_mod_title(title) {
	global pn_title
	GuiControl, Notify: Text,pn_title, % title
}

pn_mod_msg(message) {
	global pn_msg
	GuiControl, Notify: Text,pn_msg, % message
}

WinMove(hwnd,position) {
   SysGet, Mon, MonitorWorkArea
   WinGetPos,ix,iy,w,h, ahk_id %hwnd%
   x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
   y := InStr(position,"t") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"b") ? MonBottom - h : iy
   WinMove, ahk_id %hwnd%,,x,y
}

winfade(w:="",t:=128,i:=1,d:=10) {
    w:=(w="")?("ahk_id " WinActive("A")):w
    t:=(t>255)?255:(t<0)?0:t
    WinGet,s,Transparent,%w%
    s:=(s="")?255:s ;prevent trans unset bug
    WinSet,Transparent,%s%,%w%
    i:=(s<t)?abs(i):-1*abs(i)
    while(k:=(i<0)?(s>t):(s<t)&&WinExist(w)) {
        WinGet,s,Transparent,%w%
        s+=i
        WinSet,Transparent,%s%,%w%
        sleep %d%
    }
}


; 获取Total Commander路径
getTcFolder()
{
	;需要运行Total Commander
    ClipSaved := ClipboardAll 
    clipboard =
    SendMessage 1075, 2029, 0, , ahk_class TTOTAL_CMD ;2029 复制来源路径
    ClipWait,2 
    OutDir=%clipboard%
    Clipboard := ClipSaved 
    ClipSaved = 
    return OutDir
}

;获取Explore当前路径 WinGet, hWnd , Id, A
getExploreFolder(hWnd=0)
{
	If   hWnd || (hWnd :=   WinExist("ahk_class (?:Cabinet|Explore)WClass"))
   {
      For window in ComObjCreate("Shell.Application").Windows
         doc :=   window.Document
      Until   (window.hWnd = hWnd)
	}
      
      sFolder :=   doc.folder.self.path,
      ;~ MsgBox %sFolder%  ;获取forlder
      Return   sFolder
}

;标题路径Explorer打开
SaveFileFindForExplorer(){
    MouseGetPos, , , id, control
    WinGetTitle, title, ahk_id %id%
    getPath=%title%
    RegExMatch(getPath,"(\\|.:\\).*\\",newPath)
    Run % "explorer.exe /select," newPath
    IfWinExist, AHK_CLASS CabinetWClass
    {
        sleep 1000
        send {Enter}
        return
    }
    else
    {
        MsgBox "NoNoNO!"
        }
    return
}
;标题路径TC打开
SaveFileFindForTc(){	
	MouseGetPos, , , id, control
	WinGetTitle, title, ahk_id %id%
    TCPath := ini.TotalCommander_Config.TCPath
    getPath=%title%
    appName:=RegExMatch(getPath,"(\\|.:\\).*\\",candysel)
    ; Run "%TCPath%" /T /O /A /R="%candysel%"
    TC_OpenPath(candysel, newTab, "/L")
    return
}


CustomPlugin_SmartCompress(){
	;~ global   7zip
	;~ global   dir
	;candysel:=QZData("files")
    ; dir:=getTcFolder()
    TCPath := ini.TotalCommander_Config.TCPath
    RegExMatch(TCPath,"(.*\\)",TCPathDir)  ; 提取目录



    candysel := clipboard

;     clipboard:=
;     SendPos(2018)
; MsgBox %candysel%
	ThisProcess := DllCall("GetCurrentProcess")     ;判断系统是多少位 感谢卢霖
	if !DllCall("IsWow64Process", "uint", ThisProcess, "int*", IsWow64Process)
		IsWow64Process := false
	if  %IsWow64Process%=0 ;如果系统是32位
		7zip = %TCPathDir%\Tools\7z\7zG.exe
	else
		7zip = %TCPathDir%\Tools\7z\7zG.exe

	if !InStr(candysel,"`n")  ;若不是多文件则执行下列命令，以所选文件为压缩文件名
	{
		if InStr(FileExist(candysel), "D") ;若为文件夹则执行下来命令
		{
			SplitPath, candysel, name, dir, ext, name_no_ext, Drive
			Loop, %candysel%\* ,1   ;1表示获取文件夹文件夹.
			{
				if A_Index=1
				{
					File=% A_LoopFileFullPath
					continue
				}
				File.= "`r" . "`n" . A_LoopFileFullPath
			}
				FileList := RegExReplace(File, "\r\n", """ """)   ;感谢卢霖
			name_cheack(name,FileList,7zip,dir)
                clipboard :=
;			Run %7zip%  a  "%dir%"\"%name%.7z" "%FileList%"
			return
		}
		else
		{
			SplitPath, candysel, name2, dir, ext, name_no_ext, Drive
;			Run %7zip%  a  "%dir%\%name_no_ext%" "%candysel%"
			name_cheack(name_no_ext,candysel,7zip,dir)
                clipboard :=
			return
		}
	}
	RegExMatch(candysel,"((?!\\)[^\\]+(?=\\[^\\]+\n?$))",m)  ;获取上一级目录的文件名
	Loop,Parse,candysel,`n,`r  ;若为多文件，则执行下列命令,以上一级文件名为压缩文件名
	{
		SplitPath, A_LoopField, name2, dir, ext, name_no_ext, Drive
		if A_Index=1
		{
			File=% A_LoopField
			continue
		}
		File.= "`r" . "`n" . A_LoopField
		;~ FileList.=A_LoopField . """ """
	}
	;~ MsgBox %FileList%
	FileList := RegExReplace(File, "\r\n", """ """)
	Clipboard=%FileList%
;	Run %7zip%  a   "%dir%\%m1%" "%FileList%"
	name_cheack(m1,FileList,7zip,dir)
    clipboard :=
return
}
name_cheack(name,files,7zip,dir){
;name_cheack:
	;~ global   7zip
	;~ global   dir
	IfExist,%dir%\%name%.7z   ;已经存在了以“首层文件夹命名”的文件夹，怎么办？
	{
;	MsgBox %7zip%
		Loop
		{
			FolderName=%dir%\%name%( %A_Index% ).7z
			If !FileExist( FolderName )
			{
				MsgBox %FolderName%
				Run %7zip%  a   "%FolderName%" "%files%"
				break
			}
		}
		return
	}
;	MsgBox %name%
	Run %7zip%  a   "%dir%\%name%.7z" "%files%"
}