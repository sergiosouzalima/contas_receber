#include "global.ch"
#include "sql.ch"
#include "hbgtinfo.ch"
#require "hbsqlit3"


FUNCTION OBTER_QUANTIDADE_FATURA(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_COUNT 
    LOCAL pRegistros := NIL
    LOCAL nQTD_FATURA := 0

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)
    sqlite3_step(pRegistros)    
    nQTD_FATURA := sqlite3_column_int(pRegistros, 1) // QTD_FATURA  

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR  
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros)
RETURN nQTD_FATURA

FUNCTION OBTER_FATURAS(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_SELECT_ALL  
    LOCAL pRegistros := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN pRegistros

FUNCTION INSERIR_DADOS_INICIAIS_FATURA(pBancoDeDados)
    LOCAL hStatusBancoDados := { "pBancoDeDados" => pBancoDeDados }
    LOCAL I, hFaturaRegistro := { => }

    // a vencer
    FOR I := 1 TO 3
        hFaturaRegistro["CODFAT"]           := 0
        hFaturaRegistro["CODCLI"]           := NUM_RANDOM()
        hFaturaRegistro["DATA_VENCIMENTO"]  := Date() - 10 
        hFaturaRegistro["DATA_PAGAMENTO"]   := CTOD('  /  /    ')
        hFaturaRegistro["VALOR_NOMINAL"]    := NUM_RANDOM() * 1.59
        hFaturaRegistro["VALOR_PAGAMENTO"]  := 0.00
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)    
    END LOOP

    // vencidas
    FOR I := 1 TO 4
        hFaturaRegistro["CODFAT"]           := 0
        hFaturaRegistro["CODCLI"]           := NUM_RANDOM()
        hFaturaRegistro["DATA_VENCIMENTO"]  := Date() + 10 
        hFaturaRegistro["DATA_PAGAMENTO"]   := CTOD('  /  /    ')
        hFaturaRegistro["VALOR_NOMINAL"]    := NUM_RANDOM() * 1000.19
        hFaturaRegistro["VALOR_PAGAMENTO"]  := 0.00
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)    
    END LOOP

    // pagas
    FOR I := 1 TO 3
        hFaturaRegistro["CODFAT"]           := 0
        hFaturaRegistro["CODCLI"]           := NUM_RANDOM()
        hFaturaRegistro["DATA_VENCIMENTO"]  := Date() - 20
        hFaturaRegistro["DATA_PAGAMENTO"]   := Date() - 20
        hFaturaRegistro["VALOR_NOMINAL"]    := NUM_RANDOM() * 1210.55
        hFaturaRegistro["VALOR_PAGAMENTO"]  := hFaturaRegistro["VALOR_NOMINAL"]
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)    
    END LOOP    

    // pagas em atraso
    FOR I := 1 TO 2
        hFaturaRegistro["CODFAT"]           := 0
        hFaturaRegistro["CODCLI"]           := NUM_RANDOM()
        hFaturaRegistro["DATA_VENCIMENTO"]  := Date() - 5
        hFaturaRegistro["DATA_PAGAMENTO"]   := Date() - 4
        hFaturaRegistro["VALOR_NOMINAL"]    := NUM_RANDOM() * 20109.76
        hFaturaRegistro["VALOR_PAGAMENTO"]  := hFaturaRegistro["VALOR_NOMINAL"]
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)    
    END LOOP    

RETURN .T.

FUNCTION GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
    LOCAL nSqlCodigoErro := 0
    LOCAL pBancoDeDados := hStatusBancoDados["pBancoDeDados"]
    LOCAL cSql := SQL_FATURA_INSERT

    IF hFaturaRegistro["CODFAT"] > 0
        cSql := SQL_FATURA_UPDATE
    ENDIF

    cSql := StrTran(cSql, "#CODCLI",            ltrim(str(hFaturaRegistro["CODCLI"])))
    cSql := StrTran(cSql, "#DATA_VENCIMENTO",   AJUSTAR_DATA(hFaturaRegistro["DATA_VENCIMENTO"]))
    cSql := StrTran(cSql, "#DATA_PAGAMENTO",    AJUSTAR_DATA(hFaturaRegistro["DATA_PAGAMENTO"]))
    cSql := StrTran(cSql, "#VALOR_NOMINAL",     Alltrim(str(hFaturaRegistro["VALOR_NOMINAL"])))
    cSql := StrTran(cSql, "#VALOR_PAGAMENTO",   Alltrim(str(hFaturaRegistro["VALOR_PAGAMENTO"])))

    
    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN .T.
/*
FUNCTION OBTER_FATURA(pBancoDeDados, nCodCli)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_SELECT_WHERE
    LOCAL pRegistro := NIL

    cSql := StrTran(cSql, "#CODCLI", ltrim(str(nCodCli)))

    pRegistro := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR //IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro

FUNCTION EXCLUIR_FATURA(pBancoDeDados, nCodCli)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_DELETE 
    LOCAL pRegistro := NIL

    cSql := StrTran(cSql, "#CODCLI", ltrim(str(nCodCli)))

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro == SQLITE_ERROR //IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro
*/