const mode640x480x15	=	&h110
const mode640x480x16	=	&h111
const mode640x480x24	=	&h112
const mode640x480x32	=	&h129
const mode800x600x15	=	&h113
const mode800x600x16	=	&h114
const mode800x600x24	=	&h115
const mode800x600x32	=	&h12E
const mode1024x768x15	=	&h116
const mode1024x768x16	=	&h117
const mode1024x768x24	=	&h118
const mode1024x768x24b	=	&h4118
const mode1024x768x32	=	&h138
const mode1280x1024x15	=	&h119
const mode1280x1024x16	=	&h11a
const mode1280x1024x24	=	&h11b
const vesa_signature	=	&h41534556

TYPE VESA_INFO FIELD=1
	VESASignature		as unsigned integer
	VESAVersion			as unsigned short
	OEMStrPtr			as unsigned long
	Capabilities(0 to 4)	as byte
    VideoModePtr		as	unsigned long
	TotalMemory			as unsigned short
	OemSoftwareRev		as unsigned short
	OemVendorNamePtr	as unsigned long
	OemProductNamePtr	as unsigned long
	OemProductRevPtr	as unsigned long
	reserved(0 to 221)	as byte
	OemData(0 to 255)	as byte
END TYPE


TYPE MODE_INFO FIELD=1
	ModeAttributes	as unsigned short
	WinAAttributes	as byte
	WinBAttributes	as byte
	WinGranularity	as unsigned short
    WinSize			as unsigned short  
	WinASegment		as unsigned short
	WinBSegment		as unsigned short
    WinFuncPtr		as unsigned integer  
    BytesPerScanLine	as unsigned short
	XResolution		as unsigned short
	YResolution		as unsigned short
    XCharSize		as byte
	YCharSize		as byte
	NumberOfPlanes	as byte
	BitsPerPixel	as byte
	NumberOfBanks	as byte
	MemoryModel		as byte
	BankSize		as byte
    NumberOfImagePages	as byte
	Reserved_page	as byte
    RedMaskSize		as byte
	RedMaskPos		as byte
	GreenMaskSize	as byte
	GreenMaskPos	as byte
	BlueMaskSize	as byte
	BlueMaskPos		as byte
	ReservedMaskSize	as byte
	ReservedMaskPos		as byte
	DirectColorModeInfo	as byte
	PhysBasePtr			as unsigned integer
	OffScreenMemOffset	as unsigned integer
	OffScreenMemSize	as unsigned short
	Reserved(0 to 205)	as byte
END TYPE


declare function VesaProbe() as unsigned integer
declare sub VesaSetMode(mode as unsigned integer)
declare function VesaGetModeInfo(mode as unsigned integer) as unsigned integer
declare sub VesaResetScreen()

dim shared current_vesa_info as VESA_INFO
dim shared current_mode_info as MODE_INFO
dim shared BytesPerPixel as unsigned integer
dim shared XRes as unsigned integer
dim shared YRes as unsigned integer
dim shared Bpp as unsigned integer
dim shared LFB as unsigned integer
dim shared LFBSize as unsigned integer
dim shared PixelCount as unsigned integer