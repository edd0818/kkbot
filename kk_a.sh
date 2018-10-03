#!/usr/bin/expect -f

package require Tcl 8.5

set include_file [lindex $argv 0]


catch {source $include_file} result options
if {[dict get $options -code] != 0} {
    puts stderr "could not source $include_file: $result"
    exit 1
}

proc beforeFight {} {
    buffAll

    global hp
    global mp
    global clazz
    
    sleep 1 

    if {$clazz == 1 && $hp < 90 && $mp > 80} {
        puts "Get heal to start fighting."
        sleep 1
        cast "heal"
    }
}

proc afterFight {} {
    global hp
    global mp
    global clazz

    refreshHPMP

    if {$clazz != 0 && $hp > 95 && $mp < 90} {
        meditate
    }
}

proc kill { target count } {
    global min_hp_limit
    global max_hp_limit
    global heal_hp_limit

    global hp
    global mp

    while {$count > 0 } {
        set hasTarget [lookfor "$target"]
        if { $hasTarget } {
            refreshHPMP
            set canFight [expr $hp > $min_hp_limit]

            if {$canFight} {
                beforeFight
                sleep 1

                if {$mp > 50} {
                    cast spirit_hammer $target
                }

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
                            -re "(\[你|妳]?.*\[傷害|格開|但是沒中|從旁邊擦過|用盾擋開])|(\[但是沒有傷到要害|但是看起來並不要緊|流了許多鮮血|有生命危險|奄奄一息了]。 \\))" {
                                puts "Fighting with \[$target]."
                                refreshHPMP
                                # 戰鬥中補血
                                set needHeal [expr $hp < $heal_hp_limit ]

                                if {$needHeal} {
                                    puts "Need healing in fighting."
                                    cast "heal"
                                }
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
                afterFight
            } else {
                rest $max_hp_limit
            }         
        } else { return }       
    }    
}

#=====================================================================
# Config
#=====================================================================
set timeout 3    
# user
set user "xanver"
# pwd
set password "a77818"
# class 0=warrior , 1=cleric , 2=mage
set clazz 1 
# 低於血量休息
set min_hp_limit 50
# 高於血量停止休息
set max_hp_limit 85
# 戰鬥中低於血量，補血
set heal_hp_limit 75
# freeze 走錯路
set freeze 0
# 增益法術
array set buffs [list "強壯" "strong" "硬皮術" "stone_skin" "祝福" "bless" "朦朧術" "hazy"]

#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "$user\r"

expect "請輸入密碼"
send "$password\r"

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
    #kill "spirit" 2
    go "u" 1
    #kill "fairy" 2
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
    #kill "visitor" 1
    #kill "man" 1
    go "s" 2
    kill "pagan" 2
    go "n" 1
    go "e" 2
    go "n" 1
    kill "girl" 1
    kill "traveller" 1
    go "n" 1
    kill "woman" 1
    #kill "girl" 1
    #kill "boy" 1
    go "n" 1
    #kill "boy" 1
    go "n" 2
    go "u" 1
    #kill "spirit" 2
    go "u" 1
    #kill "fairy" 2
    go "u" 1
    kill "element" 2
    go "u" 1
    kill "fire" 1
    go "d" 4
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
    #kill "spirit" 2
    go "u" 1
    #kill "fairy" 2
    go "u" 1
    kill "element" 2
    go "u" 1
    kill "wind" 1
    # go "d" 4
    # #精靈塔
    # go "e" 1
    # sleep 2
    # go "e" 2
    # kill "child" 2
    # go "e" 1
    # kill "child" 2
    # go "e" 1
    # kill "child" 2
    # go "e" 1
    # kill "child" 2
    # go "n" 1
    # kill "child" 2

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
  
