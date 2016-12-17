# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Server::Queue;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Mouse;

use Fcntl qw(:flock);
use POSIX;
use PerlIO::gzip;

use Local::TCP::Calc qw(
    STATUS_NEW STATUS_WORK STATUS_DONE
    $PATH $WAIT_TIME
);

has f_handle       => (is => 'rw', isa => 'FileHandle');
has queue_filename => (is => 'ro', isa => 'Str', default => '/tmp/local_queue.log');
has max_task       => (is => 'rw', isa => 'Int', default => 0);
has updated => (is => 'rw', isa => 'Int', default => 0);
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
$SIG{ALRM} = sub{
    die "Error: timeout expired while waiting for the queue";
};
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub init{
    my $self = shift;    
    
    open(my $fh, '>', $self->queue_filename) or die $!;
    close $fh;
}

sub OPEN{
    my $self = shift;
    
    $self->updated(0);
    
    open(my $fh, '+<', $self->queue_filename) or die $!;
    
    $self->{f_handle} = $fh;
    
    alarm($WAIT_TIME);
    flock($fh, LOCK_EX) or die $!;
    alarm(0);
    
    my @q_tasks = ();
    
    while(my $record = <$fh>){
        $record =~ /^id=(\d+)\sstatus=(\d)$/;
        
        die if !defined($1) || !defined($2);
        
        push @q_tasks, {id=>$1, status=>$2};
    }
    
    return \@q_tasks;
}


sub CLOSE{
    my $self = shift;
    my $q_tasks = shift;
    
    my $fh = $self->{f_handle};
    
    if($self->updated){
        truncate $fh, 0;
        seek $fh, 0, SEEK_SET;    
        
        for(@$q_tasks){
            my $record = 'id='.($_->{id})." status=".($_->{status});
            
            print $fh ($record."\n");
        }
    }
    
    flock($fh, LOCK_UN) or die $!;
    
    close $fh;
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub add{
    my $self = shift;
    my $msg = shift;
    
    my $id = 0;
    
    my $q_tasks = $self->OPEN();
    
    if(scalar(@$q_tasks) < $self->{max_task}){
        my $max_id = 0;
        
        for(@$q_tasks){
            if($_->{id} > $max_id){
                $max_id = $_->{id}; 
            }
        }
        
        $id = $max_id+1;
        
        push @$q_tasks, {id => $id, status => STATUS_NEW};
        
        $self->updated(1);
        
        open(my $fh, '>:gzip', $PATH."task_".$id."_in.gz") or die $!;
        print $fh join("\n", @$msg);
        close($fh);                        
    }
    
    $self->CLOSE($q_tasks);
    
    return $id;
}

sub get{
    my $self = shift;
    
    my $id = 0;
    
    my $q_tasks = $self->OPEN();
    
    for(@$q_tasks){
        if($_->{status} == STATUS_NEW){
            $_ = {id=>($id = $_->{id}), status=>STATUS_WORK};
            
            $self->updated(1);
            
            last;
        }
    }
    
    $self->CLOSE($q_tasks);
    
    return $id;
}

sub delete{
    my $self = shift;
    my $id = shift;
    
    my $q_tasks = $self->OPEN();
    
    my @tmp = ();
        
    for(@$q_tasks){
        push(@tmp, $_) if $_->{id} != $id;
    }
        
    @$q_tasks = @tmp;
        
    $self->updated(1);
    
    unlink $PATH."task_$id.in";
    # unlink $PATH."task_$id.out";
    
    $self->CLOSE($q_tasks);
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub get_status{
    my $self = shift;
    my $id = shift;
    
    my $status;
    
    my $q_tasks = $self->OPEN();
    
    for(@$q_tasks){
        if($_->{id} == $id){
            $status = $_->{status};
            
            last;
        }
    }
    
    $self->CLOSE($q_tasks);
    
    return $status;    
}

sub to_done{
    my $self = shift;
    my $id = shift;
    
    my $q_tasks = $self->OPEN();
    
    for(@$q_tasks){
        if($id == $_->{id}){
            $_->{status} = STATUS_DONE;
                
            $self->updated(1);
            
            last;
        }
    }    
    
    $self->CLOSE($q_tasks);
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub get_result{
    my $self = shift;
    my $id = shift;
    
    open(my $fh_in, '<:gzip', $PATH."task_".$id."_in.gz"); 
    open(my $fh_out, '<', $PATH."task_$id.out");
    
    my @result = ();
    
    while(my $out = <$fh_out>){
        my $in = <$fh_in>;
        
        chomp($in);
        chomp($out);
        
        push(@result, ($in." == ".$out));
    }
    
    close $fh_in;
    close $fh_out;
    
    return @result;
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub get_out_filename{
    my $id = shift;
    
    return $PATH."task_$id.out";
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
no Mouse;
__PACKAGE__->meta->make_immutable();

1;
