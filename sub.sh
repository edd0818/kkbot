#!/usr/bin/env expect

puts "Hello world."

set b 1
puts "\[sub]b: $b"
proc hello {} {
	global a
	puts "\[sub]a: $a"

	set a [incr a 1	]
}