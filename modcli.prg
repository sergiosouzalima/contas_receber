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
    LOCAL hClienteRegistro := {"nCODCLI" => 0,; 
    "cNOMECLI" => SPACE(40), "cENDERECO" => SPACE(40),;
    "cCEP" => SPACE(09), "cCIDADE" => SPACE(20),;
    "cESTADO" => SPACE(02), "dULTICOMPRA" => DATE(), "lSITUACAO" => .F.}

    MOSTRA_TELA_CLI()

    hClienteRegistro := MOSTRA_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)

    GRAVA_DADOS_CLIENTE(hClienteRegistro)

RETURN 

PROCEDURE MOSTRA_TELA_CLI()
    @08, 37 TO 19, 98 DOUBLE
RETURN

FUNCTION MOSTRA_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)
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

    hClienteRegistro["nCODCLI"]     := nCODCLI
    hClienteRegistro["cNOMECLI"]    := cNOMECLI
    hClienteRegistro["cENDERECO"]   := cENDERECO
    hClienteRegistro["cCEP"]        := cCEP
    hClienteRegistro["cCIDADE"]     := cCIDADE
    hClienteRegistro["cESTADO"]     := cESTADO
    hClienteRegistro["dULTICOMPRA"] := AJUSTAR_DATA(dULTICOMPRA)
    hClienteRegistro["lSITUACAO"]   := lSITUACAO
    SET INTENSITY ON
RETURN hClienteRegistro

FUNCTION GRAVA_DADOS_CLIENTE(hClienteRegistro)
    LOCAL aOpcoes := {"Ok"} 
    LOCAL pBancoDeDados := NIL
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := "INSERT INTO CLIENTE( " +;
    " cNOMECLI, cENDERECO, " +;
    " cCEP, cCIDADE, cESTADO, " +;
    " dULTICOMPRA) VALUES( " +;
    " '#cNOMECLI', '#cENDERECO', " +;
    " '#cCEP', '#cCIDADE', '#cESTADO', " +;
    " '#dULTICOMPRA'); "
    
    cSql := StrTran(cSql, "#cNOMECLI", hClienteRegistro["cNOMECLI"])
    cSql := StrTran(cSql, "#cENDERECO", hClienteRegistro["cENDERECO"])
    cSql := StrTran(cSql, "#cCEP", hClienteRegistro["cCEP"])
    cSql := StrTran(cSql, "#cCIDADE", hClienteRegistro["cCIDADE"])
    cSql := StrTran(cSql, "#cESTADO", hClienteRegistro["cESTADO"])
    cSql := StrTran(cSql, "#dULTICOMPRA", hClienteRegistro["dULTICOMPRA"])

    pBancoDeDados := ABRIR_BANCO_DE_DADOS()

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    IF nSqlCodigoErro > 0 // Erro ao executar SQL
        HB_Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados), aOpcoes, "W+/N")
    ENDIF
RETURN .T.
