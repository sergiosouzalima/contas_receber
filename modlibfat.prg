#include "global.ch"
#include "sql.ch"
#require "hbsqlit3"
#include "tbrowse.ch"
#include "inkey.ch"

FUNCTION INSERIR_DADOS_INICIAIS_FATURA(pBancoDeDados)
    LOCAL hStatusBancoDados := { "pBancoDeDados" => pBancoDeDados }
    LOCAL I, TIPO_FATURA
    LOCAL hFaturaRegistro := { => }
    LOCAL hTipoFaturaRegistro := { ;
        "FATURA_A_VENCER"     => {Date() - 10, CTOD('  /  /    ') , NUM_RANDOM() * 1.59   , 0.00}, ;
        "FATURA_VENCIDA"      => {Date() + 10, CTOD('  /  /    ') , NUM_RANDOM() * 1000.19, 0.00}, ;
        "FATURA_PAGA"         => {Date() - 20, Date() - 20        , NUM_RANDOM() * 1210.55, 0.00}, ;
        "FATURA_PAGA_ATRASO"  => {Date() - 05, Date() - 04        , NUM_RANDOM() * 20109.76,0.00}  ;
    }

    FOR I := 1 TO 2
        hFaturaRegistro["CODFAT"] := 0
        FOR EACH TIPO_FATURA IN hTipoFaturaRegistro
            hFaturaRegistro["CODCLI"] := NUM_RANDOM()
            hFaturaRegistro["DATA_VENCIMENTO"]  := TIPO_FATURA[1]
            hFaturaRegistro["DATA_PAGAMENTO"]   := TIPO_FATURA[2]
            hFaturaRegistro["VALOR_NOMINAL"]    := TIPO_FATURA[3]
            hFaturaRegistro["VALOR_PAGAMENTO"]  := TIPO_FATURA[4]
            IF TIPO_FATURA:__enumKey == "FATURA_PAGA" .OR. ;
               TIPO_FATURA:__enumKey == "FATURA_PAGA_ATRASO"
               hFaturaRegistro["VALOR_PAGAMENTO"] := hFaturaRegistro["VALOR_NOMINAL"]
            END IF
            GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro) 
        END LOOP
    END LOOP
RETURN .T.

FUNCTION GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
    LOCAL nSqlCodigoErro := 0
    LOCAL pBancoDeDados := hStatusBancoDados["pBancoDeDados"]
    LOCAL cSql := SQL_FATURA_INSERT
    LOCAL hFatura := {}

    IF hFaturaRegistro["CODFAT"] > 0
        cSql := SQL_FATURA_UPDATE
    ENDIF

    hFatura := { ;
        "CODFAT"            => ltrim(str(hFaturaRegistro["CODFAT"])), ;
        "CODCLI"            => ltrim(str(hFaturaRegistro["CODCLI"])) ,;
        "DATA_VENCIMENTO"   => AJUSTAR_DATA(hFaturaRegistro["DATA_VENCIMENTO"]), ;
        "DATA_PAGAMENTO"    => AJUSTAR_DATA(hFaturaRegistro["DATA_PAGAMENTO"]), ;
        "VALOR_NOMINAL"     => Alltrim(str(hFaturaRegistro["VALOR_NOMINAL"])), ;
        "VALOR_PAGAMENTO"   => Alltrim(str(hFaturaRegistro["VALOR_PAGAMENTO"])) ;  
    }

    cSql := StrSwap2( cSql, hFatura )

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro == SQLITE_ERROR
        MENSAGEM("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                 "SQL: " + sqlite3_errmsg(pBancoDeDados))
    ENDIF
RETURN .T.

FUNCTION EXCLUIR_FATURA(pBancoDeDados, nCodFat)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_DELETE 
    LOCAL pRegistro := NIL

    cSql := StrSwap2( cSql, {"CODFAT" => ltrim(str(nCodFat))} )

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    
    IF nSqlCodigoErro == SQLITE_ERROR
        Alert("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
              "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro

FUNCTION MOSTRAR_NOME_CLIENTE(pBancoDeDados, nCODCLI)
    LOCAL pRegistro := QUERY( ;
        pBancoDeDados, ;
        SQL_CLIENTE_SELECT_WHERE, ;
        { "CODCLI" => ltrim(str(nCodCli)) } )

    @11, 42 CLEAR TO 11, 88
    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        @11, 42 SAY sqlite3_column_text(pRegistro, 2) // NOMECLI
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 
RETURN .T.

FUNCTION ACIONAR_VISUALIZAR_CLIENTES()
    IF ReadVar() == Upper('hFaturaRegistro["CODCLI"]')
        VISUALIZAR_CLIENTES_F2()
    ENDIF
RETURN .T.

FUNCTION VISUALIZAR_CLIENTES_F2()
    LOCAL hTeclaOperacao := { K_ENTER => NIL }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL hAtributos := { ;
        "TITULO" => "Clientes", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "DIMENSIONS" => {"Row1" => 15, "Col1" => 55, "Row2" => 25, "Col2" => MaxCol()-05}, ;
        "LOOKUP" => .T., ;
        "TITULOS" => {;
            "Cod.Cliente", ;
            "Nome Cliente" ;
        }, ;
        "TAMANHO_COLUNAS" => { 11, 25 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM_SELECIONAR, ;
        "COMANDOS_TECLAS" => { K_ENTER } ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_COUNT)

    pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_SELECT_ALL)

    aValores := {}
    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aValores, { ;
            sqlite3_column_int(pRegistros, 1), ;   // CODCLI
            sqlite3_column_text(pRegistros, 2) ;   // NOMECLI          
        })
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 

    hAtributos["QTDREGISTROS"]  := nQtdRegistros
    hAtributos["VALORES"]       := { aValores, 1 }

    hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
    IF hTeclaRegistro["TeclaPressionada"] == K_ENTER
        GetActive():VarPut( hTeclaRegistro["RegistroEscolhido"] )
    ENDIF 
RETURN .T.