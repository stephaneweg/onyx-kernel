function VesaGetInfo() as unsigned integer
	DoRealModeActionReg(&h4F00,0,0,0,0,&hf000,0,&h10)
	MemCpy(@current_vesa_info,cptr( unsigned integer ptr,&hf000),sizeof(VESA_INFO))

	if (current_vesa_info.VESASignature=vesa_signature) then 
		return 1
	else 
		return 0
	end if
end function

function VesaGetModeInfo(mode as unsigned integer) as unsigned integer
    current_mode_info.XResolution = 0
    current_mode_info.YResolution = 0
    current_mode_info.BitsPerPixel = 0
    dim ok as unsigned integer
	
	DoRealModeActionReg(&h4F01,0,mode,0,0,&hE000,0,&h10)
	MemCpy(@current_mode_info,cptr( unsigned integer ptr,&he000),sizeof(MODE_INFO))
    
    
    if (ok and &hFF00 or current_mode_info.BitsPerPixel = 0) then
		return 0
	else
        return 1
    end if
end function


function VesaProbe() as unsigned integer
    dim modes(0 to 5) as unsigned integer =>{_
        mode1024x768x32,_
        mode1024x768x24,_
        mode800x600x32,_
        mode800x600x24,_
        mode640x480x32,_
        mode640x480x24 _
    }
    
    dim modesText(0 to 5) as unsigned byte ptr =>{_
        @"1024x768x32",_
        @"1024x768x24",_
        @"800x600x32",_
        @"800x600x24",_
        @"640x480x32",_
        @"640x480x24"_
    }
    
    dim i as unsigned integer
    
    ConsoleWriteLine(@"Finding best graphic mode ... ")
    for i=0 to 5
        ConsoleWrite(@"   *")
        ConsoleWrite(modesText(i))
        
        if (VesaGetModeInfo(modes(i)) = 1) then
            ConsoleWrite(@" : OK")
            ConsoleNewLine()
            return modes(i)
        else
            ConsoleWrite(@" : FAIL")
            ConsoleNewLine()
        end if
    next
    ConsoleNewLine()
    ConsoleWriteLine(@"NO mode found")
    
    return 0
end function  

sub VesaSetMode(mode as unsigned integer)
   
  
    VesaGetModeInfo(mode)
    BPP = current_mode_info.BitsPerPixel and &hFF
    XRes = current_mode_info.XResolution and &h0000FFFF
    YRes = current_mode_info.YResolution and &h0000FFFF
    BytesPerPixel = BPP shr 3
    PixelCount = (XRes*YRes)
    LFB = current_mode_info.PhysBasePtr
    LFBSize = current_mode_info.YResolution * current_mode_info.BytesPerScanLine
    var nbrPages = (LFBSize shr 12) +1
    var lfbEND =LFB+(((LFBSize shr 12) +1) shl 12)
    kernel_context.map_range(cptr(any ptr,LFB),cptr(any ptr, LFB),cptr(any ptr, lfbEND), VMM_FLAGS_USER_DATA)
    
    SysConsole.Phys =  PMM_ALLOCPAGE()
    kernel_context.map_page(SysConsole.Virt,SysConsole.Phys, VMM_FLAGS_USER_DATA)
	DoRealModeActionReg(&h4F02,mode,0,0,0,0,0,&h10)
    
end sub


sub VesaResetScreen()
	DoRealModeActionReg(&h0003,0,0,0,0,0,0,&h10)
end sub
