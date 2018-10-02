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

proc sellAll {} {
    expect ">" {
        sleep 1
        send "sell all\r"
        puts "Inventory has been sold."
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
#=====================================================================
# Mage
#=====================================================================

proc pickup {} {
    sleep 1
    send "get all from corpse\r"
}

#=====================================================================
# Config
#=====================================================================
set timeout 3
# 低於血量休息
set min_hp_limit 50
# 高於血量停止休息
set max_hp_limit 80
# 戰鬥中低於血量，補血
set heal_hp_limit 65
# 增益法術
array set buffs [list "亞伯拉之盾" "magic_shield"]


#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "stealer\r"

expect "請輸入密碼"
send "a77818\r"



while {1} {
    # sleep 2
    # set w [lindex [getHP_MP] 0]
    # puts $w

    recall
    
    go "n" 1
    go "e" 3
    #kill "monk" 1
    pickup
    go "n" 1
    #kill "barkeeper" 1
    #kill "adventurer" 2
    pickup
    go "s" 1
    go "e" 1
    # kill "Priest" 2
    # kill "adventurer" 1
    pickup
    go "w" 1
    go "s" 3
    go "e" 1
    saveAllMoney
    go "w" 1
    go "s" 1
    go "e" 1
    sellAll
    go "w" 1
    go "s" 2
    pickup
    #城門
    go "e" 1
    go "s" 2
    #kill "adventurer" 2
    pickup
    go "e" 1
    go "n" 1
    #kill "hunter" 1
    pickup
    go "n" 1
    go "w" 2
    # 城門
    #kill "guard" 2
    pickup
    go "n" 2
    go "e" 1
    sellAll
    go "w" 1
    go "n" 2
    go "w" 1
    #kill "guard" 2
    pickup

    #======================
    recall

    go "n" 1
    go "e" 4
    #kill "priest" 2
    go "e" 1
    transport mercy
    go "e" 2
    #精靈塔
    sleep 2
    
    go "e" 1
    #kill "traveller" 1
    #kill "man" 1
    pickup
    go "e" 1
    #kill "man" 1
    #kill "girl" 1
    pickup
    go "e" 1
    go "n" 1
    #kill "visitor" 1
    #kill "man" 1
    pickup
    go "s" 2
    #kill "pagan" 2
    pickup
    go "n" 1
    go "e" 2
    go "n" 1
    #kill "girl" 1
    #kill "traveller" 1
    pickup
    go "n" 1
    #kill "woman" 1
    #kill "girl" 1
    #kill "boy" 1
    pickup
    go "n" 1
    #kill "boy" 1
    pickup
    go "n" 2
    go "s" 5
    #主殿
    # go "s" 2
    # go "e" 1
    # kill "waitress" 1
    # go "w" 1
    # go "n" 2
    go "e" 2
    go "n" 1
    sellAll
    #kill "woman" 1
    #kill "clerk" 1
    pickup
    sellAll
    go "s" 2
    #kill "adventurer" 1
    #kill "female" 1
    #kill "Cleric" 1
    pickup
    go "n" 1
    go "e" 3
    #精靈塔
    go "e" 1
    sleep 2
    go "e" 2
    #kill "child" 2
    pickup
    go "e" 1
    #kill "child" 2
    pickup
    go "e" 1
    #kill "child" 2
    pickup
    go "e" 1
    #kill "child" 2
    pickup
    go "n" 1
    #kill "child" 2
    pickup

    sleep 1
    send "save\r"
}

exit
  
