#!/usr/bin/env perl
use JSON;
use DBI;
use DBD::mysql;
use IO::Handle;

my $envFilename = "/home/dotcloud/environment.json";
my ($user , $password, $host, $port);
my $database = 'tomaguestbook';
my $dbh;

if ( -e $envFilename ) {
    # on dotCloud
    open my $fh, "<", $envFilename;
    my $env = JSON::decode_json(join '', <$fh>);

    $user = $env->{DOTCLOUD_DB_MYSQL_LOGIN};
    $password = $env->{DOTCLOUD_DB_MYSQL_PASSWORD};
    $host = $env->{DOTCLOUD_DB_MYSQL_HOST};
    $port = $env->{DOTCLOUD_DB_MYSQL_PORT};
} else {
    # local development environment
    $user = "root";
    $password = "root";
    $host = "localhost";
    $port = "3306";
}

print "Creating database '$database'..";

for($tries = 0; $tries <= 120; $tries++) {
    STDOUT->printflush(".");
    $dbh = DBI->connect("DBI:mysql:hostname=$host;port=$port;", $user, $password, {RaiseError=>0,PrintError=>0});
    last if(defined $dbh);
    sleep(2);
}
print "\n";

$dbh->func('createdb', $database, 'admin');

$dbh = DBI->connect("DBI:mysql:dbname=$database;hostname=$host;port=$port;", $user, $password, {RaiseError=>0,PrintError=>0});
$dbh->do('CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nick` char(20) NOT NULL,
  `message` varchar(300) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8');
