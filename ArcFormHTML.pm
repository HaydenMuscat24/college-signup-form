package ArcFormHTML;

use strict;
use warnings;
use Exporter;

# for html stuff
use CGI qw/:all/;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;

our @ISA= qw( Exporter );

our @EXPORT = qw(
    start_page_html
    sign_in_form_html
    page_header_html
    page_trailer_html
    page_top_html
    not_in_arc_html
    notice_html);



# HTML placed at the top of every page
sub page_header_html {

    return <<'eof'
Content-Type: text/html;charset=utf-8

<!DOCTYPE html>
<html lang="en">
  <head>
    <title>ARC event form</title >
    <link href="arcForm.css" rel="stylesheet">
  </head>
  <body>
eof
}


sub notice_html($$) {

    my ($message, $type) = @_;

    return <<"eof"
  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="card text-white bg-$type mb-3">
        <div class="card-body">
          <h4 class="card-title" align="center">$message</h4>
        </div>
      </div>
    </div>
  </div>
eof
}


# HTML placed at the bottom of every page
# It includes all supplied parameter values as a HTML comment
# if global variable $debug is set
sub page_trailer_html($) {

    my ($debug) = @_;

    my $html = "";
    $html .= join("", map("<!-- $_=".param($_)." -->\n", param())) if $debug;
    $html .= end_html;
    return $html;
}


sub page_top_html {

    return <<eof
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container justify-content-between">
          <img src="shield banner.png" height="80" alt="unsw hall banner" >
          <a class="navbar-brand" href="#">Arc Form</a>
          <img src="arc logo.png" height="80" alt="arc logo" >
    </div>
  </nav>
  <div class="row">
    <br>
  </div>
eof
}


sub start_page_html {
    my $toReturn = "";

    # a gap, then an offset to center and 6 for forms
    # _____________________________________________________
    $toReturn.= <<eof;
  <div class="row justify-content-center">
    <div class="col-lg-6">
eof

    # Event creation form
    # _____________________________________________________
    $toReturn.= <<eof;
      <div class="card border-primary mb-3">
        <div class="card-header"><h3>Authentication Code:</h3></div>
        <div class="card-body">
          <form method="POST">
            <div class="form-group">
              <input type="text" class="form-control" name="auth_code" placeholder="tastyNightmares">
            </div>
            <div class="form-group">
              <button type="submit" name="event_name" value="Coffee Night" class="btn btn-primary">Coffee Night</button>
              <button type="submit" name="event_name" value="Culture Night" class="btn btn-primary">Culture Night</button>
            </div>
            <div class="form-group">
              <div class="card-header">Custom Event:</div>
            </div>
            <div class="input-group">
              <input type="text" class="form-control" name="event_name" placeholder="eg, Ball">
              <button type="submit" class="btn btn-info">Create</button>
            </div>
          </form>
        </div>
      </div>
eof

    # email forms
    # _____________________________________________________
    $toReturn.= <<eof;
      <div class="card border-success mb-3">
        <div class="card-header">
            <h3>Email any unsent forms</h3><br>
            <p>Coffee night attendance will also be extracted from unsent
            "Coffee Night" forms and emailed.</p>
        </div>
        <div class="card-body">
          <form method="POST">
            <div class="form-group">
              <button type="submit" name="email_forms" value="true" class="btn btn-info btn-block">Email Forms</button>
            </div>
          </form>
        </div>
      </div>
eof

    # close off the outer offset divs
    # _____________________________________________________
    $toReturn.= <<eof;
    </div>
  </div>
eof

    return $toReturn;
}

sub not_in_arc_html($$$){

    my ($event_name, $zID, $auth) = @_;

    # Not found in arc
    # _____________________________________________________
    return <<eof;
  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="card border-primary mb-3">
        <div class="card-header"><h3 align="center">Are you a 2019 arc member?</h3></div>
        <div class="card-body">
            <div class="form-group">
              <div class="row justify-content-around">
                <div class="col">
                  <form method="POST">
                    <input type="hidden" name="event_name" value="$event_name">
                    <input type="hidden" name="auth_code" value="$auth">
                    <input type="hidden" name="become_arc_member" value="Yes">
                    <input type="hidden" name="zID_entered" value="$zID">
                    <button type="submit" class="btn btn-success btn-block">Yes</button>
                  </form>
                </div>
                <div class="col">
                  <form method="POST">
                    <input type="hidden" name="event_name" value="$event_name">
                    <button type="submit" class="btn btn-warning btn-block">Not Yet</button>
                  </form>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
eof
}

sub sign_in_form_html($$){

    my ($event_name, $auth) = @_;
    my $toReturn = "";

    # a gap, then an offset to center and 6 for forms
    # _____________________________________________________
    $toReturn.= <<eof;
  <div class="row justify-content-center">
    <div class="col-lg-6">
eof

    my $clean_event = $event_name;
    $clean_event =~ s/_/ /;
    # Event creation form
    # _____________________________________________________
    $toReturn.= <<eof;
      <div class="card border-primary mb-3">
        <div class="card-header"><h3>Enter or Scan your zID</h3></div>
        <div class="card-body">
          <form method="POST">
            <div class="form-group">
              <input type="hidden" name="auth_code" value="$auth">
              <input type="hidden" name="event_name" value="$event_name">
              <input type="hidden" name="sign_in_zID" value="zID">
              <input type="text" autofocus="autofocus" class="form-control" name="zID_entered" placeholder="z1234567">
            </div>
            <div class="form-group"><br>
              <button type="submit" class="btn btn-primary btn-block">Submit</button>
            </div>
          </form>
        </div>
      </div>
eof

    # Manual Entry
    # _____________________________________________________
    $toReturn.= <<eof;
      <div class="card border-info mb-3">
        <div class="card-header"><h3>Make a manual Entry</h3></div>
        <div class="card-body">
          <form method="POST">
            <div class="form-group">
              <input type="hidden" name="event_name" value="$event_name">
              <input type="hidden" name="auth_code" value="$auth">
              <input type="hidden" name="sign_in_manual" value="">
              <input type="text" class="form-control" name="first_name" placeholder="First Name">
            </div>
            <div class="form-group">
              <input type="text" class="form-control" name="last_name" placeholder="Last Name">
            </div>
            <div class="form-group">
              <input type="text" class="form-control" name="zID_entered" placeholder="z1234567">
            </div>
            <div class="form-check">
              <input class="form-check-input" type="checkbox" name="arc_member" value="">
              Are you an Arc Member?
            </div>
            <div class="form-check">
              <input class="form-check-input" type="checkbox" name="remember_me" value="">
              remember me?
            </div>
            <div class="form-group"><br>
              <button type="submit" class="btn btn-info btn-block">Submit</button>
            </div>
          </form>
        </div>
      </div>
eof

    # close off the outer offset divs
    # _____________________________________________________
    $toReturn.= <<eof;
    </div>
  </div>
eof

return $toReturn;
}

1;
