=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate{
	# -------------------------------------------------------------------------
	my $rpn = shift;

	my @stack = ();
	# -------------------------------------------------------------------------
	for my $c(@$rpn){
			if($c eq 'U+'){}
			elsif($c eq 'U-'){
				if(@stack){
					my $x = pop(@stack);
					
					push(@stack, 0-$x);		
				}else{
					die "Bad: '$_'";
				}
			}elsif($c eq '^'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y**$x);			
				}else{
					die "Bad: '$_'"; 
				}
			}elsif($c eq '*'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y*$x);			
				}else{
					die "Bad: '$_'";
				}
			}elsif($c eq '/'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					($x != 0) ? (push(@stack, $y/$x)) : (die "Bad: '$_'");			
				}else{
					die "Bad: '$_'";; 
				}
			}elsif($c eq '+'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y+$x);		
				}else{
					die "Bad: '$_'";
				}	
			}elsif($c eq '-'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y-$x);			
				}else{
					die "Bad: '$_'";
				}
			}else{
				push(@stack, $c);
			}
	}
	
	return pop(@stack);
}

1;
