#!/usr/bin/expect -f

proc go { direct steps} {
    while {$steps > 0 } {
        expect {
            "你的動作還沒有完成, 不能移動" {
                sleep 2
                exp_continue
            }
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
    puts "is \[$target] dead?"
    sleep 1
    send "l corpse\r"
    expect {
        -re "($target).*\\)的屍體" {
            puts "\[$target] is dead."
            return 1
        }
        "你要看什麼" {
            puts "\[$target] is alive."
            return 0
        }
        default {
            puts "\[$target] is alive."
            return 0
        }
    }       
}

proc prepareToFight {} {
    set hp [getHP]
    set mp [getMP]
    sleep 1
    buffAll

    if {$hp < 90 && $mp > 85} {
        puts "Get heal to start fighting."
        sleep 1
        cast "cc"
    }
}

proc kill { target count } {
    global min_hp_limit
    global max_hp_limit
    global heal_hp_limit

    while {$count > 0 } {
        set hasTarget [lookfor "$target"]
        if { $hasTarget } {
            set canFight [isHealthy $min_hp_limit]
            if {$canFight} {
                prepareToFight
                sleep 1
                send "kill $target\r"
                expect {
                    "這裡沒有這個人" {
                        puts "No body named \[$target]"
                        return
                    }
                    "你喝道 :「可惡的" {
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
        puts "HP is lower than \[$min_hp_limit%]."
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
        puts "Resting, HP: \[$hp%]."
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
    puts "Casting \[$magic]"
    send "$magic\r"
    
    expect {
        "法力不足" {
            puts "Failed to cast \[$magic], Out of mana."
            sleep 0.5
            return 1
        }
        -re "(沒有聽見你的祈願)|(不理你)|(什麼事也沒發生)|(動作沒有完成)" {
            sleep $interval
            return 2
        }
        default {
            return 0
        }
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
    puts "Checking buffs."

    array set buffs [list "強壯" "cst" "硬皮術" "csk" "祝福" "cbl" ]
    set status [getBodyStatus]
    foreach {k v} [array get buffs *] {
        
      set buffed [lsearch $status $k]
      if {$buffed >= 0} {
        puts "\[$k] buffed."
      } else {
        puts "Praying \[$k] buff"
        keepCast $v
        puts "\[$k] buffed."
      }
    }
}

proc getBodyStatus {} {   
    set dummy {}
    expect {
        ">" { 
            send "sc\r"
            expect -re "身體狀況 :(.*)" {
                set str [regsub -all {\s+} $expect_out(1,string) ""]
                set c_arr [split $str ,]
                return $c_arr
            }
        }
    }
    return $dummy
}

proc sellAll {} {
    expect ">" {
        sleep 1
        send "sell all\r"
        puts "Inventory has been sold."
    }
}
#=====================================================================
# Config
#=====================================================================
set timeout 3    
# 低於血量休息
set min_hp_limit 50
# 高於血量停止休息
set max_hp_limit 85
# 戰鬥中低於血量，補血
set heal_hp_limit 65



#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "xanver\r"

expect "請輸入密碼"
send "a77818\r"



while {1} {
    expect ">"
    send "recall\r"

    sleep 5

    go "n" 1
    go "e" 3
    kill "monk" 1
    go "n" 1
    kill "Barkeeper" 1
    kill "Adventurer" 2
    go "s" 1
    go "e" 1
    kill "Priest" 2
    kill "adventurer" 1
    go "w" 1
    go "s" 4
    go "e" 1
    sellAll
    go "w" 1
    go "s" 2
    go "e" 1
    go "n" 1   
    kill "Fox" 2
    go "n" 1
    go "e" 1
    kill "Deer" 4
    go "e" 2
    go "n" 2
    kill "Buffalo" 3
    go "e" 3
    go "n" 1
    kill "horse" 4
    go "s" 1
    go "w" 3
    go "s" 2
    go "w" 3
    go "s" 2
    go "e" 1
    kill "Rabbit" 3
    go "s" 1
    kill "Hunter" 1
    go "s" 1
    go "e" 2
    go "s" 2
    go "e" 2
    kill "Monkey" 3
    go "w" 2
    go "n" 2
    go "w" 2
    go "n" 2
    go "w" 1
    go "s" 2
    kill "Adventurer" 2
    go "w" 6
    kill "willow" 1
    go "e" 6
    go "n" 2
    go "w" 1
    # 城門
    go "n" 2
    go "e" 1
    sellAll
    go "w" 1
    go "n" 2
    go "w" 1
    kill "Guard" 2
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
  
