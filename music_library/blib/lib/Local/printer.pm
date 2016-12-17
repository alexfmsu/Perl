#!/usr/bin/env perl

package printer;

use 5.16.0;
use strict;
use warnings;
use utf8;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

sub print_library{
	(my $lengths, my $t2, my $arr_cut) = (shift, shift, shift);
	# -------------------------------------------------------------------------
	my $l = scalar @$t2;
	
	my $width = 3 * ($l -1) + 2;
	
	for(@$t2){
		my $value = %$lengths{$_};
		$width += $value if($value);
	}
	# -------------------------------------------------------------------------
	
	# BEGIN---------------------------------HEADER-----------------------------
	my $out;

	$out .= sprintf('/');
	$out .= sprintf("-" x $width);
	$out .= sprintf('\\');
	$out .= sprintf("\n");
	# END-----------------------------------HEADER-----------------------------
		
	# BEGIN---------------------------------BODY-------------------------------
	my $not_empty_query = 0;

	my $cnt = 0;

	for(my $i = 0; $i < scalar @$arr_cut; $i++){
		my %str = %{@$arr_cut[$i]};
	 	
		$out .= sprintf("|");
		
		for my $param(@$t2){	
			my $value = $str{$param};

			my $width = %$lengths{$param} + 3;
			$out .= sprintf("%".$width."s", " ".$value." |");		
			
			$not_empty_query = 1;
		}
		
		if($cnt < scalar @$arr_cut - 1){
			# BEGIN-------------------------SEPARATOR--------------------------
			$out .= sprintf("\n");
			$out .= sprintf("|");

			for my $param(@$t2){	
				my $width = %$lengths{$param} + 3;
				
				$out .= sprintf("%".$width."s", "-" x ($$lengths{$param}+2)."+");	
			}

			chop($out);
			
			$out .= sprintf("|");	
			# END---------------------------SEPARATOR--------------------------
		}

		$out .= sprintf("\n");
			
		$cnt++;
	}
	# END-----------------------------------BODY-------------------------------

	# BEGIN---------------------------------FOOTER-----------------------------
	$out .= sprintf('\\');
	$out .= sprintf("-" x $width);
	$out .= sprintf("/");
	$out .= sprintf("\n");
	# END-----------------------------------FOOTER-----------------------------

	print $out if $not_empty_query;
}

1