#define MaxPriority  10

Type ThreadQueue field = 1
    FirstThread as Thread Ptr
    LastThread as Thread ptr
    count as unsigned integer
    
    declare constructor()
    declare sub Enqueue(t as Thread ptr)
    declare sub EnqueueRange(tFirst as Thread ptr,tLast as Thread ptr,cnt as unsigned integer)
    declare function Dequeue() as Thread ptr
    declare function RTCDequeue() as Thread ptr
    declare sub Remove(t as Thread ptr)
end type

Type ThreadScheduler field = 1
    PriorityQueue(0 to MaxPriority) as ThreadQueue
    RTCQueue as ThreadQueue
    
    declare function ThreadCount() as unsigned integer
    CurrentRuningThread as Thread ptr
    RemovedThread as thread ptr
    declare function Switch(_stack as IRQ_Stack ptr,newThread as Thread ptr) as IRQ_Stack ptr
    declare sub SetThreadReady(t as Thread ptr,priority as unsigned integer)
    declare sub SetThreadRealTime(t as Thread ptr,delay as unsigned integer)
    declare sub ResetPriority(t as thread ptr)
    declare sub IncreasePriority(i as unsigned integer)
    declare function Schedule() as Thread ptr
    declare sub RemoveThread(t as Thread ptr)
    declare constructor()
end Type

dim shared Scheduler as ThreadScheduler