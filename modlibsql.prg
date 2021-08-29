/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modlibsql.prg
    Finalidade...: Rotinas comuns e disponiveis para todo o sistema
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "global.ch"
#include "sql.ch"
#require "hbsqlit3"

FUNCTION QUERY(pBancoDeDados, cSql, hParam)
    LOCAL nSqlCodigoErro := 0
    LOCAL pRegistros := NIL
    LOCAL hParamQuery := iif(ValType(hParam) == "U", NIL, hParam)

    cSql := StrSwap2( cSql, hParamQuery )

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR  
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN pRegistros

FUNCTION QUERY_COUNTER(pBancoDeDados, cSql, hParam)
    LOCAL nSqlCodigoErro := 0
    LOCAL pRegistros := NIL
    LOCAL nQtdRegistros := 0
    LOCAL hParamQuery := iif(ValType(hParam) == "U", NIL, hParam)

    cSql := StrSwap2( cSql, hParamQuery )

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)
    sqlite3_step(pRegistros)    
    nQtdRegistros := sqlite3_column_int(pRegistros, 1)  

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros)    
RETURN nQtdRegistros