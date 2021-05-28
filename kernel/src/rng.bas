


function NextRandomNumber(_min as unsigned integer,_max as unsigned integer) as unsigned integer
    dim mi as unsigned integer=_min
    dim ma as unsigned integer=_max
    if mi>ma then
        mi=_max
        ma=_min
    end if
    dim interval as unsigned integer=ma-mi
    read_rtc()
    nextR = nextR * 1103515245 + ((((( (day + month*31 + year*365) *24 )+hour) *60)+minute)*60) + second
    read_rtc()
    nextR = nextR * 1103515245 + ((((( (day + month*31 + year*365) *24 )+hour) *60)+minute)*60) + second
    return  mi+((cast(unsigned integer ,(nextR / 65536) MOD 32768)) MOD (interval+1))
return 0
end function