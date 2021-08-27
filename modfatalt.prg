/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatalt.prg
    Finalidade...: Manutencao cadastro de faturas (alteracao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#include "sql.ch"

FUNCTION modfatalt(nCodFat)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hFaturaRegistro := { => }

    MOSTRA_TELA_CADASTRO(ProcName())

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := QUERY( ;
        hStatusBancoDados["pBancoDeDados"], ;
        SQL_FATURA_SELECT_WHERE, ;
        { "CODFAT" => ltrim(str(nCodFat)) } )    

    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        hfaturaRegistro["CODFAT"]           := nCodFat
        hfaturaRegistro["CODCLI"]           := sqlite3_column_int(pRegistro, 2)
        hfaturaRegistro["NOMECLI"]          := PAD( sqlite3_column_text(pRegistro, 3), 40 )
        hfaturaRegistro["DATA_VENCIMENTO"]  := CTOD(sqlite3_column_text(pRegistro, 4))
        hfaturaRegistro["DATA_PAGAMENTO"]   := CTOD(sqlite3_column_text(pRegistro, 5))
        hfaturaRegistro["VALOR_NOMINAL"]    := sqlite3_column_double(pRegistro, 6)
        hfaturaRegistro["VALOR_PAGAMENTO"]  := sqlite3_column_double(pRegistro, 7)        
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 

    SET INTENSITY OFF
    @10,06 SAY "FATURA..............: " GET hfaturaRegistro["CODFAT"]            PICTURE "@9" WHEN .F.

    @11,06 SAY "CODIGO CLIENTE <F2>.: " ;
        GET hFaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        VALID hFaturaRegistro["CODCLI"] > 0 .AND. ;
            QUERY_COUNTER( ;
                hStatusBancoDados["pBancoDeDados"], ;
                SQL_CLIENTE_COUNT_WHERE, ;
                { "CODCLI" => ltrim(str(hFaturaRegistro["CODCLI"]))} ) == 1 .AND. ; 
            MOSTRAR_NOME_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"])
                
    @12,06 SAY "DATA VENCIMENTO.....: " GET hfaturaRegistro["DATA_VENCIMENTO"]   PICTURE "99/99/9999"
    @13,06 SAY "DATA PAGAMENTO......: " GET hfaturaRegistro["DATA_PAGAMENTO"]    PICTURE "99/99/9999"
    @14,06 SAY "VALOR_NOMINAL.......: " GET hFaturaRegistro["VALOR_NOMINAL"]     PICTURE "@E 9,999,999.99"        
    @15,06 SAY "VALOR_PAGAMENTO.....: " GET hFaturaRegistro["VALOR_PAGAMENTO"]   PICTURE "@E 9,999,999.99"
    SET KEY K_F2 TO ACIONAR_VISUALIZAR_CLIENTES(ReadVar())
    READ
    SET KEY K_F2 TO
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
        MENSAGEM("Fatura alterada com sucesso")
    ENDIF
RETURN NIL