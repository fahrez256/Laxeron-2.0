$LAXFUN
ax() {
	local showLog=true

	log() { 
		[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
	}

	if [ "$1" = "--log" ]; then
		showLog=true
		shift
	fi
	
	local nameDir="$1"
	local cachePath="${LAXMODULEPATH}/.cache"
	local cash="${LAXCASHPATH}"
	
	start_time=$(date +%s%3N)
	log "[Starting FAX]" "$nameDir"
	
	pathCash=$(find "$cash" -type d -iname "$nameDir")
	if [ -n "$pathCash" ]; then
		pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
		[ -n "$pathCashProp" ] && dos2unix "$pathCashProp" && source "$pathCashProp" && log "[Loading prop from]" "$pathCashProp"
	fi

	tmpVCode=${versionCode:-0}
	tmpTStamp=${timeStamp:-0}
	
	if [ -n "$pathCash" ]; then
		log "[Init Version Code]" "$tmpVCode"
		log "[Init Last Update]" "$(timeformat $tmpTStamp)"
	fi

	ctr=0
	idFound=false
	cacheFile="/data/local/tmp/lax_cache/modules_list.txt"
	mkdir -p "/data/local/tmp/lax_cache"
	
	find "$modulePath" -type f -iname "*.zip" > "$cacheFile"

	while IFS= read -r file; do
		ctr=$((ctr + 1))
		
		# Mendapatkan path dari 'axeron.prop' dalam file zip
		pathProp=$(unzip -l "$file" | awk '/axeron.prop/ {print $4; exit}')
		[ -z "$pathProp" ] && continue
		
		timeStamp=$(stat -c %Y "$file")
		cachePathProc="${cachePath}/proc${ctr}"
		cachePathProp="${cachePathProc}/${pathProp}"
		
		mkdir -p "$cachePathProc"
		unzip -o "$file" -d "$cachePathProc" > /dev/null
		#dos2unix "$cachePathProp"
		source "$cachePathProp"
		
		# Cek ID dan logika
		[ -n "$id" ] && echo "$id" | grep -iq "$nameDir" || continue
		idFound=true
		log "\n[Zip]" "$file"
		log "[File Last Update]" "$(timeformat $timeStamp)"
		
		# Cek jika versionCode dan timestamp sama, lewati proses instalasi
		[ "$versionCode" -eq "$tmpVCode" ] && [ "$timeStamp" -eq "$tmpTStamp" ] && continue
		log "[No changes detected. Skipping installation.]"
		
		# Cek versi terbaru
		([ "$versionCode" -gt "$tmpVCode" ] || { [ "$versionCode" -eq "$tmpVCode" ] && [ "$timeStamp" -gt "$tmpTStamp" ]; }) || continue
		tmpVCode=$versionCode
		tmpTStamp=$timeStamp
		log "[Latest Version]" "$versionCode"
		log "[Latest Update]" "$(timeformat $tmpTStamp)"
		
		pathParent="$(dirname $(unzip -l "$file" | awk '/axeron.prop/ {print $4}' | head -n 1))"
		[ "$pathParent" == "." ] && pathParent=""
		
		pathCash="${cash}/${id}"
		cachePathParent="${cachePathProc}/${pathParent}"
		
		log "[pathParent]" "$cachePathParent"
		
		[ -d "$pathCash" ] && rm -r "$pathCash" && log "[Old module has been removed.]"
		mkdir -p "$pathCash" && log "[Installing new module.]"
		
		# Optimalkan pemindahan file
		[ -d "${cachePathParent%/}" ] && mv -f "${cachePathParent%/}"/* "$pathCash/"
		
		pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
		axprop --log "$showLog" "$pathCashProp" timeStamp "$tmpTStamp"
		log "[\$] [Module successfully updated.]" "$(timeformat $tmpTStamp)"
	done < "$cacheFile"

	
	if [ "$idFound" = false ]; then
		log "[AX processing complete. No matching ID found.]"
		echo "ID not found"
		exit 1
	fi
	
	find "$pathCash" -type f -exec chmod +x {} \;

	install=$(find "$pathCash" -type f -iname "${install:-"install"}*")
	remove=$(find "$pathCash" -type f -iname "${remove:-"remove"}*")
	execution_time=$(($(date +%s%3N) - start_time))
	log "[AX processing complete.]" "$execution_time milliseconds\n"
	
	case $2 in
		-r|--remove)
			if [ -n "$remove" ]; then
				shift 2
				"${remove}" "$@"
				rm -rf "$pathCash"
			else
				echo "[ ! ] Cannot remove this module: Remove script not found."
			fi
			;;
		*)
			if [ -n "$install" ]; then
				shift
				"${install}" "$@"
			else
				echo "[ ! ] Cannot install this module: Install script not found."
			fi
			;;
	esac
}

ax "$@"
