#!/usr/bin/perl -w

# written by Hayden Muscat 2018
# online arc Form code

# _____________________________________________________________________________
#
#                               Modules / globals
# _____________________________________________________________________________

use CGI qw/:all/;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;

# used for file shuffling in deletion etc
use File::Path qw/remove_tree/;
use File::Copy qw/move/;

# contains all of my html code blocks
use ArcFormHTML;
use AuthCode;

$debug = 1;  #prints supplied parameters and values in trailer

# _____________________________________________________________________________
#
#                               Main Function
# _____________________________________________________________________________

sub main() {

    ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $mon ++; # offset by 1
    $year -= 100;

    # print start of HTML to assist debugging if there is an error in the script
    # And tell CGI::Carp to embed any warning in HTML
    print page_header_html();
    warningsToBrowser(1);

    # nav bar etc
    print page_top_html();

    # if event name existing, then have a valid event
    if (defined(param('event_name'))) {

        # check they have given a valid authentication code to begin an event
        # (so only HC can make events, instead of people making coffee night
        # themselves and signing in remotely) 
        if (defined(param('auth_code')) and param('auth_code') eq $AUTH_CODE) {

            # kept as global values I guess
            $event_name = param('event_name');
            $event_name =~ s/\s/_/g;
            $auth_code = param('auth_code');
            $attendance_file_name = "events/${event_name}${mday}-$mon.csv";

            if (defined(param('sign_in_zID'))) {
                sign_in_attempt(param('zID_entered'));
            } elsif (defined(param('sign_in_manual'))) {
                manual_sign_in();
            } elsif (defined(param('become_arc_member'))) {
                make_arc_member(param('zID_entered'));
            }

            # After all that, print the rest of the page
            submission_page();

        # authentication code not correct
        } else {
            print notice_html("Error: authentication code incorrect", "warning");
            print start_page_html();
        }

    # otherwise, we're at the start page?
    } else {
        if (defined(param('email_forms'))) { email_forms(); }
        print start_page_html();
    }

    print page_trailer_html($debug);
    exit(1);
}

sub email_forms() {

    my $success = system("./emailForms.sh");
    print notice_html("Email Sent", "info");

}

sub make_arc_member($) {

    my ($zID) = @_;

    system("dos2unix zIDFile.csv");

    my $file_open = open OLDZIDS, '<', "zIDFile.csv";
    if (!$file_open) {
        print notice_html("Error: couldn't open old zIDFile file", "danger");
        return;
    }

    $file_open = open NEWZIDS, '>', "zIDFileNew.csv";
    if (!$file_open) {
        print notice_html("Error: couldn't make new zIDFile file", "danger");
        return;
    }

    # find zID and mark them if able
    while ($line = <OLDZIDS>) {
        chomp $line;
        if ($line =~ /(.+),(.+),\s*z?$zID/i) {
            print NEWZIDS "$line,TRUE\n";
            print notice_html("Updated. Thanks for joining.", "success");
        } else {
            print NEWZIDS "$line\n";
        }
    }

    close OLDZIDS;
    close NEWZIDS;

    system("mv zIDFile.csv oldZIDFiles/zIDFile$mday-$mon.csv");
    system("mv zIDFileNew.csv zIDFile.csv");
    return;
}

sub sign_in_attempt($) {

    (my $zID) = @_;

    $zID =~ s/X\d(\d{7}).*/$1/;     # barcode pattern
    $zID =~ s/[^\d]//g;             # otherwise just keep numbers

    if (length $zID < 5) {
        print notice_html("Extracted ID too short: $zID", "warning");
        return;
    }

    # found the name of the person, and if they are in ARC.
    # =====================================================
    my $file_open = open ZIDFILE, '<', "zIDFile.csv";
    if (!$file_open) {
        print notice_html("Error: couldn't open zIDFile file", "danger");
        return;
    }

    @data = <ZIDFILE>;
    close ZIDFILE;

    # find zID and mark them if able
    my $found = 0;
    for $line (@data){
        if ($zID =~ /\d{7}/ and $line =~ /(.+),(.+),.*$zID/i){

            $found = 1;
            my ($first, $last) = (ucfirst lc $1, ucfirst lc $2);
            my $name  = "$first $last";

            my $arcMember = "No";
            $arcMember = "Yes" if ($line =~ /TRUE/);
            mark_as_attending($name, $zID, $arcMember);

            print not_in_arc_html($event_name, $zID, $auth_code) if ($arcMember eq "No");

            last;
        }
    }

    if ($found == 0) {
        print notice_html("ID '$zID' not found in system", "warning");
    }

    return;
}

sub manual_sign_in() {

    my $first = param('first_name');
    my $last  = param('last_name');
    my $zID   = param('zID_entered');
    my $isArc = "No";
    my $rememberMe = 0;

    $isArc = "Yes" if (defined(param('arc_member')));
    $rememberMe = 1 if (defined(param('remember_me')));

    # input checking stuff
    my $fuckedUp = 0;
    if ($first =~ /[^a-zA-Z'-]/) {
        $fuckedUp = 1;
        print notice_html("First name $first contains invalid characters", "warning");
    }
    if ($first eq "") {
        $fuckedUp = 1;
        print notice_html("No First name entered", "warning");
    }
    if ($last =~ /[^a-zA-Z'-]/) {
        $fuckedUp = 1;
        print notice_html("Last name $last contains invalid characters", "warning");
    }
    if ($last eq "") {
        $fuckedUp = 1;
        print notice_html("No last name entered", "warning");
    }
    if ($zID =~ /[^zZ0-9]/) {
        $fuckedUp = 1;
        print notice_html("zID $zID contains invalid characters", "warning");
    }
    if ($zID !~ /[zZ]?[0-9]{7}/) {
        $fuckedUp = 1;
        print notice_html("zID not long enough", "warning");
    }

    if ($fuckedUp == 1) { return; }

    # otherwise, let's treck onwards!

    ($first, $last) = (ucfirst lc $first, ucfirst lc $last);
    my $name  = "$first $last";

    mark_as_attending($name, $zID, $isArc);

    if ($rememberMe == 1) {
        my $file_open = open ZIDFILE, '<', "zIDFile.csv";
        if (!$file_open) {
            print notice_html("error opening zID file", "danger");
            return;
        }

        @data = <ZIDFILE>;
        close ZIDFILE;
        my $found = 0;

        # if we find a match, we change it
        for $line (@data){
            if ($zID =~ /\d{7}/ and $line =~ /(.+),(.+),\s*z?$zID/i){
                print notice_html("zID $zID is already in the system", "info");
                $found = 1;
                last;
            }
        }

        if ($found == 0) {
            $file_open = open ZIDFILE, '>>', "zIDFile.csv";
            if (!$file_open) {
                print notice_html("error opening zID file", "danger");
                return;
            }

            if ($isArc eq "No") {
                print ZIDFILE "$first,$last,$zID\n";
            } else {
                print ZIDFILE "$first,$last,$zID,TRUE\n";
            }
            print notice_html("details successfully saved", "success");

            close ZIDFILE;
        }
    }

    return;
}

sub mark_as_attending($$$) {

    my ($name, $zID, $isArc) = @_;

    my $attendOpen = open ATTEND, '<', "$attendance_file_name";
    if (!$attendOpen) {
        print notice_html("Error: couldn't open attendance file", "danger");
        return;
    }
    @attendance = <ATTEND>;
    $already_listed = 0;
    for $entry (@attendance){
        if ($entry =~ /$zID/){
            print notice_html("$zID already registered", "info");
            $already_listed = 1;
            last;
        }
    }
    close ATTEND;

    $attendOpen = open ATTEND, '>>', "$attendance_file_name";
    if (!$attendOpen) {
        print notice_html("Error: couldn't open attendance file", "danger");
        return;
    }
    if ($already_listed == 0){
        print ATTEND "$name, $zID, $isArc, ${hour}:${min}:$sec $mday/$mon/$year\n";
        print notice_html("Registration Successful", "success");
    }
    close ATTEND;

}

sub submission_page{

    # create the attendance file if its the first time getting to the page
    if (!-e "$attendance_file_name"){
        my $attendOpen = open ATTEND, '>', "$attendance_file_name";
        if (!$attendOpen) {
            print notice_html("Error: couldn't open attendance file", "danger");
            return;
        }
        print ATTEND "Name, zID, ARC membership, timestamp\n";
        close ATTEND;
    }

    print sign_in_form_html($event_name, $auth_code);
}


# _________________________________________________________________
#
#                       Main function call
# _________________________________________________________________

main();
