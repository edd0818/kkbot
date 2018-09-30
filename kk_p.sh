#!/usr/bin/expect -f

set timeout 3    

proc go { direct steps} {
    while {$steps > 0 } {
        expect {
            ">"
            {
                puts "going to $direct"
                send "$direct\r"
            }
        }
        set steps [expr $steps-1];
        sleep 1
    }
}

proc lookfor { target } {
    expect {
    ">"
    {
        puts "looking for $target."
        send "l\r"
        expect {
                "Rabbitslayer" {
                    puts "$target not found."
                    return 0
                }
                "$target" 
                {
                    puts "$target found."
                    return 1
                }
                default
                {
                    puts "$target not found."
                    return 0
                }
            }
            
        }
    }
}
proc isDead { target } {
    puts "is $target dead?"
    send "l corpse\r"
    expect {
        "*$target)的屍體" {
            puts "$target is dead."
            return 1
        }
        default {
             puts "$target is not dead."
            return 0
        }
    }
        
}
proc kill { target count } {
    while {$count > 0 } {
        set hasTarget [lookfor "$target"]
        if { $hasTarget } {
            puts "killing $target."
            expect {
                ">" {
                    send "k $target\r"

                    set isTargetDead [isDead "$target"]
                    while { !$isTargetDead } {
                        set isTargetDead [isDead "$target"]
                        if { $isTargetDead } {
                            sleep 1
                            puts "get all from corpse."
                            send "gc\r"
                            expect ">"
                            send "pa\r"
                        }
                        
                    }
                }
            }
        } else { return }
        set count [expr $count-1];
    }
    
}

proc getHP {} {
    send "hp\r"
    expect {
        -re "體力 :\[ ]*(\\d+)\/\[ ]*(\\d+)" {
            set hp_c $expect_out(1,string)
            set hp_m $expect_out(2,string)
            set p [expr ($hp_c/$hp_m)*100]
            puts "HP: $p%"
            return $p
        }   
    }
    
}
proc getMP {} {
    send "hp\r"
    expect {
        -re "法力 :\[ ]*(\\d+)\/\[ ]*(\\d+)" {
            set mp_c $expect_out(1,string)
            set mp_m $expect_out(2,string)
            set p [expr ($mp_c/$mp_m)*100]
            puts "MP: $p%"
            return $p
        }
        
    }
}
proc tee {} {
    puts "Hellp $qq"
}

proc getBodyStatus {} {
    set a " 強壯, 毒擊, 祝福, 硬皮術"
    
    set a [regsub -all {\s+} $a ""]
    set b [split $a ,]
    return $b
}

proc compare {} {
    array set ta [list "強壯" "cst" "硬皮術" "csk" "祝福" "cbl" ]
    set status [getBodyStatus]
    foreach {k v} [array get ta *] {
        #puts $k
      set buffed [lsearch $status $k]
      if {$buffed >= 0} {
        puts "\[$k] buffed."
      }
    }
}

proc ret {} {

}


spawn telnet -8 kk.muds.idv.tw 4000


expect "new"
send "pretender\r"

expect "請輸入密碼"
send "a77818\r"
expect ">"
sleep 1

set a [ret]
if([info exists var]

exit
  
