$LAXFUN
pkglist() {
    pkgfile="packages.list"
    if [[ "$1" == "-F" || "$1" == "--full" ]]; then
        pkgfile="packages_full.list"
        shift
    fi

    pkgfilepath="${LAXFILEPATH}/${pkgfile}"

    if [[ ! -f "$pkgfilepath" ]]; then
        echo "Error: File $pkgfilepath not found."
        return 1
    fi

    case "$1" in
        -L|--getLabel)
            if [[ -z "$2" ]]; then
                echo "Usage: pkglist $1 <package>"
                return 1
            fi
            grep "$2" "$pkgfilepath" | cut -d '|' -f 1
            ;;
        -P|--getPackage)
            if [[ -z "$2" ]]; then
                echo "Usage: pkglist $1 <appname>"
                return 1
            fi
            grep -i "$2" "$pkgfilepath" | cut -d '|' -f 2
            ;;
        *)
            cut -d '|' -f 2 "$pkgfilepath"
            ;;
    esac
}

pkglist "$@"
