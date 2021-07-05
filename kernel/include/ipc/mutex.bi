Type Mutex field =1
    value as unsigned integer
    ThreadQueue as Thread ptr
    CurrentThread as Thread ptr
    
    NextMutex as Mutex ptr
    declare constructor()
    declare destructor()
    
    declare function Acquire(th as thread ptr) as unsigned integer
    declare sub Release(th as thread ptr)
    
end type
Dim shared Mutexes as Mutex ptr


    
