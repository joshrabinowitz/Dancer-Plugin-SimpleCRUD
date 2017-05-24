package Dancer::Plugin::SimpleCRUD::Constants;

use base 'Exporter';
our @EXPORT_OK = qw( default_searchtype searchtypes );

use constant default_searchtype => 'e'; # equality
use constant searchtypes => (
    [ e   => { name => "Equals",           cmp => "=" } ],
    [ c   => { name => "Contains",         cmp => "like" } ],
    [ b   => { name => "Begins With",      cmp => "like" } ],
    [ ne  => { name => "Does Not Equal",   cmp => "!=" } ],
    [ nc  => { name => "Does Not Contain", cmp => "not like" } ],

    [ lt  => { name => "Less Than",                cmp => "<" } ],
    [ lte => { name => "Less Than or Equal To",    cmp => "<=" } ],
    [ gt  => { name => "Greater Than",             cmp => ">" } ],
    [ gte => { name => "Greater Than or Equal To", cmp => ">=" } ],

    [ like => { name => "Like", cmp => "LIKE" } ],
);

1;

=head1 NAME

Dancer::Plugin::SimpleCRUD::Constants - Constants for Dancer::Plugin::SimpleCRUD

=head1 SYNOPSIS

    use Dancer::Plugin::SimpleCRUD::Constants qw( default_searchtype searchtypes );
    my $default_searchtype = default_searchtype;
    my @searchtypes = searchtypes;  # a list of refs

=head1 DESCRIPTION

Holds constants for Dancer::Plugin::SimpleCRUD

=head2 Functions

=over 12

=item C<default_searchtype>

Returns 'e', which means an equality search.

=item C<searchtype>

Returns a listref describing the types of searches supported.

=back

=head1 LICENSE

This is released under the Artistic 
License. See L<perlartistic>.

=head1 AUTHOR

Josh Rabinowitz <joshr>

=head1 SEE ALSO

L<Dancer::Plugin::SimpleCRUD>

=cut
