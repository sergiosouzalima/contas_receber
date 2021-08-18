/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatinc.prg
    Finalidade...: Manutencao cadastro de faturas (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#require "hbsqlit3"
#include "tbrowse.ch"

FUNCTION modfatinc()
    LOCAL GetList := {}
    LOCAL hFaturaRegistro := { ;
        "CODFAT" => 0, "CODCLI" => 0,;
        "DATA_VENCIMENTO" => DATE(), "DATA_PAGAMENTO" => CTOD('  /  /    '),;
        "VALOR_NOMINAL" => 0.00, "VALOR_PAGAMENTO" => 0.00 }
    LOCAL hStatusBancoDados := ABRIR_BANCO_DADOS()

    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
        CENTRAL_LIN_FIM, CENTRAL_COL_FIM, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    SET INTENSITY OFF
    @11,39 SAY "CODIGO CLIENTE <F2>.: " ;
        GET hFaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        VALID hFaturaRegistro["CODCLI"] > 0 .AND. ;
              OBTER_QUANTIDADE_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"]) == 1 .AND. ;
              MOSTRAR_NOME_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"])
    @12,39 SAY "DATA VENCIMENTO.....: " ;
        GET hFaturaRegistro["DATA_VENCIMENTO"] ;
        PICTURE "99/99/9999" ;
        VALID !Empty(hFaturaRegistro["DATA_VENCIMENTO"])          
    @13,39 SAY "DATA_PAGAMENTO......: " ;
        GET hFaturaRegistro["DATA_PAGAMENTO"] ;
        PICTURE "99/99/9999"     
    @14,39 SAY "VALOR_NOMINAL.......: " ;
        GET hFaturaRegistro["VALOR_NOMINAL"]  ;
        PICTURE "@E 9,999,999.99"          
    @15,39 SAY "VALOR_PAGAMENTO.....: " ;
        GET hFaturaRegistro["VALOR_PAGAMENTO"] ;
        PICTURE "@E 9,999,999.99"
    SET KEY K_F2 TO ACIONAR_VISUALIZAR_CLIENTES()
    READ
    SET KEY K_F2 TO
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
        MENSAGEM("Fatura cadastrado com sucesso!")
    ENDIF 
RETURN NIL

STATIC FUNCTION MOSTRAR_NOME_CLIENTE(pBancoDeDados, nCODCLI)
    LOCAL pRegistro := OBTER_CLIENTE(pBancoDeDados, nCODCLI)

    @11, 75 CLEAR TO 11, 112
    DO WHILE sqlite3_step(pRegistro) == SQLITE_ROW
        @11, 75 SAY sqlite3_column_text(pRegistro, 2) // NOMECLI
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 
RETURN .T.

STATIC FUNCTION ACIONAR_VISUALIZAR_CLIENTES()
    IF ReadVar() == Upper('hFaturaRegistro["CODCLI"]')
        VISUALIZAR_CLIENTES()
    ENDIF
RETURN .T.

STATIC FUNCTION VISUALIZAR_CLIENTES()
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