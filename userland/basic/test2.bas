
sub foo(x) 
    return 3
end sub


sub main(a,b)
    if (a = 2) and ( a > 3) or ( b < 8)
        var c
        c = 3
    elseif a<foo(9)+3
        var c
        c = a+foo(8)
    end if
end sub
        