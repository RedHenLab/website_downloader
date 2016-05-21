#!/usr/bin/perl

####################################################################
# website_downloader.pl                                            #
# version 1, 15 May 2016                                           #
# written by Peter Uhrig for the Distributed Little Red Hen Lab    #
####################################################################
# https://sites.google.com/site/distributedlittleredhen/home/tutorials-and-educational-resources/creating-a-website-downloader-in-perl

use LWP::Simple;
use strict;
use Encode;

# Lines above here define a set of options and libraries that are used in this piece of software. Only change them if you know what you are doing.

# Start here with configuration
my $starturl = "http://www.foxnews.com/on-air/hannity/transcripts?page=";
my $startindex = 0;
my $endindex = 2;
my $targetfolder = "transcripts_fox_hannity";
my $beginningoffilename = "transcript_fox_hannity_";
# End of show-specific configuration. For Fox News transcripts, you should not need to change anything below here.

my $urlsearchpattern = qr/      <h3 class="title"><a href="(http:\/\/www\.foxnews\.com\/transcript\/.*?)"/; # The part in brackets defines the URL
# The URL looks like this: http://www.foxnews.com/transcript/2016/05/13/trump-paul-ryan-doing-good-job-uniting-gop-amazon-ceo-using-washington-post-for/
my $fileinformationsearchpattern = qr/transcript\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*?)\/?$/; # This needs to yield year, month, day and title (in this order!). Otherwise, changes are necessary below.

# Create the target folder unless it already exists.
mkdir $targetfolder unless -d $targetfolder;
my $beginningoffilename = $targetfolder."/".$beginningoffilename; # This puts the folder's name into the beginningoffilename variable

for (my $i = $startindex;$i <= $endindex ; $i++) {
	# Let us print the current status so we know what the program is trying to do:
	print "Looking at page No. $i\n"; # The symbol \n stands for a new line
	# The following line downloads the content of $starturl to the variable $startpage:
	my $startpage = get($starturl.$i); # The dot concatenates two items, so in this case it adds whatever value $i currently has (from 0 to 307) to the string given as $starturl above
	# Now $startpage contains the source code of the webpage. Let us now search it for the pattern we identified as pattern above.
	my @transcripturls = $startpage =~ /$urlsearchpattern/g;
	# Now @transcripturls is a list of all the transcript URLs that were found on the startpage. Let us run through this list and do something with each of these URLs:
	foreach my $transcripturl (@transcripturls) {
		# We set the filename variable to the beginning of the filename set above every time we look at a new transcript.
		my $filename = $beginningoffilename;
		# To complete the filename, we will need year, month, day and title. These are found by the pattern described above.
		my ($year, $month, $day, $title) = $transcripturl =~ /$fileinformationsearchpattern/;
		$filename .= $year."-".$month."-".$day."_".$title.".html"; # The operator .= means that all this is concatenated to the variable $filename
		# Now let us check if that file exists already. If so, we inform the user and go to the next transcript:
		if (-e $filename) {
			print "Transcript already there: $filename\n";
			next;
		}
		# Again: Print the status:
		print "Downloading transcript $transcripturl\n";
		# The following line does the actual download:
		my $transcripthtml = get($transcripturl);
		# Now let us print the transcript to file:
		open my $fh, ">:encoding(UTF-8)", $filename or die("Could not open file. $!");
		print $fh $transcripthtml; # This means "print to the file represented by the filehandle $fh the content of the following variable: $transcripthtml"
		close $fh;
	}
}
