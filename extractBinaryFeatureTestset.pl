#!/usr/perl -w
use strict;

=pod
@author		:Senthilkumar Soundararajan
@usage		:extractBinaryFeatureTestset.pl <input train file> <out file>
@Purpose	:To generate features from the test set for Table identification challenge. 
=cut

die << 'USAGE' unless @ARGV == 2;
1. input train file
2. out file
USAGE

$| = 1;
$_.=',';

sub get_feature
{
	my $table = shift;
	my $link = 0;
	my $row_count = 0;
	
	my $has_links = 0; 			# contains more {First colum has hyper link}
	my $has_attribs = 0; 			# all the first column is bold
	my $has_dimensions = 0; 		# { length : width : height : color : shape : type } 
	my $has_details = 0; 			# { material : quantity : brand : case : Warranty }
	my $has_book_detals = 0; 		# { ISBN : author }
	my $has_product_detals = 0; 	# { Dimensions : Frame : fork : manual }
	my $has_electronics = 0; 		# { Camera : Bluetooth : WiFi : SIM : 2G : 3G : 4G : OS : RAM : Operating System }
	
	my $dec_flag = 1;
	while ( $table =~ /<tr.*?>(.*?)<\/tr>/gs )
	{
		++$row_count;
		my $row = $1;
		if ( $row =~ /<th.*?>(.*?)<\/th>/s )
		{
				$has_attribs = 1;
		}
		else
		{
			$dec_flag = 0;
		}
		if ( $table =~ /<a /si )
		{
			++$link;
		}
		if ( $row =~ /<th.*?>(.+?)<\/th>|<td.*?>(.+?)<\/td>/is )
		{
			my $content = $1;
			if ( $content )
			{
				if ( $content =~ /length|width|height|color|shape|type/is )
				{
					$has_dimensions = 1;
				}
				if ( $content =~ /material|quantity|brand|case|Warranty/is )
				{
					$has_details = 1;
				}
				if ( $content =~ /ISBN|author/is )
				{
					$has_book_detals = 1;
				}
				if ( $content =~ /Dimensions|Frame|fork|manual/is )
				{
					$has_product_detals = 1;
				}
				if ( $content =~ /Camera|Bluetooth|WiFi|SIM|2G|3G|4G|OS|RAM|Operating\s+System/is )
				{
					$has_electronics = 1;
				}
			}
				
		}
	
	}
	if ( $dec_flag == 0 )
	{
		$has_attribs = 1;
	}
	if ( $row_count > 2 && $link > 3 )
	{
		$has_links = 1;
	}
	return ( $has_attribs,$has_links,$has_dimensions,$has_details,$has_book_detals,$has_product_detals,$has_electronics );
}

sub extractfeature
{
	my $table = shift;
	
	# Features
	my $has_table = 0; 			# equal columns in all row
	my $has_title = 0; 			# contains any of {Setting Information :  Specifications : Components : Specs : Contributors : Book Details : FEATURES}
	my $has_nested_table = 0; 	# { TABLE insde table }
	my $has_no_row_col = 0; 		# { only table tag }
	my $has_one_row = 0;		# { row 1 }
	my $has_one_col = 0;		# { col 1 }
	
	#functions 
	
	my ( $has_attribs,$has_links,$has_dimensions,$has_details,$has_book_detals,$has_product_detals,$has_electronics ) = &get_feature($table);
	
	# variables
	my ( $row_count, $head_count) = ( 0,0 );
	my $col_count = 0;
	my $tmp_head_count = 0;
	my $total_col = 0;

	my %h_row_col;
	
	my $row_flag = 0;
	my $has_attribs_flag = 0;
	while ( $table =~ /<tr.*?>(.*?)<\/tr>/gs )
	{
		
		my $col = 0;
		my $col_hd = 0;
		++$row_count;
		my $row = $1;
		if ( $row_flag == 0 )
		{
			$row_flag = 1;
		}
		
		if ( $row =~ /<table.*?<\/table>/s )
		{
			$has_nested_table = 1;
			last;
		}
		
		while ( $row =~ /<th.*?>(.*?)<\/th>/gs )
		{
			my $head_cont = $1;
			if ( $head_cont =~ /Setting\s+Information|Specifications|Components|Specs|Contributors|Book\s+Details|FEATURES/si )
			{
				$has_title = 1;
			}
			if ( $row_count == 1)
			{	
				++$head_count;
			}
			else
			{
				++$col_hd;
				++$tmp_head_count;
				if ( $col_hd == 1 )
				{
					my $col_cont = $1;
				}
				
			}
		}
		while ( $row =~ /<td.*?>(.*?)<\/td>/gs )
		{
			
			++$col;
			if ( $col == 1 )
			{
				my $col_cont = $1;
				
			}
		}
		if ( $col_count != 0 )
		{
			if ( $col_count == $col )
			{
				$has_table = 1;
			}
			else
			{
				$has_table = 0;
				last;
			}
		}
		elsif ( defined $col )  
		{
			$col_count = $col;
		}
		if ( defined $col )
		{
			$total_col += $col;
		}
	}
	if ( $row_flag == 0)
	{
		$has_no_row_col = 1;
	}
	if ( $row_count == 2  )
	{
		if ( ( $head_count == $col_count or $head_count = $tmp_head_count ) )  # && $has_table eq 0
		{
			$has_table = 1;
		}
		$total_col += $head_count;
	}
	# Removing this feature
	# my $avg_table_col = 0;
	# if ( $row_count > 0 )
	# {
		# $avg_table_col = (1.0 * $total_col) / $row_count;
	# }
	
	if ( $row_count == 1 )    # or  ( $col_count == 1 && $row_count > 1 )
	{
		$has_one_row = 1;
	}
	if ( $col_count == 1 )
	{
		$has_one_col = 1;
	}
	
	
	return ( $has_table, $has_nested_table, $has_no_row_col, $has_one_row,$has_one_col,$row_count,$col_count,$head_count,$has_title,$has_attribs,$has_links,$has_dimensions,$has_details,$has_book_detals,$has_product_detals,$has_electronics);
}




my ($in_file, $out_file ) = @ARGV;

open ( OUT, ">$out_file.test.feature" ) || die $!;
print OUT "#has_table\thas_neted_table\thas_no_row_col\thas_one_row\thas_one_col\trow_count\tcol_count\thead_count\thas_title\thas_attribs\thas_links\thas_dimensions\thas_details\thas_book_detals\thas_product_detals\thas_electronics\n";



open ( TRAIN ,'<', $in_file ) || die $!;
local $/;
my $text = <TRAIN>;
close (TRAIN);

my $i = 0;



my $count = 0;
while ($text =~ /(.*?),"(<table.*?<\/table>)"/sig)
{
	my $tabel = $2;
	my ($has_table, $has_nested_table, $has_no_row_col, $has_one_row, $has_one_col,$row_count,$col_count,$head_count,$has_title,$has_attribs,$has_links,$has_dimensions,$has_details,$has_book_detals,$has_product_detals,$has_electronics) = &extractfeature($tabel);
	print OUT "$has_table\t$has_nested_table\t$has_no_row_col\t$has_one_row\t$has_one_col\t$row_count\t$col_count\t$head_count\t$has_title\t$has_attribs\t$has_links\t$has_dimensions\t$has_details\t$has_book_detals\t$has_product_detals\t$has_electronics\n";

	
}
