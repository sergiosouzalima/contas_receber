#include "global.ch"
#include "sql.ch"
#include "hbgtinfo.ch"
#require "hbsqlit3"

FUNCTION OBTER_QUANTIDADE_CLIENTE(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_COUNT 
    LOCAL pRegistros := NIL
    LOCAL nQTD_CLIENTE := 0

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)
    sqlite3_step(pRegistros)    
    nQTD_CLIENTE := sqlite3_column_int(pRegistros, 1) // QTD_CLIENTE  

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros)
RETURN nQTD_CLIENTE

FUNCTION OBTER_CLIENTES(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_SELECT_ALL  
    LOCAL pRegistros := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistros

FUNCTION INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
    LOCAL hClienteRegistro := { "pBancoDeDados" => pBancoDeDados }
    LOCAL aNomes := {"JOSE", "JOAQUIM", "MATHEUS", "PAULO", "CRISTOVAO", "ANTONIO"}
    LOCAL aSobreNomes := {"SILVA", "SOUZA", "LIMA", "MARTINS", "GOMES", "PAIVA"}
    LOCAL I

    FOR I := 1 TO 10
        hClienteRegistro["CODCLI"]     := 0
        hClienteRegistro["NOMECLI"]    := aNomes[NUM_RANDOM()] + " " + aSobreNomes[NUM_RANDOM()] 
        hClienteRegistro["ENDERECO"]   := StrTran("RUA SANTO #1", "#1", aNomes[NUM_RANDOM()])
        hClienteRegistro["CEP"]        := "04040000"
        hClienteRegistro["CIDADE"]     := "SAO " + aNomes[NUM_RANDOM()]
        hClienteRegistro["ESTADO"]     := "SP"
        hClienteRegistro["ULTICOMPRA"] := Date()

        GRAVAR_CLIENTE(hClienteRegistro, hClienteRegistro)    
    END LOOP

RETURN .T.

FUNCTION GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
    LOCAL nSqlCodigoErro := 0
    LOCAL pBancoDeDados := hStatusBancoDados["pBancoDeDados"]
    LOCAL cSql := SQL_CLIENTE_INSERT

    IF hClienteRegistro["CODCLI"] > 0
        cSql := SQL_CLIENTE_UPDATE
        cSql := StrTran(cSql, "#CODCLI", ltrim(str(hClienteRegistro["CODCLI"]))) 
        cSql := StrTran(cSql, "#SITUACAO", hClienteRegistro["SITUACAO"])
    ENDIF

    cSql := StrTran(cSql, "#NOMECLI", AllTrim(hClienteRegistro["NOMECLI"]))
    cSql := StrTran(cSql, "#ENDERECO", AllTrim(hClienteRegistro["ENDERECO"]))
    cSql := StrTran(cSql, "#CEP", hClienteRegistro["CEP"])
    cSql := StrTran(cSql, "#CIDADE", AllTrim(hClienteRegistro["CIDADE"]))
    cSql := StrTran(cSql, "#ESTADO", hClienteRegistro["ESTADO"])
    cSql := StrTran(cSql, "#ULTICOMPRA", AJUSTAR_DATA( hClienteRegistro["ULTICOMPRA"] ))

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN .T.

FUNCTION OBTER_CLIENTE(pBancoDeDados, nCodCli)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_SELECT_WHERE
    LOCAL pRegistro := NIL

    cSql := StrTran(cSql, "#CODCLI", ltrim(str(nCodCli)))

    pRegistro := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro

FUNCTION EXCLUIR_CLIENTE(pBancoDeDados, nCodCli)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_DELETE 
    LOCAL pRegistro := NIL

    cSql := StrTran(cSql, "#CODCLI", ltrim(str(nCodCli)))

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro
