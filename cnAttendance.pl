#!/usr/bin/perl -w

# written by Hayden Muscat 2019
# creates an attendance list based on the coffee night event form

die "No coffee night form supplied\n" if (@ARGV < 1 || $ARGV[0] !~ /Coffee_Night/);

# get a hash of all IDs that exist in the coffee night file
open CN_FILE, '<', "$ARGV[0]" or die "Error: couldn't open coffee night file\n";
for my $line (<CN_FILE>){
    chomp $line;
    if ($line =~ /([^,]+),([^,]+)/){
        my $zID = $2;
        $zID =~ s/[^\d]//g;
        $attended{$zID} = 1;
    }
}
close CN_FILE;

# go through all the people in the zID list. if they attendend, say so otherwise not
$cnFileSuffix = $ARGV[0];
$cnFileSuffix =~ s/.*Coffee_Night//;
open ZID_FILE, '<', "zIDFile.csv" or die "Error: couldn't open zIDFile file.\n";
open ATTENDANCE_FILE, '>', "events/cn_Attendance_$cnFileSuffix" or die "Error: couldn't create attendance file.\n";

print ATTENDANCE_FILE "First Name, Last Name, Room, Attended\n";

for my $line (<ZID_FILE>){
    chomp $line;
    if ($line =~ /([^,]+),([^,]+),([^,]+),([^,]+)/){
        my ($first, $last, $zID, $room) = (ucfirst lc $1, ucfirst lc $2, $3, $4);
        $zID =~ s/[^\d]//g;
        if (defined $attended{$zID}) {
            print ATTENDANCE_FILE "$first, $last, $zID, $room, Yes\n";
        } else {
            print ATTENDANCE_FILE "$first, $last, $zID, $room, No\n";
        }
    }
}
close ZID_FILE;
close ATTENDANCE_FILE;
