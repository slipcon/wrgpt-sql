#!/usr/bin/perl -w

use strict;
use XML::Simple;
use Data::Dumper;
use File::stat;
use DBI;

#require 'stats.pl';

chdir("$ENV{'DATADIR'}");
my $xmlfilename = "standings.xml";
my $elimfilename = "eliminations.xml";

my $dbname = "$ENV{'DATABASE'}";
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname");

my $sb = stat($xmlfilename);

my $standings = XMLin( $xmlfilename, ForceArray => [ 'oldtable' ] );
my $eliminations = XMLin( $elimfilename, SuppressEmpty => "" );

#print Dumper($standings);
#print Dumper($eliminations);

my $hashref = $standings->{player};
foreach my $key (keys %$hashref)
{
  my $playername = $key;
  my $table = $standings->{player}->{$key}->{table};
  my $chips = $standings->{player}->{$key}->{bankroll};
  my $highchips = $standings->{player}->{$key}->{highbankroll};
  my $lowchips = $standings->{player}->{$key}->{lowbankroll};

  if ($table =~ /(\w)(\d+)/)
  {
    my $round = $1;
    my $tableNumber = $2;

    $dbh->do(qq(INSERT INTO standings (playerId, tableId, bankroll, highbankroll, lowbankroll) SELECT p.playerId, t.tableId, $chips, $highchips, $lowchips FROM players p, tables t WHERE p.name='$playername' and t.round='$round' AND t.tablenum=$tableNumber));
  }
}

my $elimref = $eliminations->{elimination};
foreach my $key (keys %$elimref)
{
  my $playername = $key;
  my $hitman = $eliminations->{elimination}->{$key}->{hitman};

  print "player $playername eliminated by $hitman\n";

  $dbh->do(qq(INSERT INTO eliminations (playerId, hitman) SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='$playername' AND p2.name='$hitman'));
}
