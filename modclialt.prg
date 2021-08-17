/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modclialt.prg
    Finalidade...: Manutencao cadastro de clientes (alteracao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modclialt(nCodCli)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hClienteRegistro := { => }

    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
        CENTRAL_LIN_FIM, CENTRAL_COL_FIM, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := OBTER_CLIENTE(hStatusBancoDados["pBancoDeDados"], nCodCli)

    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        hClienteRegistro["CODCLI"]      := nCodCli
        hClienteRegistro["NOMECLI"]     := PAD( sqlite3_column_text(pRegistro, 2), 40 )
        hClienteRegistro["ENDERECO"]    := PAD( sqlite3_column_text(pRegistro, 3), 40 )
        hClienteRegistro["CEP"]         := PAD( sqlite3_column_text(pRegistro, 4), 09 )
        hClienteRegistro["CIDADE"]      := PAD( sqlite3_column_text(pRegistro, 5), 20 )
        hClienteRegistro["ESTADO"]      := PAD( sqlite3_column_text(pRegistro, 6), 02 )
        hClienteRegistro["ULTICOMPRA"]  := CTOD(sqlite3_column_text(pRegistro, 7))
        hClienteRegistro["SITUACAO"]    := sqlite3_column_text(pRegistro, 8)
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 

    SET INTENSITY OFF
    @10,39 SAY "CODIGO.......: " GET hClienteRegistro["CODCLI"]      PICTURE "@9" WHEN .F.
    
    @11,39 SAY "NOME.........: " ;
        GET hClienteRegistro["NOMECLI"] ;    
        PICTURE "@!" ;
        VALID !Empty(hClienteRegistro["NOMECLI"])
    @12,39 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!"           
    @13,39 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!"           
    @15,39 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!"            
    @16,39 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999"
    @17,39 SAY "SITUACAO.....: " ;
        GET hClienteRegistro["SITUACAO"] ;
        PICTURE "!" ;
        VALID hClienteRegistro["SITUACAO"] $ "SN" 
    READ
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
        MENSAGEM("Cliente alterado com sucesso")
    ENDIF
RETURN NIL