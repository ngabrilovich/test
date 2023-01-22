#!/usr/bin/env perl

use strict;
use warnings;
use locale;
use DBI;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use MailLogTest::Schema;

my $logfile = "../public/files/out";

my $schema = MailLogTest::Schema->connect( 'dbi:mysql:database=scorpycat;host=10.145.1.3;', 'scorpycat', 'plasasgu', { PrintError => 1 } ) or die;

open(FH, '<', $logfile) or die $!;

while (<FH>) {
    chomp $_;
    my @data = split (" ", $_);
    #В таблицу message должны попасть только строки прибытия сообщения (с флагом <=)
    if ($data[3] eq "<=") {
	#Не у всех есть поле "id=", встречаются записи без него, с "U=mailnull P=local". Раз id NOT NULL, такие, видимо, пойдут в log, a не в message.
	if ($data[9]) {
	    if ($data[9]=~ m/id\=(\S+)$/) {
		my @row = @data;
		my $row = join(" ", splice(@row, 2, 9));
		my $message = $schema->resultset('Message')->new({ 
		    created  => "$data[0]"." "."$data[1]",
		    id       => "$1",
		    int_id  => "$data[2]",
		    str  => "$row",
								 });
		$message->insert();
	    #Встретились записи, где "id=" в 11 элементе, а не в 10. Если дальше более разнообразно, то for (@data) вместо этого элсифа, будет дольше, но надёжнее. 
	    }  elsif ($data[10]) {
		if ($data[10]=~ m/id\=(\S+)$/) {
		    my @row = @data;
		    my $row = join(" ", splice(@row, 2, 10));
		    my $message = $schema->resultset('Message')->new({
			created  => "$data[0]"." "."$data[1]",
			id       => "$1",
			int_id  => "$data[2]",
			str  => "$row",
								     });
		    $message->insert();
		}
	    }
	} else {
	    if (($data [4]) && $data[4]=~ m/(\S+@\S+)$/) {
		 my @row = @data;
		 my $row = join(" ", splice(@row, 2, 10));
		 my $log = $schema->resultset('Log')->new({
		     created  => "$data[0]"." "."$data[1]",
		     int_id  => "$data[2]",
		     str  => "$row",
		     address =>"$1"
							  });
		 $log->insert();
		
	    } else {
		 my @row = @data;
		 my $row = join(" ", splice(@row, 2, 10));
		 my $log = $schema->resultset('Log')->new({
		     created  => "$data[0]"." "."$data[1]",
		     int_id  => "$data[2]",
		     str  => "$row"
							  });
		 $log->insert();
	    }
	}
    } else {
	if ($data[4] && $data[4]=~ m/(\S+@\S+)$/) {
	    my @row = @data;
	    my $row = join(" ", splice(@row, 2, 10));
	    my $log = $schema->resultset('Log')->new({
		created  => "$data[0]"." "."$data[1]",
		int_id  => "$data[2]",
		str  => "$row",
		address =>"$1"
						     });
	    $log->insert();
	    
	} else {
	    my @row = @data;
	    my $row = join(" ", splice(@row, 2, 10));
	    my $log = $schema->resultset('Log')->new({
		created  => "$data[0]"." "."$data[1]",
		int_id  => "$data[2]",
		str  => "$row"
						     });
	    $log->insert();
	}
    }
}
#Проверила count, действительно, 1561 в message и остальные 8439 в log
