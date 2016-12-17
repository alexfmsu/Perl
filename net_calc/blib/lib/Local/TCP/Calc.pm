# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc;

use 5.16.0;
use strict;
use warnings;
use utf8;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    TYPE_CONN_OK TYPE_CONN_ERR
    TYPE_START_WORK TYPE_CHECK_WORK
    STATUS_NEW STATUS_WORK STATUS_ERROR STATUS_DONE
    get_request send_request
    $PATH $WAIT_TIME
);

sub TYPE_START_WORK {1}
sub TYPE_CHECK_WORK {2}
sub TYPE_CONN_ERR   {3}
sub TYPE_CONN_OK    {4}

sub STATUS_NEW   {1}
sub STATUS_WORK  {2}
sub STATUS_DONE  {3}
sub STATUS_ERROR {4}

sub PACKED_HEADER_SIZE {8}

our $WAIT_TIME = 30;
our $PATH = './tasks/';
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub pack_header{
    my $pkg = shift;
    my $type = shift;
    my $size = shift;
    
    return pack "LL", $type, $size;
}

sub unpack_header{
    my $pkg = shift;
    my $packed_header = shift;
    
    return unpack "LL", $packed_header;
}

sub pack_message{
    my $pkg = shift;
    my $messages = shift;
    
    return pack "L(L/A*)*", scalar(@$messages), @$messages;
}

sub unpack_message{
    my $pkg = shift;
    my $packed_messages = shift;
    
    my ($size, @messages) = unpack "L(L/A*)*", $packed_messages;
    
    if(!defined($size) || $size != scalar @messages){
        die "Error: can't unpack messages";
    }
    
    return \@messages;
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub get_header{
    my $socket = shift;
    
    my $packed_header;
    my $packed_header_size = PACKED_HEADER_SIZE;
    
    my $bytes_read = $socket->sysread($packed_header, $packed_header_size);
    
    if(!defined($bytes_read) || $bytes_read != $packed_header_size){
        return -1;
    }
    
    return __PACKAGE__->unpack_header($packed_header);
}

sub get_message{
    my $socket = shift;
    my $packed_message_size = shift;
    
    my $packed_message;
    my $message = [];
    
    if($packed_message_size > 0){
        my $bytes_read = $socket->sysread($packed_message, $packed_message_size);
        
        if(!defined($bytes_read) || $bytes_read != $packed_message_size){
            drop_connection($socket, "Error: can't receive packed messages");
        }
        
        $message = __PACKAGE__->unpack_message($packed_message);
    }
    
    return $message;
}

sub get_request{
    my $socket = shift;
    
    my ($type, $packed_message_size) = get_header($socket);
    
    if(!defined($type) || !defined($packed_message_size)){
        return -1;
    }
    
    my $message = get_message($socket, $packed_message_size);
    
    return ($type, $message);
}

sub send_request{
    my $socket = shift;
    my $message = shift;
    my $type = shift;
    
    if(!defined($type)){
        warn("\n\nError: can't send request\n\n");

        return -1;
    }
    
    my $packed_message = __PACKAGE__->pack_message($message);
    my $packed_header = __PACKAGE__->pack_header($type, length($packed_message));
    
    my $packed_all = $packed_header.$packed_message;
    my $packed_all_size = length $packed_all;
    
    my $bytes_write = $socket->syswrite($packed_all, $packed_all_size);
    
    if(!defined($bytes_write) || $bytes_write != $packed_all_size){
        warn("\n\nError: can't send request\n\n");

        return -1;
    }

    return 0;
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

1;
