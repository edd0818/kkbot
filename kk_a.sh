#!/usr/bin/expect -f

proc recall {} {
    sleep 1
    expect ">" {
        puts "Recalling"
        send "recall\r"
        expect {
            "你正忙著呢" {
                recall
            }
        }
    }
    sleep 5
}

proc go { direct steps} {
    while {$steps > 0 } {
        expect {
            "你的動作還沒有完成, 不能移動" {
                sleep 2
                go $direct 1
            }
            "你走向如鏡面般的水藍色薄膜" {
                sleep 2
                exp_continue
            }
            "你小心翼翼地提腳向這片白色的薄膜走去" {
                sleep 2
                exp_continue
            }
            "你試圖逃走" {
                sleep 1
                go $direct 1
            }
            -re "你.*逃跑了" {
                recall
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
        send "l $target\r"
        expect {
                -re "正處於" {
                    puts "\[$target] found."
                    return 1
                }
                "你要看什麼" {
                    puts "\[$target] not found."
                    return 0
                }
                default {
                    puts "\[$target] found."
                    return 1
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

proc handleCorpse {} {
    puts "Get all from corpse."
    sleep 1
    send "gc\r"
    expect ">"
    send "pa\r"
}

proc prepareToFight {} {
    set hp [getHP]
    set mp [getMP]
    sleep 1
    buffAll

    if {$hp < 90 && $mp > 70} {
        puts "Get heal to start fighting."
        sleep 1
        cast "heal"
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
                        expect {
                            -re "死了|你得到.*點經驗" {
                                puts "\[$target] is dead."
                                handleCorpse
                                set count [expr $count-1]
                            }
                            -re "\[你|妳]?.*\[傷害|格開|但是沒中|從旁邊擦過|用盾擋開]" {
                                set hasTarget [lookfor "$target"]
                                puts "Fighting with \[$target]."
                                # 戰鬥中補血
                                set needHeal [expr ![isHealthy $heal_hp_limit] ]

                                if {$needHeal} {
                                    puts "Need healing in fighting."
                                    cast "heal"
                                }
                                exp_continue
                            }
                            default {
                                puts "\[$target] is dead."
                                handleCorpse
                                set count [expr $count-1]
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
        cast "heal"
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
    send "cast $magic\r"
    
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

    array set buffs [list "強壯" "strong" "硬皮術" "stone_skin" "祝福" "bless" "朦朧術" "hazy"]
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

proc transport { kingdom } {
    expect ">" {
        send "pray mercy\r"
    }
    sleep 5
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
set heal_hp_limit 70



#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "xanver\r"

expect "請輸入密碼"
send "a77818\r"

while {1} {
    recall

    go "n" 1
    go "e" 4
    #kill "priest" 2
    go "e" 1
    transport mercy
    go "e" 2
    #精靈塔
    sleep 2
    go "u" 1
    kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    go "u" 1
    kill "element" 2
    go "u" 1
    kill "water" 1
    go "d" 4
    go "e" 1
    kill "traveller" 1
    kill "man" 1
    go "e" 1
    kill "man" 1
    kill "girl" 1
    go "e" 1
    go "n" 1
    kill "visitor" 1
    kill "man" 1
    go "s" 2
    kill "pagan" 2
    go "n" 1
    go "e" 2
    go "n" 1
    kill "girl" 1
    kill "traveller" 1
    go "n" 1
    kill "woman" 1
    kill "girl" 1
    kill "boy" 1
    go "n" 1
    kill "boy" 1
    go "n" 2
    go "u" 1
    kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    go "u" 1
    kill "element" 2
    go "u" 1
    kill "fire" 1
    go "d" 4
    go "s" 5
    #主殿
    go "s" 2
    go "e" 1
    kill "waitress" 1
    go "w" 1
    go "n" 2
    go "e" 2
    go "n" 1
    sellAll
    kill "woman" 1
    kill "clerk" 1
    sellAll
    go "s" 2
    kill "adventurer" 1
    kill "female" 1
    #kill "Cleric" 1
    go "n" 1
    go "e" 3
    go "u" 1
     kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    go "u" 1
    kill "element" 2
    go "u" 1
    kill "wind" 1
    go "d" 4
    #精靈塔
    go "e" 1
    sleep 2
    go "e" 2
    kill "child" 2
    go "e" 1
    kill "child" 2
    go "e" 1
    kill "child" 2
    go "e" 1
    kill "child" 2
    go "n" 1
    kill "child" 2

    sleep 1
    send "save\r"
}


#========[史坎布雷]=========

# while {1} {
#     expect ">"
#     send "recall\r"

#     sleep 5

#     go "n" 1
#     go "e" 3
#     #kill "monk" 1
#     go "n" 1
#     kill "Barkeeper" 1
#     #kill "Adventurer" 2
#     go "s" 1
#     go "e" 1
#     kill "Priest" 2
#     kill "adventurer" 1
#     go "w" 1
#     go "s" 4
#     go "e" 1
#     sellAll
#     go "w" 1
#     go "s" 2
#     #城門
#     go "e" 1
#     go "n" 1   
#     #kill "Fox" 2
#     go "n" 1
#     go "e" 1
#     #kill "Deer" 4
#     go "e" 2
#     go "n" 2
#     kill "Buffalo" 3
#     go "e" 3
#     go "n" 1
#     kill "horse" 4
#     go "s" 1
#     go "w" 3
#     go "s" 2
#     go "w" 3
#     go "s" 2
#     go "e" 1
#     #kill "Rabbit" 3
#     go "s" 1
#     kill "Hunter" 1
#     go "s" 1
#     go "e" 2
#     go "s" 2
#     go "e" 2
#     #kill "Monkey" 3
#     go "w" 2
#     go "n" 2
#     go "w" 2
#     go "n" 2
#     go "w" 1
#     go "s" 2
#     kill "Adventurer" 2
#     go "e" 4
#     go "s" 7
#     go "e" 2
#     kill "horse" 4
#     go "w" 2
#     go "n" 7
#     go "w" 4
#     go "w" 6
#     kill "willow" 1
#     go "e" 6
#     go "n" 2
#     go "w" 1
#     # 城門
#     kill "guard" 2
#     go "n" 2
#     go "e" 1
#     sellAll
#     go "w" 1
#     go "n" 2
#     go "w" 1
#     #kill "Guard" 2
#     go "w" 1
#     go "n" 1
#     #kill "Frog" 3
#     #go "s" 1
#     #go "w" 2
#     #go "n" 2
#     #go "e" 1
#     #go "s" 1
#     sleep 1
#     send "save\r"
# }

exit
  
