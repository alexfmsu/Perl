# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Client;

use 5.16.0;
use strict;
use warnings;
use utf8;

use IO::Socket;

our $VERSION = v1.0;

use Local::TCP::Calc qw(
    TYPE_CONN_ERR
    get_request send_request
);
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub set_connect{
    my $pkg = shift;
    my $ip = shift;
    my $port = shift;
    
    my $server = IO::Socket::INET->new(
        PeerAddr => $ip,
        PeerPort => $port,
        Proto => 'tcp',
        Type => SOCK_STREAM
    ) or "Can't connect to ".$ip." $/";
    
    my $status;
    
    $server->sysread($status, 1);
    
    if($status == TYPE_CONN_ERR){
        die "Connection refused by server ".$ip." on port ".$port; 
    }
    
    return $server;
}

sub do_request{ 
    my $pkg = shift;
    my $server = shift;
    my $type = shift;
    my $message = shift;
    
    my $snd = send_request($server, $message, $type);
    
    if($snd == -1){
        close($server);
        exit(0);
    }

    my ($status, $struct) = get_request($server);
    
    return @$struct;
}

1;
