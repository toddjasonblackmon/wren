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

fun putx_dig u =
  putc *('0123456789abcdef' + (u & 0xf))

fun putx u =            # Print an unsigned hex number.
  if ult 15 u then putx (srl u 4) else 0;
  putx_dig u

fun dump_putx u w =     # Print unsigned hex number with width w
  if 1 < w then dump_putx (srl u 4) (w-1) else 0;
  putx_dig u

# Note that everything that uses peek in this code is assuming little endian

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

fun hdr_str_len addr = ((peek (addr+2)) & 0x0f) + 1
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
	else (0xffff & peek addr) + c0

# Returns xt of found string, or 0 otherwise
fun find str = get_xt (find_help str dp)

fun not x = -(x+1)

# Assumes wValues are 4 bytes (not true on LP64); assumes little endian
#fun byte_mask n = not (sla 0xff (n*8))
#fun byte_or orig byte new = orig & (byte_mask byte) | (sla (new & 0xff) (byte*8))
#fun aligned addr = addr & (not 0x03)
#fun offset addr = addr & 0x03
#
#fun cpoke addr x = 
#	poke (aligned addr) (byte_or (peek (aligned addr)) (offset addr) x)

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


# Nice little header
cr;cr;puts 'Library Loaded';cr;
putd (dp-cp); puts ' bytes ('; 
putd (perc_remaining); puts '%) remaining.'; cr

