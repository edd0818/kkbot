#!/usr/bin/expect -f
package require Tcl 8.5

set include_file [lindex $argv 0]

catch {source $include_file} result options
if {[dict get $options -code] != 0} {
    puts stderr "could not source $include_file: $result"
    exit 1
}

proc beforeFight {target} {
    buffAll
    buffWeapon
    summonWolf

    global hp
    global mp

    refreshHPMP

    if {$mp > 40} {
        cast "fireball" $target
    }
}

proc onFight {target} {
    global hp
    global mp

    refreshHPMP

    if {$hp < 50} {
        #drink "potion"
    } 

}

proc afterFight {target} {
    global hp
    global mp

    refreshHPMP

    if {$hp > 90 && $mp < 90} {
        meditate
    }
}
#=====================================================================
# Mage
#=====================================================================
proc buffWeapon {} {
    puts "Buff weapon."
    sleep 1
    keepCast "coating"  
}

proc summonWolf {} {
    set haswolf [lookfor "wolf"]
    if {!$haswolf} {
        puts "Wolf! come here!"
        keepCast "wolf"
    }    
}
#=====================================================================
# Config
#=====================================================================
set timeout 5
# user
set user "klown"
# pwd
set password "a77818"
# class 0=warrior , 1=cleric , 2=mage
set clazz 2
# 低於血量休息
set min_hp_limit 50
# 高於血量停止休息
set max_hp_limit 80
# 戰鬥中低於血量，補血
set heal_hp_limit 65
# 增益法術
array set buffs [list "亞伯拉之盾" "magic_shield" "巨魔之力" "ogre_power"]


#=====================================================================
#
#=====================================================================
spawn telnet kk.muds.idv.tw 4000


expect "new"
send "$user\r"

expect "請輸入密碼"
send "$password\r"



while {1} {
    set freeze 0
    recall
    # Cast all first
    go "s" 3
    castg "casi" "cast3"
    go "n" 3
    #Home
    go "n" 1
    go "e" 1
    go "n" 1
    #buy "potion" 2 5
    go "s" 1
    go "e" 2
    #kill "monk" 1
    go "n" 1
    #kill "barkeeper" 1
    #kill "adventurer" 2
    go "s" 1
    go "e" 1
    kill "priest" 2
    #kill "adventurer" 1
    go "w" 1
    go "s" 3
    go "e" 1
    #saveAllMoney
    go "w" 1
    go "s" 1
    #kill "dog" 1
    go "e" 1
    #sellAll
    go "w" 1
    go "s" 2
    #城門
    go "e" 2
    go "s" 1
    kill "hunter" 1
    go "s" 1
    go "w" 1
    kill "adventurer" 2
    go "n" 2
    go "w" 1
    # 城門
    kill "guard" 2
    go "n" 2
    go "e" 1
    #sellAll
    go "w" 1
    go "n" 2
    go "w" 1
    #kill "guard" 2
    #go "w" 1
    #go "n" 1
    #kill "frog" 3

    #============
    recall
    # Cast all first
    go "s" 3
    castg "casi" "cast3"
    go "n" 3
    #Home
    go "n" 1
    go "e" 5
   
    transport mercy

    go "e" 2
    #精靈塔
    sleep 2
    go "u" 1
    kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    #go "u" 1
    #kill "element" 2
    #go "u" 1
    #kill "water" 1
    go "d" 2
    go "e" 1
    #kill "traveller" 1
    #kill "man" 1
    go "e" 1
    #kill "man" 1
    #kill "girl" 1
    go "e" 1
    go "n" 1
    kill "visitor" 1
    kill "man" 1
    go "s" 2
    #kill "pagan" 2
    go "n" 1
    go "e" 2
    go "n" 1
    #kill "girl" 1
    #kill "traveller" 1
    go "n" 1
    #kill "woman" 1
    kill "girl" 1
    kill "boy" 1
    go "n" 1
    kill "boy" 1
    go "n" 1
    #kill "fighter" 1
    go "n" 1
    go "u" 1
    kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    #go "u" 1
    #kill "element" 2
    #go "u" 1
    #kill "fire" 1
    go "d" 2
    go "s" 5
    #主殿
    go "s" 1
    #kill "osouf" 1
    go "s" 1
    #kill "osouf" 1
    #kill "fighter" 1
    go "n" 2
    go "e" 2
    go "n" 1
    #sellAll
    #kill "woman" 1
    #kill "clerk" 1
    #sellAll
    go "s" 1
    #kill "traveller" 1
    go "s" 1
    #kill "adventurer" 1
    #kill "female" 1
    #kill "cleric" 1
    go "n" 1
    go "e" 3
    go "u" 1
    kill "spirit" 2
    go "u" 1
    kill "fairy" 2
    #go "u" 1
    #kill "element" 2
    #go "u" 1
    #kill "wind" 1
    # go "d" 2
    # #精靈塔
    # go "e" 1
    # sleep 2
    # go "e" 3
    # go "n" 1
    # kill "lady" 3
    # go "e" 1
    # kill "sailor" 2
    # go "e" 1
    # kill "sailor" 2
    # go "s" 1
    # kill "sailor" 2
    # kill "child" 1
    # go "s" 1
    # kill "sailor" 2
    # kill "child" 2
    # go "e" 2
    # kill "man" 1

    sleep 1
    send "save\r"
}

exit 0
  
