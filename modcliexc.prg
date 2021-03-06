/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcliexc.prg
    Finalidade...: Manutencao cadastro de clientes (exclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#include "sql.ch"

FUNCTION modcliexc(nCodCli)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hClienteRegistro := { => }
    LOCAL cImpossivelExcluir := ;
    "Impossivel excluir. Existe(m) #nQTD_CLIENTE fatura(s) associada(s) a este cliente"
    LOCAL nQTD_CLIENTE := 0

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
        hClienteRegistro["FONE_DDI"]    := PAD( sqlite3_column_text(pRegistro, 4), 02 )
        hClienteRegistro["FONE_DDD"]    := PAD( sqlite3_column_text(pRegistro, 5), 02 )
        hClienteRegistro["FONE"]        := PAD( sqlite3_column_text(pRegistro, 6), 10 )
        hClienteRegistro["EMAIL"]       := PAD( sqlite3_column_text(pRegistro, 7), 40 )
        hClienteRegistro["DATA_NASC"]   := CTOD(sqlite3_column_text(pRegistro, 8))
        hClienteRegistro["DOCUMENTO"]   := PAD( sqlite3_column_text(pRegistro, 9), 20 )
        hClienteRegistro["CEP"]         := PAD( sqlite3_column_text(pRegistro, 10), 09 )
        hClienteRegistro["CIDADE"]      := PAD( sqlite3_column_text(pRegistro, 11), 20 )
        hClienteRegistro["ESTADO"]      := PAD( sqlite3_column_text(pRegistro, 12), 02 )
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 

    hClienteRegistro := modcli_get_fields(hClienteRegistro, DELETING_MODE)

    IF CONFIRMA("Confirma exclusao?")    
        IF (nQTD_CLIENTE := QUERY_COUNTER( ;
                            hStatusBancoDados["pBancoDeDados"], ;
                            SQL_FATURA_CLIENTE_COUNT_WHERE, ;
                            { "CODCLI" => ltrim(str(nCodCli)) } )) > 0
            cImpossivelExcluir := StrTran(cImpossivelExcluir, "#nQTD_CLIENTE", ltrim(str(nQTD_CLIENTE)))
            MENSAGEM(cImpossivelExcluir)
        ELSE
            EXCLUIR_CLIENTE(hStatusBancoDados["pBancoDeDados"], nCodCli)
            MENSAGEM("Cliente excluido com sucesso")
        ENDIF
    ENDIF
RETURN NIL