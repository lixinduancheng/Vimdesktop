global FI=(cui.getConfigFile())
global TMPF1=(getdir #temp+"\abc1.tmp")
global TMPF2=(getdir #temp+"\abc2.tmp")
------------------------------Find "Item Name"
fn FindITM TTT =(
	F=openfile FI
	HAVEOXTOL=false
	FC = 0
	RT = #()
	for i in 1 to 500 do(
		if eof F == false then(
			FC = i
			a=(readline F)
			b = findstring a TTT
			if b != undefined do(
				HAVEOXTOL=true
				exit
			)
		)else exit
	)
	close F
	append RT HAVEOXTOL
	append RT FC
	return RT
)
--=============================ok
fn InsetText III =(
	F=openfile FI
	T1=createfile TMPF1
	T2=createfile TMPF2
	for i in 1 to III do(
		a=(readline F)
		format "%\n" a to:T1
	)
	for i in 1 to 500 do(
		if eof F == false then(
			a=(readline F)
			format "%\n" a to:T2
		)else exit
	)
	close F
	close T1
	close T2
	F2=openfile FI mode:"w"
	T1=openfile TMPF1
	T2=openfile TMPF2
	for i in 1 to III do(
		format "%\n" (readline T1) to:F2
	)
	------------------------My Inset
format "%\n" "                <Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"0\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"cici_Render8Direction`cici_Tools\" tip=\"cici_Render8Direction\" label=\"cici_Render8Direction\" />" to:F2
	------------------------
	for i in 1 to 500 do(
		if eof T2 == false then
			format "%\n" (readline T2) to:F2
		else
			exit
	)
	close F2
	close T1
	close T2
	return true
)
--=============================ok
if (FindITM "cici_Render8Direction")[1] == false then(
	aaa=FindITM "<Items>"  --找到要插入的行
	InsetText aaa[2]
	deletefile TMPF1
	deletefile TMPF2
	cui.loadConfig FI
)