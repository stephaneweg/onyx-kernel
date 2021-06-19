
Type AppRegistration
    Thread as unsigned integer
    Process as unsigned integer
    Title as unsigned byte ptr
    
    prevApp as AppRegistration ptr
    nextApp as AppRegistration ptr
    
    declare constructor()
    declare destructor()
end Type


declare sub ProcessRegister(proc as unsigned integer,th as unsigned integer)
declare sub ProcessUnregister(proc as unsigned integer)
declare sub ProcessSetTitle(proc as unsigned integer,t as unsigned byte ptr)
declare sub ProcessActivate(proc as unsigned integer)

dim shared CurrentApp as AppRegistration ptr
dim shared FirstRegisteredApp as AppRegistration ptr
dim shared LastRegisteredApp as AppRegistration ptr
dim shared mainMenu as GDIBase ptr
dim shared mainMenuButton as TButton ptr