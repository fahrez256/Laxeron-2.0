export LAXPKG="!axPkg"
export LAXID="!axId"
export LAXVNAME="!axVName"
export LAXVCODE="!axVCode"
export LAXPATH="/sdcard/Android/data/$LAXPKG"
export LAXFILEPATH="${LAXPATH}/files"
export LAXMAINPATH="https://raw.githubusercontent.com/fahrez256/Laxeron-2.0/main"
export LAXBINPATH="/data/local/tmp/lax_bin"
export LAXCASHPATH="/data/local/tmp/lax_cash"
export LAXCACHEPATH="/data/local/tmp/lax_cache"
export LAXMODULEPATH="/sdcard/AxModules"
export LAXFUNLOC="${LAXBINPATH}/function"
export LAXFSH="${LAXMODULEPATH}/.sh"
export LAXCORE="74002f09_c51ec767_ad1e71b1"
export LAXFUN="source $LAXFUNLOC"

[ -f "$LAXFSH" ] && dos2unix "$LAXFSH" && source "$LAXFSH"

mkdir -p "$LAXBINPATH" "$LAXCASHPATH" "$LAXMODULEPATH"

currentCore=$(dumpsys package "$LAXPKG" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)

if [ -z "$LAXPKG" ] || [ "$LAXPKG" != "com.appzero.axeron" ]; then
	echo "Something wrong, may need an update?"
	exit 1
fi

echo "$LAXCORE" | grep -q "$currentCore" || { echo "Axeron Not Original" && exit 1; }

functionApi="${LAXMAINPATH}/fun/function.sh"
responsePath="${LAXFILEPATH}/function"
errorPath="${LAXFILEPATH}/func.log"

useCache=false

# Cek apakah $LAXFUNLOC sudah ada
if [ -f "$LAXFUNLOC" ]; then
	# Jika responsePath ada, copy ke $LAXFUNLOC dan berikan izin eksekusi
	if [ -e "$responsePath" ]; then
		cp "$responsePath" "$LAXFUNLOC" && chmod +x "$LAXFUNLOC"
	fi

	# Eksekusi LAXFUN
	$LAXFUN
	useCache=true
fi

# Hapus file response dan error jika ada
rm -f "$responsePath" "$errorPath"

# Memulai service dengan am startservice
am startservice -n "${LAXPKG}/.Storm" --es api "$functionApi" --es successName "function" --es errorName "func.log" > /dev/null 2>&1

# Jika cache tidak digunakan, tunggu hingga responsePath atau errorPath muncul
if [ "$useCache" = false ]; then
	while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
		# Looping hingga salah satu file muncul
		# Bisa tambahkan sleep untuk mengurangi load CPU
		sleep 0.1
	done
	
	# Jika responsePath ditemukan, copy ke $LAXFUNLOC dan set izin eksekusi
	if [ -e "$responsePath" ]; then
		cp "$responsePath" "$LAXFUNLOC" && chmod +x "$LAXFUNLOC"
	fi

	# Cek apakah $LAXFUNLOC sudah terbuat dengan benar
	if [ -f "$LAXFUNLOC" ]; then
		# Eksekusi LAXFUN
		$LAXFUN
	else
		echo "LAX Function not found :("
	fi
fi
