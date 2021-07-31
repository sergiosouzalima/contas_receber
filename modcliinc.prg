/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcliinc.prg
    Finalidade...: Manutencao cadastro de clientes (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
*/


FUNCTION modcliinc()

    hb_Alert( "Entrei no modcliinc() ",, "W+/N" )    

RETURN NIL

/*
PROCEDURE MANUTENCAO_CLIENTE( cOperacao, nLinhaBrowser, aColuna01 )
    LOCAL hClienteRegistro := { ;
        "CODCLI" => 0, "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
        "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
        "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .F.}
    LOCAL hStatusBancoDados := NIL
 
    hClienteRegistro := MOSTRAR_OBTER_CAMPOS_CLI(cOperacao, hClienteRegistro)

    hStatusBancoDados := DISPONIBILIZA_BANCO_DE_DADOS()

    GRAVAR_DADOS_CLIENTE(hStatusBancoDados["pBancoDeDados"], hClienteRegistro)
RETURN NIL

FUNCTION MOSTRAR_OBTER_CAMPOS_CLI(cOperacao, hClienteRegistro)
    LOCAL GetList := {}
    LOCAL nCODCLI := SPACE(04), cNOMECLI := SPACE(40), cENDERECO := SPACE(40)
    LOCAL cCEP := SPACE(09), cCIDADE := SPACE(20), cESTADO := SPACE(02) 
    LOCAL dULTICOMPRA := DATE(), lSITUACAO := .F.

    @08, 37 TO 19, 98 DOUBLE
    @09, 38 CLEAR TO 18, 97

    @08, 40 SAY "[ " + cOperacao + " ]"

    SET INTENSITY OFF

    @10,39 SAY "CODIGO.......: " GET nCODCLI      PICTURE "99999"         
    @11,39 SAY "NOME.........: " GET cNOMECLI     PICTURE "@!X"           
    @12,39 SAY "ENDERECO.....: " GET cENDERECO    PICTURE "@!X"           
    @13,39 SAY "CEP..........: " GET cCEP         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET cCIDADE      PICTURE "@!X"           
    @15,39 SAY "ESTADO.......: " GET cESTADO      PICTURE "!!"            
    @16,39 SAY "ULTIMA COMPRA: " GET dULTICOMPRA  PICTURE "DD/DD/DDDD"    
    //@17,39 SAY "SITUACAO.....: " GET lSITUACAO    PICTURE "L"
    READ

    hClienteRegistro["CODCLI"]     := nCODCLI
    hClienteRegistro["NOMECLI"]    := cNOMECLI
    hClienteRegistro["ENDERECO"]   := cENDERECO
    hClienteRegistro["CEP"]        := cCEP
    hClienteRegistro["CIDADE"]     := cCIDADE
    hClienteRegistro["ESTADO"]     := cESTADO
    hClienteRegistro["ULTICOMPRA"] := AJUSTAR_DATA(dULTICOMPRA)
    hClienteRegistro["SITUACAO"]   := lSITUACAO
    SET INTENSITY ON
RETURN hClienteRegistro
*/