/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modclialt.prg
    Finalidade...: Manutencao cadastro de clientes (alteracao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "global.ch"

FUNCTION modclialt(nCodCli)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hClienteRegistro := { ;
        "CODCLI" => 0,;
        "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
        "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
        "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .T.}

    hb_DispBox( LINHA_INI_CENTRAL, COLUNA_INI_CENTRAL,;
        LINHA_FIM_CENTRAL, COLUNA_FIM_CENTRAL, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := OBTER_CLIENTE(hStatusBancoDados["pBancoDeDados"], nCodCli)

    DO WHILE sqlite3_step(pRegistro) == 100
        hClienteRegistro["CODCLI"]      := nCodCli
        hClienteRegistro["NOMECLI"]     := sqlite3_column_text(pRegistro, 2)
        hClienteRegistro["ENDERECO"]    := sqlite3_column_text(pRegistro, 3)
        hClienteRegistro["CEP"]         := sqlite3_column_text(pRegistro, 4)
        hClienteRegistro["CIDADE"]      := sqlite3_column_text(pRegistro, 5)
        hClienteRegistro["ESTADO"]      := sqlite3_column_text(pRegistro, 6)
        hClienteRegistro["ULTICOMPRA"]  := sqlite3_column_text(pRegistro, 7)
        hClienteRegistro["SITUACAO"]    := sqlite3_column_text(pRegistro, 8)
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 

    SET INTENSITY OFF
    @10,39 SAY "CODIGO.......: " GET hClienteRegistro["CODCLI"]      PICTURE "@9" WHEN .F.
    @11,39 SAY "NOME.........: " GET hClienteRegistro["NOMECLI"]     PICTURE "@!X"           
    @12,39 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!X"           
    @13,39 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!X"           
    @15,39 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!"            
    @16,39 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999"
    @17,39 SAY "SITUACAO.....: " GET hClienteRegistro["SITUACAO"]    VALID "12" $ hClienteRegistro["SITUACAO"]
    READ
    SET INTENSITY ON

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)

    Alert("Cliente alterado",, "W+/N")
RETURN NIL