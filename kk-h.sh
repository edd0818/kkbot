#!/usr/bin/expect -f
package require Tcl 8.5

set include_file [lindex $argv 0]

catch {source $include_file} result options
if {[dict get $options -code] != 0} {
    puts stderr "could not source $include_file: $result"
    exit 1
}

#=====================================================================
# Mage
#=====================================================================

proc pickup {} {
    sleep 1
    send "get all from corpse\r"
    sleep 0.3
    send "get all from corpse 2\r"
    sleep 0.3
    send "get all from corpse 3\r"
    sleep 0.3

}

#=====================================================================
# Config
#=====================================================================
set timeout 8
# user
set user "whouse"
# pwd
set password "a77818"
# class 0=warrior , 1=cleric , 2=mage
set clazz 0
# 低於血量休息
set min_hp_limit 50
# 高於血量停止休息
set max_hp_limit 80
# 戰鬥中低於血量，補血
set heal_hp_limit 65

#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "$user\r"

expect "請輸入密碼"
send "$password\r"



while {1} {
    # sleep 2
    # set w [lindex [getHP_MP] 0]
    # puts $w
    set freeze 0

    recall
    # Cast all first
    go "s" 3
    castg "casi" "cast4"
    go "n" 3
    # Home
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
    #saveAllMoney
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
    # Cast all first
    go "s" 3
    castg "casi" "cast4"
    go "n" 3
    #Home
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
    go "n" 1
    #kill "fighter" 1
    pickup
    go "n" 1
    go "s" 5
    #主殿
    go "s" 1
    #kill "osouf" 1
    pickup
    go "s" 1
    #kill "fighter" 1
    pickup
    go "n" 2
    go "e" 2
    go "n" 1
    sellAll
    #kill "woman" 1
    #kill "clerk" 1
    pickup
    sellAll
    go "s" 1
    # kill "traveller" 1
    pickup
    go "s" 1
    #kill "adventurer" 1
    #kill "female" 1
    #kill "Cleric" 1
    pickup
    go "n" 1
    go "e" 3
    #精靈塔
    go "e" 1
    sleep 2
    go "e" 3
    go "n" 1
    #kill "lady" 3
    pickup
    go "e" 1
    #kill "sailor" 2
    pickup
    go "e" 1
    # kill "sailor" 2
    pickup
    go "s" 1
    # kill "sailor" 2
    # kill "child" 1
    pickup
    go "s" 1
    # kill "sailor" 2
    # kill "child" 2
    pickup
    go "e" 2
    # kill "man" 1
    pickup


    sleep 1
    send "save\r"
}

exit
  
