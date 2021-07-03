Type Signal field = 1
    Value as unsigned integer
    ThreadQueue as Thread ptr
    nextSignal as Signal ptr
    declare constructor()
    declare destructor()
    declare function Wait(t as thread ptr) as unsigned integer
    declare sub Set()
end type
dim shared Signals as Signal ptr