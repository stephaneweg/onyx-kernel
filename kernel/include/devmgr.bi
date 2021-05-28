

declare sub DEVMGR_INIT()
declare function DEVMGR_FIND(diskname as byte ptr) as Device ptr

declare function DEVMGR_CREATE_DEVICE(devName as unsigned byte ptr) as Device ptr
declare function DEVMGR_CREATE_IO_DEVICE(devName as unsigned byte ptr) as IODevice ptr
declare function DEVMGR_CREATE_CHAR_DEVICE(devName as unsigned byte ptr) as CharDevice ptr
declare function DEVMGR_CREATE_BLOCK_DEVICE(devName as unsigned byte ptr) as BlockDevice ptr