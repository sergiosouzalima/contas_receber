/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcli.prg
    Finalidade...: Manutencao cadastro de clientes
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
*/
#include "global.ch"
#require "hbsqlit3"

PROCEDURE MODCLI()
    LOCAL nProgramaEscolhido := 0

    nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    
    WHILE !(nProgramaEscolhido == SAIR)
        MANUTENCAO_CLIENTE(nProgramaEscolhido)
        
        nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    ENDDO
RETURN

FUNCTION MOSTRA_MENU_MODCLI()
    LOCAL nITEM
    LOCAL nProgramaEscolhido
    LOCAL aMenu := {{"1 - INCLUSAO ", "INCLUSAO DE CLIENTE"     },;
        {"2 - ALTERACAO", "ALTERACAO DE DADOS DE CLIENTE"},;
        {"3 - EXCLUSAO ", "EXCLUSAO DE CLIENTE"      },;
        {"4 - CONSULTA ", "CONSULTA DE CLIENTE"      },;
        {"5 - RETORNA  ", "RETORNA AO MENU ANTERIOR"}}

    MOSTRA_TELA_PADRAO()
  
    MOSTRA_QUADRO(aMenu)
  
    FOR nITEM := 1 TO LEN(aMenu)
        @ 09 + nITEM, 10 PROMPT aMenu[nITEM,01] message aMenu[nITEM,02]
    NEXT
    MENU TO nProgramaEscolhido
RETURN nProgramaEscolhido

PROCEDURE MANUTENCAO_CLIENTE(nProgramaEscolhido)
    LOCAL hClienteRegistro := {"CODCLI" => 0,; 
    "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
    "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
    "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .F.}

    MOSTRAR_TELA_CLI()

    hClienteRegistro := MOSTRAR_OBTER_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)

    GRAVAR_DADOS_CLIENTE(hClienteRegistro)

RETURN 

PROCEDURE MOSTRAR_TELA_CLI()
    @08, 37 TO 19, 98 DOUBLE
RETURN

FUNCTION MOSTRAR_OBTER_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)
    LOCAL GetList := {}
    LOCAL nCODCLI := SPACE(04), cNOMECLI := SPACE(40), cENDERECO := SPACE(40)
    LOCAL cCEP := SPACE(09), cCIDADE := SPACE(20), cESTADO := SPACE(02) 
    LOCAL dULTICOMPRA := DATE(), lSITUACAO := .F.

    SET INTENSITY OFF

    @10,39 SAY "CODIGO.......: " GET nCODCLI      PICTURE "99999"         
    @11,39 SAY "NOME.........: " GET cNOMECLI     PICTURE "@!X"           
    @12,39 SAY "ENDERECO.....: " GET cENDERECO    PICTURE "@!X"           
    @13,39 SAY "CEP..........: " GET cCEP         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET cCIDADE      PICTURE "@!X"           
    @15,39 SAY "ESTADO.......: " GET cESTADO      PICTURE "AA"            
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
