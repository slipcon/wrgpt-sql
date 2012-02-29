#!/usr/bin/perl

use DBI;
use File::Basename;

my $dbname = "$ENV{'DATABASE'}";
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname");

sub getTableId
{
  my $round = shift;
  my $table = shift;

  my $qry = $dbh->prepare(qq(
        SELECT tableId FROM tables WHERE tablenum=$table AND round='$round'));
  $qry->execute or die "select";

  my $tableId = ($qry->fetchrow_array())[0];
  $qry->finish;

  if ( "$tableId" eq "" ) {
    $dbh->do(qq(INSERT INTO tables (round, tablenum, broken) VALUES ('$round', $table, false)));

    $qry = $dbh->prepare(qq(
          SELECT tableId FROM tables WHERE tablenum=$table AND round='$round'));
    $qry->execute or die "select";
    $tableId = ($qry->fetchrow_array())[0];
    $qry->finish;
  }

  return $tableId;
}

sub getHandId
{
  my $tableId = shift;
  my $handNum = shift;
  my $timet = shift;

  my $qry = $dbh->prepare(qq(
        SELECT handId FROM hands WHERE tableId=$tableId AND handnum=$handNum));
  $qry->execute or die "select";

  my $handId = ($qry->fetchrow_array())[0];
  $qry->finish;

  if ( "$handId" eq "" ) {
    my $ts = localtime($timet);
    $dbh->do(qq(INSERT INTO hands (tableId, handnum, startTime, endTime, inProgress) VALUES ($tableId, $handNum, '$ts', NULL, true)));

    $qry = $dbh->prepare(qq(
          SELECT handId FROM hands WHERE tableId=$tableId AND handnum=$handNum));
    $qry->execute or die "select";
    $handId = ($qry->fetchrow_array())[0];
    $qry->finish;
  }

  return $handId;
}

sub simplifyCards
{
  my $cards = shift;

  $cards =~ s/10/T/g;

  if ($cards =~ /(.)(.) (.)(.)/)
  {
    $cards = "$1$3";
    if ("$1" ne "$3")
    {
      if ("$2" eq "$4")
      {
        $cards .= "s";
      }
      else
      {
        $cards .= "o";
      }
    }
  }

  return $cards;
}


sub getPlayerId
{
  my $name = shift;
  my %playerIdCache = ();

  if (defined $playerIdCache{$name}) {
    return $playerIdCache{$name};
  }

  my $qry = $dbh->prepare(qq(
        SELECT playerId FROM players WHERE name='$name'));
  $qry->execute or die "select";

  my $playerId = ($qry->fetchrow_array())[0];
  $qry->finish;

  if ( "$playerId" eq "" ) {
    $dbh->do(qq(INSERT INTO players (name, stillPlaying, timeoutCount, eliminated) VALUES ('$name', true, 0, false)));

    $qry = $dbh->prepare(qq(
          SELECT playerId FROM players WHERE name='$name'));
    $qry->execute or die "select";
    $playerId = ($qry->fetchrow_array())[0];
    print "Added player $name as ID $playerId\n";
    $qry->finish;
  }

  $playerIdCache{$name} = $playerId;
  return $playerId;
}

sub trim
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}



my $hist_filepath = $ARGV[0];
my ($hist_filename, $junk, $junk)  = fileparse($hist_filepath);

$hist_filename =~ /(\D)(\d+)\.history/ or
       die "$hist_filename doesn't appear to be a history filename";
my $round = $1;
my $table = $2;

print "round: $round\n";
print "table: $table\n";

my $tableId = getTableId( $round, $table );

print "tableId = $tableId\n";

my $current_hand = 0;
my $prevTime = 0;
my $handId = -1;
my %playerHandCache = ();

open(HISTORY, $ARGV[0]) or die "can't open input: $ARGV[0]";
while (<HISTORY>)
{
  chomp;
  if ((/Table Broken/) ||
      (/Table finished, waiting to redraw seats/) ||
      (/All tables finished, waiting for redraw/)) {
    $dbh->do(qq(UPDATE tables SET broken=true WHERE tableid=$tableId));
    next;
  }

  my ($timet, $handnum, $actionnum, $actiontxt) = split(/:/, $_, 4);

  if ($prevTime == 0)
  {
    $prevTime = $timet;
  }

  if ($current_hand != $handnum) 
  {
    $current_hand = $handnum;

    $handId = getHandId( $tableId, $handnum, $timet );
    print "new hand: $current_hand, handId=$handId\n";
    
    # reset the player hand cache
    %playerHandCache = ();
  }

  next if ($actiontxt =~ /^! .* is back from vacation$/);
  next if ($actiontxt =~ /^! .* went on vacation until/);
  next if ($actiontxt =~ /^! Dealing a new hand$/);
  next if ($actiontxt =~ /^! Game resumes$/);
  next if ($actiontxt =~ /^! No ante$/);
  next if ($actiontxt =~ /^! .* blinds \$(\d+)$/);
  next if ($actiontxt =~ /^! .* blinds \$(\d+) and is all in$/);
  next if ($actiontxt =~ /^! Pot right.*, flopping\/dealing\/drawing cards$/);
  next if ($actiontxt =~ /^! Flopped card/);
  next if ($actiontxt =~ /^! (\d+) players$/);
  next if ($actiontxt =~ /^! (\d+) players, (\d+) all in$/);
  next if ($actiontxt =~ /^! Hand over, no showdown/);
  next if ($actiontxt =~ /^! Pot (\d+): uncalled \$(\d+) returned to/);
  next if ($actiontxt =~ /^! Pot (\d+): .* wins \$(\d+) with/);
  next if ($actiontxt =~ /^! .* wins \$(\d+) \(net \$(\d+)\)/);
  next if ($actiontxt =~ /^! (\d+) players left in the tournament/);
  next if ($actiontxt =~ /^! A new hand will be dealt shortly/);
  next if ($actiontxt =~ /^! Game has been protested by/);
  next if ($actiontxt =~ /^! No further bets accepted until floorman rules on protest./);
  next if ($actiontxt =~ /^! Timeouts are disabled./);
  next if ($actiontxt =~ /^! Player cancelled protest./);
  next if ($actiontxt =~ /^! Protest resolved./);
  next if ($actiontxt =~ /^! Antes and blinds go up/);
  next if ($actiontxt =~ /^! .* resigned from the game/);
  next if ($actiontxt =~ /^! Table waiting for live reshuffle/);
  next if ($actiontxt =~ /^! Game delayed for 24 hours\(max\)/);
  next if ($actiontxt =~ /^! Waiting to deal new hand until tomorrow$/);
  next if ($actiontxt =~ /^! Everyone antes/);
  next if ($actiontxt =~ /^! Everyone else antes/);
  next if ($actiontxt =~ /^! .* antes .* and is all in/);
  next if ($actiontxt =~ /^! .* is all in and does not blind/);

  if ($actiontxt =~ /^! Hand over, current board is:\s+(.+)/)
  {
    print "hand over - board - $1\n";
    $dbh->do(qq(UPDATE hands SET board='$1' WHERE handid=$handId));
    next;
  }

  if ($actiontxt =~ /^! Current board is:\s+(.+)/)
  {
    print "hand over - board - $1\n";
    $dbh->do(qq(UPDATE hands SET board='$1' WHERE handid=$handId));
    next;
  }

  if ($actiontxt =~ /^!\s+(.*)\s+(?:has:|reveals)\s+(.+)$/)
  {
    my $player = trim($1);
    print "player \"$player\" - cards \"$2\"\n";
    my $playerId = getPlayerId( $player );
    my $cards = $2;
    my $showdown = "true";
    if ($actiontxt =~ /reveals/)
    {
      $showdown = "false";
    }
    my $simpleCards = simplifyCards( $cards );

    $dbh->do(qq(UPDATE playerhands SET cards='$cards',simplecards='$simpleCards',showdown='$showdown' WHERE playerId=$playerId AND handid=$handId));
    next;
  }

  # these three identify table talk, hopefully
  next if ($actiontxt =~ /^\%/);
  next if ($actiontxt =~ /^! -- /);
  next if ($actiontxt =~ /^____________/);

  if ($actiontxt =~ /^! (.+) is eliminated\!/)
  {
    $dbh->do(qq(UPDATE players SET eliminated=true WHERE name='$1'));
    $dbh->do(qq(UPDATE players SET stillPlaying=false WHERE name='$1'));
    next;
  }


  if ($actiontxt =~ /^! (.+) timed out during this hand/)
  {
    $dbh->do(qq(UPDATE players SET timeoutCount=timeoutCount+1 WHERE name='$1'));
    next;
  }

  my $player;
  if ($actiontxt =~ /^! (.+) is on vacation and folds/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) is on vacation and checks/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) folds$/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) checks$/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) calls/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) raises \$(\d+)/) { $player = $1; }
  elsif ($actiontxt =~ /^! (.+) bets \$(\d+)/) { $player = $1; }
  elsif ($actiontxt =~ /ENDOFHAND/) { } # do nothing, catch this case later
  else { print "LOG: unparsed action \"$actiontxt\"\n"; }

  my $ts = localtime($timet);
  if ($actiontxt =~ /ENDOFHAND/)
  {
    print "end hand: $current_hand, handId=$handId\n";
    $dbh->do(qq(UPDATE hands SET inProgress=false, endTime='$ts' WHERE handId=$handId));
  }
  else
  {
    #print "LOG: getting playerid for \"$player\" for action \"$actiontxt\"\n";
    my $playerId = getPlayerId( $player );
    my $deltaT = $timet - $prevTime;
    $dbh->do(qq(INSERT INTO moves (playerid, handid, moveTime, wait) VALUES ($playerId, $handId, '$ts', '$deltaT s')));


    if (!defined $playerHandCache{$playerId}) {
      $dbh->do(qq(INSERT INTO playerhands (playerid, handid) VALUES ($playerId, $handId)));
      $playerHandCache{$playerId} = 1;
    }

  }

  $prevTime = $timet;
}
close(HISTORY);

