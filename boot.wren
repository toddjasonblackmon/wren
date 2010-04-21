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

fun dump_iter a l c =		# Print out an address as a short
	(if c < l then (
		dump_putx (peek a) 8;
		(if c % 8 = 7 then cr else putc *' ');
		dump_iter (a+4) l (c+1))
	else cr)

fun dump a l = cr; dump_iter a ((l+3)/4) 0


puts 'Library Loaded';cr

