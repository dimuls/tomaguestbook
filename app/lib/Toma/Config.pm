package Toma::Config;

use v5.12.4;
use utf8;

use Exporter::Easy (
  EXPORT => [qw( $cfg cfg )],
);

use JSON;

my $cloud_env_file = "/home/dotcloud/environment.json";

our $cfg = {
  'db.scheme'   => 'toma_guestbook',
  'db.login'    => 'toma',
  'db.password' => '',
  'db.host'     => '127.0.0.1',
  'db.port'     => 3306,
  'http.host'   => '*',
  'http.port'   => 3000,
  'app.name'    => 'tomaguestbook',
};

if ( -e $cloud_env_file ) {
  open my $fh, "<", $cloud_env_file or die $!;
  my $env = JSON::decode_json(join '', <$fh>);
  $cfg->{'db.scheme'  } = 'tomaguestbook';
  $cfg->{'db.user'    } = $env->{DOTCLOUD_DB_MYSQL_LOGIN};
  $cfg->{'db.password'} = $env->{DOTCLOUD_DB_MYSQL_PASSWORD};
  $cfg->{'db.host'    } = $env->{DOTCLOUD_DB_MYSQL_HOST};
  $cfg->{'db.port'    } = $env->{DOTCLOUD_DB_MYSQL_PORT};
  $cfg->{'http.port'  } = $env->{PORT_WWW};
  $cfg->{'app.name'   } = $env->{DOTCLOUD_PROJECT};
}

sub cfg($) {
  return $cfg->{$_[0]};
}

1;
