#!/usr/bin/env expect

package require Tcl 8.5

set include_file "sub.sh"

set a 1

catch {source $include_file} result options
if {[dict get $options -code] != 0} {
    puts stderr "could not source $include_file: $result"
    exit 1
}

proc hi {} {
	global b
	

	set b [incr b 1	]
	puts "b: $b"
}

hello
puts "a: $a"
hi
