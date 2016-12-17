use 5.016;
use strict;
use AnyEvent::HTTP;
$AnyEvent::HTTP::MAX_PER_HOST = 100;
use AE;
use Getopt::Long;
use HTML::Parser;
use DDP;

my %used;
my $cv = AE::cv;
my $all = 0;
my $maxi;
my $host;
my $help;

GetOptions("max=i" => \$maxi, "host=s" => \$host, "help" => \$help);

if(defined $help) {
    say '--max=100';
    say '--host=https://habrahabr.ru/\n';
    
    exit;
}

die "No max parameter" if !defined($maxi);
die "No host parameter" if !defined($host);

die "wrong host" if ($host !~ /https?:\/\/(.*?)\..+/);

my $host_name = $1;

$| = 1;

sub check{
    my ($prev, $text) = @_;
    
    $text =~ s/\#(.*)//;
    
    return if !defined($text);
    
    if ($text =~ m/^https?:\/\/(.*?)\./) {
        return if $1 ne $host_name;
        
        if(not exists($used{$text})){
            return $text;
        } 
        
        return undef;
    
    }else{
        $text = substr($text, 1);
        $text = $prev.$text;
        
        if (not exists($used{$text})){
            return $text;
        }else{
            return undef;
        }
    }
    
    return undef;
}

my @top10_val = ();
my @top10_host = ();

sub add_to_res_res{
    my ($host, $value) = @_;

    if(scalar @top10_val < 10){
        push(@top10_val, $value);
        push(@top10_host, $host);
    
        return;
    }else{
        if ($top10_val[9] < $value) {
            pop @top10_val;
            pop @top10_host;
            push(@top10_val, $value);
            push(@top10_host, $host);
            
            my $i = 8;
            
            while ($i >= 0 and $top10_val[$i] < $top10_val[$i + 1]) {
                ($top10_val[$i], $top10_val[$i + 1]) = ($top10_val[$i + 1], $top10_val[$i]);
                ($top10_host[$i], $top10_host[$i + 1]) = ($top10_host[$i + 1], $top10_host[$i]);
                $i--;
            }
        }
    }
}

sub lt_maxi{
    $all++;
    print "$all / $maxi";
    if($all  <= $maxi){
        print "\b" for 1..length($maxi);
        print "\b\b\b";
        print "\b" for 1..length($all);
        
        return 1;
    }else{
        return 0;
    }
}

sub web_crawler {
    my ($href) = @_;
    return sub {
        my $content = $_[0];
        
        return if !lt_maxi();

        $used{$href} = $_[1]->{"content-length"};
        add_to_res_res($href, $_[1]->{"content-length"});
        
        my @result;
        
        my $p = HTML::Parser->new(
            api_version => 3,
            start_h => [
                sub {
                    my ($tagname, $attr) = @_;
                    if ($tagname eq "a" and exists($attr->{"href"})) {
                        my $a_href = $attr->{"href"};
                        $a_href = check($href, $a_href);

                        if(defined $a_href and (scalar(keys(%used)) < $maxi)){
                            $used{$a_href} = 0;
                            push(@result, $a_href);
                        }
                    }
                }, "tagname, attr"],
        );
        
        $p->parse($content);
        
        for my $i(@result){
            $cv->begin;
            
            my $callback = web_crawler($i);
            
            http_get($i, $callback);
        }
        
        if($all >= $maxi){
            $cv->send();

            return;
        }
        
        $cv->end;
    }
}

my $first_func = web_crawler($host);

$cv->begin;
http_get($host, $first_func);
$cv->recv();

for my $i (0..9){
    say ($i + 1);
    print "\tName: $top10_host[$i] \n\tSize: ";
    printf "%.4f" ,($top10_val[$i] / (1024 ** 2));
    say 'Mb';
}