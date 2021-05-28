#macro outb(p,v)
asm
	movw dx,p
	movb al,v
	out dx, al
end asm
#endmacro

#macro inb(p,v)
asm
	movw dx,p
	in al,dx
	mov v,al
end asm
#endmacro

#macro outw(p,v)
asm
	movw dx,p
	movw ax,v
	out dx,ax
end asm
#endmacro

#macro inw(p,v)
asm
	movw dx,p
	in ax,dx
	mov v,ax
end asm
#endmacro