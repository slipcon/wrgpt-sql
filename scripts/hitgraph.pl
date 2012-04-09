#!/usr/bin/perl -w

use DBI;
use File::Basename;
use POSIX;

my $dbname = "$ENV{'DATABASE'}";
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname");

my $average = 30000;

sub getAverage
{
  my $qry = $dbh->prepare(qq(
        SELECT avg(bankroll) FROM standings;));
  $qry->execute or die "select";

  $average = ($qry->fetchrow_array())[0];
}


sub getPlayers
{
  my $qry = $dbh->prepare(qq(
        SELECT p.name, p.playerid, p.stillplaying, p.eliminated, s.bankroll FROM players p left join standings s on p.playerid=s.playerid;));
  $qry->execute or die "select";

  while (my @row = $qry->fetchrow_array())
  {
    (my $name, my $id, my $stillplaying, my $eliminated, my $bankroll) = @row;

    if (! defined( $bankroll))
    {
      $bankroll = 0;
    }

    my $color="black";
    if ($eliminated == 1)
    {
      $color = "red";
    }

    my $fontsize="14.0"; # default

    my $ratio = ($bankroll / $average);
    if ($ratio < 0.50)
    {
      $fontsize = "10.0";
    }
    elsif ($ratio < 1.0)
    {
      $fontsize = "12.0";
    }
    elsif( $ratio < 2.0)
    {
      $fontsize = "14.0";
    }
    else
    {
      my $mult = floor($ratio);

      $fontsize = 14.0 + 8.0*$mult;
    }


    #if ($bankroll > 400000)
    #{
      #$fontsize="36.0";
    #}
    #elsif ($bankroll > 300000)
    #{
      #$fontsize="30.0";
    #}
    #elsif ($bankroll > 200000)
    #{
      #$fontsize="26.0";
    #}
    #elsif ($bankroll > 150000)
    #{
      #$fontsize="20.0";
    #}
    #elsif ($bankroll > 100000)
    #{
      #$fontsize="18.0";
    #}
    #elsif ($bankroll > 50000)
    #{
      #$fontsize="14.0";
    #}
    #else
    #{
      #$fontsize="10.0";
    #}

    if ($stillplaying == 1 || $eliminated == 1)
    {
      print "\tP" . $id . " [color=" . $color . " label=\"" . $name . "\" fontsize=\"" . $fontsize . "\"];\n";
    }

  }
  $qry->finish;
}

sub checkElims
{
  my $qry = $dbh->prepare(qq(
        select p.name from players p left join eliminations e on p.playerID = e.playerId where p.eliminated=true AND e.playerId is null;));
  $qry->execute or die "select";

  my $count = 0;
  while (my @row = $qry->fetchrow_array())
  {
    $count++;
  }

  $qry->finish;

  if ($count != 0)
  {
    print STDERR "Error - missing eliminations, update finish-setup.sql\n";
    exit 0;
  }

}

sub getHits
{
  my $qry = $dbh->prepare(qq(
        SELECT playerid,hitman FROM eliminations;));
  $qry->execute or die "select";

  while (my @row = $qry->fetchrow_array())
  {
    (my $id, my $hitman) = @row;

    print "\tP" . $hitman . " -> P" . $id . ";\n";

  }
  $qry->finish;
}

checkElims();
getAverage();

print "digraph G {\n";

getPlayers();
getHits();

print "}\n";



