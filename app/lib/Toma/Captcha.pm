package Toma::Captcha;

use v5.12.4;
use utf8;

use Exporter::Easy (
  EXPORT => [qw(generate_captcha check_captcha)],
);

use constant CAPTCHA_LENGTH => 6;

use Authen::Captcha;

my $ch = Authen::Captcha->new(
  data_folder => './data/captcha',
  output_folder => './public/captcha',
#  height => 2,
);

sub generate_captcha() {
  return $ch->generate_code(CAPTCHA_LENGTH);
}

sub check_captcha($$) {
  my( $md5sum, $captcha ) = @_;
  return $ch->check_code($captcha, $md5sum) > 0 ? 1 : 0;
}
