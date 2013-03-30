#!/usr/bin/env perl

use v5.12.4;
use utf8;

use lib './lib';

use Mojolicious::Lite;

use Toma::Config;
use Toma::Model;
use Toma::Captcha;

app->config(
  hypnotoad => {
    listen => ["http://$cfg->{'http.host'}:$cfg->{'http.port'}"]
  }
);

get '/' => sub {
  my ( $self ) = @_;
  my ($messages, $pages_count, $page) = get_messages_page(1);
  $self->stash(
       messages => $messages,
    pages_count => $pages_count,
           page => $page,
  );
  $self->render('index');
};

get '/captcha' => sub {
  my ( $self ) = @_;
  my $session = $self->session;
  $session->{captcha_md5} = generate_captcha() unless defined $session->{captcha_md5};
  $self->render(text => "/captcha/$session->{captcha_md5}.png");
};

get '/captcha/update' => sub {
  my ( $self ) = @_;
  my $session = $self->session;
  $session->{captcha_md5} = generate_captcha();
  $self->render(text => "/captcha/$session->{captcha_md5}.png");
};

get '/page/:page' => sub {
  my ( $self ) = @_;
  my $page = $self->param('page') || ''; 
  $self->redirect_to('/') and return unless $page =~ /^\d+$/ and $page > 0;
  my ($messages, $pages_count) = get_messages_page($page);
  $self->stash(
       messages => $messages,
    pages_count => $pages_count,
           page => $page,
  );
  $self->render('index');
};

post '/message' => sub { 
  my ( $self ) = @_;
  my $session = $self->session;
  my $nick = $self->param('nick') || '';
  my $message = $self->param('message') || '';
  my $captcha = $self->param('captcha');
  my $captcha_md5 = $session->{captcha_md5};
  $session->{captcha_md5} = generate_captcha();
  unless( defined $captcha and check_captcha($captcha_md5, $captcha) ) {
    $self->render(json => { error => 'Ошибка: вы ввели неправильную капчу' });
    return;
  }
  if( $nick ) { 
    $nick =~ s/(^\s+|\s+$)//g;
  }
  if( $message ) {
    $message =~ s/(^\s+|\s+$)//g;
    $message =~ s/\s+/ /g;
  }
  unless( $message or length($message) > 300 or length($message) < 10 ) {
    $self->render(json => { error => 'Ошибка: сообщение должно быть от 10 до 300 символов' });
    return;
  }
  add_message($nick, $message);
  $self->render(json => { ok => 'Posted' });
};

app->start;
