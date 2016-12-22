#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

use strict;
use warnings;
use feature qw(say);
use File::Find; 
use File::Basename;
use Cwd;
use POSIX qw(floor);
use File::Slurp;
use utf8; # need to be able to handle the UK "£" symbol

my @contentFile;
my $name;
my $fileDir;
my $ext;
my $filePath;
my $fileName;
my $folderToAnalyse;
my $fullPathname;
my @splitter;
my $poundSign = chr(156);
my $newfile;

$folderToAnalyse = "F:\\dev\\abosSpreadsheet";
checkFolderExists($folderToAnalyse) ? 1 : exit;

# find all the txt files from the folder (and its sub-folders) to analyse
say "\n\n\n******* sheet.txt *******\n\n";
find( \&fileWanted, $folderToAnalyse); 
analyseFiles(\@contentFile);

exit;

sub analyseFiles {
    # expect one argument
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # input array argument passed by reference, de-reference it
    my @foundProjFiles = @{$_[0]};
    my @arrOfProjFilePaths;

    foreach my $found (@foundProjFiles) {
        # get filename, directory and extension of the found video
        ($name,$fileDir,$ext) = fileparse($found,'\..*');
        $fileDir =~ s/\//\\/g;
        $filePath="$fileDir";
        $fileName="$name$ext";
        chomp $filePath;
        chomp $fileName;
        $fullPathname = $filePath.$fileName;

        push(@arrOfProjFilePaths, $fullPathname);
    }

    foreach my $file (@arrOfProjFilePaths) {
        my @afile = read_file($file);
        my @payments;
        my @miscs;
        my @referees;
        my @pitches;
        my @refunds;
        foreach my $line (@afile){
            # ignore lines that are just whitespace
            ($line =~ /^\s*$/) ? next : 1;

            # payments 
            if ($line =~ / payment/) {
                # split at "£" (use utf8)
                my @quids = split /£/, $line;
                # split at spaces " "
                my @spaces = split / /, $quids[1];
                push @payments, $spaces[0];
            }

#
#
#
#
# TODO: split Misc. into paid and received on spreadsheet
#
#
#
            # miscelleneous
            if ($line =~ /Misc\./) {
                # split at "£" (use utf8)
                my @quids = split /£/, $line;
                my @spaces = split / /, $quids[1];
                push @miscs, $spaces[0];
            }
            
            # referees
            if ($line =~ / referee/) {
                # split at "£" (use utf8)
                my @quids = split /£/, $line;
                my @spaces = split / /, $quids[1];
                push @referees, $spaces[0];
            }

            # pitches
            if ($line =~ / pitch/) {
                # split at "£" (use utf8)
                my @quids = split /£/, $line;
                my @spaces = split / /, $quids[1];
                push @pitches, $spaces[0];
            }
            
            # refunds
            if ($line =~ / refund/) {
                # split at "£" (use utf8)
                my @quids = split /£/, $line;
                my @spaces = split / /, $quids[1];
                push @refunds, $spaces[0];
            }
        }
        #foreach my $payment (@payments){
        #    say $payment;
        #}
        #foreach my $misc (@miscs){
        #    say $misc;
        #}
        #foreach my $referee (@referees){
        #    say $referee;
        #}
        #foreach my $pitch (@pitches){
        #    say $pitch;
        #}
        foreach my $refund (@refunds){
            say $refund;
        }
        # remove the filename extension and rename
        ($newfile = $file) =~ s/\.[^.]+$//;
        $newfile = $newfile."New.txt";
        # write the concatenated array to file
        #open(my $fh, '>', $newfile) or die "Could not open file '$newfile' $!";
        #foreach my $line (@dates){
        #    print $fh $line;
        #}
        #close $fh;
    }
}

sub fileWanted {
    # expect zero arguments
    if (@_ != 0){
        say "Error on line: ".__LINE__;
        exit;
    }
    if ($File::Find::name =~ /sheet\.txt$/){
        push @contentFile, $File::Find::name;
    }
    return;
}

sub checkFolderExists {
    if (@_ != 1){
        say "Error on line: ".__LINE__;
        exit;
    }
    # pass folder name as first argument to this function
    my $folderName = $_[0];
    if (-d $folderName){
        #say "$folderName exists, continuing ...";
        return 1;
    }
    else {
        say "Error: folder '$folderName' doesn't exist";
        return 0;
    }
}

