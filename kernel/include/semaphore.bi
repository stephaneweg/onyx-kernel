Type Semaphore field =1
    value as unsigned integer
    ThreadQueue as Thread ptr
    CurrentThread as Thread ptr
    
    nextSem as semaphore ptr
    declare constructor()
    declare destructor()
    
    declare function SemLock(th as thread ptr) as unsigned integer
    declare sub SemUnlock(th as thread ptr)
    
end type

Dim shared Semaphores as Semaphore ptr