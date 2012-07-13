package EasyMTML;

use strict;
use File::Spec;
use MT::FileMgr;

sub _init_tags {
    my $app = MT->instance();
    my $plugin = MT->component( 'EasyMTML' );
    my $tags_dir = File::Spec->catdir( $plugin->path, 'perl' );
    opendir( DIR, $tags_dir );
    my @tags = readdir( DIR );
    closedir( DIR );
    my $block_tags = $plugin->registry( 'tags', 'block' );
    my $function_tags = $plugin->registry( 'tags', 'function' );
    my $global_modifiers = $plugin->registry( 'tags', 'modifier' );
    for my $tag( @tags ) {
        next if ( $tag =~ /^\./ );
        my $file = File::Spec->catfile( $tags_dir, $tag );
        my $fmgr = MT::FileMgr->new( 'Local' ) or die MT::FileMgr->errstr;
        my $data = $fmgr->get_data( $file );
        my @item = split( /\./, $tag );
        my $kind = $item[ 0 ];
        my $tag_name = $item[ 1 ];
        $tag_name =~ s/^mt//i;
        if ( $kind eq 'block' ) {
            $block_tags->{ $tag_name } = MT->handler_to_coderef( $data );
        } elsif ( $kind eq 'function' ) {
            $function_tags->{ $tag_name } = MT->handler_to_coderef( $data );
        } elsif ( $kind eq 'modifier' ) {
            $global_modifiers->{ $tag_name } = MT->handler_to_coderef( $data );
        }
    }
}

1;