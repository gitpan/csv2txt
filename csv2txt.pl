#!/usr/bin/perl
# Require Perl5
#
# csv2txt -- CSV to text
#
# by SANFACE Software <sanface@sanface.com> 5 July 2002
#
# csv2txt version 1.0
#
# TODO
# alignment: center, left, right for columns and rows
# decimal e.g. 0.00 for columns and rows
# repeat the first line at the begin of every new page
# module
#
use strict;
use warnings;
use Getopt::Long;
use File::DosGlob 'glob';
my $version="1.0";
my $producer="csv2txt";
my $companyname="SANFACE Software";
my $SANFACEmail="mailto:sanface\@sanface.com";
my $csv2txtHome="http://www.sanface.com/$producer.html";

my ($i,$j,$help,$verbose,$Version,$landscape,$center);
my $delimiter=";";
my $addblanks=1;
my $alignment="left";
my ($workbook,$worksheet,$numformat,$format,$formatpercent,$decimal);
my $headings="center";

&GetOptions("help"           => \$help,
	    "delimiter=s"    => \$delimiter,
	    "addblanks=s"    => \$addblanks,
	    "alignment=s"    => \$alignment,
            "current"        => \$Version,
	    "decimal=s"      => \$decimal,
            "verbose"        => \$verbose) || printusage() ;

if($Version) {print "$producer $version\n$csv2txtHome\nDeveloped by $companyname\n$SANFACEmail\n";exit;}
$help and printusage();
if ($alignment !~ /left|right|center/i) {print "Warning $alignment is not right or left or center.\n The program will use the default left\n"; $alignment="left";}
if ($addblanks < 0) {print "Warning $addblanks is not an integer.\n The program will use the default 1\n"; $addblanks=1;}

$verbose and print qq!Delimiter: "$delimiter"\nNumber of blanks to add to the end of every cell: $addblanks\nDecimal Format : $decimal\nAlignment : $alignment\n!;

if (@ARGV) {
  my @files;
  my ($i,$input,$output);

  if ($^O =~ /^MSWin32$/i) {
    foreach $i (@ARGV) {
      if($i=~/\*|\?/) {push @files,glob($i)}
      else {push @files,$i}
      }
    }
  else {@files = @ARGV}
  foreach $input (@files) {
    my (@fields,@word);
    $output = $input . ".txt";
    $verbose and print "Processing $input file\n";
    open (IN, "$input") || die "$producer: couldn't open input file $input\n";
    open (OUT, ">$output") || die "$producer: couldn't open input file $output\n";

    while (<IN>)
      {
      s/\n//;
      s/\r//;
      push @fields, [split/$delimiter/];
      }

    for ($j=0;$j<=$#{$fields[0]};$j++) {
      $word[$j]=length($fields[0][$j])
      }
  
    for ($i=0;$i<=$#fields;$i++) {
      for ($j=0;$j<=$#{$fields[$i]};$j++) {
        if ($i eq 0) {next}
        else {
          if (length($fields[$i][$j])>$word[$j]) {$word[$j]=length($fields[$i][$j])}
        }
      }
    }
    
    $decimal.="f";
    my ($leftchars,$rightchars);
    for ($i=0;$i<=$#fields;$i++) {
      for ($j=0;$j<=$#{$fields[$i]};$j++) {
	if ($decimal) {
	  if ($fields[$i][$j]  =~ /\d+\.\d+$/) {
	    $fields[$i][$j]=sprintf("%.$decimal", $fields[$i][$j]);
	  }
	}
	if ($alignment eq "left") {
	  $fields[$i][$j].=" " x ($word[$j]-length($fields[$i][$j]) + $addblanks)
          }
	if ($alignment eq "right") {
	  $fields[$i][$j]= " " x ($word[$j]-length($fields[$i][$j])+$addblanks) . $fields[$i][$j]
          }
	if ($alignment eq "center") {
 	  $rightchars = ($word[$j]-length($fields[$i][$j])+$addblanks)/2 + ($word[$j]-length($fields[$i][$j])+$addblanks)%2*0.5;
 	  $leftchars = $word[$j]-length($fields[$i][$j])+$addblanks-$rightchars;
	  $fields[$i][$j]= " " x $leftchars . $fields[$i][$j] . " " x $rightchars;
          }
	print OUT "$fields[$i][$j]";
        }
      print OUT "\n";
      }
    $verbose and print "Writing $output file\n";
    close(IN);
    close(OUT);
    }
  }

sub printusage {
    print <<USAGEDESC;

usage:
        $producer [-options ...] list

where options include:
    -help                        print out this message
    -delimiter char              the delimiter for your csv (default ";")
    -addblanks number            number of blanks to add to end of every cell
                                 (default 1)
    -current                     the program version
    -decimal			 Decimal format
    -alignment right|left|center left is the default
    -verbose                     verbose

list:
    with list you can use metacharacters and relative and absolute path name

example:
    $producer -delimiter : *.txt

If you want to know more about this tool, you might want
to read the docs. They came together with $producer or
visit $csv2txtHome

USAGEDESC
    exit(1);
}

exit 0;

# __END__

=head1 NAME

CSV2TXT - Version 1.0 5th July 2002

=head1 DESCRIPTION

CSV2TXT  is a very flexible and powerful PERL5 program.
It's a converter from csv files to text files.  

=head1 SYNOPSIS

Syntax : csv2txt [-options] files

=head1 Features

Some  feature  of CSV2TXT includes :

 o the possibility to select the csv delimiter
 o the possibility to set global alignment (left, right, center)
 o the possibility to set global decimal format

=head1 Options

where options include:

    -help                        print out this message
    -delimiter char              the delimiter for your csv (default ";")
    -addblanks number            number of chars to add to every column
                                 (default 1)
    -current                     the program version
    -decimal			 Decimal format
    -alignment right|left|center left is the default
    -verbose                     verbose

list:

   with list you can use metacharacters and relative and absolute path 
   name
 
  csv2txt -a center -decimal 2 -delimiter ":" *.csv

Every file of the list is converted in a text file. The final text file
name will be the cvs file name + .txt extension.

Remember: you can fin the last release and the last documentation at
http://www.sanface.com/csv2txt.htm

=head1 AUTHOR

     SANFACE Software sanface@sanface.com
     http://www.sanface.com/

=head1 COPYRIGHT

� SANFACE Software

All Rights Reserved. This program is free software. It may be used,
redistributed and/or modified under the same terms as Perl itself.

=cut
