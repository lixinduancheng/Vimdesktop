﻿var idslct = charIDToTypeID( "slct" );
    var desc = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
        var ref = new ActionReference();
        var idlassoTool = stringIDToTypeID( "lassoTool" );
        ref.putClass( idlassoTool );
    desc.putReference( idnull, ref );
    var iddontRecord = stringIDToTypeID( "dontRecord" );
    desc.putBoolean( iddontRecord, true );
    var idforceNotify = stringIDToTypeID( "forceNotify" );
    desc.putBoolean( idforceNotify, true );
executeAction( idslct, desc, DialogModes.NO );