declare sub ConsoleWrite(p as unsigned byte ptr) 
declare sub ConsoleNewLine()

sub ConsoleWrite(p as unsigned byte ptr) 
    dim result as string = ""
    var l = strlen(p)
    for i as unsigned integer= 0 to l-1
        print chr(p[i]);
    next i
end sub

sub ConsoleNewLine()
    print
end sub