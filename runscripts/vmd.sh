#export HOST_DISPLAY=$(w -h $USER | awk '$2 ~ /:[0-9.]*/{print $2}')
SCRIPT_PATH=$(dirname -- "$0")

apptainer run --containall --env DISPLAY=$DISPLAY $SCRIPT_PATH/../sif-images/vmd-guix.sif
