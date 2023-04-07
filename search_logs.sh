#! /usr/bin/bash

PATH_DIR="$1";

#OUTPUT FILES
DEFAULT_LOGS="./default_logs.txt";
OTHER_LOGS="./other_logs.txt";
STR_LOGS="./str_logs.txt";
COMPLEX_DEFAULT_LOGS="./complex_default_logs.txt";
COMPLEX_OTHER_LOGS="./complex_other_logs.txt";

#CSV DELIMITATOR
CSV_DELIMITATOR='@';

#CSV FILES
STRING_LOGS_CSV="./strings_logs.csv";
DEFAULT_LOGS_CSV="./default_logs.csv";
OTHER_LOGS_CSV="./other_logs.csv";

#SEARCH REGEX
STR_REGEX="[ \t\r\n\v\f]*<<[ \t\r\n\v\f]*\"[^\"]*\"[ \t\r\n\v\f]*;";

#LOGS LEVEL
DEFAULT_LOGS_LEVEL=("LOGNOTICE" "LOGWARN" "LOGERR" "LOGCRIT" "LOGALERT" "LOGFAT");
OTHER_LOGS_LEVEL=("LOGDEB", "LOGDEB1", "LOGINFO", "LOGINFO1", "LOGINFO2", "LOGINFO3", "LOGINFO4");

search_default_logs() {
    if [ -f "$DEFAULT_LOGS" ] ; then
        rm "$DEFAULT_LOGS"
    fi

    for i in ${!DEFAULT_LOGS_LEVEL[@]}; do
        search=".*${DEFAULT_LOGS_LEVEL[$i]}";
        grep -RE $search $PATH_DIR >> $DEFAULT_LOGS;
    done   
}

search_other_logs() {
    if [ -f "$OTHER_LOGS" ] ; then
        rm "$OTHER_LOGS"
    fi

    for i in ${!OTHER_LOGS_LEVEL[@]}; do
        search=".*${OTHER_LOGS_LEVEL[$i]}";
        grep -RE $search $PATH_DIR >> $OTHER_LOGS;
    done   
}

search_str_logs() {
    if [ -f "$STR_LOGS" ] ; then
        rm "$STR_LOGS"
    fi

    for i in ${!DEFAULT_LOGS_LEVEL[@]}; do
        search=".*${DEFAULT_LOGS_LEVEL[$i]}$STR_REGEX";
        grep -RE "${search}" $PATH_DIR >> $STR_LOGS;
    done

    for i in ${!OTHER_LOGS_LEVEL[@]}; do
        search=".*${OTHER_LOGS_LEVEL[$i]}$STR_REGEX";
        grep -RE "${search}" $PATH_DIR >> $STR_LOGS;
    done
}

search_complex_default_logs() {
    if [ -f "$COMPLEX_DEFAULT_LOGS" ] ; then
        rm "$COMPLEX_DEFAULT_LOGS"
    fi
    cp $DEFAULT_LOGS $COMPLEX_DEFAULT_LOGS;
    for i in ${!DEFAULT_LOGS_LEVEL[@]}; do
        search=".*${DEFAULT_LOGS_LEVEL[$i]}$STR_REGEX";
        sed -i "/$search/d" $COMPLEX_DEFAULT_LOGS
    done
}

search_complex_other_logs() {
    if [ -f "$COMPLEX_OTHER_LOGS" ] ; then
        rm "$COMPLEX_OTHER_LOGS"
    fi
    cp $OTHER_LOGS $COMPLEX_OTHER_LOGS;
    for i in ${!OTHER_LOGS_LEVEL[@]}; do
        search=".*${OTHER_LOGS_LEVEL[$i]}$STR_REGEX";
        sed -i "/$search/d" $COMPLEX_OTHER_LOGS
    done
}

#SEARCH ALL LOGS TO TXT FILES
extract_logs() {
    search_default_logs
    search_other_logs
    search_str_logs
    search_complex_default_logs
    search_complex_other_logs
}

export_str_logs() {
    if [ -f "$STRING_LOGS_CSV" ] ; then
        rm "$STRING_LOGS_CSV"
    fi

    while IFS=':' read -r col1 col2
    do 
        col2=`echo $col2 | sed 's/ *$//g'`
        echo "$col1$CSV_DELIMITATOR$col2" >> $STRING_LOGS_CSV;

    done < $STR_LOGS
}

export_default_logs() {
    if [ -f "$DEFAULT_LOGS_CSV" ] ; then
        rm "$DEFAULT_LOGS_CSV"
    fi

    while IFS=':' read -r col1 col2
    do 
        col2=`echo $col2 | sed 's/ *$//g'`
        echo "$col1$CSV_DELIMITATOR$col2" >> $DEFAULT_LOGS_CSV;

    done < $COMPLEX_DEFAULT_LOGS
}

export_other_logs() {
    if [ -f "$OTHER_LOGS_CSV" ] ; then
        rm "$OTHER_LOGS_CSV"
    fi

    while IFS=':' read -r col1 col2
    do 
        col2="${col2:1}"
        col2=`echo $col2 | sed 's/ *$//g'`
        echo "$col1$CSV_DELIMITATOR$col2" >> $OTHER_LOGS_CSV;

    done < $COMPLEX_OTHER_LOGS
}

#EXPORT ALL LOGS TO CSV FILES
export_logs() {
    export_str_logs
    export_default_logs
    export_other_logs
}

#MAIN SCRIPT
run_script() {
    extract_logs
    export_logs

    #DELETE TXT FILES
    rm $DEFAULT_LOGS $OTHER_LOGS $STR_LOGS $COMPLEX_DEFAULT_LOGS $COMPLEX_OTHER_LOGS
}

run_script


