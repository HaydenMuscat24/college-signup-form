#!/bin/sh

# --------------Mail out the files

myEmail="theunswhall@gmail.com"
subject="Arc Forms"

# compute coffee night attendance
for file in `ls events`; do
    if [[ $file =~ "Coffee_Night" ]] ; then
        ./cnAttendance.pl "events/$file";
    fi
done

## this is a bloody mess but what can ya do,
## emailing just wouldn't fucking work

if [ `ls events/ | wc -w` -gt 0 ]; then
    cd events
    message="Attached are any new csv files

Old ones are archived. If needed, send an email to hayden.muscat24@gmail.com"
    (cat << eof
$message
eof
for file in `ls` ; do
    uuencode $file $file
done
!
) | /usr/sbin/sendmail -v $myEmail
    cd ..
else
    message="No new csv files to send.

Old ones are archived. If needed, send an email to hayden.muscat@epfl.ch"
    (cat << eof
$message
eof

!
    ) | /usr/sbin/sendmail -v $myEmail
    exit 0
fi

# --------------Move the files to the archive

if [ ! -d "events" ]; then
    exit "wtf have you done"
fi

files=`ls events/`

if [ ! -d "archive" ]; then
    mkdir "archive"
fi

for file in $files; do
    if [ -e "archive/$file" ] ; then
        cat "events/$file" >> "archive/$file"
        rm "events/$file"
    else
        mv "events/$file" "archive/$file"
    fi
done
