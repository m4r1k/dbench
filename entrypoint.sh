#!/usr/bin/env sh
set -e

if [ -z $DBENCH_MOUNTPOINT ]; then
    DBENCH_MOUNTPOINT=/tmp
fi

echo Working dir: $DBENCH_MOUNTPOINT
echo

FIOCMD="fio --ioengine=libaio --filesize=2G --ramp_time=2s --runtime=5m --numjobs=16 --direct=1 --verify=0 --randrepeat=0 --group_reporting --directory=$DBENCH_MOUNTPOINT --time_based"

if [ "$1" = 'fio' ]; then

    echo Testing Read IOPS and Bandwidth...
    READ_IOPS=$($FIOCMD --name=read_iops --readwrite=randread --blocksize=4k --iodepth=256 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/read_iops.*
    echo "$READ_IOPS"
    READ_IOPS_VAL=$(echo "$READ_IOPS"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    READ_BW_VAL=$(echo "$READ_IOPS"|grep -E 'read ?:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write IOPS and Bandwidth...
    WRITE_IOPS=$($FIOCMD --name=write_iops --readwrite=randwrite --blocksize=4k --iodepth=256 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/write_iops.*
    echo "$WRITE_IOPS"
    WRITE_IOPS_VAL=$(echo "$WRITE_IOPS"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    WRITE_BW_VAL=$(echo "$WRITE_IOPS"|grep -E 'write:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Read Latency...
    READ_LATENCY=$($FIOCMD --name=read_latency --readwrite=randread --blocksize=4k --iodepth=4 --numjobs=1)
    rm -f $DBENCH_MOUNTPOINT/read_latency.*
    echo "$READ_LATENCY"
    READ_LATENCY_VAL=$(echo "$READ_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[\b 0-9.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write Latency...
    WRITE_LATENCY=$($FIOCMD --name=write_latency --readwrite=randwrite --blocksize=4k --iodepth=4 --numjobs=1)
    rm -f $DBENCH_MOUNTPOINT/write_latency.*
    echo "$WRITE_LATENCY"
    WRITE_LATENCY_VAL=$(echo "$WRITE_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[\b 0-9.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Read Sequential Speed...
    READ_SEQ=$($FIOCMD --name=read_seq --readwrite=read --blocksize=1m --iodepth=64 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/read_seq.*
    echo "$READ_SEQ"
    READ_SEQ_VAL=$(echo "$READ_SEQ"|grep -E 'READ:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write Sequential Speed...
    WRITE_SEQ=$($FIOCMD --name=write_seq --readwrite=write --blocksize=1m --iodepth=64 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/write_seq.*
    echo "$WRITE_SEQ"
    WRITE_SEQ_VAL=$(echo "$WRITE_SEQ"|grep -E 'WRITE:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Read/Write Mixed...
    RW_MIX=$($FIOCMD --name=rw_mix --readwrite=randrw --rwmixread=75 --blocksize=4k --iodepth=256 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/rw_mix.*
    echo "$RW_MIX"
    RW_MIX_R_IOPS=$(echo "$RW_MIX"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)

    echo Testing Write/Read Mixed...
    WR_MIX=$($FIOCMD --name=wr_mix --readwrite=randrw --rwmixwrite=75 --blocksize=4k --iodepth=256 --gtod_reduce=1)
    rm -f $DBENCH_MOUNTPOINT/wr_mix.*
    echo "$WR_MIX"
    WR_MIX_W_IOPS=$(echo "$WR_MIX"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    echo
    echo

    echo All tests complete.
    echo
    echo ==================
    echo = Dbench Summary =
    echo ==================
    echo "Random Read/Write IOPS: $READ_IOPS_VAL / $WRITE_IOPS_VAL BW: $READ_BW_VAL / $WRITE_BW_VAL"
    echo "Average Latency (usec) Read/Write: $READ_LATENCY_VAL / $WRITE_LATENCY_VAL"
    echo "Sequential Read/Write: $READ_SEQ_VAL / $WRITE_SEQ_VAL"
    echo "Mixed Random Read/Write IOPS: $RW_MIX_R_IOPS / $WR_MIX_W_IOPS"

    exit 0
fi

exec "$@"
