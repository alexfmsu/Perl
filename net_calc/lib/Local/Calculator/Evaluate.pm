package Local::Calculator::Evaluate;

use 5.016;
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
	
	return "NaN" if(!@$rpn);

	my @stack = ();
	# -------------------------------------------------------------------------
	for my $c(@$rpn){
			if($c eq 'U+'){}
			elsif($c eq 'U-'){
				if(@stack){
					my $x = pop(@stack);
					
					push(@stack, 0-$x);		
				}else{
					return "NaN";
				}
			}elsif($c eq '^'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y**$x);			
				}else{
					return "NaN"; 
				}
			}elsif($c eq '*'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y*$x);			
				}else{
					return "NaN";
				}
			}elsif($c eq '/'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					$x != 0 ? push(@stack, $y/$x) : return "NaN";			
				}else{
					return "NaN"; 
				}
			}elsif($c eq '+'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y+$x);		
				}else{
					return "NaN";
				}	
			}elsif($c eq '-'){
				if(scalar(@stack) > 1){
					my $x = pop(@stack);
					my $y = pop(@stack);
					
					push(@stack, $y-$x);			
				}else{
					return "NaN";
				}
			}else{
				push(@stack, $c);
			}
	}
	
	return pop(@stack);
}

1;
