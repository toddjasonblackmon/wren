# These are useful
fun cr = putc 10; 0     # Print a newline (and arbitrarily return 0).

fun puts s =            # Print a string.
    if *s then (putc *s; puts (s+1)) else 0

fun putud u =           # Print an unsigned decimal.
    if ult 9 u then putud (udiv u 10) else 0;
    putc (*'0' + umod u 10)

fun abs n =             # Absolute value.
    if n < 0 then -n else n

fun putd n =            # Print a signed decimal.
    if n < 0 then putc *'-' else 0;
    putud (abs n)

fun putx u =            # Print an unsigned hex number.
  if ult 15 u then putx (srl u 4) else 0;
  putc *('0123456789abcdef' + (u & 0xf))


fun dump_putx u w =     # Print unsigned hex number with width w
  if 1 < w then dump_putx (srl u 4) (w-1) else 0;
  putc *('0123456789abcdef' + (u & 0xf))

# Dump format
# 00000000: 0000 0000 0000 0000 0000 0000 0000 0000  AAAAAAAAAAAAAAAA

fun put_hdr addr = 
	dump_putx addr 8;
	putc 58; putc 32

fun put_hex_line addr len =
	if 0 < len then (
		dump_putx (0xff & peek addr) 2;
		if 1 = len then (putc 32; putc 32; putc 32)
		else (
			dump_putx (0xff & peek (addr+1)) 2;
			putc 32;
			put_hex_line (addr+2) (len-2))
	) else 0
		
fun put_spaces num = 
	if 0 < num then (
		putc 32; 
		put_spaces (num-1)
	) else 0

fun put_printable char =
	if (31 < char & char < 127) then putc char else putc *'.'


fun put_ascii addr len = 
	if 0 < len then (
		put_printable (0xff & peek addr);
		put_ascii (addr+1) (len-1)
	) else 0


fun dump addr len = 
	cr;
	put_hdr addr;
	if (len < 16) then (
		put_hex_line addr len;
		# We want to add 5 spaces for every full pair missing
		put_spaces ((16-len)/2*5);
		put_ascii addr len
	) else (
		put_hex_line addr 16;
		put_ascii addr 16;
		if (16 = len) then cr else dump (addr+16) (len-16))
# Lookup

fun putcs n addr = 
	putc *addr;
	if 1<n then putcs (n-1) (addr+1) else 0

fun hdr_str_len addr = srl (peek (addr+2)) 4 & 0x0f
fun hdr_str addr = addr+3

fun put_name hdr_addr =
	putcs (hdr_str_len hdr_addr) (hdr_addr+3)	


fun next_hdr addr = 
	addr + hdr_str_len addr + 3

fun words_help addr =
	if addr < d0 then (
		putcs (hdr_str_len addr) (addr+3);
		putc 32;
		words_help (next_hdr addr))
	else cr

fun words = words_help dp
fun perc_remaining = 100*(dp-cp)/(d0-c0)
	
# 1 if equal, 0 if not
fun streq s1 s2 = 
	if *s1 = *s2 then
		if *s1 = 0 then 1
		else streq (s1+1) (s2+1)
	else 0
		
# n is length of s1
# s2 is null terminated
fun streq_n n s1 s2 =
	if n = 0 then 0 = *s2
	else if *s1 = *s2 then
		streq_n (n-1) (s1+1) (s2+1)
	else 0

fun find_help str addr = 
	if addr < d0 then
		if (streq_n (hdr_str_len addr) (hdr_str addr) str) then
			addr
		else
			find_help str (next_hdr addr)
	else
		0

fun get_xt addr = 
	if (addr = 0) then 0
	else (srl (peek (addr)) 2 & 0x3fff) + c0

# Returns xt of found string, or 0 otherwise
fun find str = get_xt (find_help str dp)

# This isn't reliable. Probably need to hard wire this anyways
## Dangerous stuff here, don't play unless you understand!
#fun execute xt =
#	poke (find 'exec_helper') 0x09090909 ;
#	poke (find 'exec_helper'-1) (0x08 + sla (xt-c0) 16)
#
## Don't ever, ever call this!
#fun exec_helper = cr;cr
## End dangerous stuff

# Use execute on xt's of no argument functions.
# Example:
# fun test = puts 'Hello World';cr
# You can run test by executing it's xt.
# execute (find 'test')

let dis_pc = 0


fun dis_string = 
	dis_pc : (dis_pc + 1);
	if *(dis_pc-1) = 0 then 0
	else (putc *(dis_pc-1) ; dis_string)

fun dis_value bytes =
	if bytes = 0 then 0
	else (
		dis_pc : (dis_pc + 1);
		*(dis_pc - 1) + 256 * dis_value (bytes-1))

fun dis_fun_lookup addr hdr =
	if hdr < d0 then (
		if addr = (get_xt hdr) then
			put_name hdr
		else
			dis_fun_lookup addr (next_hdr hdr))
	else (	# didn't find it, so just print address 
		puts '0x '; putx addr)

fun dis_call =
	puts 'TO: '; dis_fun_lookup (c0 + (*(dis_pc+2)*256 + *(dis_pc+1))) dp;
	puts ' ARGS: '; putx *(dis_pc); dis_pc : dis_pc + 3

fun dis_op val =
	dis_pc : (dis_pc+1);
	if val = 0 then (puts 'HALT'; dis_pc : 0)	#flag to stop
	else if val = 0x01 then (puts 'PUSH  0x'; putx (dis_value 4))
	else if val = 0x26 then (puts 'PUSHW 0x'; putx (dis_value 2))
	else if val = 0x27 then (puts 'PUSHB 0x'; putx (dis_value 1))
	else if val = 0x25 then (puts 'LDS 0x'; putx (dis_value 4))
	else if val = 0x02 then  puts 'POP'
	else if val = 0x03 then (puts 'PUSH_STRING "' ; dis_string ; puts '"')
	else if val = 0x04 then (puts 'GLOBAL_FETCH ' ; putd (dis_value 2))
	else if val = 0x05 then (puts 'GLOBAL_STORE ' ; putd (dis_value 2))
	else if val = 0x06 then (puts 'LOCAL_FETCH '  ; putd (dis_value 1))
	else if val = 0x07 then (puts 'TCALL '        ; dis_call)
	else if val = 0x08 then (puts 'CALL '         ; dis_call)
	else if val = 0x09 then (puts 'RETURN'        ; dis_pc : 0)
	else if val = 0x0a then (puts 'BRANCH '       ; putd (dis_value 2))
	else if val = 0x0b then (puts 'JUMP '         ; putd (dis_value 2))
	else if val = 0x0c then  puts 'ADD'
	else if val = 0x0d then  puts 'SUB'
	else if val = 0x0e then  puts 'MUL'
	else if val = 0x0f then  puts 'DIV'
	else if val = 0x10 then  puts 'MOD'
	else if val = 0x11 then  puts 'UMUL'
	else if val = 0x12 then  puts 'UDIV'
	else if val = 0x13 then  puts 'UMOD'
	else if val = 0x14 then  puts 'NEGATE'
	else if val = 0x15 then  puts 'EQ'
	else if val = 0x16 then  puts 'LT'
	else if val = 0x17 then  puts 'ULT'
	else if val = 0x18 then  puts 'AND'
	else if val = 0x19 then  puts 'OR'
	else if val = 0x1a then  puts 'XOR'
	else if val = 0x1b then  puts 'SLA'
	else if val = 0x1c then  puts 'SRA'
	else if val = 0x1d then  puts 'SRL'
	else if val = 0x1e then  puts 'GETC'
	else if val = 0x1f then  puts 'PUTC' 
	else if val = 0x20 then  puts 'FETCH_BYTE' 
	else if val = 0x21 then  puts 'PEEK'
	else if val = 0x22 then  puts 'POKE'
	else if val = 0x23 then  puts 'LOCAL_FETCH_0'
	else if val = 0x24 then  puts 'LOCAL_FETCH_1'
	else (puts 'UNKNOWN: ' ; putx val; dis_pc : 0)

		

fun dis_help =
	if dis_pc = 0 then cr
	else ( dis_op *dis_pc; cr; dis_help)

fun dasm str =
	dis_pc : find str;
	cr; puts str ; puts ' '; putx dis_pc;
	cr ;dis_help

# Nice little header
cr;cr;puts 'Library Loaded';cr;
putd (dp-cp); puts ' bytes ('; 
putd (perc_remaining); puts '%) remaining.'; cr

