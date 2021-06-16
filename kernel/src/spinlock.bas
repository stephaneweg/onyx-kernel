sub SpinLock.Init()
    this.LockVar = 0
end sub

sub SpinLock.Acquire()
    dim slock as unsigned integer ptr= @this.LockVar
    asm
        mov ecx,[slock]
        .SpinLock_acquire:
            lock bts dword ptr [ecx],0
            jnc .SpinLock_acquired
        .SpinLock_retest:
            pause
            test dword ptr [ecx],1
            je .SpinLock_retest
            
            lock bts dword ptr [ecx],0
            jc .SpinLock_retest
        .SpinLock_acquired:
    end asm
end sub

sub SpinLock.Release()
    this.LockVar = 0
end sub
    
