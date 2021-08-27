#include "global.ch"
#include "sql.ch"
#require "hbsqlit3"

FUNCTION OBTER_QUANTIDADE_CLIENTES(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_COUNT 
    LOCAL pRegistros := NIL
    LOCAL nQTD_CLIENTE := 0

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)
    sqlite3_step(pRegistros)    
    nQTD_CLIENTE := sqlite3_column_int(pRegistros, 1) // QTD_CLIENTE  

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros)
RETURN nQTD_CLIENTE

FUNCTION OBTER_CLIENTES(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_SELECT_ALL  
    LOCAL pRegistros := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR  
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN pRegistros

FUNCTION INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
    LOCAL hStatusBancoDados := { "pBancoDeDados" => pBancoDeDados }
    LOCAL aNomes := {"JOSE", "JOAQUIM", "MATHEUS", "PAULO", "CRISTOVAO", "ANTONIO"}
    LOCAL aSobreNomes := {"SILVA", "SOUZA", "LIMA", "MARTINS", "GOMES", "PAIVA"}
    LOCAL I, hClienteRegistro := { => }

    FOR I := 1 TO 12
        hClienteRegistro := { ;
            "CODCLI"        =>  0, ;
            "NOMECLI"       =>  AllTrim(aNomes[NUM_RANDOM()] + " " + aSobreNomes[NUM_RANDOM()]), ; 
            "ENDERECO"      =>  AllTrim(StrTran("RUA SANTO #1", "#1", aNomes[NUM_RANDOM()])), ;
            "CEP"           =>  "04040-000", ;
            "CIDADE"        =>  AllTrim("SAO " + aNomes[NUM_RANDOM()]), ;
            "ESTADO"        =>  "SP", ;
            "ULTICOMPRA"    =>  Date(), ;
            "SITUACAO"      =>  NIL ; 
        }

        GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)    
    END LOOP

RETURN .T.

FUNCTION GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
    LOCAL nSqlCodigoErro := 0
    LOCAL pBancoDeDados := hStatusBancoDados["pBancoDeDados"]
    LOCAL cSql := SQL_CLIENTE_INSERT
    LOCAL hCliente := {}

    IF hClienteRegistro["CODCLI"] > 0
        cSql := SQL_CLIENTE_UPDATE
    ENDIF

    hCliente := { ;
        "CODCLI"        =>  AllTrim(Str(hClienteRegistro["CODCLI"])), ;
        "NOMECLI"       =>  AllTrim(hClienteRegistro["NOMECLI"]), ; 
        "ENDERECO"      =>  AllTrim(hClienteRegistro["ENDERECO"]), ;
        "CEP"           =>  hClienteRegistro["CEP"], ;
        "CIDADE"        =>  AllTrim(hClienteRegistro["CIDADE"]), ;
        "ESTADO"        =>  hClienteRegistro["ESTADO"], ;
        "ULTICOMPRA"    =>  AJUSTAR_DATA(hClienteRegistro["ULTICOMPRA"]), ;
        "SITUACAO"      =>  hClienteRegistro["SITUACAO"] ;
    }

    cSql := StrSwap2( cSql, hCliente )
    
    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN .T.

FUNCTION EXCLUIR_CLIENTE(pBancoDeDados, nCodCli)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_CLIENTE_DELETE 
    LOCAL pRegistro := NIL
 
    cSql := StrSwap2( cSql, {"CODCLI" => ltrim(str(nCODCLI))} )

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)    
    IF nSqlCodigoErro == SQLITE_ERROR    
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN pRegistro
