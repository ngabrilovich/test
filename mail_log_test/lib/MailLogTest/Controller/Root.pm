package MailLogTest::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

use MailLogTest::Schema;

sub index {
    my $self = shift;
}
sub search {
    my $self = shift;
    my $schema = MailLogTest::Schema->connect( 'dbi:mysql:database=scorpycat;host=10.145.1.3;', 'scorpycat', 'plasasgu', { PrintError => 1 } ) or die;
    my $address = $self->param('email');
    
    my $logs = $schema->resultset( 'Log' )->search_rs( {address => $address}, { order_by => qw/int_id created/});
    #Из-за того, что в таблице сообщений нет адреса, придётся искать вот такой конструкцией.
    my $messages = $schema->resultset( 'Message' )->search_like( {str => '____________________'.$address.' %'}, { order_by => qw/int_id created/});
    $self->stash->{lcount} = $logs->count;
    $self->stash->{mcount} = $messages->count;
    #Ну тут не совсем так надо бы. Или даже совсем не так. Искать одновременно в двух, или объединять после? Сейчас не соображу уже.
    $self->stash->{logs} = $logs->search_rs({},{rows => 100, order_by => qw/int_id created/,});
    $self->stash->{messages} = $messages->search_rs({},{rows => 100, order_by => qw/int_id created/,});

}
1;
