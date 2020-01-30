# college-signup-form

## How it works

The website is just a cgi script in perl, which you access by just going to the location of the file as if its a website. The perl file is run, and it spits out all the relevant html depending on what variables it recieves. It works by storing local files as necessary, and is hardly the best way to achieve all this. It was co-opted from a 2nd year university assignment. Feel free to use something modern instead.

## Setting up:

After downloading:
- Make sure the permissions on parent directories and files are correct such that the cgi script can be accessed and run (thus accesible as a web page)
- This code expects a csv file named zIDFile.csv of the form: firstName,secondName,zID,roomNumber
- Change the code with which you want to require to create events in AuthCode.pm

Feel free to copy and change whatever code you want, and email me if you want any help.
