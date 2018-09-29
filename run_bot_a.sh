#!/data/data/com.termux/files/usr/bin/bash
cp ~/storage/downloads/kkbot-master/kkbot-master/$1 ~/
sed -i -- 's/usr\/bin/data\/data\/com.termux\/files\/usr\/bin/g' $1
~/run_bot.sh ~/$1.sh 

