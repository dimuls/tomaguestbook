package Toma::Model;

use v5.12.4;
use utf8;

use Exporter::Easy (
  EXPORT => [qw( add_message get_messages_page )],
);

use Toma::Config;
use DBIx::Connector;

use constant MESSAGES_PER_PAGE => 5;

my $conn = DBIx::Connector->new(
  "dbi:mysql:dbname=$cfg->{'db.scheme'};host=$cfg->{'db.host'};port=$cfg->{'db.port'};",
  $cfg->{'db.login'},
  $cfg->{'db.password'},
);

sub _get_dbh() {
  my $connected = $conn->connected;
  my $dbh = $conn->dbh;
  unless( $connected ) {
    $dbh->{'mysql_enable_utf8'} = 1;
    $dbh->do('SET NAMES utf8');
  }
  return $dbh;
}

sub add_message($$) {
  my ( $name, $message ) = @_;
  my $dbh = _get_dbh;
  $name = 'Аноним' if $name eq '';
  $dbh->do('INSERT INTO messages(name, message) VALUES(?, ?)', undef, $name, $message);
}

sub get_messages_page($) {
  my $page = $_[0] || 1;
  my $dbh = _get_dbh;
  my $events_count = $dbh->selectrow_array('SELECT COUNT(*) FROM messages');
  my $pages_count = int (($events_count / MESSAGES_PER_PAGE) + 0.99);
  my $skip = MESSAGES_PER_PAGE * ($page - 1);
  my $limit = MESSAGES_PER_PAGE;
  return
    $dbh->selectall_arrayref("SELECT id, DATE_FORMAT(date, '%H:%i %d.%m.%Y') AS date, name, message FROM messages ORDER BY id DESC LIMIT $skip, $limit", { Slice => {} }),
    $pages_count,
    $page
}

1;
