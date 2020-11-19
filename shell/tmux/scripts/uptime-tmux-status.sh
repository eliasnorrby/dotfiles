#!/bin/bash

# This is a widget for my tmux statusline. It renders colored load averages.

if [[ "$#" -ne 5 ]]; then
  echo "use: low med high black white (colors)"
  exit
fi

LOW=$1
MED=$2
HIGH=$3
BLACK=$4
WHITE=$5

LIMIT_MED=4
LIMIT_HIGH=6

major_loads=$(uptime | rev | cut -d":" -f1 | rev | sed s/,\ /./g | cut -d"." -f1,3,5)
load_1_int=$(echo $major_loads | cut -d"." -f1)
load_5_int=$(echo $major_loads | cut -d"." -f2)
load_15_int=$(echo $major_loads | cut -d"." -f3)

if [ "$load_1_int" -ge "$LIMIT_HIGH" ]; then
  COL1_BG=$HIGH
  COL1_FG=$BLACK
elif [ "$load_1_int" -ge "$LIMIT_MED" ]; then
  COL1_BG=$MED
  COL1_FG=$BLACK
else
  COL1_BG=$LOW
  COL1_FG=$WHITE
fi

if [ "$load_5_int" -ge "$LIMIT_HIGH" ]; then
  COL5_BG=$HIGH
  COL5_FG=$BLACK
elif [ "$load_5_int" -ge "$LIMIT_MED" ]; then
  COL5_BG=$MED
  COL5_FG=$BLACK
else
  COL5_BG=$LOW
  COL5_FG=$WHITE
fi

if [ "$load_15_int" -ge "$LIMIT_HIGH" ]; then
  COL15_BG=$HIGH
  COL15_FG=$BLACK
elif [ "$load_15_int" -ge "$LIMIT_MED" ]; then
  COL15_BG=$MED
  COL15_FG=$BLACK
else
  COL15_BG=$LOW
  COL15_FG=$WHITE
fi

load_1=`uptime | rev | cut -d":" -f1 | rev | cut -d"," -f1`
load_5=`uptime | rev | cut -d":" -f1 | rev | cut -d"," -f2`
load_15=`uptime | rev | cut -d":" -f1 | rev | cut -d"," -f3`

string1="#[fg=$COL1_FG,bg=$COL1_BG]$load_1 #[fg=$WHITE,bg=$BLACK]"
string5="#[fg=$COL5_FG,bg=$COL5_BG]$load_5 #[fg=$WHITE,bg=$BLACK]"
string15="#[fg=$COL15_FG,bg=$COL15_BG]$load_15 #[fg=$WHITE,bg=$BLACK]"

echo "#[fg=$WHITE,bg=default] $string1$string5$string15"
