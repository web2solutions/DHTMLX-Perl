package DHTMLX::Core;

=encoding utf8
=head1 NAME

DHTMLX::Core - Basics tasks on DHTMLX Perl module.

=head1 SYNOPSIS

    use DHTMLX::Core;

    # Instantiating DHTMLX::Core object
    
    # using ASP - more about $Request, $Response and $Server on http://www.apache-asp.com/objects.html
    my $core = DHTMLX::Core->new( "ASP", $Request, $Response, $Server );

    # using CGI
    my $core = DHTMLX::Core->new( "CGI" );

    # usando Catalyst
    my $core = DHTMLX::Core->new( "Catalyst" );

=head1 DESCRIPTION

DHTMLX::Core provides generic features used on entire DHTMLX Perl module

=cut

# ABSTRACT: Basics tasks on DHTMLX Perl module

	use strict;
	use warnings 'all';
	#use Win32::ASP;
	#use Win32::OLE;
	use DBI;
	use Date::Day;
	use Date::Language;
	use Digest::MD5 qw(md5_hex);
	use HTML::Entities;
	use JSON;
	use Locale::Currency::Format;
	use File::Path qw{mkpath}; # make_path
	use File::stat;
	use Path::Class;

	use POSIX qw(locale_h strtod setlocale LC_MONETARY LC_CTYPE);
	
	# configuracoes de localidade
	setlocale(LC_CTYPE, "pt_BR");
	setlocale(LC_MONETARY, "pt_BR");
	
	# variaveis e definicoes iniciais
	my $dsn;
	my $conexao;
        my $SGDB = "PostgreSQL"; # PostgreSQL # SQL Server
        my $hostbanco; # 127.0.0.1
        my $instancia = "CLOUDWORK\\SQLEXPRESS"; # \\ duas barras para scape CLOUDWORK\\SQLEXPRESS - Para MS SQL Version
        my $nomebanco;
        my $userbanco; # sa
        my $senhabanco;
        my $driver = "ADO"; # Pg # ADO # ODBC
        
        my $framework = "ASP";
        my $request;
	my $response;
	my $server;
	my $cgi;
        
 
 	# construtor new do objeto
        sub new
        {
            my $class = shift;
	    my $conf = shift;
            my $self = {
		framework => $conf->{'framework'} || undef,
		request => $conf->{'Request'} || undef,
                response => $conf->{'Response'} || undef,
                server => $conf->{'Server'} || undef,
		SGDB => $conf->{'SGDB'} || undef, # PostgreSQL # SQL Server
		instancia => $conf->{'instancia'} || undef, # \\ duas barras para scape CLOUDWORK\\SQLEXPRESS - Para MS SQL Version
		hostbanco => $conf->{'hostbanco'} || undef,
		nomebanco => $conf->{'nomebanco'} || undef,
		userbanco => $conf->{'userbanco'} || undef,
		senhabanco => $conf->{'senhabanco'} || undef,
		driver => $conf->{'driver'} # Pg # ADO # ODBC
            };    
	    
	    if(defined($self->{SGDB}))
            {
		$SGDB = $self->{SGDB};
	    }
	    if(defined($self->{instancia}))
            {
		$instancia = $self->{instancia};
	    }
	    if(defined($self->{hostbanco}))
            {
		$hostbanco = $self->{hostbanco};
	    }
	    else
	    {
		die "database host is missing";
	    }
	    if(defined($self->{nomebanco}))
            {
		$nomebanco = $self->{nomebanco};
	    }
	    else
	    {
		die  "database name is missing";
	    }
	    if(defined($self->{userbanco}))
            {
		$userbanco = $self->{userbanco};
	    }
	    else
	    {
		die  "database user is missing";
	    }
	    if(defined($self->{senhabanco}))
            {
		$senhabanco = $self->{senhabanco};
	    }
	    else
	    {
		die "database password is missing";
	    }
	    if(defined($self->{driver}))
            {
		$driver = $self->{driver};
	    }
	    
	    
            if(defined($self->{framework}))
            {
		$framework = $self->{framework};
	    }
	    if($framework eq "ASP")
	    {
		#Win32::OLE->Option( CP => Win32::OLE::CP_UTF8, LCID => 65001 );
		# importa objetos ASP
		$request = $self->{request};
		$response = $self->{response};
		$server = $self->{server};
	    }	    
	    elsif($framework eq "CGI")
	    {
		use CGI;
		$cgi = new CGI;
	    }
	    
            
            bless $self, $class;
            return $self, $class;
        }
	
=head1 METHODS


=head2 conectar

    my $conexao = $core->conectar(); 

Provides a active DBI connection

    $conexao->disconnect;
    
End the active connection

=cut
	sub conectar()
	{
		my($self, $h, $d, $u, $p) = @_;
		
		$h = $h || $hostbanco;
		$d = $d || $nomebanco;
		$u = $u || $userbanco;
		$p = $p || $senhabanco;
		
		if($driver eq "ADO")
		{
			if($SGDB eq "PostgreSQL")
			{
				$dsn="	DRIVER={PostGreSQL UNICODE};
					SERVER=$h;
					DATABASE=$d;
					UID=$u;
					PWD=$p;
					OPTION=3;
					set lc_monetary=pt_BR;
					set lc_numeric=pt_BR;
					set lc_time=pt_BR;
					SET datestyle TO POSTGRES, DMY;
				";
				
				$conexao = DBI->connect("DBI:$driver:$dsn") or $self->error("problema ao conectar ao $SGDB");
			}
			elsif($SGDB eq "SQL Server")
			{
				$dsn = '
					Provider = SQLOLEDB.1;
					Password = '.$senhabanco.';
					Persist Security Info = True;
					User ID = '.$userbanco.';
					Initial Catalog = '.$nomebanco.';
					Data Source = '.$instancia.';
					SET DATEFORMAT dmy;
				';
				#=>
				#===> SQL Server Native Client 10.0 dando erro com ORDER BY
				#=>
				#DRIVER = {SQL Server Native Client 10.0};
				#SERVER = '.$instancia.';
				#DATABASE = '.$nomebanco.';
				#UID = '.$userbanco.';
				#PWD = '.$senhabanco.';
				$conexao = DBI->connect('DBI:'.$driver.':'.$dsn.'') or die "problema ao conectar ao $SGDB";
			}
		}
		elsif($driver eq "Pg")
		{
			$dsn = "dbname = $nomebanco;
				host = $hostbanco;
			";
			$conexao = DBI->connect("DBI:$driver:$dsn", "$userbanco", "$senhabanco", {'RaiseError' => 1}) or die "problema ao conectar ao $SGDB";
		}
		elsif($driver eq "ODBC")
		{
			$conexao = DBI->connect('dbi:ODBC:'.$nomebanco, "$userbanco", "$senhabanco") or die "problema ao conectar ao $SGDB";
		}
		return $conexao;
	}
	
=head2 SGDB

    my $sgdb_version = $core->SGDB(); 

Return the active sgdb factory


=cut
	sub SGDB()
	{
		my($self) = @_;
		return $SGDB;
	}

=head2 noInjection
    
    print $core->noInjection("te'st");
    # prints te&apos;st

Escape ' character with a html entitie.
It is used in Get and Post methods of this module
Prevent sql injection


=cut
	sub noInjection
	{
		my($self, $string) = @_;
		$string =~ s/\'/\&apos\;/g;
		$string =~ s/\</\&lt\;/g;
		$string =~ s/\>/\&gt\;/g;
		$string =~ s/\[/\&\#091\;/g;
		$string =~ s/\]/\&\#093\;/g;
		$string =~ s/select/sel\&\#101\;ct/g;
		$string =~ s/delete/del\&\#101\;te/g;
		$string =~ s/update/up\&\#100\;ate/g;
		$string =~ s/drop/dro\&\#112\;/g;
		$string =~ s/insert/ins\&\#101\;rt/g;
		$string =~ s/where/wh\&\#101\;re/g;
		$string =~ s/\'/\&apos\;/g;
		$string =~ s/\'/\&apos\;/g;
		return $string;
	}

=head2 error
    
    undef($foo);
    $foo = $foo || $core->error( "foo is undefined" )
    
    # prints
    
     	{
	    "response":"foo is undefined",
	    "status":"error"
	}

Prints a JSON string with errors details and exit the application;


=cut
	sub error
	{
	    my($self, $strErro) = @_;        
	    my %resposta = (
		status  => "error",
		response =>  $strErro,
	    );
	    my $json = \%resposta;
	    print to_json($json);
	    exit;
	}
	
=head2 Post
    
    my $value_from_post = $core->Post($inputname);

Retrieve data from POST method


=cut
	sub Post()
	{
		my($self, $item) = @_;
		if($framework eq "ASP")
		{
			return $self->noInjection($request->Form($item)->Item());
		}
		elsif($framework eq "CGI")
		{
			return $self->noInjection($cgi->param($item));
		}
		else
		{
			return "defina framework";
		}
	}
	
=head2 Get
    
    my $value_from_get = $core->Get($inputname);

Retrieve data from GET method


=cut
	sub Get()
	{
		my($self,$item) = @_;
		if($framework eq "ASP")
		{
			return $self->noInjection($request->QueryString($item)->Item());
		}
		elsif($framework eq "CGI")
		{
			return $self->noInjection($cgi->url_param($item));
		}
		else
		{
			return "framework undefined";
		}
		
	}
	
=head2 getpath
    
    my $abs_path = $core->getpath($vpath_string);

Return absolute path of a given virtual / alias path


=cut
	sub getpath()
	{
	    my($self, $vpath) = @_;
	    return $server->MapPath($vpath)
	}
	
	sub pega_fullpath()
	{
	    my($self, $vpath) = @_;
	    return $server->MapPath($vpath)
	}
	
	
	sub getCookie()
	{
		my($self,$nomedocookie) = @_;
		return $request->{Cookies}{$nomedocookie}->Item();	
	}
	
	sub getCookieKey()
	{
		my($self,$nomedocookie,$chave) = @_;
		return $request->{Cookies}{$nomedocookie}{$chave};	
	}
	

=head2 getdomain
    
    my $domain = $core->getdomain();

Return the domain application


=cut
	sub getdomain()
	{
	    my($self) = @_;
	    return $request->ServerVariables("server_name");
	}
	
=head2 framework
    
    my $framework_factory = $core->framework();

Return the framework factory in use


=cut
	sub framework()
	{
	    my( $self ) = @_;
	    return $framework;
	}
	
	
	
	sub getserver()
	{
	    my($self) = @_;
	    return $server;
	}
	
	
	
	
	
	
	
	
=head1 AUTHOR

José Eduardo Perotta de Almeida, C<< eduardo at web2solutions.com.br >>


=head1 LICENSE AND COPYRIGHT

Copyright 2012 José Eduardo Perotta de Almeida.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut
1;
