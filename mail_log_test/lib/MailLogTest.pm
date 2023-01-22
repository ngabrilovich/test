package MailLogTest;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup  {
  my $self = shift;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('root#index');
  $r->any('/search')->to('root#search');
}

1;
