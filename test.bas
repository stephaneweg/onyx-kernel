declare function foo(x as integer) as integer
declare sub main(a as integer,b as integer)

function foo(x as integer) as integer
    return 3
end function


sub main(a as integer,b as integer)
    if (a=2) and (a>3) or (b<8) then
        dim c as integer
        c = 3
    elseif a<foo(9)+3 then
        dim c as integer
        c = a+foo(8)
    end if
end sub
        