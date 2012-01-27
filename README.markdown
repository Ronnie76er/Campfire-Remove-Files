Simply deletes all the files in your campfire rooms.

Requires Ruby 1.8.7 

Usage:

	./campfireremovefiles.rb -s server -t apitoken

where `server` is the name of your campfire server (in the form of name.campfirenow.com) and `apitoken` is the token given to you.  You can get this token by going under the "My Info" link on your campfire page.

The script will print out a list of rooms, and give you a choice of which one to delete from (or all). You can ignore the "peer certificate" warning, it just means that you're not verifying the cert from campfirenow. We'll assume the server is correct.

Sample run:

    $ ./campfireremovefiles.rb -s campfireurl.campfirenow.com -t 1234567890abcdef
    warning: peer certificate won't be verified in this SSL session
	Choose the room you want to delete the files from: 
	1: Test
	2: Test 1
	3: Test 2
	4: All
	? 2
	This will delete all files in the room Test 1!!  Are you sure? (y/n)
	? y
	Deleting test2.txt
	Deleting test1.txt
