#!/bin/sh
# Plots system information to be used with polybar. 
# source: https://github.com/p-dr/polybar-system-plot

## DEFAULT VALUES

## List interfaces with ip link
# INTERFACE=wlp3s0

## Queue length, number of characters used
# QLEN=100  

## Size of moving window used for smoothing (moving average)
# WLEN=3

## Time interval in seconds between updates
# INTERVAL=.01

## increasing height bars characters (set by default to use with VerticalBars font).
# #CHARSET='.,╷╻!|┆│┃║'
# #CHARSET=ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝḞ
# CHARSET=ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎ

INTERFACE=wlp3s0
QLEN=100  # queue length (characters)
WLEN=3  # length of half window used to smoothing
INTERVAL=.01
CHARSET=ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎ
MOVEMENT_DIRECTION=left
DATA_DIRECTION=r  # monitor received data by default

while [[ $# -gt 0 ]] ; do

    case $1 in
        --download|-r)  # redundant
        DATA_DIRECTION=r  # received
        shift
        ;;
        --upload|-t)
        DATA_DIRECTION=t  # transmitted
        shift
        ;;
        --direction|-d)  # left or right
        MOVEMENT_DIRECTION=$2
        shift
        shift
        ;;
        --wlength)
        WLEN=$2
        shift
        shift
        ;;
        --iface)
        INTERFACE=$2
        shift
        shift
        ;;
        --length)
        QLEN=$2
        shift
        shift
        ;;
        --interval)
        INTERVAL=$2
        shift
        shift
        ;;
    esac
done


mean () {
    local res=0
    for i in $@ ; do
        res=$(( $res + $i ))
    done
    res=$(( $res / ${#@}))
    mean_res=$res
}


smooth_queue () {
    smoothed=()
    for i in $( seq 0 $(( ${#queue[@]} - $WLEN )) ) ; do
        window=${queue[@]:$i:$WLEN}
        mean ${window[@]}
        smoothed+=($mean_res)
    done
}


echo_queue () {
    local max=0
    for i in $@ ; do
        if (( $i > $max )) ; then
            max=$i
        fi
    done
    max=$(( $max + 1 ))  # put max in last bin

    local res=()
    for i in $@ ; do
        if (($max)) ; then
            ind=$(( $i * ${#CHARSET} / $max ))
        else
            ind=0
        fi
        res+=(${CHARSET[@]:$ind:1})
    done

    printf %s ${res[@]} $'\n'
}

echo $movement_direction
QLEN=$(( $QLEN + $WLEN - 1))  # compensate windowing length reduction
queue=()
for i in $(seq $QLEN) ; do queue+=( "0" ) ; done

oldreceived=$(cat "/sys/class/net/$INTERFACE/statistics/${DATA_DIRECTION}x_bytes")
while [ true ] ; do
    received=$(cat "/sys/class/net/$INTERFACE/statistics/${DATA_DIRECTION}x_bytes")
    delta=$(($received - $oldreceived))
    oldreceived=$received

    if [ $MOVEMENT_DIRECTION == left ] ; then
        queue=( "${queue[@]:1}" "$delta" )
    elif [ $MOVEMENT_DIRECTION == right ] ; then
        queue=( "$delta" "${queue[@]:0:(( $QLEN - 1 ))}" )
    fi

    smooth_queue
    echo_queue ${smoothed[@]}
    sleep $INTERVAL
done
