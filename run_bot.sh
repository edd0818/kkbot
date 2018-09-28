#!/data/data/com.termux/files/usr/bin/bash
cp ~/storage/downloads/kkbot-master/kkbot-master/kk_a.sh ~/
sed -i -- 's/usr\/bin/data\/data\/com.termux\/files\/usr\/bin/g' kk_a.sh
iconv -f utf-8 -tbig5 kk_a.sh > kk_a.exp
chmod +x kk_a.exp
LANG=zh_TW.BIG5 ~/kk_a.exp 

