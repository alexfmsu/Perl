package MusicLibraryPrinter;

use 5.16.0;
use strict;
use warnings;
use utf8;

binmode(STDOUT, ':utf8');

sub print_library{
    # ---------------------------------------------------------------------------------------------
    (my $_titles, my $_select_titles, my $_select) = (shift, shift, shift);
    
    my @titles = @$_titles;
    my @select_titles = @$_select_titles;
    my @select = @$_select;
    my %cell_size = ();
    # ---------------------------------------------------------------------------------------------
    my @len = (0) x scalar @titles;
    
    for(@select){
        my %str = %{$_};
        
        for my $j(0..$#titles){
            my $l = length $str{$titles[$j]};
            
            if($l > $len[$j]){
                $cell_size{$titles[$j]} = $len[$j] = $l; 
            }
        }
    }
    # ---------------------------------------------------------------------------------------------
    my $l = scalar @select_titles;
    
    my $width = 3 * ($l -1) + 2;
    
    for(@select_titles){
        my $value = $cell_size{$_};
        
        $width += $value if($value);
    }
    # ---------------------------------------------------------------------------------------------
    
    # BEGIN-------------------------------------------HEADER---------------------------------------
    my $out;
    
    $out .= sprintf('/');
    $out .= sprintf("-" x $width) if $width > 0;
    $out .= sprintf('\\');
    $out .= sprintf("\n");
    # END---------------------------------------------HEADER---------------------------------------
        
    # BEGIN-------------------------------------------BODY-----------------------------------------
    my $not_empty_query = 0;
    
    my $cnt = 0;
    
    for(@select){
        my %str = %{$_};
        
        $out .= sprintf("|");
        
        for my $param(@select_titles){  
            my $value = $str{$param};
            
            my $width = $cell_size{$param} + 3;
            $out .= sprintf("%".$width."s", " ".$value." |");       
            
            $not_empty_query = 1;
        }
        
        if($cnt < scalar @select - 1){
            # BEGIN-----------------------------------SEPARATOR------------------------------------
            $out .= sprintf("\n");
            $out .= sprintf("|");
            
            for my $param(@select_titles){  
                my $width = $cell_size{$param} + 3;
                
                $out .= sprintf("%".$width."s", "-" x ($cell_size{$param}+2)."+");  
            }
            
            chop($out);
            
            $out .= sprintf("|");   
            # END-------------------------------------SEPARATOR------------------------------------
        }
        
        $out .= sprintf("\n");
            
        $cnt++;
    }
    # END---------------------------------------------BODY-----------------------------------------
    
    # BEGIN-------------------------------------------FOOTER---------------------------------------
    $out .= sprintf('\\');
    $out .= sprintf("-" x $width) if $width > 0;
    $out .= sprintf("/");
    $out .= sprintf("\n");
    # END---------------------------------------------FOOTER---------------------------------------
    
    print $out if $not_empty_query;
}

1;