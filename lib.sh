#!/usr/bin/env expect

#=====================================================================
# Global Variable
#=====================================================================
# freeze 走錯路
set freeze 0
# 血量
set hp
# 魔力
set mp
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

proc handleCorpse {} {
	global clazz
    puts "Get all from corpse."
    sleep 1
    send "gc\r"

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

    send "hp\r"
    expect {
        -re "體力 :\[ ]*(\\d+)\/\[ ]*(\\d+)\r\n法力 :\[ ]*(\\d+)\/\[ ]*(\\d+)" {
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

proc buffWeapon {} {
    puts "Buff weapon."
    sleep 1
    keepCast "coating"  
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





