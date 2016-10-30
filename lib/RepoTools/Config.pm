package RepoTools::Config;

use strict;
use Carp;
use Config::Tiny;
use Data::Dumper;

sub new
{
	my $name = shift;
	my $options = shift || {};

	my $self = bless({}, $name);

	confess "Missing 'filename' option"
		unless(defined($options->{'filename'}));

	$self->{'filename'} = $options->{'filename'};

	confess "Configuration file does not exist: $self->{'filename'}"
		unless(-f $self->{'filename'});
	confess "Cannot open configuration file: $self->{'filename'}"
		unless(-r $self->{'filename'});

	return $self;
}

sub parse
{
	my $self = shift;

	my $config = Config::Tiny->new()->read($self->{'filename'});

	confess "Error parsing configuration file: " . Config::Tiny->errstr
		if(Config::Tiny->errstr);
	confess "Error parsing configuration file: Found options outside [..repo..]: '" . join(',', keys(%{$config->{'_'}})) . "'"
		if(defined($config->{'_'}));

	while(my($repo, $repodata) = each(%{$config}))
	{
		confess "Error parsing configuration file: Missing source/dest for repo '$repo'"
			unless(defined($repodata->{'source'}) && defined($repodata->{'dest'}));

		while(my($key, $value) = each(%{$repodata}))
		{
			confess "Error parsing configuration file: Unknown option '$key'"
				unless($key =~ /^(source|dest|disabled)$/);
		}
	}

	return $config;
}

1;