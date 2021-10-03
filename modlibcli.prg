/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modlibcli.prg
    Finalidade...: Rotinas comuns e disponiveis para o modulo de clientes
    Autor........: Sergio Lima
    Atualizado em: Outubro, 2021
*/

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

    FOR I := 1 TO 6
        hClienteRegistro := { ;
            "CODCLI"        =>  0, ;
            "NOMECLI"       =>  AllTrim(aNomes[NUM_RANDOM()] + " " + aSobreNomes[NUM_RANDOM()]), ; 
            "ENDERECO"      =>  AllTrim(StrTran("RUA SANTO #1", "#1", aNomes[NUM_RANDOM()])), ;
            "FONE_DDI"      =>  "55", ;
            "FONE_DDD"      =>  "11", ;
            "FONE"          =>  "955555555", ;
            "EMAIL"         =>  "meu-email.mail.net", ; 
            "DATA_NASC"     =>  Date(), ;
            "DOCUMENTO"     =>  "123.789.456-10", ;
            "CEP"           =>  "04040-000", ;
            "CIDADE"        =>  AllTrim("SAO " + aNomes[NUM_RANDOM()]), ;
            "ESTADO"        =>  "SP" ;
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
        "#CODCLI"        =>  AllTrim(Str(hClienteRegistro["CODCLI"])), ;
        "#NOMECLI"       =>  AllTrim(hClienteRegistro["NOMECLI"]), ; 
        "#ENDERECO"      =>  AllTrim(hClienteRegistro["ENDERECO"]), ;
        "#FONE_DDI"      =>  AllTrim(hClienteRegistro["FONE_DDI"]), ;
        "#FONE_DDD"      =>  AllTrim(hClienteRegistro["FONE_DDD"]), ;
        "#FONE"          =>  AllTrim(hClienteRegistro["FONE"]), ;
        "#EMAIL"         =>  AllTrim(hClienteRegistro["EMAIL"]), ;
        "#DATA_NASC"     =>  AJUSTAR_DATA(hClienteRegistro["DATA_NASC"]), ;
        "#DOCUMENTO"     =>  AllTrim(hClienteRegistro["DOCUMENTO"]), ;
        "#CEP"           =>  AllTrim(hClienteRegistro["CEP"]), ;
        "#CIDADE"        =>  AllTrim(hClienteRegistro["CIDADE"]), ;
        "#ESTADO"        =>  AllTrim(hClienteRegistro["ESTADO"]) ;
    }

    cSql := hb_StrReplace( cSql, hCliente )

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