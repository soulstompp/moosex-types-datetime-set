#!/usr/bin/perl

package MooseX::Types::DateTime::Set;

use strict;
use warnings;

our $VERSION = "0.05";

use MooseX::Types::Moose qw/Num HashRef Str/;

use DateTime::Set ();
use DateTime::Span ();
use DateTime::SpanSet ();

use MooseX::Types::DateTime;

use namespace::clean;

use MooseX::Types -declare => [qw( DateTimeSet DateTimeSpan DateTimeSpanSet ArrayRefOfDateTimes ArrayRefOfDateTimeSpans ArrayRefOfDateTimeSets HashRefOfDateTimes HashRefOfDateTimeSets HashRefOfDateTimeSpans )];

class_type "DateTime::Set";
class_type "DateTime::Span";
class_type "DateTime::SpanSet";

subtype 'DateTimeSet' 
    => as 'DateTime::Set';

subtype 'DateTimeSpan' 
    => as 'DateTime::Span';

subtype 'DateTimeSpanSet' 
    => as 'DateTime::SpanSet';

subtype 'ArrayRefOfDateTimes' 
    => as 'ArrayRef[DateTime]';

subtype 'ArrayRefOfDateTimeSpans'
    => as 'ArrayRef[DateTimeSpan]';

subtype 'ArrayRefOfDateTimeSets' 
    => as 'ArrayRef[DateTimeSet]';

subtype 'HashRefOfDateTimes' 
    => as 'HashRef[DateTime]';

subtype 'HashRefOfDateTimeCandidates' 
    => as 'HashRef[DateTime|Int]';

subtype 'HashRefOfDateTimeSets' 
    => as 'HashRef[DateTime]';

subtype 'HashRefOfDateTimeSpans' 
    => as 'HashRef[DateTime]';

my $datetime_constraint = find_type_constraint('DateTime'); 

our %coercions = (
    "DateTime::Set" => [
		        from 'Int' => via {
                                         my $date_time = $datetime_constraint->coerce($_);

                                         return DateTime::Set->from_datetimes( dates => [ $date_time ] );
                                        },
                        #TODO: why can't use Now here? i get an error everytime that I use it
		        from 'Str', via {
                                         return $_ unless $_ eq 'now';

                                         my $date_time = DateTime->now(); 
                                         return DateTime::Set->from_datetimes( dates => [ $date_time ] );
                                        },
		        from 'DateTime' => via {
                                            return DateTime::Set->from_datetimes( dates => [ $_ ] );
                                           },
        		from 'ArrayRefOfDateTimes' => via { 
                                                       return DateTime::Set->from_datetimes( dates => $_ );
                                                      }
                       ],
    "DateTime::Span" => [
                         from 'HashRefOfDateTimeCandidates' => via {
                                                                  my $args_ref = shift @_;
                                                       
                                                                  for my $value (values %$args_ref) {
                                                                      $value = $datetime_constraint->coerce($value);
                                                                  }

                                                                  return DateTime::Span->from_datetimes( %{$args_ref} );
                                                                 },
                         from 'HashRefOfDateTimeCandidates' => via {
                                                                  my $args_ref = shift @_;
                                                         
                                                                  return DateTime::Span->from_datetimes( %{$args_ref} );
                                                                 }
                        ],
    "DateTime::SpanSet" => [
                            from 'ArrayRefOfDateTimeSpans', via {
                                                                 return DateTime::SpanSet->from_spans( spans => [  $_ ] );
                                                                },
                            from 'HashRefOfDateTimeSets', via {
                                                               return DateTime::SpanSet->from_sets( %{$_} );
                                                              }

                           ],
);

for my $type ( "DateTime::Set", 'DateTimeSet' ) {
    coerce $type => @{ $coercions{"DateTime::Set"} };
}

for my $type ( "DateTime::Span", 'DateTimeSpan' ) {
    coerce $type => @{ $coercions{"DateTime::Span"} };
}

for my $type ( "DateTime::SpanSet", 'DateTimeSpanSet' ) {
    coerce $type => @{ $coercions{"DateTime::SpanSet"} };
}

no Moose;

1;

__END__

=pod

=head1 NAME

MooseX::Types::DateTime - L<DateTime> related constraints and coercions for
Moose

=head1 SYNOPSIS

Export Example:

    use MooseX::Types::DateTime::Set qw(DateTimeSpanSet);

    has holiday_hours => (
        isa => 'DateTimeSpanSet',
        is => "rw",
        coerce => 1,
    );

    Class->new( holiday_hours => $array_of_datetime_spans );

Namespaced Example:

	use MooseX::Types::DateTime::SpanSet;

    has holiday_hours => (
        isa => 'DateTime::SpanSet',
        is => "rw",
        coerce => 1,
    );

    Class->new( holiday_hours => $array_of_datetime_spans );

=head1 DESCRIPTION

This module packages several L<Moose::Util::TypeConstraints> with coercions,
designed to work with the L<DateTime::Set> suite of objects.

=head1 CONSTRAINTS

=over 4

=item L<DateTime::Set>

A class type for L<DateTime::Set>.

=over 4

=item from C<Num>
TODO
Uses L<DateTime/from_epoch>. Floating values will be used for subsecond
percision, see L<DateTime> for details. The DateTime object created from
this coercion will be added as a set holding only this date. 

=item from C<ArrayRef>
TODO

=item from C<HashRef>
TODO

=item from C<Duration>
TODO

=back
=back

=item L<DateTime::Span>

A class type for L<DateTime::Span>.

=over 4

=item from C<Num>
TODO
Uses L<DateTime/from_epoch>. Floating values will be used for subsecond
percision, see L<DateTime> for details. The DateTime object created from
this coercion will be added as a set holding only this date. 

=item from C<ArrayRef>
TODO

=item from C<HashRef>
TODO

=item from C<Duration>
TODO

=back
=back

=item L<DateTime::SpanSet>

A class type for L<DateTime::Span>.

=over 4

=item from C<Num>
TODO
Uses L<DateTime/from_epoch>. Floating values will be used for subsecond
percision, see L<DateTime> for details. The DateTime object created from
this coercion will be added as a set holding only this date. 

=item from C<ArrayRef>
TODO

=item from C<HashRef>
TODO

=item from C<Duration>
TODO

=back
=back

=back

=head1 SEE ALSO

L<MooseX::Types::DateTime>

L<DateTime>, L<DateTime::Set>, L<DateTime::Span>, L<DateTime::SpanSet>

=head1 VERSION CONTROL

This module is maintained using git. You can get the latest version from
L<git://github.com/soulstompp/moosex-types-datetime-set.git>.

=head1 AUTHOR

Kenny Flegal E<lt>soulstompp@gmail.com<gt>

=head1 ACKNOWLEDGEMENTS

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt> (his work was directly copied to start this project)

John Napiorkowski E<lt>jjn1056 at yahoo.comE<gt> (his work was directly copied to start this project)

=head1 COPYRIGHT

	Copyright (c) 2010 Kenny Flegal. All rights reserved
	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=cut
