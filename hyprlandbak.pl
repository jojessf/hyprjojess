#!/usr/bin/perl
use Sys::Hostname;
use Getopt::Lazier;
use File::Path qw(make_path);
use File::Copy qw(copy move);

my ($opt, @DARG) = Getopt::Lazier->new(@ARGV);

$opt->{host} //= hostname;
$opt->{bakroot} //= "/nu/inf/hypr/hyprjojess/".$opt->{host}."/";
mkdir($opt->{bakroot}) if ! -d $opt->{bakroot};
$opt->{indir} //= $ENV{HOME};
$opt->{bakfils} //= "\.conf,\.jsonc,\.css,\.xml";
$opt->{bakstamp} //= `date +"%Y%m%d%H%M%S"`;
chomp($opt->{bakstamp});

chdir($opt->{indir}) or die "no indir " . __LINE__ . "\n";
FI: while(<*>) {
   my $skip = 1;
   foreach my $extnsn (split(",", $opt->{bakfils})) {
      $skip = 0 if m/$extnsn$/;
   }
   next FI if $skip;
   my $fi = $_;
   my $fipath = readlink($_);
   my $fidir  = $fipath;
      $fidir =~ s/^(.*\/).*?$/$1/;
      $fidir =~ s/^$ENV{HOME}\///g;
      $fipath =~ s/^$ENV{HOME}\///g;
   next FI if ! -l $_;
   print "FI:" . $fi . "\t". $fipath . "\n";   
   print "MKDIR ".$opt->{bakroot} . $fidir . "\n";
   make_path($opt->{bakroot} . $fidir);
   die if ! -d $opt->{bakroot} . $fidir;
   print "COPY $fipath, ".$opt->{bakroot}.$fipath . "\n";
   copy($fipath, $opt->{bakroot}.$fipath) or do {
      print "ERROR, next\n";  
   };
}

chdir($opt->{bakroot}) or die;
chdir("../") or die;
system("zip -r ".$opt->{host}.".".$opt->{bakstamp}.".zip ".$opt->{bakroot} );
mkdir("bak");
move($opt->{host}.".".$opt->{bakstamp}.".zip", "bak/");
