#!/usr/bin/perl
# Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
# All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

%AI_PAGE;
%AO_PAGE;
%DI_PAGE;
%DO_PAGE;
%DRV_NAME;
%MAJOR_NUM;

@MORE_POLL_DEVICE = ( "USB1902", "USB1903", "USB1901", "USB2405", "USB2401" );
$MEM_MGR_LOAD;
$CARD_FOUND;
$DRIVER_PATH;
$DRIVER_DIR;
$CONF_FILE_NAME;
$INSMOD_COMMAND;

$KERNEL_VER;
$test;

if(open(ker_info, "</proc/sys/kernel/version"))
{
    my $kernel_descrip = <ker_info>;
    ($number, $var1, $var2, $rest) = $kernel_descrip =~ /(\S+)\s+(\S+)\s+(\S+)\s+(.*)/;
    close ker_info;
    if( $var1 eq "SMP" )
    {
        print("\nThe SMP information is got from /proc/sys/kernel/version !\n\n");
    }
}
else
{
    print("The modules in this directory are compiled for Uni-Processor kernel\n");
    print("However, we can't access the kernel information from /proc/sys/kernel.\n");
    print("Do you continue ? (Y/N)");
    my $input_char = <STDIN>;
    chop( $input_char );
    if( $input_char eq "Y" ){}
    elsif( $input_char eq "y" ){}
    else {exit 0};
}

############### check the kernel version

if( open(ker_info, "</proc/sys/kernel/osrelease" ) )
{
    my $kernel_version = <ker_info>;
    ($rest) = $kernel_version =~ /(.*)/;
    close ker_info;

    $DRIVER_DIR = "/drivers/";
    $KERNEL_VER = $rest . "/";
}
############### continue the old operation

if( $ARGV[0] eq "" )
{
    $CONF_FILE_NAME = "<usbdask.conf";
}
else
{
    if( $ARGV[0] =~ /\/$/){
        ($DRIVER_PATH) = $ARGV[0] =~ /(\S+)\/$/;
    }
    else{
        $DRIVER_PATH = $ARGV[0];
    }
    $CONF_FILE_NAME = "<" . $DRIVER_PATH . "/drivers/usbdask.conf";
}


if($DRIVER_PATH ne "")
{
    $test = $DRIVER_PATH . "/drivers";
}
else
{
    $test = `pwd`;
}

($rest) = $test =~ /(.*)/;
$test = $rest . "/" . $KERNEL_VER;
if(! -d $test) 
{
    $KERNEL_VER = "";
}

if( ! open(DaskConf, $CONF_FILE_NAME) )
{
    my $ERR_MSG;
    if( $DRIVER_PATH eq "" )
    {
        $ERR_MSG = "ADLInk module installation: can't open usbdask.conf\n";
        print("$ERR_MSG \t\t\t\t\t\tPress ENTER for exit:");
    }
    else
    {
#        $ERR_MSG = "ADLInk module installation: can't open " . $DRIVER_PATH . "/drivers/usbdask.conf\n";
        $ERR_MSG = "ADLInk module installation: can't open " . $CONF_FILE_NAME;
        print("$ERR_MSG \t\t\t\t\t\tPress ENTER to continue:");
    }
    my $temp_char = <STDIN>;
    exit 0;
}

for( $count = 0 ; $count < 4; $count ++ ){
    $line = <DaskConf>;
}

#======================================================================
# read usbdask.conf
while (<DaskConf>){
    chop();
    ($card_type,$cards,$ai_page,$ao_page,$di_page,$do_page) = /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
    ($drv_name) = $card_type =~ /USB(\w+)/;
    $drv_name =~ tr/A-Z/a-z/;
    $DRV_NAME{$card_type}= $drv_name;
    $CARDS{$card_type}= $cards;
    $AI_PAGE{$card_type}= ($ai_page);
    $AO_PAGE{$card_type}= ($ao_page);
    $DI_PAGE{$card_type}= ($di_page);
    $DO_PAGE{$card_type}= ($do_page);
}
close DaskConf;


#======================================================================
# copy the *.bin

if( ! -d "/etc/udask" ){
  `mkdir -p /etc/udask/fw`;
}

if( ! -d "/etc/udask/fw" ){
  `mkdir /etc/udask/fw`;
}

if( $DRIVER_PATH ne "" )
{
    $INSMOD_COMMAND ="cp -f " . $DRIVER_PATH . "/drivers/*.bin /etc/udask/fw";
}
else
{
    $INSMOD_COMMAND ="cp -f ../drivers/*.bin /etc/udask/fw";
}
`$INSMOD_COMMAND`;
#======================================================================
# copy the libusb_dask64.so to /usr/lib64
if( $DRIVER_PATH ne "" )
{

    if( ! -d "/usr/lib64" ){
        $INSMOD_COMMAND ="cp -f " . $DRIVER_PATH . "/lib/libusb_dask64.so /usr/lib64";
    }
    elsif( ! -d "/usr/lib/x86_64-linux-gnu" ){
        $INSMOD_COMMAND ="cp -f " . $DRIVER_PATH . "/lib/libusb_dask64.so /usr/lib/x86_64-linux-gnu";
    }
    
}
else
{

    if( ! -d "/usr/lib64" ){
        $INSMOD_COMMAND ="cp -f ../lib/libusb_dask64.so /usr/lib64";
    }
    elsif( ! -d "/usr/lib/x86_64-linux-gnu" ){
        $INSMOD_COMMAND ="cp -f ../lib/libusb_dask64.so /usr/lib/x86_64-linux-gnu";
    }
}
`$INSMOD_COMMAND`;

#======================================================================
#  32-bit library is not needed yet 
#======================================================================
# copy the libusb_dask.so to /usr/lib

#if( $DRIVER_PATH ne "" ){
#    $INSMOD_COMMAND ="cp -f " . $DRIVER_PATH . "/lib/libusb_dask.so /usr/lib";
#}
#else{
#    $INSMOD_COMMAND ="cp -f ../lib/libusb_dask.so /usr/lib";
#}
#`$INSMOD_COMMAND`;

#======================================================================


# copy udev rule to /etc/udev-rules/
if( $DRIVER_PATH ne ""){
    $INSMOD_COMMAND = "cp " . $DRIVER_PATH . "/drivers/60-usbdaq.rules /etc/udev/rules.d";
}
else{
    $INSMOD_COMMAND = "cp 60-usbdaq.rules /etc/udev/rules.d";
}
`$INSMOD_COMMAND`;

#======================================================================
# card_found check
$CARD_FOUND = 0;
foreach $cardtype (keys(%CARDS))
{
   if( $CARDS{$cardtype} > 0 ){
       $CARD_FOUND = 1;
       last;
   }
}

if( $CARD_FOUND == 0 )
{
    print(" No PCIDASK adapter in 'usbdask.conf' , you need configure the adapters \n with usbdask_conf utility \n");
    exit 0;
}
#======================================================================
#insert Adl_Memory_Manager module
$MEM_MGR_LOAD = 0;

foreach $cardtype (keys(%DRV_NAME))
{
    foreach $MORE_POLL_DEVICE (@MORE_POLL_DEVICE)
    {
        if( $cardtype eq $MORE_POLL_DEVICE )
        {
            $MEM_MGR_LOAD = 0;
            last;
        }
    }

    if( $MEM_MGR_LOAD == 1 ){
        last;
    }
}


if( $DRIVER_PATH ne "" ){
    $DRIVER_PATH = $DRIVER_PATH . $DRIVER_DIR;
}
# get the driver path
if( $DRIVER_PATH ne "" ) {
    $DRIVER_PATH = $DRIVER_PATH . $KERNEL_VER;
}
else{
    $DRIVER_PATH = $KERNEL_VER;
}

# adl_mem_mgr.ko is not necessary 
$MEM_MGR_LOAD = 0;

if( $MEM_MGR_LOAD == 1 ){
    if( $DRIVER_PATH ne "" ){
        $INSMOD_COMMAND = "insmod -f " . $DRIVER_PATH . "adl_mem_mgr.o";
    }
    else{
        $INSMOD_COMMAND = "insmod -f adl_mem_mgr.o";
    }
    `$INSMOD_COMMAND`;
}

#======================================================================
#insert the usbdask module
foreach $cardtype (keys(%DRV_NAME))
{
    my $BUFSIZE_NEED = 0;
    my $drv_name = "u" . $DRV_NAME{$cardtype} . ".ko";

    # check the BufSize needed
    foreach $MORE_POLL_DEVICE (@MORE_POLL_DEVICE){
        if( $cardtype eq $MORE_POLL_DEVICE ){
            $BUFSIZE_NEED = 1; # some adapter need AI, AO, DI, or DO , ie. BufSize is needed
            last;
        }
    }

    if( $BUFSIZE_NEED == 1 ){
        print(" insmod -f $drv_name \n");
        if( $DRIVER_PATH ne "" ){
            $INSMOD_COMMAND ="insmod -f " . $DRIVER_PATH . $drv_name . " BufSize=$AI_PAGE{$cardtype},$AO_PAGE{$cardtype},$DI_PAGE{$cardtype},$DO_PAGE{$cardtype}";
        }
        else{
            $INSMOD_COMMAND = "insmod -f " . $drv_name . " BufSize=$AI_PAGE{$cardtype},$AO_PAGE{$cardtype},$DI_PAGE{$cardtype},$DO_PAGE{$cardtype}";
        }
        `$INSMOD_COMMAND`;
    }else{
        print(" insmod -f $drv_name \n");
        if( $DRIVER_PATH ne "" ){
            $INSMOD_COMMAND ="insmod -f " . $DRIVER_PATH . $drv_name;
        }
        else{
            $INSMOD_COMMAND = "insmod -f " . $drv_name;
        }
        `$INSMOD_COMMAND`;
    }
}

exit 0;

