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

    hClienteRegistro := modcli_get_fields(hClienteRegistro, UPDATING_MODE)

    IF hb_keyLast() == K_ENTER
        hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
        MENSAGEM("Cliente alterado com sucesso")
    ENDIF
RETURN NIL