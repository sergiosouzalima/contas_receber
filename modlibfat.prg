#include "global.ch"
#include "sql.ch"
#require "hbsqlit3"
#include "tbrowse.ch"
#include "inkey.ch"


FUNCTION OBTER_QUANTIDADE_FATURAS(pBancoDeDados)
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

FUNCTION OBTER_FATURA(pBancoDeDados, nCodFat)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := SQL_FATURA_SELECT_WHERE
    LOCAL pRegistro := NIL

    cSql := StrSwap2( cSql, {"CODFAT" => ltrim(str(nCodFat))} )

    pRegistro := sqlite3_prepare(pBancoDeDados, cSql)

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro == SQLITE_ERROR
        Alert("Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
              "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN pRegistro

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
    LOCAL pRegistro := OBTER_CLIENTE(pBancoDeDados, nCODCLI)

    @11, 75 CLEAR TO 11, 112
    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        @11, 75 SAY sqlite3_column_text(pRegistro, 2) // NOMECLI
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 
RETURN .T.

FUNCTION ACIONAR_VISUALIZAR_CLIENTES()
    IF ReadVar() == Upper('hFaturaRegistro["CODCLI"]')
        VISUALIZAR_CLIENTES()
    ENDIF
RETURN .T.

FUNCTION VISUALIZAR_CLIENTES()
    LOCAL oBrowse := TBrowseNew( ;
                        LOOKUP_LIN_INI, LOOKUP_COL_INI, ;
                        LOOKUP_LIN_FIM, LOOKUP_COL_FIM)
    LOCAL pRegistros := NIL
    LOCAL aTitulos := { "Cod.Cliente", "Nome Cliente" }
    LOCAL aColuna01 := {}, aColuna02 := {}
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL n := 1, nCursor, cColor, nRow, nCol
    LOCAL nQtdCliente := 0, nKey := 0

    hb_DispBox( LOOKUP_CONTORNO_LIN_INI, LOOKUP_CONTORNO_COL_INI, ;
                LOOKUP_CONTORNO_LIN_FIM, LOOKUP_CONTORNO_COL_FIM, ;
                hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistros := OBTER_CLIENTES(hStatusBancoDados["pBancoDeDados"])

    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aColuna01, sqlite3_column_int(pRegistros, 1))  // CODCLI
        AADD(aColuna02, sqlite3_column_text(pRegistros, 2)) // NOMECLI
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 
 
    oBrowse:colorSpec     := "W/N, N/BG"
    oBrowse:ColSep        := hb_UTF8ToStrBox( "│" )
    oBrowse:HeadSep       := hb_UTF8ToStrBox( "╤═" )
    oBrowse:FootSep       := hb_UTF8ToStrBox( "╧═" )
    oBrowse:SkipBlock     := {| nSkip, nPos | ;
                               nPos := n, ;
                               n := iif ( nSkip > 0, ;
                                           Min( Len( aColuna01 ), n + nSkip ), Max( 1, n + nSkip ) ;
                                        ), ;
                               n - nPos }
 
    oBrowse:AddColumn(TBColumnNew(aTitulos[01], {|| aColuna01[n]})) // CODCLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[02], {|| aColuna02[n]})) // NOMECLI
    oBrowse:GetColumn( 2 ):Picture := "@!"
  
    oBrowse:Freeze := 2 
    nCursor := SetCursor( 0 )
    nRow := Row()
    nCol := Col()

    nQtdCliente := OBTER_QUANTIDADE_CLIENTES(hStatusBancoDados["pBancoDeDados"])
    hb_DispOutAt(LOOKUP_RODAPE_LIN, LOOKUP_RODAPE_COL, StrZero(nQtdCliente,4) +;
    " Clientes | [ESC]=Sair [ENTER]=Escolher ["+ SETAS + "]=Movimentar")
       
    WHILE .T.
        oBrowse:ForceStable()

        nKey := Inkey(0)

        IF oBrowse:applyKey( nKey ) == TBR_EXIT .OR. nKey == K_ENTER 
            EXIT
        ENDIF
    ENDDO

    IF LastKey() == K_ENTER 
        GetActive():VarPut( Eval( oBrowse:getColumn( oBrowse:colPos() ):block ) )
    ENDIF

    @LOOKUP_CONTORNO_LIN_INI, LOOKUP_CONTORNO_COL_INI ;
        CLEAR TO ;
    LOOKUP_CONTORNO_LIN_FIM, LOOKUP_CONTORNO_COL_FIM
    
    SetPos( nRow, nCol )
    SetColor( cColor )
    SetCursor( nCursor )    
RETURN .T.