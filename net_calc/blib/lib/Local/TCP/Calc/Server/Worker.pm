# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Server::Worker;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Mouse;

use POSIX;
use Fcntl qw(:flock);
use PerlIO::gzip;

use Local::TCP::Calc qw(
    $PATH $WAIT_TIME
);
use Local::Calculator::RPN;
use Local::Calculator::Evaluate;

has cur_task_id => (is => 'ro', isa => 'Int', required => 1);
has forks       => (is => 'rw', isa => 'ArrayRef', default => sub {return []});
has calc_ref    => (is => 'ro', isa => 'CodeRef', required => 1);
has max_forks   => (is => 'ro', isa => 'Int', required => 1);
has expr_count   => (is => 'ro', isa => 'Int', required => 1);
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
has error => (is => 'rw', isa => 'Int', default => 0);

sub write_err{
    my $self = shift;
    my $error = shift;
    my $fh;

    alarm($WAIT_TIME);
    flock($fh, LOCK_EX) or die $!;    
    alarm(0);
                
    truncate $fh, 0;
    seek $fh, 0, SEEK_SET;
                
    print $fh $error;
                
    flock($fh, LOCK_UN) or die $!;        
}

sub write_res {
    my $self = shift;
    my $result = shift;
    my $fh = shift;

    alarm($WAIT_TIME);
    flock($fh, LOCK_EX) or die $!;    
    alarm(0);
            
    print $fh $result."\n";
            
    flock($fh, LOCK_UN) or die $!;        
}

sub start{
    my $self = shift;
    
    $SIG{CHLD} = "DEFAULT";
    
    my $id = $self->cur_task_id;
    
    my @tasks = ();
    my $cnt = $self->expr_count;
    my $fh_in;
    
    open($fh_in, '<:gzip', $PATH."task_".$id."_in.gz") or die $!;
    while(my $expr = <$fh_in>){
        chomp($expr);
        push @tasks, $expr;
    }
    close($fh_in);
    
    open(my $fh_out, '>', $PATH."task_$id.out") or die $!;
    
    my @forks = ();
    $self->{forks} = \@forks;
    
    my $max_forks = $self->max_forks;
    my $tasks_per_fork = floor($cnt/$max_forks);
    
    my $start = 0;
    my $fin = $tasks_per_fork - 1;
    
    my $mod_cnt = $cnt % $max_forks;
    
    my $i = 0;    
    
    for(0..$max_forks-2){
        my $pid = fork();
        
        if(!defined($pid)){
            warn "Can't fork $!";
            $self->error(1);
            last;
        }
        if($pid > 0){
            if($i++ == 0){ 
                for(@tasks[$start..$fin]){
                    $SIG{CHLD} = "IGNORE";
                    my $res = $self->{calc_ref}($_);
                    $SIG{CHLD} = "DEFAULT";
                
                    $self->write_res($res, $fh_out);
                }
            }    
            
            $start = $fin+1;
            $fin = $start + $tasks_per_fork - 1; 
                    
            if($mod_cnt > 0){
                $fin++;
                $mod_cnt--;
            }
        }else{
            for(@tasks[$start..$fin]){
                $SIG{CHLD} = "IGNORE";
                my $res = $self->{calc_ref}($_);
                $SIG{CHLD} = "DEFAULT";
                        
                $self->write_res($res, $fh_out);
            }
            
            exit(0);
        }
    }
    
    # while(waitpid(-1, WNOHANG) > 0){};
    while($self->wait_child() != -1){};
    
    if($self->error){ 
        $self->write_err("Error: task execution is corrupt", $fh_out);
    }             
    
    close $fh_out;
}

sub wait_child{
    my $self = shift;
    
    my $w_pid = waitpid(0, 0);
    
    return $w_pid if $w_pid == -1;
    
    my @forks = ();
    
    $self->{forks} = \@forks;
    @forks = grep{$_ != $w_pid} @forks;
    
    if(!WIFEXITED($?)){
        kill('TERM', $_) for @{$self->forks};
        
        $self->error(1);
    }
    
    return $w_pid;
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
