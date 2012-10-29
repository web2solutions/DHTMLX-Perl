package DHTMLX::Usuario;
@ISA = qw/ DHTMLX::Core /;
	
	use strict;
	use warnings 'all';
	
	my $id;
        my $nome;
        my $login;
	
 	# construtor new do objeto
        sub new
        {
            my $class = shift;
            my $self = {
                id => "",
                nome => "",
                login => "",
            };
		
            $id=$self->{_id};
            $nome=$self->{_nome};
            $login=$self->{_login};
            
            bless $self, $class;
            
            return $self, $class;
        }
	
	
	sub login
	{
		my($self) = @_;
		my $login = $self->getCookieKey('IME_EXTRANET_USUARIO_LOGIN','user_login');
		return $login;
	}
	
	sub checklogin
	{
		my($self) = @_;
		my $estadologin = $self->getCookieKey('IME_EXTRANET_USUARIO_LOGIN','user_logado');
		if (not $estadologin eq "true")
		{
			print '
				<script>window.parent.location = "http://"+document.domain+"/extranet";</script>
			';
		}
	}
	
	sub nome
	{	
		my($self) = @_;
		my $nomeusuario = $self->getCookieKey('IME_EXTRANET_USUARIO_LOGIN','user_nome');
		return $nomeusuario;
	}
	
	sub id
	{	
		my($self) = @_;		
		my $id = $self->getCookieKey('IME_EXTRANET_USUARIO_LOGIN','user_id');
		return $id;
	}
	sub grupo
	{	
		my($self) = @_;
		my $grupo = $self->getCookieKey('IME_EXTRANET_USUARIO_LOGIN','user_tipo');
		return $grupo;
	}
	
	sub isPermitidoExcluir
	{
		my($self) = @_;
		my $permitidoexcluir;
		my $grupo2 = $self->grupo();
		if($grupo2 eq "administrador" || $grupo2 eq "manutencao")
		{
			$permitidoexcluir = 1;
		}
		else
		{
			my $conexao = $self->conectar();
			my $sql="SELECT permitidoexcluir FROM tbl_conf WHERE 1=1;";
			my $sth = $conexao->prepare($sql);
			$sth->execute() or core->erro($conexao->errstr);
			while(my $registro = $sth->fetchrow_hashref())
			{
				$permitidoexcluir = $registro->{'permitidoexcluir'};
			}
			$sth->finish;
			$conexao->disconnect;
		}
		return $permitidoexcluir;
	}

1;

__END__
=encoding utf8
 
=head1 NAME

CommerceManager::Usuario

=head1 VERSION

version 0.001

=head1 SYNOPSIS

use strict;
use warnings 'all';
use Win32::ASP;


use base 'ASP4::FormHandler';
use vars __PACKAGE__->VARS; # Import $Request, $Response, $Session, etc:

use CommerceManager::Core;
use CommerceManager::Usuario;

my $core = new CommerceManager::Core($Request, $Response, $Server);

my $usuario = new CommerceManager::Usuario();
$usuario->checklogin(); # verifica se ta logado, senao reload window pai para /extranet
my $idusuario = $usuario->id();
my $grupo = $usuario->grupo(); 
    


=head1 METHODS

=head2 sincroniza
    
    $tribunal->sincroniza

Realiza busca na base de dados do TRTES e retorna um obj JSON contendo todo o andamento

=head1 RESPONSE FORMAT

   


=head1 EXAMPLES

Para um exemplo de uso, visualize consulta_TRTES.pl sob o diretorio example/ na raiz da distriuição deste módulo
    
=head1 AUTHORS

José Eduardo Perotta de Almeida, C<< eduardo at web2solutions.com.br >>


=head1 LICENSE AND COPYRIGHT

Copyright 2011 José Eduardo Perotta de Almeida.

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


__END__