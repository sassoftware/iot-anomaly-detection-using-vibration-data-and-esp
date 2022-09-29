#!/usr/bin/perl
# Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
# All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

@DRV_NAME = ( "u1902", "u1903", "u1901","u1210", "u2405", "u2401", "u7230");
$MAX_CARDS = 8;
$RMMOD_COMMAND;

#===============================================================================
# remove the device nodes created when module inserting
foreach $DRV_NAME (@DRV_NAME){
	my $next_devnode = 0;
	my $delete_all = 0;
	for(my $count=0; $count<$MAX_CARDS; $count++){
	    my $node_name = $DRV_NAME . "W" . "0". $count;            
	    if(-e "/dev/$node_name"){
			if($delete_all==0){
				while(1){
					print(" device node '/dev/$node_name' found , do you remove it ?(Y)es/(N)o/(A)ll :");
					my $input_char = <STDIN>;
					chop($input_char);
					if($input_char eq "Y"){
						unlink "/dev/$node_name";
						$RMMOD_COMMAND = "rmmod " . $DRV_NAME;
						`$RMMOD_COMMAND`;
						last;
					}
					elsif($input_char eq "y"){
						unlink "/dev/$node_name";
						$RMMOD_COMMAND = "rmmod " . $DRV_NAME;
						`$RMMOD_COMMAND`;
						last;
					}
					elsif($input_char eq "N"){
						last;
					}
					elsif($input_char eq "n"){
						last;
					}
					elsif($input_char eq "A"){
						unlink "/dev/$node_name";
						print(" Remove the device node '/dev/$node_name'\n");
						$delete_all = 1;
						last;
					}
					elsif($input_char eq "a"){
						unlink "/dev/$node_name";
						print(" Remove the device node '/dev/$node_name'\n");
						$delete_all = 1;
						last;
					}
				}
			}
			else{
				unlink "/dev/$node_name";
				print(" Remove the device node '/dev/$node_name'\n");
			}
	    }
	}
}


# remove the shared library from USB-DASK/X

if( -e "/usr/lib/libusb_dask.so" ){
   print("do you want remove the shared library :'/usr/lib/libusb_dask.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib/libusb_dask.so";
        print(" Remove shared library : '/usr/lib/libusb_dask.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib/libusb_dask.so";
        print(" Remove shared library : '/usr/lib/libusb_dask.so' \n");
   }
}

if( -e "/usr/lib/libthermo.so" ){
   print("do you want remove the shared library :'/usr/lib/libthermo.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib/libthermo.so";
        print(" Remove shared library : '/usr/lib/libthermo.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib/libthermo.so";
        print(" Remove shared library : '/usr/lib/libthermo.so' \n");
   }
}

if( -e "/usr/lib64/libusb_dask64.so" ){
   print("do you want remove the shared library :'/usr/lib64/libusb_dask64.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib64/libusb_dask64.so";
        print(" Remove shared library : '/usr/lib64/libusb_dask64.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib64/libusb_dask64.so";
        print(" Remove shared library : '/usr/lib64/libusb_dask64.so' \n");
   }
}
elsif( -e "/usr/lib/x86_64-linux-gnu/libusb_dask64.so" ){
   print("do you want remove the shared library :'/usr/lib/x86_64-linux-gnu/libusb_dask64.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib/x86_64-linux-gnu/libusb_dask64.so";
        print(" Remove shared library : '/usr/lib/x86_64-linux-gnu/libusb_dask64.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib/x86_64-linux-gnu/libusb_dask64.so";
        print(" Remove shared library : '/usr/lib/x86_64-linux-gnu/libusb_dask64.so' \n");
   }
}

if( -e "/usr/lib64/libthermo64.so" ){
   print("do you want remove the shared library :'/usr/lib64/libthermo64.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib64/libthermo64.so";
        print(" Remove shared library : '/usr/lib64/libthermo64.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib64/libthermo64.so";
        print(" Remove shared library : '/usr/lib64/libthermo64.so' \n");
   }
}
elsif( -e "/usr/lib/x86_64-linux-gnu/libthermo64.so" ){
   print("do you want remove the shared library :'/usr/lib/x86_64-linux-gnu/libthermo64.so'? (Y)es/(N)o ");
   my $input_char = <STDIN>;
   chop( $input_char );
   if( $input_char eq "Y" ){
        unlink "/usr/lib/x86_64-linux-gnu/libthermo64.so";
        print(" Remove shared library : '/usr/lib/x86_64-linux-gnu/libthermo64.so' \n");
   }elsif( $input_char eq "y" ){
        unlink "/usr/lib/x86_64-linux-gnu/libthermo64.so";
        print(" Remove shared library : '/usr/lib/x86_64-linux-gnu/libthermo64.so' \n");
   }
}
