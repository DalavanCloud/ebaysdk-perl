use Test::More;
use strict; no warnings;
#use LWP::Debug qw(+);
use Data::Dumper;
use lib qw/lib/;


my @skip_msg;

plan skip_all => join( ' ', 'Skipping product tests - not implemented' );

BEGIN {

    eval {
        use eBay::API::Simple::Product;
    };
    
    if ( $@ ) {
        push @skip_msg, 'missing module eBay::API::Simple::Product, skipping test';
    }
    
       
    if ( scalar( @skip_msg ) ) {
        #plan skip_all => join( ' ', @skip_msg );
    }
    else {
        #plan qw(no_plan);
    }    

}

my $call;
$eBay::API::Simple::Finding=1;

eval {

    $call = eBay::API::Simple::Product->new(
        { appid => undef } # <----- your appid here
    );

};

if ( $@ ) {
    push( @skip_msg, $@ );
}

SKIP: {
    skip join("\n", @skip_msg), 1 if scalar(@skip_msg);
 
    $call->execute( 'findProducts', { productSearch => { 
        keywords => 'chrome', invocationId => '1234567890', categoryId => '170577' } 
    } );
 
    #diag $call->request_content;
    #diag $call->response_content;
    
    if ( $call->has_error() ) {
        fail( 'api call failed: ' . $call->errors_as_string() );
    }
    else {
        is( ref $call->response_dom(), 'XML::LibXML::Document', 'response dom' );
        is( ref $call->response_hash(), 'HASH', 'response hash' );
        
        like( $call->nodeContent('timestamp'), 
            qr/^\d{4}-\d{2}-\d{2}/, 
            'response timestamp' 
        );
    
        ok( $call->nodeContent('totalEntries') > 10, 'response total entries' );
        #diag( 'total entries: ' . $call->nodeContent('totalEntries') );
        #diag( Dumper( $call->response_hash() ) );
    }

    $call->execute( 'BadCall', { keywords => 'shoe' } );

    is( $call->has_error(), 1, 'look for error flag' );
    ok( $call->errors_as_string() ne '', 'check for error message' );
    ok( $call->response_content() ne '', 'check for response content' );

    $call->execute( 'findItemsByKeywords', { keywords => 'shoe' } );

    is( $call->has_error(), 0, 'error check' );
    is( $call->errors_as_string(), '', 'error string check' );
    ok( $call->nodeContent('totalEntries') > 10, 'response total entries' );

    #diag( Dumper( $call->response_hash() ) );

    my @nodes = $call->response_dom->findnodes(
        '//item'
    );

    my $count = 0;
    foreach my $n ( @nodes ) {
        ++$count;
        #diag( $n->findvalue('title/text()') );
        ok( $n->findvalue('title/text()') ne '', "title check $count" );
    }

}

