/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcli.prg
    Finalidade...: Manutencao cadastro de clientes
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
*/

#include "global.ch"
#require "hbsqlit3"
#include "inkey.ch"
#include "tbrowse.ch"

PROCEDURE MODCLI()
    LOCAL hTeclaOperacao := { ;
        K_I => "modcliinc" , K_i => "modcliinc", ;
        K_A => "modclialt" , K_a => "modclialt", ;
        K_E => "modcliexc" , K_e => "modcliexc"  }
    LOCAL hTeclaRegistro := { "TeclaPressionada" => 0, "RegistroEscolhido" => 0 }
    LOCAL cOperacao := ""
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}

    MOSTRA_NOME_PROGRAMA(ProcName())

    hTeclaRegistro := VISUALIZAR_CLIENTES(hTeclaOperacao, hTeclaRegistro)

    IF !(hTeclaRegistro["TeclaPressionada"] == K_ESC)
        &( NOME_PROGRAMA( ;
            hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
            hTeclaRegistro["RegistroEscolhido"] ) )
    ENDIF
RETURN

STATIC FUNCTION VISUALIZAR_CLIENTES(hTeclaOperacao, hTeclaRegistro)
    LOCAL oBrowse := ;
        TBrowseNew(BROWSE_LIN_INI, BROWSE_COL_INI, BROWSE_LIN_FIM, BROWSE_COL_FIM)
    LOCAL pRegistros := NIL
    LOCAL aTitulos := { "Cod.Cliente", "Nome Cliente", "Endereco", "CEP", ;
                        "Cidade", "UF", "Dt.Ult.Compra", "Situacao Ok?" }
    LOCAL aColuna01 := {0}, aColuna02 := {"----------"}
    LOCAL aColuna03 := {"----------"}, aColuna04 := {"----------"}
    LOCAL aColuna05 := {"----------"}, aColuna06 := {"--"} 
    LOCAL aColuna07 := {CToD(Space(8))}, aColuna08 := {"---"} 
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL n := 1, nCursor, cColor, nRow, nCol
    LOCAL nQtdClientes := 0, nKey := 0

    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
        CENTRAL_LIN_FIM, CENTRAL_COL_FIM,;
        hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdClientes := OBTER_QUANTIDADE_CLIENTES(hStatusBancoDados["pBancoDeDados"])

    IF nQtdClientes > 0
        aColuna01 := {}; aColuna02 := {}; aColuna03 := {}; aColuna04 := {}
        aColuna05 := {}; aColuna06 := {}; aColuna07 := {}; aColuna08 := {} 

        pRegistros := OBTER_CLIENTES(hStatusBancoDados["pBancoDeDados"])

        DO WHILE sqlite3_step(pRegistros) == 100
            AADD(aColuna01, sqlite3_column_int(pRegistros, 1))  // CODCLI
            AADD(aColuna02, sqlite3_column_text(pRegistros, 2)) // NOMECLI
            AADD(aColuna03, sqlite3_column_text(pRegistros, 3)) // ENDERECO
            AADD(aColuna04, sqlite3_column_text(pRegistros, 4)) // CEP
            AADD(aColuna05, sqlite3_column_text(pRegistros, 5)) // CIDADE
            AADD(aColuna06, sqlite3_column_text(pRegistros, 6)) // ESTADO
            AADD(aColuna07, sqlite3_column_text(pRegistros, 7)) // ULTICOMPRA
            AADD(aColuna08, sqlite3_column_text(pRegistros, 8)) // SITUACAO
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
 
    oBrowse:AddColumn(TBColumnNew(aTitulos[01], {|| aColuna01[n]})) // CODCLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[02], {|| aColuna02[n]})) // NOMECLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[03], {|| aColuna03[n]})) // ENDERECO
    oBrowse:AddColumn(TBColumnNew(aTitulos[04], {|| aColuna04[n]})) // CEP
    oBrowse:AddColumn(TBColumnNew(aTitulos[05], {|| aColuna05[n]})) // CIDADE
    oBrowse:AddColumn(TBColumnNew(aTitulos[06], {|| aColuna06[n]})) // ESTADO
    oBrowse:AddColumn(TBColumnNew(aTitulos[07], {|| aColuna07[n]})) // ULTICOMPRA
    oBrowse:AddColumn(TBColumnNew(aTitulos[08], {|| aColuna08[n]})) // SITUACAO
    oBrowse:GetColumn( 2 ):Picture := "@!"
  
    oBrowse:Freeze := 2 
    nCursor := SetCursor( 0 )
    nRow := Row()
    nCol := Col()

    RODAPE_VISUALIZAR( nQtdClientes, "Clientes", PERMITE_TODAS_OPERACOES )
       
    WHILE .T.
        oBrowse:ForceStable()

        nKey := Inkey(0)

        IF oBrowse:applyKey( nKey ) == TBR_EXIT .OR. ;
            TECLA_PERMITIDA_VISUALIZAR(nQtdClientes, hTeclaOperacao, nKey) 
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