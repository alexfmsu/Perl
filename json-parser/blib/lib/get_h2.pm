package get_h;
use 5.16.0;
use DDP;

my $number = '
		-?
		(?:
			0
			|
			[1-9]
			\d*
		)
		(?:
			\.
			\d+
		)*
		(?:
			[eE]
			[+-]?
			\d*
		)?
';

my $string = '
		\"
		(?:
			\w+
		)*
		
		\"
	';
# return 0;

my $true = 'true';
my $false = 'false';
my $null = 'null';


sub get_json{
 	my $str = shift;

	my @stack = ();
	my %h = ();
		
	my $value;
	my $object;
	my $array;

	$value = qr{
		(??{$string})
		|
		(??{$number})
		|
		(??{$object})
		|
		(??{$array})
		|
		(??{$true})
		|
		(??{$false})
		|
		(??{$null})
	}x;

	$object = qr{
		\{\s*
			
			(?:
				(?>
					(?<key> $string )\s*\:\s*(?<value> (??{$value}) ) (?:\,\s*)?
					
					(?{ 
						# say $+{value};
						my $val = get_json($+{value});
						$h{$+{key}} = $+{value};
					})
				)
			|
				(??{ $object })
			)*
			\s*
			(?<!\,)
		\s*\}
	}x;

	my $ind = 0;
	my $old = @stack;

	my $l = \@stack;
	
	$array = qr{
		\[\s*	
			(?{	$ind++; if($ind>1){push @$l, []; $old = $l; $l = @$l[-1];} })
			(?:
				(?> 
					 (?<n>   [^\[\,\]]+)   )\,?
								(?{
									my $val = get_json($+{n});
									# print("to_json: ".$val."\n");
									# say $+{n};
									# print("123");					
									# push @$l, $+{n};
									push @$l, $val;					
								})
			      
	        |
	        	(??{ $array })			
			)*
			\s*
			(?<!\,)
		\s*\](?{	$l = $old;	}) 
	}x;
	
	my $arr = qr/$array/;
	my $obj = qr/$object/;

	$str =~ s/^\s+(.*)/$1/;
	$str =~ s/(.*)\s+$/$1/;		
	
	if($str =~ m{^$number$}x){
		return $str;
	}elsif($str =~ m{^$string$}x){
		$str =~ s/^\"(.*)/$1/;
		$str =~ s/(.*)\"$/$1/;		

		return $str;
	}elsif($str =~ m{^$obj$}x){
		# say 'match';
		return \%h;
		# p %h;
	}elsif($str =~ m{^$arr$}x){
		# say 'match';
		return \@stack;	
	}else{
		# say 'not match';
		return 0;
	 	# die 'Error';	


	}

	return 0;
}

1







# my $np;

# $np = qr{
#            \[
#            (?:
#               (?> (?<n>   [^\[\,\]]+)   )\,?  (?{	say $+{n}	})# Non–parens without backtracking
           
#            |
#               (??{  $np })
              
#                # Group with matching parens
#            )*
#            \]
#      }x;

# my $NP = qr/$np/;

# if('[sdsd,[wwe,sdsa]]'=~m{$NP}x){
# 	say 'match';
# }
