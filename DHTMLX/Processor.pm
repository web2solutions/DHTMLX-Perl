package DHTMLX::Processor;

    @ISA = qw/ DHTMLX::Core /;
    
    use strict;
    use warnings 'all';
    use JSON;
    use Win32::ASP;
    use Win32::OLE;
    use utf8;
    use WWW::Mechanize;
    use HTML::TreeBuilder::XPath;
    use HTML::Entities;
    my $entitieschars = 'ÁÍÓÚÉÄÏÖÜËÀÌÒÙÈÃÕÂÎÔÛÊáíóúéäïöüëàìòùèãõâîôûêÇç';
    
    my $servidor;

    sub new
    {
        my $class = shift;
        my $self = {

	};
	
	bless $self, $class;
	
	if($self->framework eq "ASP")
	{
	    use Win32::OLE;
	    Win32::OLE->Option( CP => Win32::OLE::CP_UTF8, LCID => 65001 );
	}
       
        return $self;
    }
 
    sub toFile ()
    {
	my($self, $diretorio, $nome, $documento, $tipo, $fylesystem, $logo, $dirlogo, $cabecalho, $rodape, $usarlayout, $formatoDocumento, $dimensaoMargem, $orientation) = @_;
	
	use MsOffice::Word::HTML::Writer;
	use File::Path qw{mkpath}; # make_path
	
	$documento = encode_entities($documento, $entitieschars);
	$cabecalho = encode_entities($cabecalho, $entitieschars);
	$rodape = encode_entities($rodape, $entitieschars);
	
	my $dimensaoDocumento;
	my $fA4 = "21.0cm 29.7cm";
	my $fA5 = "14.8cm 21.0cm";
	my $fA6 = "10.5cm 14.8cm";
	my $fExecutive = "18.4cm 26.6cm";
	my $fLetter = "21.5cm 27.9cm";
	my $fOficio = "21.5cm 35.5cm";
	my $fEvelope10 = "10.4cm 24.1cm";
	
	if(! $orientation)
	{
	    $orientation = "portrait";
	}
	elsif($orientation eq "portrait")
	{
	    $orientation = "portrait";
	}
	elsif($orientation eq "landscape")
	{
	    $orientation = "landscape";
	    $fA4 = "29.7cm 21.0cm";
	    $fA5 = "21.0cm 14.8cm";
	    $fA6 = "14.8cm 10.5cm";
	    $fExecutive = "26.6cm 18.4cm";
	    $fLetter = "27.9cm 21.5cm";
	    $fOficio = "35.5cm 21.5cm";
	    $fEvelope10 = "24.1cm 10.4cm";
	}
	
	if(! $formatoDocumento)
	{
		$dimensaoDocumento = $fA4;
	}
	elsif($formatoDocumento eq "A4")
	{
		$dimensaoDocumento = $fA4;
	}
	elsif($formatoDocumento eq "A5")
	{
		$dimensaoDocumento = $fA5;
	}
	elsif($formatoDocumento eq "A6")
	{
		$dimensaoDocumento = $fA6;
	}
	elsif($formatoDocumento eq "executive")
	{
		$dimensaoDocumento = $fExecutive;
	}
	elsif($formatoDocumento eq "oficio")
	{
		$dimensaoDocumento = $fOficio;
	}
	elsif($formatoDocumento eq "envelope_10")
	{
		$dimensaoDocumento = $fEvelope10;
	}
	elsif($formatoDocumento eq "letter")
	{
		$dimensaoDocumento = $fLetter;
	}
	
	if(! $dimensaoMargem)
	{
		$dimensaoMargem = "2.5cm 3.0cm 3.0cm 2.5cm"; # sup, esq, dir, inf
	}
		
	$cabecalho=~ s/\.\.\/upld\/empresa\///g;
	
	my $dirTmp = $diretorio."\\tmp";
	my $dirImg = $diretorio."\\imagens";
	my $dirFile = $diretorio."\\arquivos";
		
	-d $diretorio || mkpath($diretorio);
	-d $dirTmp || mkpath($dirTmp); 
	-d $dirImg || mkpath($dirImg); 
	-d $dirFile || mkpath($dirFile);
	
	#print $diretorio;
	#exit;

	my $mudadirTrabalho = chdir $dirTmp;
	
	#my $strhtml = decode_entities($documento);
	
	if($tipo eq "html")
	{
	    #salva o resultado da consulta no formato html
	    open FH, ">$nome.html";
	    print FH $documento;	
	    close FH;
	}
	
	elsif($tipo eq "doc")
	{
	
	    my $doc = MsOffice::Word::HTML::Writer->new(
		title        => "$nome",
		WordDocument => {View => 'Print'},
	    );
	
	    if($usarlayout eq 1)
	    {
	        $doc->attach("$logo", $dirlogo."\\$logo");
		if($cabecalho && $rodape)
		{
		    $doc->create_section(
			page => {
			    size   => "$dimensaoDocumento",
			    margin => "$dimensaoMargem", # sup, esq, dir, inf
			    "mso-page-orientation" => $orientation
			}, 
			header => sprintf(
			    "$cabecalho"
			),
			footer => sprintf(
			    "$rodape",
			    $doc->field('PAGE'),
			    $doc->field('NUMPAGES')
			)
		    );
		}
		elsif($cabecalho && !$rodape)
		{
		    $doc->create_section(
			page => {
			    size   => "$dimensaoDocumento",
			    margin => "$dimensaoMargem", # sup, esq, dir, inf
			    "mso-page-orientation" => $orientation
			}, 
			header => sprintf(
			    "$cabecalho"
			)
		    );
		}
		elsif(!$cabecalho && $rodape)
		{
		    $doc->create_section(
			    page => {
				size   => "$dimensaoDocumento",
				margin => "$dimensaoMargem", # sup, esq, dir, inf
				"mso-page-orientation" => $orientation
			    }, 
			    footer => sprintf(
				"$rodape",
				$doc->field('PAGE'),
				$doc->field('NUMPAGES')
			    )
		    );
		}
		elsif(!$cabecalho && !$rodape)
		{
		    $doc->create_section(
			page => {
			    size   => "$dimensaoDocumento",
			    margin => "$dimensaoMargem", # sup, esq, dir, inf
			    "mso-page-orientation" => $orientation
			}
		    );
		}
	    }
	    $doc->write($documento);
	    $doc->save_as("$nome.doc");
	}
	
	elsif($tipo eq "pdf")
	{
	    #cria um arquivo html te porar para conversao em pdf
	    open FH, ">$nome.html";
	    print FH $documento;	
	    close FH;
		
	    #gera pdf usando ASPPDF
	    my $arquivoinicial;
	    my $arquivofinal;
	    
	    my $curll = $fylesystem;
	    $curll =~ s/\.\.\///gi;
	    my $fullurl = 'http://'.$self->getdomain()->Item().'/'. $curll . 'tmp/'.$nome.'.html';
	    #print $fullurl;
		
	    $arquivoinicial = "$nome.html";
	    $arquivofinal = "$nome.pdf";
		
	    my $Pdf = CreateObject Win32::OLE 'Persits.Pdf' or die $!;
	    my $Doc = $Pdf->CreateDocument;
	    #$Doc->{Title} = "$nome";
	    #$Doc->{Creator} = "DHTMLX Perl Processor";
	    #print $fullurl;
	    #my $Font = $Doc->Fonts("Helvetica");
	    #$Doc->Rotate(180);
	    if($orientation eq "landscape")
	    {
		$Doc->ImportFromUrl($fullurl, "landscape=true");
	    }
	    else
	    {
		$Doc->ImportFromUrl($fullurl);
	    }
		
	    my $Filename = $Doc->Save(  $diretorio."\\tmp\\".$arquivofinal , 1 );
	    #print  $diretorio."tmp/".$arquivofinal ;

	    #apaga arquivo html temporario		
	    #my $str=$dirTmp."\\$nome.html";
	    #unlink($str);
	}
		
	my %resposta = (
		status  => "sucesso",
		resposta =>  "Novo documento de texto $nome.$tipo criado com sucesso",
		nomearquivo =>  "$nome",
		tipo =>  "$tipo",
		url =>  "$fylesystem/tmp/$nome.$tipo",
        );
        my $json = \%resposta;
        my $json_text = to_json($json, { utf8  => 1 });
        print $json_text;
    }
    
    sub getCEP ()
    {
	my($self, $cep) = @_;
	my $URI="http://www.buscacep.correios.com.br/servicos/dnec/index.do";
	my $html;
	my $table_rows;
	my $resultado;
	my $mech = WWW::Mechanize->new;
	$mech->post($URI);
	$mech->submit_form(
		form_name => "Geral",
		fields      => {
			relaxation => "$cep",
		}
	);
	$html = $mech->content;
	$mech->update_html( $html );
	my $tree = HTML::TreeBuilder::XPath->new;
	$tree->parse( $html );
	$table_rows = $tree->findnodes( '//table[@bgcolor="gray"]/tr[1]' );
	foreach my $row ( $table_rows->get_nodelist )
	{
		my $tree_tr = HTML::TreeBuilder::XPath->new;
		$tree_tr->parse( $row->as_HTML );
		my $endereco = $tree_tr->findvalue('//td[1]');
		my $bairro = $tree_tr->findvalue('//td[2]');
		my $cidade = $tree_tr->findvalue('//td[3]');
		my $estado = $tree_tr->findvalue('//td[4]');
		my $cep = $tree_tr->findvalue('//td[5]');
		$resultado = {
			endereco => encode_entities($endereco, $entitieschars) || "",
			bairro => encode_entities($bairro, $entitieschars) || "",
			cidade => encode_entities($cidade, $entitieschars) || "",
			estado => "$estado",
			cep => "$cep"
		};
		$tree_tr->delete;
	}
	my %resposta = (
		status  => "sucesso",
		resposta =>  "Cep encontrado nos Correios com sucesso",
		resultado =>  encode_entities($resultado, $entitieschars) || "",
        );
        my $json = \%resposta;
        my $json_text = to_json($json);
        print $json_text;
    }
    
    sub savecol()
    {
	my( $self, $table, $column_name, $column_nvalue, $p_key_name, $p_key_value, $column_type ) = @_;
	
	$p_key_name = $p_key_name || $self->error( "you must define the primary key name" );
	$p_key_value = $p_key_value || $self->error( "you must define the primary key value" );
	$column_name = $column_name || $self->error( "you must define the primary column name" );
	$column_nvalue = $column_nvalue || $self->error( "you must define the primary column value" );
	$column_type = $column_type || $self->error( "you must define the primary column type" );
	
	if($column_name eq $p_key_name)
	{
	    $self->error( "you can not edit the primary key value" )
	}
	
	my $conexao = $self->conectar();
	my $sql = "UPDATE $table SET $column_name = ? WHERE $p_key_name = ?";

	my $sth = $conexao->prepare($sql);
	$sth->execute( $column_nvalue, $p_key_value ) or $self->error( $conexao->errstr );
	$sth->finish;
	$conexao->disconnect;

	my %resposta = (
	    status  => "sucesso",
	    resposta =>  "salvo com sucesso"
	);     

	my $json = \%resposta;
	my $json_text = to_json($json);                           
	print $json_text;
    }
    
    sub delrow()
    {
	my( $self, $table, $p_key_name, $p_key_value ) = @_;
	
	$p_key_name = $p_key_name || $self->error( "you must define the primary key name" );
	$p_key_value = $p_key_value || $self->error( "you must define the primary key value" );
	
	
	
	
	my $conexao = $self->conectar();
	my $sql = "DELETE FROM $table WHERE $p_key_name IN($p_key_value)";

	my $sth = $conexao->prepare($sql);
	$sth->execute(  ) or $self->error( $conexao->errstr );
	$sth->finish;
	$conexao->disconnect;

	my %resposta = (
	    status  => "sucesso",
	    response =>  "deletado com sucesso"
	);     

	my $json = \%resposta;
	my $json_text = to_json($json);                           
	print $json_text;
    }
    
    sub saveprocessor()
    {
	my( $self, $table, $p_key_name, $column_name, $column_nvalue, $mode, $rowId, $newId  ) = @_;
	
	use XML::Mini::Document;
	
	my $errormsg = undef();
	
	$mode = $mode || $self->error( "you must define the mode" );
	$rowId = $rowId || $self->error( "you must define the row ID" );
	$newId = $newId || $self->error( "you must define the new row ID if exists or current ID" );
	my $action;
	$p_key_name = "id";
		
	if(!defined($column_nvalue))
	{
	    undef($column_nvalue);
	}
	
	sub cadastraregistro()	
	{					
		$newId = 0;
		return "insert";
	}
	sub editarregistro()
	{
		if(!defined($column_nvalue))
		{
			undef($column_nvalue);
		}
		my $conexao = $self->conectar();
		my $sql="UPDATE $table SET $column_name = ? WHERE $p_key_name = ?;";
		my $dbh = $conexao->prepare($sql);
		$dbh->execute($column_nvalue, $rowId) or error($conexao->errstr);
		$dbh->finish;
		$conexao->disconnect;
		return "update";
	}
	sub deletarregistro()
	{	
		my $conexao = $self->conectar();
		my $sql="DELETE FROM $table WHERE $p_key_name = ?;";
		my $dbh = $conexao->prepare($sql);
		$dbh->execute($rowId) or error($conexao->errstr);
		$dbh->finish;
		$conexao->disconnect;
		return "delete";
	}
	
	sub error()
	{
		$errormsg = shift;
		return "error";
		exit;
	}

	# cria o xml
	my $newDoc = XML::Mini::Document->new();
	my $newDocRoot = $newDoc->getRoot();

	# seta o header do xml
	my $xmlHeader = $newDocRoot->header('xml');
	$xmlHeader->attribute('version', '1.0');
	$xmlHeader->attribute('encoding', 'UTF-8');

	# cria o NODE pai com nome de data
	my $dataNode = $newDocRoot->createChild('data');
	
	if(defined($mode))
	{
		if($mode eq "inserted")
		{
		    $action = cadastraregistro();
		}
		elsif($mode eq "deleted")
		{
		    $action = deletarregistro();
		}
		else
		{
		    $action = editarregistro();
		}
		
		if($action eq "error")
		{
		    my $actionNode = $dataNode->createChild('action')->text($errormsg);
		    $actionNode->attribute('type', "error");
		    $actionNode->attribute('sid', "$rowId");
		    $actionNode->attribute('tid', "$rowId");
		}
		else
		{
		    my $actionNode = $dataNode->createChild('action');
		    $actionNode->attribute('type', "$action");
		    $actionNode->attribute('sid', "$rowId");
		    $actionNode->attribute('tid', "$rowId");	
		}
	}
	else
	{
		my $actionNode = $dataNode->createChild('action')->text('!nativeeditor_status parameter is missing');
		$actionNode->attribute('type', "error");
		$actionNode->attribute('sid', "$rowId");
		$actionNode->attribute('tid', "$rowId");
	}
	
	print $newDoc->toString();
    }

    # Implementar somente em casos específicos, pois o Perl destroi o objeto automaticamente quando estiver fora de escopo.
    #sub DESTROY
    #{
    #   print "  GestordeInteresses::DESTROY foi executado.";
    #}
1;