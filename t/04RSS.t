use Test::More;
use strict; no warnings;
#use LWP::Debug qw(+);
use Data::Dumper;
use lib qw/lib t/;
use Fake;


BEGIN {
    my @skip_msg;

    eval {
        use eBay::API::Simple::RSS;

    };
    
    if ( $@ ) {
        push @skip_msg, 'missing module eBay::API::Simple::RSS, skipping test';
    }
    if ( scalar( @skip_msg ) ) {
        plan skip_all => join( ' ', @skip_msg );
    }
    else {
        plan qw(no_plan);
    }

}

@Fake::ISA = qw(eBay::API::Simple::RSS);
my $call = Fake->new();

my $response1 = <<END;
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
        <title>RSS Title</title>
        <description>This is an example of an RSS feed</description>
        <link>http://www.someexamplerssdomain.com/main.html</link>
        <lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000 </lastBuildDate>
        <pubDate>Mon, 06 Sep 2009 16:45:00 +0000 </pubDate>
 
        <item>
                <title>Example entry</title>
                <description>Here is some text containing an interesting description.</description>
                <link>http://www.wikipedia.org/</link>
                <guid>unique string per item</guid>
                <pubDate>Mon, 06 Sep 2009 16:45:00 +0000 </pubDate>
        </item>
 
</channel>
</rss>
END

$call->{response_content} = $response1;

$call->execute(
    'http://worldofgood.ebay.com/Eco-Organic-Clothes-Shoes-Men-Women-Children/43/list',
    { format => 'rss' },
);

#diag($call->request_content);
#diag($call->response_content);

if ( $call->has_error() ) {
    fail( 'api call failed: ' . $call->errors_as_string() );
}
else {
    is( ref $call->response_dom(), 'XML::LibXML::Document', 'response dom' );
    is( ref $call->response_hash(), 'HASH', 'response hash' );

    ok( $call->nodeContent('title') eq 'RSS Title', 'nodeContent test' );
    #diag Dumper( $call->response_hash );
}

$call->execute( 'http://bogusurlexample.com' );

#is( $call->has_error(), 1, 'look for error flag' );
#ok( $call->errors_as_string() ne '', 'check for error message' );
#ok( $call->response_content() ne '', 'check for response content' );

exit;

my $call2 = eBay::API::Simple::RSS->new(
    { request_method => 'POST' }
);

$call2->execute(
    'http://en.wikipedia.org/w/index.php?title=Special:RecentChanges&feed=rss',
    { page => 1 },
);

is( ref $call2->response_dom(), 'XML::LibXML::Document', 'post response dom' );
is( ref $call2->response_hash(), 'HASH', 'post response hash' );
ok( $call2->nodeContent('title') ne '', 'post nodeContent test' );

