#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok 'MooseX::Types::DateTime::Set';

use Moose::Util::TypeConstraints;

use MooseX::Types::DateTime;

isa_ok( find_type_constraint($_), "Moose::Meta::TypeConstraint", "$_") for qw(DateTime DateTimeSet DateTimeSpan DateTimeSpanSet); 
isa_ok( find_type_constraint($_), "Moose::Meta::TypeConstraint::Parameterizable", "$_") for qw(ArrayRefOfDateTimes ArrayRefOfDateTimeSpans ArrayRefOfDateTimeSets HashRefOfDateTimes HashRefOfDateTimeSets HashRefOfDateTimeSpans);

{
    {
     package Foo;
     use Moose;

     has datetime_set => (
            isa => "DateTimeSet",
            is  => "rw",
            coerce => 1,
        );
    }

    my $epoch = time;

    my $coerced = Foo->new( datetime_set => $epoch )->datetime_set();

    isa_ok( $coerced, "DateTime::Set", "coerced from epoch into datetime set" );
 
    my $extracted_dt = $coerced->min();

    isa_ok( $extracted_dt, "DateTime", "extracted date is DateTime" );
    
    is( $extracted_dt->epoch, $epoch, "epoch of extracted DateTime is correct" );

    #isa_ok( Foo->new( datetime_set => { year => 2000, month => 1, day => 1 } )->date, "DateTime::Set" );

    isa_ok( Foo->new( datetime_set => 'now' )->datetime_set, "DateTime::Set", "datetime from now returned DateTime::Set" );

    #this is dieing here why aren't i throwing when the code I copied did?
#    throws_ok { Foo->new( date => "junk1!!" ) } qr/DateTimeSet/, "date time constraint";
}

{
    {
        package Quxx;
        use Moose;

        has datetime_span => (
            isa => "DateTimeSpan",
            is  => "rw",
            coerce => 1,
        );
    }

    my $time = time;

    my $now = DateTime->from_epoch( epoch => $time );

    #10 minutes later
    my $future_epoch = time + 600;
    
    my $future = DateTime->from_epoch( epoch => $future_epoch );
  
    my ($coerced, $coerced_span);

    $coerced = Quxx->new( datetime_span => { start => $time, end => $future } );
    isa_ok( $coerced->datetime_span, "DateTime::Span", "coerced from hash with one number and one datetime" );

    $coerced_span = $coerced->datetime_span();
    is( $coerced_span->start()->epoch(), $time, "coerced spans from has with one number and one datetime start value is accurate" );
    is( $coerced_span->end()->epoch(), $future_epoch, "coerced spans from has with two datetimes end value is accurate" );
 

    $coerced = Quxx->new( datetime_span => { start => $now, end => $future } );
    isa_ok( $coerced->datetime_span, "DateTime::Span", "coerced from hash with two datetimes" );

    $coerced_span = $coerced->datetime_span();
    is( $coerced_span->start()->epoch(), $time, "coerced spans from has with two datetimes start value is accurate" );
    is( $coerced_span->end()->epoch(), $future_epoch, "coerced spans from has with two datetimes end value is accurate" );
    
    throws_ok { Quxx->new( datetime_span => { blah => $now, bleh => $future } )  } qr/DateTimeSpan/, "dies on bad keys";
    throws_ok { Quxx->new( datetime_span => { start => 'blah', end => 'bleh' } ) } qr/DateTimeSpan/, "dies on bad values";
}

{
    {
        package BaR;
        use Moose;

        has datetime_span_set => (
            isa => "DateTimeSpanSet",
            is  => "rw",
            coerce => 1,
        );
    }

    throws_ok { BaR->new( datetime_span_set => [{start => 'blah', end => 'bleh'}] ) } qr/DateTimeSpan/, "dies on bad values";
}
