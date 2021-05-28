sub set_timer_freq(hz as unsigned integer)
    dim freq as unsigned long =I8254_MAX_FREQ / hz ' &h2e9b
    
    dim l as unsigned byte  = freq and &hFF
    dim h as unsigned byte  = ((freq  and &h00FF00)shr 8)
	outb (I8254_CONTROL,&h36 )
	outb (I8254_TIMER0,[l])
	outb (I8254_TIMER0,[h])
end sub

sub pic_init ()
	'' send ICW1 to both pics
	outb(MASTER_COMMAND, &h11)
	outb(SLAVE_COMMAND, &h11)
	
	'' ICW2 is where we want to map the interrupts
	'' we map them directly after the exceptions
	outb(MASTER_DATA, &h20)
	outb(SLAVE_DATA, &h28)
	
	'' ICW3: tell the PICs that they're connected through IRQ 2
	outb(MASTER_DATA, &h04)
	outb(SLAVE_DATA, &h02)
	
	'' ICW4: tell the PICs we're in 8086-mode
	outb(MASTER_DATA, &h01)
	outb(SLAVE_DATA, &h01)
	
	'' select ISR
	'outb(MASTER_COMMAND, &h0B)
	'outb(SLAVE_COMMAND, &h0B)
end sub


sub unmask_irq()
	outb(MASTER_DATA, &h0)
    outb(SLAVE_DATA, &h0)
end sub

sub mask_irq()
	outb(MASTER_DATA, &hFF)
    outb(SLAVE_DATA, &hFF)
end sub

function get_RTC_update_in_progress_flag() as unsigned byte
      dim b as unsigned byte
      outb(cmos_address, &h0A)
      inb(cmos_data,[b])
      b = b and &h80
      return b
end function

function get_RTC_register(reg as unsigned byte) as unsigned byte
      dim b as unsigned byte
      
      outb(cmos_address,[reg])
      inb(cmos_data,[b])
      return b
end function


function GetDateBCD() as unsigned integer
    read_rtc()
    
    
    
    var y4=((year mod 10000)\1000) shl 28
    var y3=((year MOD 1000)\100) shl 24
    var y2=((year MOD 100)\10) shl 20
    var y1=(year mod 10) shl 16
    
    var m2=((month mod 100)\10) shl 12
    var m1=(month mod 10) shl 8
    
    var d2=((day mod 100)\10) shl 4
    var d1=(day mod 10)
    
    return y4 or y3 or y2 or y1 or m2 or m1 or d2 or d1
end function

function GetTimeBCD() as unsigned integer
    read_rtc()
    
    var ss1 = (second mod 10)
    var ss2 = ((second mod 100)\10) shl 4
    
    var mm1 = (minute mod 10) shl 8
    var mm2 = ((minute mod 100)\10) shl 12
    
    var hh1 = (hour mod 10) shl 16
    var hh2 = ((hour mod 100)\10) shl 20
    
    return ss1 or ss2 or mm1 or mm2 or hh1 or hh2
end function


sub read_rtc()
    dim century as unsigned byte
    dim last_second as unsigned byte
    dim last_minute as unsigned byte
    dim last_hour as unsigned byte
    dim last_day as unsigned byte
    dim last_month as unsigned byte
    dim last_year as unsigned byte
    'dim last_century as unsigned byte
    dim registerB as unsigned byte
      
    while get_RTC_update_in_progress_flag()<>0 :wend

    second = get_RTC_register(&h00)
    minute = get_RTC_register(&h02)
    hour = get_RTC_register(&h04)
    day = get_RTC_register(&h07)
    month = get_RTC_register(&h08)
    year = get_RTC_register(&h09)
    'century=get_RTC_register(&h32)
    do
        last_second=second
        last_minute=minute
        last_hour=hour
        last_day=day
        last_month=month
        last_year=year
        'last_century=century
        while get_RTC_update_in_progress_flag()<>0 :wend
        second = get_RTC_register(&h00)
        minute = get_RTC_register(&h02)
        hour = get_RTC_register(&h04)
        day = get_RTC_register(&h07)
        month = get_RTC_register(&h08)
        year = get_RTC_register(&h09)
        'century=get_RTC_register(&h32)
    loop while last_second<>second or last_minute<>minute or last_hour<>hour or last_day<>day or last_month<>month or last_year<>year 'or last_century<>century
    registerB=get_RTC_register(&h0B)
    
    if ((registerB and &h04)=0) then
        second = (second and &h0F) + ((second shr 4) * 10)
        minute = (minute and &h0F) + ((minute shr 4) * 10)
        hour = ( (hour and &h0F) + (((hour and &h70) shr 4 ) * 10) ) or (hour and &h80)
        day = (day and &h0F) + ((day shr 4) * 10)
        month = (month and &h0F) + ((month shr 4) * 10)
        year = (year and &h0F) + ((year shr 4) * 10)
        'century = (century and &h0F) + ((century  shr 4) * 10)
    end if
    
    if ((registerB and &h02)=0) and ((hour and &h80)>0) then
            hour = ((hour and &h7F) + 12) mod 24
    end if
    
    year+=2000
end sub

function pic_is_spurious (irq as unsigned byte) as unsigned integer
    dim b as unsigned integer
	if (irq = 7) then
        inb(MASTER_COMMAND,[b])
        b = b and &b10000000
		'' check ISR of the first pic
		if (b = 0) then return 1
	elseif (irq = 15) then
		'' check ISR of the second pic
        inb(SLAVE_COMMAND,[b])
        b = b and &b10000000
		'' check ISR of the first pic
		if (b = 0) then return 1
	end if
	
	return 0
end function