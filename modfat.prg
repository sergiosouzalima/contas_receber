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
    LOCAL cOperacao := ""

    hTeclaRegistro := VISUALIZAR_FATURAS(hTeclaOperacao, hTeclaRegistro)

    IF hTeclaRegistro["TeclaPressionada"] != K_ESC
        &( NOME_PROGRAMA( ;
            hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
            hTeclaRegistro["RegistroEscolhido"] ) )
    ENDIF
RETURN

FUNCTION VISUALIZAR_FATURAS(hTeclaOperacao, hTeclaRegistro)
    LOCAL oBrowse := ;
        TBrowseNew(LINHA_INI_BROWSE, COLUNA_INI_BROWSE, LINHA_FIM_BROWSE, COLUNA_FIM_BROWSE)
    LOCAL pRegistros := NIL
    LOCAL aTitulos := { "Cod.Fatura", "Cod.Cliente", "Nome Cliente", ;
                        "Dt.Vencimento", "Dt.Pagamento", ;
                        "Valor Nominal", "Valor Pagamento" }
    LOCAL aColuna01 := {}, aColuna02 := {}, aColuna03 := {}, aColuna04 := {}
    LOCAL aColuna05 := {}, aColuna06 := {}, aColuna07 := {}
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL n := 1, nCursor, cColor, nRow, nCol
    LOCAL nQtdCliente := 0, nKey := 0

    hb_DispBox( LINHA_INI_CENTRAL, COLUNA_INI_CENTRAL,;
        LINHA_FIM_CENTRAL, COLUNA_FIM_CENTRAL,;
        hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pRegistros := OBTER_FATURAS(hStatusBancoDados["pBancoDeDados"])

    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aColuna01, sqlite3_column_int(pRegistros, 1))  // CODFAT
        AADD(aColuna02, sqlite3_column_text(pRegistros, 2)) // CODCLI
        AADD(aColuna03, sqlite3_column_text(pRegistros, 3)) // NOMECLI
        AADD(aColuna04, sqlite3_column_text(pRegistros, 4)) // DATA_VENCIMENTO
        AADD(aColuna05, sqlite3_column_text(pRegistros, 5)) // DATA_PAGAMENTO
        AADD(aColuna06, sqlite3_column_text(pRegistros, 6)) // VALOR_NOMINAL
        AADD(aColuna07, sqlite3_column_text(pRegistros, 7)) // VALOR_PAGAMENTO
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 
 
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
    oBrowse:GetColumn( 2 ):Picture := "@!"
  
    oBrowse:Freeze := 2 
    nCursor := SetCursor( 0 )
    nRow := Row()
    nCol := Col()

    nQtdCliente := OBTER_QUANTIDADE_FATURA(hStatusBancoDados["pBancoDeDados"])
    hb_DispOutAt(LINHA_RODAPE_BROWSE, COLUNA_RODAPE_BROWSE, StrZero(nQtdCliente,4) +;
    " Faturas | [ESC]=Sair [I]=Incluir [A]=Alterar [E]=Excluir ["+ SETAS + "]=Movimentar")
       
    WHILE .T.
        oBrowse:ForceStable()

        nKey := Inkey(0)

        IF oBrowse:applyKey( nKey ) == TBR_EXIT .OR. hb_HPos( hTeclaOperacao, nKey ) > 0 
            EXIT
        ENDIF
    ENDDO

    hTeclaRegistro := { "TeclaPressionada" => nKey, "RegistroEscolhido" => aColuna01[oBrowse:rowPos()] }

    SetPos( nRow, nCol )
    SetColor( cColor )
    SetCursor( nCursor )    
RETURN hTeclaRegistro