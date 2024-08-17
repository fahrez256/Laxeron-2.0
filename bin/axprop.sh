$LAXFUN

axprop() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: axprop <filename> <key> [-s|--String] <value> | axprop <filename> -d <key> | axprop <filename> -g <key>"
        return 1
    fi

    log() {
        [ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"
    }
    
    if [ "$1" == "--log" ]; then
        case $2 in
            "true"|"false") showLog=$2; shift 2 ;;
            *) shift ;;
        esac
    fi

    local filename=$1
    local key=$2
    local value
    local sanitized_key

    sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')

    if [ ! -f "$filename" ]; then
        echo "File $filename not found!"
        return 1
    fi
    
    case $key in
        -d|--delete)
            key=$3
            sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')
            if grep -q "^$sanitized_key=" "$filename"; then
                sed -i "/^$sanitized_key=/d" "$filename"
                log "[Deleted key]" "$key"
            else
                log "[Key $key not found]"
            fi
            ;;
        -g|--get)
            key=$3
            sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')
            if grep -q "^$sanitized_key=" "$filename"; then
                grep "^$sanitized_key=" "$filename" | cut -d '=' -f2-
            else
                log "[Key $key not found]"
            fi
            ;;
        *)
            if [ "$3" = "-s" ] || [ "$3" = "--String" ]; then
                value="\"$4\""
            else
                value=$3
            fi
            if grep -q "^$sanitized_key=" "$filename"; then
                sed -i "s/^$sanitized_key=.*/$sanitized_key=$value/" "$filename"
            else
                echo "$sanitized_key=$value" >> "$filename"
            fi
            log "[Updated $(basename $filename) with $sanitized_key]" "$value"
            ;;
    esac
}
axprop "$@"
