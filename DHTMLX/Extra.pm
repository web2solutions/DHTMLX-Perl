package DHTMLX::Extra;

=encoding utf8
=head1 NAME

DHTMLX::Extra - Tarefas extras ao módulo DHTMLX.

=head1 SYNOPSIS

    use DHTMLX::Extra;

    # Instantiating DHTMLX::Extra object

    my $extra = DHTMLX::Extra->new();

    
=head1 DESCRIPTION

Fornece métodos e propriedades extras ao módulo DHTMLX.

Ex: Envio de E-mail, Configurações pessoais como logo, nome da empresa

O uso do objeto DHTMLX::Extra não é obrigatório

=cut

# ABSTRACT: Basics tasks on DHTMLX Perl module

@ISA = qw/ DHTMLX::Core /;
	
	use strict;
	use warnings 'all';
	
	
	
 	# construtor new do objeto
        sub new
        {
            my $class = shift;
            my $self = {
                
            };

            
            bless $self, $class;
            
            return $self, $class;
        }
	
	
	sub company_name
	{
		my( $self ) = @_;
		
		my $company_name;
		my $conexao = $self->conectar();
		my $sql="SELECT empresa FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		while(my $registro = $sth->fetchrow_hashref())
		{	$company_name = $registro->{'empresa'}; }
		$sth->finish;
		$conexao->disconnect;
		return $company_name;
	}
	
	sub company_phone
	{
		my( $self ) = @_;
		my $telefone;
		my $conexao = $self->conectar();
		my $sql="SELECT telefone FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		while(my $registro = $sth->fetchrow_hashref())
		{	$telefone = $registro->{'telefone'}; }
		$sth->finish;
		$conexao->disconnect;
		return $telefone;
	}
	
	sub company_address
	{
		my( $self ) = @_;
		my $endereco;
		my $bairro;
		my $cidade;
		my $estado;
		my $cep;
		my $strendereco;
		my $conexao = $self->conectar();
		my $sql="SELECT endereco,bairro,cidade,estado,cep FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		while(my $registro = $sth->fetchrow_hashref())
		{
			$endereco = $registro->{'endereco'};
			$bairro = $registro->{'bairro'};
			$cidade = $registro->{'cidade'};
			$estado = $registro->{'estado'};
			$cep = $registro->{'cep'};
			$strendereco="$endereco, $bairro. $cidade - $estado. cep.: $cep.";
		}
		$sth->finish;
		$conexao->disconnect;
		return $strendereco;
	}
	
	sub company_logo
	{
		my($self) = @_;
		my $logo;
		my $conexao = $self->conectar();
		my $sql="SELECT logo FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		while(my $registro = $sth->fetchrow_hashref())
		{
			$logo = $registro->{'logo'};
		}
		$sth->finish;
		$conexao->disconnect;
		return "logo_docs.png";
	}
	
	
	sub send_mail
	{
		my($self, $nomealvo, $emailalvo, $assunto, $mensagem) = @_;
		
		use Mail::SendEasy;
		
		my $empresa;
		my $email;
		my $senha;
		my $smtp;
		my $contato;
		
		my $conexao = $self->conectar();
		my $sql="SELECT nomesite,usrmail,passmail,smtphost,emailcont FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		if(my $registro = $sth->fetchrow_hashref())
		{
			$empresa = $registro->{'nomesite'};
			$email = $registro->{'usrmail'};
			$senha = $registro->{'passmail'};
			$smtp = $registro->{'smtphost'};
			$contato = $registro->{'emailcont'};
		}
		$sth->finish;
		$conexao->disconnect;
		
		my $mail = new Mail::SendEasy(
			smtp => "$smtp",
			user => "$email" ,
			pass => "$senha" ,
		);
		
		my $status = $mail->send(
			from    => "$email" ,
			from_title => "$empresa" ,
			reply   => "$contato" ,
			error   => "$contato" ,
			to      => "$emailalvo" ,
			subject => "$assunto - $empresa" ,
			msg     => "" ,
			html    => "$mensagem" ,
		);
		if (!$status)
		{
			return $mail->error ;
		}else
		{
			return 1;
		}
	}
	
	
	sub send_personal_mail
	{
		my($self, $from_name, $from_mail, $nomealvo, $emailalvo, $assunto, $mensagem) = @_;
		
		use Mail::SendEasy;
		
		my $empresa;
		my $email;
		my $senha;
		my $smtp;
		my $contato;
		
		my $conexao = $self->conectar();
		my $sql="SELECT nomesite,usrmail,passmail,smtphost,emailcont FROM tbl_conf WHERE 1=1;";
		my $sth =$conexao->prepare($sql);
		$sth->execute() or $self->erro($conexao->errstr);
		if(my $registro = $sth->fetchrow_hashref())
		{
			$empresa = $registro->{'nomesite'};
			$email = $registro->{'usrmail'};
			$senha = $registro->{'passmail'};
			$smtp = $registro->{'smtphost'};
			$contato = $registro->{'emailcont'};
		}
		$sth->finish;
		$conexao->disconnect;
		
		my $mail = new Mail::SendEasy(
			smtp => "$smtp",
			user => "$email" ,
			pass => "$senha" ,
		);
		
		my $status = $mail->send(
			from    => "$from_mail" ,
			from_title => "$from_name" ,
			reply   => "$from_mail" ,
			error   => "$from_mail" ,
			to      => "$emailalvo" ,
			subject => "$assunto - $empresa" ,
			msg     => "" ,
			html    => "$mensagem" ,
		);
		if (!$status)
		{
			return $mail->error ;
		}else
		{
			return 1;
		}
	}
	
	sub preparaurl
	{
		my($self, $string) = @_;
		$string=~ s/ /-/g;
		my %chars = (	"\\&" => "E",			" " => "-",			"," => "-",			"\\." => "-",	"\\/" => "-",			"\\;" => "-",			"\\!" => "-",			"\\?" => "-",			"/" => "-",			"'" => "",			"ç" => "c",			"Ç" => "C",			"á" => "a",			"ä" => "a",			"à" => "a",			"ã" => "a",			"â" => "a",			"Á" => "A",			"Ä" => "A",			"À" => "A",			"Ã" => "A",			"Â" => "A",			"é" => "e",			"ë" => "e",			"è" => "e",			"ê" => "e",			"É" => "E",			"Ë" => "E",			"È" => "E",			"Ê" => "E",			"í" => "i",			"ï" => "i",			"ì" => "i",			"î" => "i",			"Í" => "I",			"Ï" => "I",			"Ì" => "I",			"Î" => "I",			"ó" => "o",			"ö" => "o",			"ò" => "o",			"õ" => "o",			"ô" => "o",			"Ó" => "O",			"Ö" => "O",			"Ò" => "O",			"Õ" => "O",			"Ô" => "O",			"ú" => "u",			"ü" => "u",			"ù" => "u",			"û" => "u",			"Ú" => "U",			"Ü" => "U",			"Ù" => "U",			"Û" => "U",		);
		foreach my $especial (keys %chars)
		{
			my $errado=$especial;
			my $certo=$chars{$especial};
			$string=~ s/$errado/$certo/g;
		}
		return $string
	}
	

1;

__END__
=encoding utf8
 
=head1 NAME

DHTMLX::Extra

=head1 VERSION

version 0.001

=head1 SYNOPSIS

use strict;
use warnings 'all';
use Win32::ASP;



    


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