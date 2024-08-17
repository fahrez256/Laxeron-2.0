$LAXFUN
toast() {
	case $# in
		1)
			title=""
			msg="$1"
			duration=1800
			;;
		2)
			case $2 in
				''|*[!0-9]*)
					title="$1"
					msg="$2"
					duration=0
					;;
				*)
					title=""
					msg="$1"
					duration="$2"
					;;
			esac
			;;
		3)
			title="$1"
			msg="$2"
			duration="$3"
			;;
		*)
			echo "Usage: toast <msg> | toast <title> <msg> | toast <msg> <duration> | toast <title> <msg> <duration>"
			return 1
			;;
	esac

	am broadcast -a lax2.TOAST --es title "$title" --es msg "$msg" --ei duration "$duration" > /dev/null 2>&1
}

toast "$@"
