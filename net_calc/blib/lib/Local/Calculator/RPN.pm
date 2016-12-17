package Local::Calculator::RPN;

use 5.010;
use strict;
use warnings;
use diagnostics;

use Local::Calculator::tokenize;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub rpn{
	# -------------------------------------------------------------------------
	my $expr = shift;
	my $source = Local::Calculator::Tokenize::tokenize($expr);
	my @rpn;

	my @stack = ();
	# -------------------------------------------------------------------------
	my %priority = (
		'(' => 0, ')' => 0,
		'+' => 1, '-' => 1,
		'*' => 2, '/' => 2,
		'U+'=> 3, 'U-'=> 3,
		'^' => 4
	);
	
	my %order = (
		'(' => 'l', ')' => 'l',
		'U-'=> 'l', 'U+'=> 'l',
		'+' => 'b', '-' => 'b',
		'*' => 'b', '/' => 'l',
		'^' => 'r'
	);
	
	my @signs = ('U-', 'U+', '+', '-', '*', '/', '^');
	
	for my $c(@$source){ 
		if($c ~~ @signs){
			while(@stack){
				my $top = $stack[-1];
					
				if($order{$top} ne 'r'){
					($priority{$c} <= $priority{$top}) ? (push(@rpn, pop(@stack))) : (last);
				}elsif($priority{$c} < $priority{$top}){
					push(@rpn, $c); 
					
					$c = '';				
					last;
				}
			}
				
			push(@stack, $c) if $c;
		}elsif($c eq '('){
			push(@stack, $c);
		}elsif($c eq ')'){
			while((my $tmp = pop(@stack)) ne '('){
				push(@rpn, $tmp);
			}
		}else{
			push(@rpn, ''.(0+$c));
		}
	}
	
	push(@rpn, reverse @stack);
	
	return \@rpn;
}

1;
