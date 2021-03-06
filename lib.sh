#!/usr/bin/env expect

#=====================================================================
# Global Variable
#=====================================================================
# freeze 走錯路
set freeze 0
# 血量
set hp 0
# 魔力
set mp 0

#=====================================================================
# Common
#=====================================================================

package require Tcl 8.5

puts "Lib is included."

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
    global freeze
    if {$freeze} {return}

    while {$steps > 0 } {
        puts "going to \[$direct]"
        send "$direct\r"
        expect {
            -re "(你的動作還沒有完成, 不能移動)|(你的指令下太快了)|(你試圖逃走)" {
                sleep 1
            }
            -re "(你.*逃跑了)" {
                recall
                break
            }
             -re "(這裡明顯的出口是)|(這裡唯一的出口)" {
                puts "arrive \[$direct]"
                set steps [expr $steps-1];
                sleep 0.5
            }
            "這個方向沒有出路" {
            	set freeze 1
            	break
            }
            default {
                set steps [expr $steps-1];
                sleep 0.5
            }
        }      
    }
}

proc lookfor { target } {
    sleep 1
    puts "looking for \[$target]."
    send "l $target\r"
    expect {
        -re "(沒有受傷)|(但是沒有傷到要害)|(但是看起來並不要緊)|(流了許多鮮血)|(血流不止)|(有生命危險)|(奄奄一息了)" {
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

proc handleCorpse {} {
	global clazz
    global user

    if {$user != "klown"} {
        puts "Get all from corpse."
        sleep 1
        send "gc\r"
    }

    if {$clazz == 1} {
    	expect ">"
    	send "pa\r"
    }
}

proc rest {max_hp_limit } {
	global clazz
    global hp 
    refreshHPMP

    while {$hp < $max_hp_limit} {
        refreshHPMP 

        if {$clazz == 1} {
        	sleep 1
        	cast "heal"
        }      
 
        puts "Resting, HP: \[$hp%]."
        sleep 10
    }
}

proc refreshHPMP {} {
    global hp
    global mp
 #    puts "start- hp: $hp, mp: $hp"
	# set hp [incr hp 1	]
	# set mp [incr mp 1	]
 #    puts "end- hp: $hp, mp: $hp"

    send "hp\r"
    expect {
        -re "體力 :\[ ]*(\\d+)\/\[ ]*(\\d+).*法力 :\[ ]*(\\d+)\/\[ ]*(\\d+)" {
            set hp_c $expect_out(1,string)
            set hp_m $expect_out(2,string)
            set hp [expr (double($hp_c)/$hp_m)*100]
            puts "HP: $hp%"
            set mp_c $expect_out(3,string)
            set mp_m $expect_out(4,string)
            set mp [expr (double($mp_c)/$mp_m)*100]
            puts "MP: $mp%"          
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
        expect ">"
        send "sc\r"
    }
}

proc transport { kingdom } {
    expect ">" {
        send "pray mercy\r"
    }
    sleep 5
}

proc saveAllMoney {} {
    sleep 1
    send "sc\r"
    expect -re "身上帶著 (\\d+) 枚金幣" {
        set money $expect_out(1,string)
        if {$money > 0} {
            puts "Depositing $money in bank."
            send "deposit $money\r"
        }       
    } 
}

proc kill { target count } {
    global freeze
    if {$freeze} {return}

    global min_hp_limit
    global max_hp_limit

    global hp
    global mp

    while {$count > 0 } {
        set hasTarget [lookfor "$target"]
        if { $hasTarget } {
            refreshHPMP
            set canFight [expr $hp > $min_hp_limit]

            if {$canFight} {
                beforeFight $target            

                send "kill $target\r"
                expect {
                    "這裡沒有這個人" {
                        puts "No body named \[$target]"
                        return
                    }
                    -re "(你喝道 :「可惡的)|(對 !! 加油 !! 加油 !!)" {
                        set retry 0
                        expect {
                            -re "(你得到.*點經驗)" {
                                puts "\[$target] is dead."
                                handleCorpse
                                set count [expr $count-1]
                            }
                            -re "(\[你|妳]?.*\[傷害|格開|但是沒中|從旁邊擦過|用盾擋開])|(\[沒有受傷|但是沒有傷到要害|但是看起來並不要緊|流了許多鮮血|血流不止|有生命危險|奄奄一息了]。 \\))" {
                                puts "Fighting with \[$target]."

                                onFight $target
                                
                                exp_continue
                            }
                            default {
                                if {$retry > 0} {
                                    puts "\[$target] is dead.(timeout)"
                                    handleCorpse
                                    set count [expr $count-1]
                                } else {
                                    set retry [expr $retry+1]
                                    exp_continue
                                }  
                            }
                        }
                    }
                }
                afterFight $target
            } else {
                rest $max_hp_limit
            }         
        } else { return }       
    }    
}

proc buy {item {id 1} {num 1}} {
    sleep 1
    puts "Buy $item *$num."
    send "buy $num $item $id\r"
}

proc drink {item} {
    sleep 1
    puts "Drinking $item."
    send "drink $item\r"
}

proc castg {name option} {
    global user
    set retry 0

    sleep 1
    puts "Casting ALL"
    send "tell $name $option\r"
    expect {
        "現在不願聽你說話" {
            puts "You're banned. fxxk!"
        }
        "沒有這個人" {
            puts "No CASTG here."
        }
        "冥思中" {
            puts "CASTG is not ready."
        }
        -re "\\((\[a-z]*) 正在使用中" {
            set castee $expect_out(1,string)
            set here [lookfor $castee]
            if {$castee != $user && $here} {
                puts "CASTG is occupied by \[$castee]."
            } else {
                send "l $name\r"
                expect "沒有受傷" {
                    send "tell $name reset\r" 
                    expect "reset castg成功" {
                        puts "Reset CASTG."
                        sleep 0.5
                        castg $name $option
                    } 
                }
            }
        }
        -re "($user) CAST模式.*已完成, CASTG關閉" {
            puts "DONE."
        }
        -re "(喃喃唸道)|(高舉雙手)" {
            exp_continue
        }
        default {
            if {$retry < 5} {
                set retry [expr $retry+1]
                exp_continue
            } else {
                puts "Retry failed."
            }        
        }
    }
}
#=====================================================================
# Cleric & Mage
#=====================================================================

proc cast { magic {target ""} {interval 2} } {
    global user
    if {$target == ""} {
        set target $user
    }
    puts "Casting \[$magic] on \[$target]"
    send "cast $magic on $target\r"
    
    expect {
        -re "(法力不足)|(法力不夠)" {
            puts "Failed to cast \[$magic], Out of mana."
            sleep 0.5
            return 1
        }
        -re "(沒有聽見你的祈願)|(不理你)|(什麼事也沒發生)|(動作沒有完成)" {
            sleep $interval
            return 2
        }
        "已經" {
        	return 0
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

    global buffs
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

proc meditate {} {
    puts "Meditating..."
    sleep 1
    send "meditate\r"
    expect {
        "不能冥思" {
            puts "Not ready to meditate." 
        }
        -re "(開始冥思)|(你看見)|(你覺得)|(你聽到)|(驚醒)" {
            exp_continue
        }
        "你從冥思中醒來" {
            puts "done."
        }
    }
}





