#! /bin/sh

apps_dir=/media/mmcblk0p1/apps

source $apps_dir/stop.sh

cat $apps_dir/ads_receiver_77_76/ads_receiver_77_76.bit > /dev/xdevcfg

$apps_dir/common_tools/reset-adc.sh
echo 568 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio568/direction
$apps_dir/common_tools/setup-adc
$apps_dir/common_tools/setup-adc t
echo 1 > /sys/class/gpio/gpio568/value
echo 0 > /sys/class/gpio/gpio568/value
$apps_dir/common_tools/setup-adc n

#address=`awk -F : '$5="FF"' OFS=: /sys/class/net/eth0/address`

#echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
#echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
#echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter

#ip link add mvl0 link eth0 address $address type macvlan mode passthru

$apps_dir/ads_receiver_77_76/sdr-receiver eth0 &
#$apps_dir/ads_receiver_77_76/sdr-receiver mvl0 &
