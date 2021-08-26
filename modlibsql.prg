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