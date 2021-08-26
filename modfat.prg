/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfat.prg
    Finalidade...: Manutencao cadastro de faturas
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "global.ch"
#require "hbsqlit3"
#include "inkey.ch"
#include "tbrowse.ch"

PROCEDURE MODFAT()
    LOCAL hTeclaOperacao := { ;
        K_I => "modfatinc" , K_i => "modfatinc", ;
        K_A => "modfatalt" , K_a => "modfatalt", ;
        K_E => "modfatexc" , K_e => "modfatexc"  }
    LOCAL hTeclaRegistro := { "TeclaPressionada" => 0, "RegistroEscolhido" => 0 }
    LOCAL cOperacao := "", nQtdFatura := 0
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}

    MOSTRA_NOME_PROGRAMA(ProcName())

    hTeclaRegistro := VISUALIZAR_FATURAS(hTeclaOperacao, hTeclaRegistro)

    IF !(hTeclaRegistro["TeclaPressionada"] == K_ESC)
        &( NOME_PROGRAMA( ;
            hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
            hTeclaRegistro["RegistroEscolhido"] ) )
    ENDIF
RETURN

STATIC FUNCTION VISUALIZAR_FATURAS(hTeclaOperacao, hTeclaRegistro)
    LOCAL oBrowse := ;
        TBrowseNew(BROWSE_LIN_INI, BROWSE_COL_INI, BROWSE_LIN_FIM, BROWSE_COL_FIM)
    LOCAL pRegistros := NIL
    LOCAL aTitulos := { "Cod.Fatura", "Cod.Cliente", "Nome Cliente", ;
                        "Dt.Vencimento", "Dt.Pagamento", ;
                        "Valor Nominal", "Valor Pagamento" }
    LOCAL aColuna01 := {0}, aColuna02 := {0}
    LOCAL aColuna03 := {"-----------"}
    LOCAL aColuna04 := {CTOD(space(8))}, aColuna05 := {CTOD(space(8))}
    LOCAL aColuna06 := {0.00}, aColuna07 := {0.00}
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL n := 1, nCursor, cColor, nRow, nCol
    LOCAL nQtdFaturas := 0, nKey := 0

    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
        CENTRAL_LIN_FIM, CENTRAL_COL_FIM,;
        hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdFaturas := OBTER_QUANTIDADE_FATURAS(hStatusBancoDados["pBancoDeDados"])

    IF nQtdFaturas > 0
        aColuna01 := {}; aColuna02 := {}; aColuna03 := {}; aColuna04 := {}
        aColuna05 := {}; aColuna06 := {}; aColuna07 := {} 

        pRegistros := OBTER_FATURAS(hStatusBancoDados["pBancoDeDados"])

        DO WHILE sqlite3_step(pRegistros) == 100
            AADD(aColuna01, sqlite3_column_int(pRegistros, 1))  // CODFAT
            AADD(aColuna02, sqlite3_column_int(pRegistros, 2))  // CODCLI
            AADD(aColuna03, sqlite3_column_text(pRegistros, 3)) // NOMECLI
            AADD(aColuna04, sqlite3_column_text(pRegistros, 4)) // DATA_VENCIMENTO
            AADD(aColuna05, sqlite3_column_text(pRegistros, 5)) // DATA_PAGAMENTO
            AADD(aColuna06, FORMATAR_REAIS( sqlite3_column_double(pRegistros, 6) ) )// VALOR_NOMINAL
            AADD(aColuna07, FORMATAR_REAIS( sqlite3_column_double(pRegistros, 7) ) )// VALOR_PAGAMENTO
        ENDDO
        sqlite3_clear_bindings(pRegistros)
        sqlite3_finalize(pRegistros) 
    ENDIF
 
    oBrowse:colorSpec     := "W+/N, N/BG"
    oBrowse:ColSep        := hb_UTF8ToStrBox( "│" )
    oBrowse:HeadSep       := hb_UTF8ToStrBox( "╤═" )
    oBrowse:FootSep       := hb_UTF8ToStrBox( "╧═" )
    oBrowse:SkipBlock     := {| nSkip, nPos | ;
                               nPos := n, ;
                               n := iif ( nSkip > 0, ;
                                           Min( Len( aColuna01 ), n + nSkip ), Max( 1, n + nSkip ) ;
                                        ), ;
                               n - nPos }
 
    oBrowse:AddColumn(TBColumnNew(aTitulos[01], {|| aColuna01[n]})) // CODFAT
    oBrowse:AddColumn(TBColumnNew(aTitulos[02], {|| aColuna02[n]})) // CODCLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[03], {|| aColuna03[n]})) // NOMECLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[04], {|| aColuna04[n]})) // DATA_VENCIMENTO
    oBrowse:AddColumn(TBColumnNew(aTitulos[05], {|| aColuna05[n]})) // DATA_PAGAMENTO
    oBrowse:AddColumn(TBColumnNew(aTitulos[06], {|| aColuna06[n]})) // VALOR_NOMINAL
    oBrowse:AddColumn(TBColumnNew(aTitulos[07], {|| aColuna07[n]})) // VALOR_PAGAMENTO
    oBrowse:GetColumn( 1 ):Picture := "9999"
    oBrowse:GetColumn( 2 ):Picture := "9999"

    oBrowse:Freeze := 2 
    nCursor := SetCursor( 0 )
    nRow := Row()
    nCol := Col()

    RODAPE_VISUALIZAR( nQtdFaturas, "Faturas", PERMITE_TODAS_OPERACOES )
       
    WHILE .T.
        oBrowse:ForceStable()

        nKey := Inkey(0)

        IF oBrowse:applyKey( nKey ) == TBR_EXIT .OR.  ;
            TECLA_PERMITIDA_VISUALIZAR(nQtdFaturas, hTeclaOperacao, nKey)
            EXIT
        ENDIF
    ENDDO

    hTeclaRegistro := { ;
        "TeclaPressionada" => nKey, ;
        "RegistroEscolhido" => Eval( oBrowse:getColumn( 1 ):block ) }

    SetPos( nRow, nCol )
    SetColor( cColor )
    SetCursor( nCursor )    
RETURN hTeclaRegistro