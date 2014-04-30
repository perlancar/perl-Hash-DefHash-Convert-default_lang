package Perinci::Sub::Convert::default_lang;

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(convert_property_default_lang);

# VERSION
# DATE

our %SPEC;

$SPEC{convert_property_default_lang} = {
    v => 1.1,
    summary => 'Convert default_lang property in Rinci function metadata',
    args => {
        meta => {
            schema  => 'hash*', # XXX defhash
            req     => 1,
            pos     => 0,
        },
        new => {
            summary => 'New value',
            schema  => ['str*'],
            req     => 1,
            pos     => 1,
        },
    },
    result_naked => 1,
};
sub convert_property_default_lang {
    my ($self, %args) = @_;

    my $meta = $args{meta};
    my $new  = $args{new};

    # collect defhashes
    my @dh = ($meta);
    push @dh, @{ $meta->{links} } if $meta->{links};
    push @dh, @{ $meta->{examples} } if $meta->{examples};
    push @dh, $meta->{result} if $meta->{result};
    push @dh, values %{ $meta->{args} } if $meta->{args};
    push @dh, grep {ref($_) eq 'HASH'} @{ $meta->{tags} };

    my $i = 0;
    for my $dh (@dh) {
        $i++;
        my $old = $dh->{default_lang} // "en_US";
        return if $old eq $new && $i == 1;
        $dh->{default_lang} = $new;
        $self->push_lines('', "$mvar\->{default_lang} = '$new';");
        for my $prop (qw/summary description/) {
            my $propo = "$prop.alt.lang.$value";
            my $propn = "$prop.alt.lang.$new";
            next unless defined($m->{$prop}) ||
                defined($m->{$propo}) || defined($m->{$propn});
            if (defined $m->{$prop}) {
                $m->{$propo} //= $m->{$prop};
                $self->push_lines("$mvar\->{'$propo'} //= $mvar\->{'$prop'};");
            }
            if (defined $m->{$propn}) {
                $m->{$prop} = $m->{$propn};
                $self->push_lines("$mvar\->{'$prop'} = $mvar\->{'$propn'};");
            } else {
                delete $m->{$prop};
                $self->push_lines("delete $mvar\->{'$prop'};");
            }
            if (defined $m->{$propn}) {
                delete $m->{$propn};
                $self->push_lines("delete $mvar\->{'$propn'};","");
            }
        }
    }
}

1;
# ABSTRACT: Convert default_lang property value in defhash

=head1 SYNOPSIS

 use Hash::DefHash::Convert::default_lang qw(convert_property_default_lang);
 convert_property_default_lang(meta => $meta, new => 'id_ID');


=head1 SEE ALSO

L<Rinci>

=cut
