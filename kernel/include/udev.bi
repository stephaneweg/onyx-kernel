type UserModeDevice field = 1
        Name        as unsigned byte ptr
        OwnerThread as Thread ptr
        Descriptor  as unsigned integer
        Entry       as unsigned integer
        NextDev     as UserModeDevice ptr
        
        
        declare static sub Create(n as unsigned byte ptr,th as Thread ptr,descr as unsigned integer, entryPoint as unsigned integer)
        declare static function Find(n as unsigned byte ptr) as unsigned integer
        declare static function Invoke(d as unsigned integer,callerTHread as Thread ptr,param1 as unsigned integer,param2 as unsigned integer,param3 as unsigned integer,param4 as unsigned integer) as unsigned integer
end type

dim shared UserModeDevices as UserModeDevice ptr

declare sub UDEV_INIT()