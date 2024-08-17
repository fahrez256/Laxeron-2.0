export LAXPKG="!axPkg"
export LAXID="!axId"
export LAXVNAME="!axVName"
export LAXVCODE=!axVCode
export LAXBIN="/data/local/tmp/lax_bin"
export LAXMODULE="/sdcard/AxModules"
export LAXFUNPATH="${LAXBIN}/function"
export LAXFUN=". $LAXFUNPATH"
mkdir -p $LAXMODULE
local functionApi=""
local responsePath="/sdcard/data/${AXERONPKG}/files/response"
local errorPath="/sdcard/data/${AXERONPKG}/files/error"
am startservice -n ${AXERONPKG}/.Storm --es api "$functionApi" > /dev/null 2>&1
while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
done
cp "$responsePath" "$LAXFUNPATH"
chmod +x "$LAXFUNPATH"
$LAXFUN
}
