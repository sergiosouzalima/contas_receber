/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatexc.prg
    Finalidade...: Manutencao cadastro de faturas (exclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modfatexc(nCodFat)
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL pRegistro := NIL
    LOCAL hfaturaRegistro := { => }
    LOCAL nQTD_FATURA := 0

    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
        CENTRAL_LIN_FIM, CENTRAL_COL_FIM, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistro := OBTER_FATURA(hStatusBancoDados["pBancoDeDados"], nCodFat)

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
    @10,39 SAY "FATURA.........: " GET hfaturaRegistro["CODFAT"]            PICTURE "@9" WHEN .F.
    @11,39 SAY "CLIENTE........: " ;
        GET hfaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        WHEN .F.
    @11,70 GET hfaturaRegistro["NOMECLI"] PICTURE "@!" WHEN .F.

    @12,39 SAY "DATA VENCIMENTO: " GET hfaturaRegistro["DATA_VENCIMENTO"]   PICTURE "99/99/9999" WHEN .F.
    @13,39 SAY "DATA PAGAMENTO.: " GET hfaturaRegistro["DATA_PAGAMENTO"]    PICTURE "99/99/9999" WHEN .F. 
    @14,39 SAY "VALOR_NOMINAL..: " GET hFaturaRegistro["VALOR_NOMINAL"]     PICTURE "@E 9,999,999.99" WHEN .F.         
    @15,39 SAY "VALOR_PAGAMENTO: " GET hFaturaRegistro["VALOR_PAGAMENTO"]   PICTURE "@E 9,999,999.99" WHEN .F.
    SET INTENSITY ON

    IF CONFIRMA("Confirma exclusao?")    
        EXCLUIR_FATURA(hStatusBancoDados["pBancoDeDados"], nCodFat)
        MENSAGEM("fatura excluida com sucesso")
    ENDIF
RETURN NIL