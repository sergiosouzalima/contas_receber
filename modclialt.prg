/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modclialt.prg
    Finalidade...: Manutencao cadastro de clientes (alteracao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#include "sql.ch"

FUNCTION modclialt(nCodCli)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hClienteRegistro := { => }

    MOSTRA_TELA_CADASTRO(ProcName())

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := QUERY( ;
        hStatusBancoDados["pBancoDeDados"], ;
        SQL_CLIENTE_SELECT_WHERE, ;
        { "CODCLI" => ltrim(str(nCodCli)) } )

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
    @10,06 SAY "CODIGO.......: " GET hClienteRegistro["CODCLI"]      PICTURE "@9" WHEN .F.
    
    @11,06 SAY "NOME.........: " ;
        GET hClienteRegistro["NOMECLI"] ;    
        PICTURE "@!" ;
        VALID !Empty(hClienteRegistro["NOMECLI"])
    @12,06 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!"           
    @13,06 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999"     
    @14,06 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!"           
    @15,06 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!"            
    @16,06 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999"
    @17,06 SAY "SITUACAO.....: " ;
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