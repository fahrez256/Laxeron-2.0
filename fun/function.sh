# Global
whitelist_file="${LAXMODULEPATH}/.config/whitelist.list"
cachePath="${LAXMODULEPATH}/.cache"
urlBin="${LAXMAINPATH}/bin"

# Color
ORANGE='\033[38;2;255;85;3m'
GREY='\033[38;2;105;105;105m'
NC='\033[0m'

# Format waktu
timeformat() { 
    echo "$(date -d "@$1" +"%Y-%m-%d %H.%M.%S")" 
}

# Import fungsi dari file
import() {
    filename="$1"
    file=$(find "$(dirname "$0")" -type f -name "$filename")
    
    if [ -z "$file" ]; then
        dir="$(dirname "$0")"
        while [ "$dir" != "$LAXCASHPATH" ]; do
            file=$(find "$dir" -maxdepth 1 -name "$filename")
            if [ -n "$file" ]; then
                break
            fi
            dir="$(dirname "$dir")"
        done
    fi

    if [ -n "$file" ]; then
        dos2unix "$file" 2>/dev/null
        source "$file"
        eval "path_$(echo "$filename" | tr -cd '[:alnum:]_-')=\"$file\""
    else
        echo "File $filename not found"
    fi
}

# Encode teks ke format r17
rozaq() {
    if [ -z "$1" ]; then
        echo "Error: No text provided."
        return 1
    fi
    echo "r17$(echo -n "$1" | base64 | tr A-Za-z R-ZA-Qr-za-q)"
}

# Jalankan perintah dengan opsi tertentu
storm() {
    local exec=false
    local save=false
    local file_name="response"
    local runPath="$LAXFILEPATH"

    if [ $# -eq 0 ]; then
        echo "Usage: storm <URL> [options]"
        return 0
    fi

    case $1 in
        --runPath|-rP)
            if [ -d "$2" ]; then
                runPath="$2"
                shift 2
            else
                shift 1
            fi
            ;;
    esac

    local responsePath="${LAXFILEPATH}/response"
    local errorPath="${LAXFILEPATH}/error"

    case $1 in
        --exec|-x)
            exec=true
            api=$([[ "${2:0:3}" = "r17" ]] && echo "${2:3}" | tr R-ZA-Qr-za-q A-Za-z | base64 -d || echo "$2")
            shift 2
            ;;
        --save|-s)
            save=true
            api=$([[ "${2:0:3}" = "r17" ]] && echo "${2:3}" | tr R-ZA-Qr-za-q A-Za-z | base64 -d || echo "$2")
            shift 2
            ;;
        *)
            api=$1
            shift
            ;;
    esac

    case $1 in
        --fname|-fn)
            file_name="$2"
            rm -f "${runPath}/$file_name"
            shift 2
            ;;
    esac

    if [ -z "$api" ]; then
        echo "Error: No API URL provided."
        return 1
    fi
    
    rm -f "$responsePath"
    rm -f "$errorPath"
    
    am startservice -n "${LAXPKG}/.Storm" --es api "$api" > /dev/null 2>&1

    while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
    done

    if [ -e "$responsePath" ]; then
        if [ "$exec" = true ]; then
            cp "$responsePath" "${runPath}/$file_name"
            chmod +x "${runPath}/$file_name"
            "${runPath}/$file_name" "$@"
        elif [ "$save" = true ]; then
            cp "$responsePath" "${runPath}/$file_name"
            chmod +x "${runPath}/$file_name"
        else
            cat "$responsePath" && echo
        fi
    elif [ -e "$errorPath" ]; then
        cat "$errorPath" && echo
    fi
}
