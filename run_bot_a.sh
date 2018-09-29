#!/data/data/com.termux/files/usr/bin/bash
cp ~/storage/downloads/kkbot-master/kkbot-master/$1.sh ~/
sed -i -- 's/usr\/bin/data\/data\/com.termux\/files\/usr\/bin/g' $1
iconv -f utf-8 -t big5 $1.sh > $1.exp
chmod +x $1.exp
~/run_bot.sh ~/$1.sh 

