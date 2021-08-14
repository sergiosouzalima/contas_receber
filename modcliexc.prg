/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modclialt.prg
    Finalidade...: Manutencao cadastro de clientes (exclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modcliexc(nCodCli)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hClienteRegistro := { => }
    LOCAL cImpossivelExcluir := ;
    "Impossivel excluir. Existe(m) #nQTD_CLIENTE fatura(s) associada(s) a este cliente"
    LOCAL nQTD_CLIENTE := 0

    hb_DispBox( LINHA_INI_CENTRAL, COLUNA_INI_CENTRAL,;
        LINHA_FIM_CENTRAL, COLUNA_FIM_CENTRAL, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := OBTER_CLIENTE(hStatusBancoDados["pBancoDeDados"], nCodCli)

    DO WHILE sqlite3_step(pRegistro) == 100
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
        WHEN .F.
    @12,39 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!" WHEN .F.      
    @13,39 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999" WHEN .F.   
    @14,39 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!" WHEN .F.      
    @15,39 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!" WHEN .F.        
    @16,39 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999" WHEN .F.
    @17,39 SAY "SITUACAO.....: " ;
        GET hClienteRegistro["SITUACAO"] ;
        PICTURE "!" ;
        WHEN .F. 
    SET INTENSITY ON

    IF CONFIRMA("Confirma exclusao?")    
        IF (nQTD_CLIENTE := OBTER_QUANTIDADE_CLIENTE_EM_FATURAS(hStatusBancoDados["pBancoDeDados"], nCodCli)) > 0
            cImpossivelExcluir := StrTran(cImpossivelExcluir, "#nQTD_CLIENTE", ltrim(str(nQTD_CLIENTE)))
            MENSAGEM(cImpossivelExcluir)
        ELSE
            EXCLUIR_CLIENTE(hStatusBancoDados["pBancoDeDados"], nCodCli)
            MENSAGEM("Cliente excluido com sucesso")
        ENDIF
    ENDIF
RETURN NIL