export LAXPKG="!axPkg"
export LAXID="!axId"
export LAXVNAME="!axVName"
export LAXVCODE="!axVCode"
export LAXPATH="/sdcard/Android/data/${LAXPKG}/files"
export LAXMAINPATH="https://raw.githubusercontent.com/fahrez256/Laxeron-2.0/main"
export LAXBINPATH="/data/local/tmp/lax_bin"
export LAXCASHPATH="/data/local/tmp/lax_cash"
export LAXMODULEPATH="/sdcard/AxModules"
export LAXFUNLOC="${LAXBINPATH}/function"
export LAXPROP="${LAXMODULEPATH}/.prop"
export LAXCORE="ad1e71b1"
export LAXFUN="source $LAXFUNLOC"

[ -f "$LAXPROP" ] && dos2unix "$LAXPROP" && source "$LAXPROP"

mkdir -p "$LAXBINPATH"
mkdir -p "$LAXCASHPATH"
mkdir -p "$LAXMODULEPATH"

currentCore=$(dumpsys package "$LAXPKG" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)
echo $currentCore

[ -z "$LAXPKG" ] || [ "$LAXPKG" != "com.appzero.axeron" ] && { echo "Something wrong, may need an update?" && exit 1; }
echo "$LAXCORE" | grep -q "$currentCore" || { echo "Axeron Not Original" && exit 1; }

functionApi="${LAXMAINPATH}/fun/function.sh"
responsePath="${LAXPATH}/response"
errorPath="${LAXPATH}/error"

am startservice -n "${LAXPKG}/.Storm" --es api "$functionApi" > /dev/null 2>&1

while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
done

cp "$responsePath" "$LAXFUNLOC" && chmod +x "$LAXFUNLOC"
rm -f "$responsePath" && rm -f "$errorPath"
[ -f "$LAXFUNLOC" ] && $LAXFUN || echo "LAX Function not found :("
