#!/data/data/com.termux/files/usr/bin/bash
cp ~/storage/downloads/kkbot-master/kkbot-master/$1 ~/
cp ~/storage/downloads/kkbot-master/kkbot-master/lib.sh ~/
sed -i -- 's/usr\/bin/data\/data\/com.termux\/files\/usr\/bin/g' $1
~/run_bot.sh ~/$1

