package Local::JSONParser;

use 5.16.0;
use strict;
use warnings;
use utf8;

use base qw(Exporter);
use Encode qw(encode decode);

our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

binmode(STDOUT,':utf8');

# NUMBER
our $number = qr{
	[\-]?
	(
		0
		|
		([1-9]\d*)
	)
	(
		\.\d+
	)*
	(
		[eE][\+\-]?\d+
	)?
}x;
# NUMBER

# STRING
our $special_char = qr{
	[\\]
	(
		["|\\|/|b|f|n|r|t]
		|
		(u[[:xdigit:]]{4})
	)
}x;

our $string = qr{
 	\"
 	(
 		(??{$special_char})
 		|
 		[^\"\\]
 	)*
	\"
}x;
# STRING

# TRIM
sub trim{
	$_ = shift;

	s/^\s+//;
	s/\s+$//;
	
	return $_;
}
# TRIM

# SPLIT-OBJECT
sub splitObject{
	my $expr = trim(shift);

	my %obj;

	while($expr =~ /
		(
			(?<key>
				(
					\".+?\"
				)
			)\s*\:\s*
						
			(?<value>
				(
					$string
					|
					\[.*\]
					|
					\{.*\}
					|
					.+?
				)
				(?=\,|$)
			)(\,|$)
		)
	/gxs){
		if(defined($+{key}) and defined($+{value})){
			my $key = $+{key};
			my $value = $+{value};

			$key = getKey($key);
			$obj{$key} = getValue($value);
		}
	}

	die "Error: parse $_\n" if($_ ne '' && !%obj);
		
	return \%obj;
}
# SPLIT-OBJECT
	
# SPLIT-ARRAY
sub splitArray{
	my $expr = trim(shift);

	my @arr;

	while($expr =~ /
		(
			(?<obj>
				\{.*\}
				(?=\,|$)
			)		
		)
		|
		(
			(?<arr>
				\[.*\]
				(?=\,$)
			)
		)
		|
		(
			(^|\,\s*)
			(?<value>
				($string|\w+)\s*
				(?=\,|$)
			)
		)
	/gxs){
		if(defined($+{value})){
			push @arr, getValue($+{value});
		}elsif(defined($+{obj})){
			push @arr, getValue($+{obj});
		}elsif(defined($+{arr})){
			push @arr, getValue($+{arr});
		}
	}

	die "Error: parse $_\n" if($_ ne '' and !@arr);

	return \@arr;
}
# SPLIT-ARRAY

# GET-ARRAY
sub getArray{
	$_ = shift;

	if(m/\s*\,\s*$/){
		die "Error";
	}

	return splitArray($_);
}
# GET-ARRAY
	
# GET-OBJECT
sub getObject{
	$_ = shift;

	if(m/\s*\,\s*$/){
		die "Error";
	}

	return splitObject($_);
}
# GET-OBJECT

our %spec_chars = (
	'\\\"' => "\"",
	'\\\\' => "\\",
	'\\\/' => "\/",
	'\\\b' => "\b",
	'\\\f' => "\f",
	'\\\n' => "\n",
	'\\\r' => "\r",
	'\\\t' => "\t" 
);


# GET-STRING
sub getString{
	$_ = trim(shift);

	if(/^$string$/){
		$_ =~ s/^\"//;
		$_ =~ s/\"$//;
		
		for my $key(keys %spec_chars){
        	my $value = $spec_chars{$key};
        	
        	$_ =~ s/(?<!\\)$key/$value/e;
    	}
			
		$_ =~ s/(?<!\\)\\u([[:xdigit:]]{4})/chr(hex $1)/ge;
			
		return $_;
	}else{
		die "Error";	
	}	
}
# GET-STRING

# GET-KEY
sub getKey{
	$_ = shift;

	return getString($_);
}
# GET-KEY

# GET-VALUE
sub getValue{ 
	$_ = trim(shift);
		
	return getArray($1) if /^\[(.*)\]$/s;
	return getObject($1) if /^\{(.*)\}$/s;
	return $1 if /^(\s*|null|true|false|$number)$/;
	
	return getString($_);
}
# GET-VALUE
	
sub parse_json {
	my $source = shift;
		
	return getValue($source);	
}

1;
