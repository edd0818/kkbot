#!/usr/bin/expect -f

proc go { direct steps} {
    while {$steps > 0 } {
        expect {
            ">"
            {
                puts "going to \[$direct]"
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
        puts "looking for \[$target]."
        send "l\r"
        expect {
                "Rabbitslayer" {
                    puts "$target not found."
                    return 0
                }
                "$target" 
                {
                    puts "\[$target] found."
                    return 1
                }
                default
                {
                    puts "\[$target] not found."
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
            puts "\[$target] is dead."
            return 1
        }
        default {
             puts "\[$target] is alive."
            return 0
        }
    }
    sleep 1
        
}
proc kill { target count } {
    set min_hp_limit 50
    set max_hp_limit 80
    set heal_hp_limit 75

    while {$count > 0 } {
        set hasTarget [lookfor "$target"]
        if { $hasTarget } {

            set canFight [isHealthy $min_hp_limit]

            if {$canFight} {
                puts "killing \[$target]."
                expect {
                    ">" {
                        send "k $target\r"

                        set isTargetDead [isDead "$target"]
                        while { !$isTargetDead } {

                            set isTargetDead [isDead "$target"]

                            if { $isTargetDead } {
                                sleep 1
                                puts "Get all from corpse."
                                send "gc\r"
                                expect ">"
                                send "pa\r"
                                set count [expr $count-1]
                            } else {
                                # 戰鬥中補血
                                set needHeal [expr ![isHealthy $heal_hp_limit] ]

                                if {$needHeal} {
                                    cast "ch"
                                }
                            }
                            
                        }
                    }
                }
                
            } else {
                rest $max_hp_limit
            }
            
        } else { return }
        
    }
    
}

proc isHealthy { min_hp_limit } {
    set hp [getHP]
    if {$hp < $min_hp_limit} {
        puts "HP is lower than $min_hp_limit%."
        return 0   
    } else {
        puts "I'm healthy."
        return 1
    }
}

proc rest {max_hp_limit } {
    set hp [getHP]

    while {$hp < $max_hp_limit} {
        set hp [getHP]
        sleep 1
        cast "ch"
        puts "Resting, HP: $hp%."
        sleep 10
    }
}

proc getHP {} {
    send "hp\r"
    expect {
        -re "體力 :\[ ]*(\\d+)\/\[ ]*(\\d+)" {
            set hp_c $expect_out(1,string)
            set hp_m $expect_out(2,string)
            set p [expr (double($hp_c)/$hp_m)*100]
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
            set p [expr (double($mp_c)/$mp_m)*100]
            puts "MP: $p%"
            return $p
        }
        
    }
}

proc cast { magic {interval 2} } {
    set limit 15
    set mp [getMP]
    if {$mp > $limit} {
        puts "Casting \[$magic]"
        send "$magic\r"

        expect {
            "法力不足" {
                return 1
            }
            "沒有聽見你的祈願" {
                return 2
            }
            "不理你" {
                return 2
            }
            "動作沒有完成" {
                return 2
            }
            default {
                return 0
            }
        }
        sleep $interval
    }
}

proc keepCast { magic } {
    #puts "keepCast: $magic"
    set result [cast $magic]
    while {$result > 1} {
        set result [cast $magic]
    }
}

proc  buffAll {} {
    set buffs {"cst" "csk" "cbl"}

    expect {
        ">" { 
            foreach buff $buffs {
                puts "Casting buff \[$buff]"
                keepCast $buff
                puts "\[$buff] buffed"
            }
        }
    }
}

set timeout 3    

spawn telnet -8 kk.muds.idv.tw 4000


expect "new"
send "xanver\r"

expect "請輸入密碼"
send "a77818\r"



while {1} {
    expect ">"
    send "recall\r"

    sleep 5

    go "n" 1
    # No casting in Advanturer Home 
    buffAll
    go "e" 3
    kill "monk" 1
    go "n" 1
    kill "Adventurer" 2
    go "s" 1
    go "e" 1
    kill "adventurer" 1
    go "w" 1
    go "s" 4
    go "s" 2
    go "e" 1
    go "n" 1
    kill "Fox" 2
    go "n" 1
    go "e" 1
    kill "Deer" 4
    go "e" 2
    go "n" 2
    kill "Buffalo" 1
    go "s" 2
    go "w" 3
    go "s" 2
    go "e" 1
    kill "Rabbit" 3
    go "s" 2
    go "e" 2
    go "s" 2
    go "e" 2
    kill "Monkey" 3
    go "w" 2
    go "n" 2
    go "w" 2
    go "n" 2
    go "w" 2
    go "n" 4
    go "w" 1
    kill "Guard" 1
    go "w" 1
    go "n" 1
    kill "Frog" 3
    #go "s" 1
    #go "w" 2
    #go "n" 2
    #go "e" 1
    #go "s" 1
    sleep 1
    send "save\r"
}

exit
  
