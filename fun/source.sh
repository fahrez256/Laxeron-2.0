export LAXPKG="!axPkg"
export LAXID="!axId"
export LAXVNAME="!axVName"
export LAXVCODE="!axVCode" # Tambahkan tanda kutip untuk nilai variabel jika perlu
export LAXBIN="/data/local/tmp/lax_bin"
export LAXMODULE="/sdcard/AxModules"
export LAXFUNPATH="${LAXBIN}/function"
export LAXFUN=". $LAXFUNPATH"

mkdir -p "$LAXBIN"
mkdir -p "$LAXMODULE"

functionApi="https://raw.githubusercontent.com/fahrez256/Laxeron-2.0/main/fun/function.sh"
responsePath="/sdcard/Android/data/${LAXPKG}/files/response"
errorPath="/sdcard/Android/data/${LAXPKG}/files/error"

rm -f "$responsePath"

am startservice -n "${LAXPKG}/.Storm" --es api "$functionApi" > /dev/null 2>&1

while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
done

# Menyalin dan mengatur izin
if [ -e "$responsePath" ]; then
    cp "$responsePath" "$LAXFUNPATH"
    chmod +x "$LAXFUNPATH"
    $LAXFUN
else
    echo "LAX Function not found :("
fi
