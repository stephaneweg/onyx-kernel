declare sub pic_init ()
declare sub set_timer_freq(hz as unsigned integer)


declare sub unmask_irq()
declare sub mask_irq()
declare function pic_is_spurious (irq as unsigned byte) as unsigned integer

declare sub read_rtc()
declare function get_RTC_update_in_progress_flag() as unsigned byte
declare function get_RTC_register(reg as unsigned byte) as unsigned byte
declare function GetDateBCD() as unsigned integer
declare function GetTimeBCD() as unsigned integer

const MASTER_COMMAND as unsigned byte = &h20
const MASTER_DATA    as unsigned byte = &h21
const SLAVE_COMMAND  as unsigned byte = &hA0
const SLAVE_DATA     as unsigned byte = &hA1
const COMMAND_EOI as unsigned byte = &h20

const I8254_MAX_FREQ as unsigned integer = 1193180
const I8254_TIMER0 as unsigned byte = &h40
const I8254_TIMER1 as unsigned byte = &h41
const I8254_TIMER2 as unsigned byte = &h42
const I8254_CONTROL as unsigned byte = &h43

CONST cmos_address as unsigned short  = &h70
const cmos_data    as unsigned short = &h71
const century_register as unsigned byte =&h32

dim shared second as unsigned byte
dim shared minute as unsigned byte
dim shared hour as unsigned byte
dim shared day as unsigned byte
dim shared month as unsigned byte
dim shared year as unsigned short