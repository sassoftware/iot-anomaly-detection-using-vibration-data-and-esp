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

@MORE_POLL_DEVICE = ( "USB1902", "USB1903", "USB1901", "USB2405", "USB2401", "USB7230", "USB7250", "USB1210");
$MEM_MGR_LOAD;
$CARD_FOUND;
$DRIVER_PATH = "..";
$DRIVER_DIR;
$CONF_FILE_NAME;
$INSMOD_COMMAND;

$KERNEL_VER;
$test;
#===============
@ALL_DEVICE = ("1902","1903","1901","2405","2401","7230","7250","1210");
$CONFIG_PATH = "../conf/user/";
$MODULES_PATH = "/etc/modules";
#===============


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
    $CONF_FILE_NAME = "<" . $DRIVER_PATH . "/util/usbdask.conf";
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
    else{
        $ERR_MSG = "ADLInk module installation: can't open " . $DRIVER_PATH . "/util/usbdask.conf\n";
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
    $AI_PAGE{$card_type}= ($ai_page << 2);
    $AO_PAGE{$card_type}= ($ao_page << 2);
    $DI_PAGE{$card_type}= ($di_page << 2);
    $DO_PAGE{$card_type}= ($do_page << 2);
}
close DaskConf;

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
#make conf file

foreach $cardtype (keys(%DRV_NAME)){
    my $file_name = "u" . $DRV_NAME{$cardtype} . ".conf";
    open(FH, '>', $CONFIG_PATH . $file_name) or die $!;
    my $conf_string = "options " . "u" . $DRV_NAME{$cardtype} . " BufSize=$AI_PAGE{$cardtype},$AO_PAGE{$cardtype},$DI_PAGE{$cardtype},$DO_PAGE{$cardtype}"; 
    print FH "$conf_string\n";
    close(FH);
    
    my @conf_list = "u" . $DRV_NAME{$cardtype} . "\t" . $AI_PAGE{$cardtype} . "\t" . $AO_PAGE{$cardtype} . "\t" . $DI_PAGE{$cardtype} . "\t" . $DO_PAGE{$cardtype} . "\n";
    @newconf = (@newconf, @conf_list); 
    
}

#======================================================================
# status list
my @dir;
print "\n=================================================================";
foreach $cardtype (keys(%DRV_NAME)){
    foreach $MORE_BUF_DEVICE (@MORE_BUF_DEVICE){
        if($cardtype eq $MORE_BUF_DEVICE){
            $base_path = "ls /dev | grep " . $cardtype;                    
            my @dev_tmp= `$base_path`;            
            @dir = (@dir, @dev_tmp);            
        }
    }    
}

print "\nCurrent Config:";
print "\n Card\tAI\tAO\tDI\tDO\t[unit: KB]";
print "\n @newconf";


print "\n=================================================================\n";


exit 0;
