#!/data/data/com.termux/files/usr/bin/bash
sed -i -- 's/usr\/bin/data\/data\/com.termux\/files\/usr\/bin/g' $1
~/run_bot.sh ~/$1

