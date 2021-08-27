/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatexc.prg
    Finalidade...: Manutencao cadastro de faturas (exclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#include "sql.ch"

FUNCTION modfatexc(nCodFat)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hfaturaRegistro := { => }
    LOCAL nQTD_FATURA := 0

    MOSTRA_TELA_CADASTRO(ProcName())

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := QUERY( ;
        hStatusBancoDados["pBancoDeDados"], ;
        SQL_FATURA_SELECT_WHERE, ;
        { "CODFAT" => ltrim(str(nCodFat)) } )     

    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        hfaturaRegistro["CODFAT"]           := nCodFat
        hfaturaRegistro["CODCLI"]           := sqlite3_column_int(pRegistro, 2)
        hfaturaRegistro["NOMECLI"]          := sqlite3_column_text(pRegistro, 3)
        hfaturaRegistro["DATA_VENCIMENTO"]  := CTOD(sqlite3_column_text(pRegistro, 4))
        hfaturaRegistro["DATA_PAGAMENTO"]   := CTOD(sqlite3_column_text(pRegistro, 5))
        hfaturaRegistro["VALOR_NOMINAL"]    := sqlite3_column_double(pRegistro, 6)
        hfaturaRegistro["VALOR_PAGAMENTO"]  := sqlite3_column_double(pRegistro, 7)
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 

    SET INTENSITY OFF
    @10,06 SAY "FATURA.........: " GET hfaturaRegistro["CODFAT"]            PICTURE "@9" WHEN .F.
    @11,06 SAY "CLIENTE........: " ;
        GET hfaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        WHEN .F.
    @11,37 GET hfaturaRegistro["NOMECLI"] PICTURE "@!" WHEN .F.

    @12,06 SAY "DATA VENCIMENTO: " GET hfaturaRegistro["DATA_VENCIMENTO"]   PICTURE "99/99/9999" WHEN .F.
    @13,06 SAY "DATA PAGAMENTO.: " GET hfaturaRegistro["DATA_PAGAMENTO"]    PICTURE "99/99/9999" WHEN .F. 
    @14,06 SAY "VALOR_NOMINAL..: " GET hFaturaRegistro["VALOR_NOMINAL"]     PICTURE "@E 9,999,999.99" WHEN .F.         
    @15,06 SAY "VALOR_PAGAMENTO: " GET hFaturaRegistro["VALOR_PAGAMENTO"]   PICTURE "@E 9,999,999.99" WHEN .F.
    SET INTENSITY ON

    IF CONFIRMA("Confirma exclusao?")    
        EXCLUIR_FATURA(hStatusBancoDados["pBancoDeDados"], nCodFat)
        MENSAGEM("fatura excluida com sucesso")
    ENDIF
RETURN NIL