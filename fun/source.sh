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

if [ -f "$LAXPROP" ]; then
  dos2unix "$LAXPROP"
  source "$LAXPROP"
fi

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

rm -f "$responsePath"
rm -f "$errorPath"

am startservice -n "${LAXPKG}/.Storm" --es api "$functionApi" > /dev/null 2>&1

while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
done

[ -e "$responsePath" ] && { cp "$responsePath" "$LAXFUNLOC" && chmod +x "$LAXFUNLOC"; }

if [ -f "$LAXFUNLOC" ]; then
    $LAXFUN
else
    echo "LAX Function not found :("
fi
