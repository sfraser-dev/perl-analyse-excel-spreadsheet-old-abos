#!/usr/bin/perl -w

# runs with Strawberry Perl: http://strawberryperl.com/

# Copy and paste the SquadNotes sheet "date, GBP and comments" to a new spreadsheet
# Save this spreadsheet as a CSV file with the following options
# file -> save as -> csv (edit filter settings, text csv format, ... 
# ... character set Western Europe, field delimiter :, Text delimiter ", ...
# ... save cell contents as shown, quote all text cells)

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
my $formattedFile;

$folderToAnalyse = "F:\\dev\\abosSpreadsheet";
checkFolderExists($folderToAnalyse) ? 1 : exit;

# find "sheet.txt" from the folder (and its sub-folders) to analyse
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
        my @paymentsCash;
        my @paymentsDate;
        my @miscs;
        my @miscsCash;
        my @miscsDate;
        my @referees;
        my @refereesCash;
        my @refereesDate;
        my @pitches;
        my @pitchesCash;
        my @pitchesDate;
        my @refunds;
        my @refundsCash;
        my @refundsDate;
        my @fundraisings;
        my @fundraisingsCash;
        my @fundraisingsDate;
        my @facilities;
        my @facilitiesCash;
        my @facilitiesDate;
        foreach my $line (@afile){
            # ignore lines that are just whitespace
            ($line =~ /^\s*$/) ? next : 1;

            # payments 
            if ($line =~ /\"Abo payment/) {
                # split at ":"
                my @cols = split /:/, $line;
                push @payments, $cols[2];
                push @paymentsCash, $cols[1];
                push @paymentsDate, $cols[0];
            }
            
            # miscelleneous spend
            if ($line =~ /\"Miscellaneous spend/) {
                # split at ":"
                my @cols = split /:/, $line;
                push @miscs, $cols[2];
                push @miscsCash, $cols[1];
                push @miscsDate, $cols[0];
            }
            
            # referees
            if ($line =~ /\"Referee /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @referees, $cols[2];
                push @refereesCash, $cols[1];
                push @refereesDate, $cols[0];
            }
            
            # pitches
            if ($line =~ /\"Pitch /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @pitches, $cols[2];
                push @pitchesCash, $cols[1];
                push @pitchesDate, $cols[0];
            }
            
            # refunds
            if ($line =~ /\"Refund /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @refunds, $cols[2];
                push @refundsCash, $cols[1];
                push @refundsDate, $cols[0];
            }
            
            # fundraising
            if ($line =~ /\"Fundraising /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @fundraisings, $cols[2];
                push @fundraisingsCash, $cols[1];
                push @fundraisingsDate, $cols[0];
            }
            
            # facilities
            if ($line =~ /\"Facility /) {
                # split at ":"
                my @cols = split /:/, $line;
                push @facilities, $cols[2];
                push @facilitiesCash, $cols[1];
                push @facilitiesDate, $cols[0];
            }
        }

        my $paymentsSum = 0; 
        my $miscsSum = 0; 
        my $refereesSum = 0; 
        my $pitchesSum = 0; 
        my $refundsSum = 0; 
        my $fundraisingsSum = 0; 
        my $facilitiesSum = 0; 

        # remove the filename extension and rename
        ($formattedFile = $file) =~ s/\.[^.]+$//;
        $formattedFile= $formattedFile."Formatted.txt";
        # write formatted information to file
        open(my $fh, '>', $formattedFile) or die "Could not open file '$formattedFile' $!";


        printf $fh "\n";
        printf $fh "********** Payments from Abos **********\n";
        for(my $i=0; $i<scalar(@payments); $i++){
            $paymentsSum += $paymentsCash[$i];
            chomp $payments[$i];
            printf $fh ("%-10d %-10.2f %s\n", $paymentsDate[$i], $paymentsCash[$i], $payments[$i]);
        }
        printf $fh "Total payments from Abos = £$paymentsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Miscellaneous Spends **********\n";
        for(my $i=0; $i<scalar(@miscs); $i++){
            $miscsSum += $miscsCash[$i];
            chomp $miscs[$i];
            printf $fh ("%-10d %-10.2f %s\n", $miscsDate[$i], $miscsCash[$i], $miscs[$i]);
        }
        printf $fh "Total miscelleneous spends= £$miscsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Referee costs **********\n";
        for(my $i=0; $i<scalar(@referees); $i++){
            $refereesSum += $refereesCash[$i];
            chomp $referees[$i];
            printf $fh ("%-10d %-10.2f %s\n", $refereesDate[$i], $refereesCash[$i], $referees[$i]);
        }
        printf $fh "Total referee costs = £$refereesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Pitch costs **********\n";
        for(my $i=0; $i<scalar(@pitches); $i++){
            $pitchesSum += $pitchesCash[$i];
            chomp $pitches[$i];
            printf $fh ("%-10d %-10.2f %s\n", $pitchesDate[$i], $pitchesCash[$i], $pitches[$i]);
        }
        printf $fh "Total pitch costs = £$pitchesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Refunds **********\n";
        for(my $i=0; $i<scalar(@refunds); $i++){
            $refundsSum += $refundsCash[$i];
            chomp $refunds[$i];
            printf $fh ("%-10d %-10.2f %s\n", $refundsDate[$i], $refundsCash[$i], $refunds[$i]);
        }
        printf $fh "Total refunds = £$refundsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Fundraising **********\n";
        for(my $i=0; $i<scalar(@fundraisings); $i++){
            $fundraisingsSum += $fundraisingsCash[$i];
            chomp $fundraisings[$i];
            printf $fh ("%-10d %-10.2f %s\n", $fundraisingsDate[$i], $fundraisingsCash[$i], $fundraisings[$i]);
        }
        printf $fh "Total fundraisings = £$fundraisingsSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Facilities **********\n";
        for(my $i=0; $i<scalar(@facilities); $i++){
            $facilitiesSum += $facilitiesCash[$i];
            chomp $facilities[$i];
            printf $fh ("%-10d %-10.2f %s\n", $facilitiesDate[$i], $facilitiesCash[$i], $facilities[$i]);
        }
        printf $fh "Total cost for facilities = £$facilitiesSum\n";

        printf $fh "\n";
        printf $fh "\n";
        printf $fh "********** Summary **********\n";
        printf $fh "Total payments from Abos = £$paymentsSum\n";
        printf $fh "Total miscelleneous spends= £$miscsSum\n";
        printf $fh "Total referee costs = £$refereesSum\n";
        printf $fh "Total pitch costs = £$pitchesSum\n";
        printf $fh "Total refunds = £$refundsSum\n";
        printf $fh "Total fundraisings = £$fundraisingsSum\n";
        printf $fh "Total cost for facilities = £$facilitiesSum\n";

        # close the file
        close $fh;
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
