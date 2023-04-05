#! /usr/bin/bash

PATH_DIR="$1";

#OUTPUT FILES
ALL_LOGS="./all_logs.txt";
STR_LOGS="./str_logs.txt";
COMPLEX_LOGS="./complex_logs.txt";

#SEARCH REGEX
STR_REGEX="[ \t\r\n\v\f]*<<[ \t\r\n\v\f]*\"[^\"]*\"[ \t\r\n\v\f]*;";

#LOGS LEVEL
LOGS_LEVEL=("LOGNOTICE" "LOGWARN" "LOGERR" "LOGCRIT" "LOGALERT" "LOGFAT");

search_all_logs() {
    if [ -f "$ALL_LOGS" ] ; then
        rm "$ALL_LOGS"
    fi

    for i in ${!LOGS_LEVEL[@]}; do
        search=".*${LOGS_LEVEL[$i]}";
        echo -e "\n-----${LOGS_LEVEL[$i]}-----\n" >> $ALL_LOGS;
        grep -RE $search $PATH_DIR >> $ALL_LOGS;
    done
}

search_str_logs() {
    if [ -f "$STR_LOGS" ] ; then
        rm "$STR_LOGS"
    fi

    for i in ${!LOGS_LEVEL[@]}; do
        search=".*${LOGS_LEVEL[$i]}$STR_REGEX";
        echo -e "\n-----${LOGS_LEVEL[$i]}-----\n" >> $STR_LOGS;
        grep -RE "${search}" $PATH_DIR >> $STR_LOGS;
    done
}

search_complex_logs() {
    if [ -f "$COMPLEX_LOGS" ] ; then
        rm "$COMPLEX_LOGS"
    fi
    cp $ALL_LOGS $COMPLEX_LOGS;
    for i in ${!LOGS_LEVEL[@]}; do
        search=".*${LOGS_LEVEL[$i]}$STR_REGEX";
        sed -i "/$search/d" $COMPLEX_LOGS
    done
}

search_all_logs
search_str_logs
search_complex_logs
