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

PROCEDURE MODCLI()
    //LOCAL nProgramaEscolhido := 0

    MOSTRA_BROWSE()

    //nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    //
    //WHILE !(nProgramaEscolhido == SAIR)
    //    MANUTENCAO_CLIENTE(nProgramaEscolhido)
    //    
    //    nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    //ENDDO
RETURN

FUNCTION MOSTRA_BROWSE()
    LOCAL nBrowseLinIni := 09, nBrowseColIni := 35
    #ifdef __PLATFORM__Linux
        LOCAL nBrowseLinFim := MaxRow()-3
        LOCAL nBrowseLinFim := 25
    #endif
    LOCAL nBrowseLinFim := MaxRow()-3, nBrowseColFim := MaxCol()-3
    LOCAL oBrowse := TBrowseNew(nBrowseLinIni, nBrowseColIni, nBrowseLinFim, nBrowseColFim)
    LOCAL cSql := "SELECT LTRIM(CODCLI) AS CODCLI, "+;
                  "NOMECLI || '     ' AS NOMECLI, ENDERECO, CEP, CIDADE, "+;
                  "ESTADO, ULTICOMPRA, "+;
                  "(CASE SITUACAO WHEN 1 THEN 'Sim' ELSE 'Nao' END) SITUACAO FROM CLIENTE;"
    LOCAL pRegistros := NIL
    LOCAL aTitulos := { "Cod.Cliente", "Nome Cliente", "Endereco", "CEP", ;
                        "Cidade", "UF", "Dt.Ult.Compra", "Situacao Ok?"}
    LOCAL aColuna01 := {}, aColuna02 := {}, aColuna03 := {}, aColuna04 := {}
    LOCAL aColuna05 := {}, aColuna06 := {}, aColuna07 := {}, aColuna08 := {} 
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL n       := 1
    LOCAL nCursor
    LOCAL cColor
    LOCAL nRow, nCol
    LOCAL nQtdCliente := 0

    hStatusBancoDados := DISPONIBILIZA_BANCO_DE_DADOS()

    pRegistros := sqlite3_prepare(hStatusBancoDados["pBancoDeDados"], cSql)

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
 
    oBrowse:colorSpec     := "W+/N, N/BG"
    oBrowse:ColSep        := hb_UTF8ToStrBox( "│" )
    oBrowse:HeadSep       := hb_UTF8ToStrBox( "╤═" )
    oBrowse:FootSep       := hb_UTF8ToStrBox( "╧═" )
    //oBrowse:GoTopBlock    := {|| n := 1 }
    //oBrowse:GoBottomBlock := {|| n := Len( aTitulos ) }
    oBrowse:SkipBlock     := {| nSkip, nPos | ;
                               nPos := n, ;
                               n := iif ( nSkip > 0, ;
                                           Min( Len( aColuna01 ), n + nSkip ), Max( 1, n + nSkip ) ;
                                        ), ;
                               n - nPos }
 
    oBrowse:AddColumn(TBColumnNew("#",  {|| n}))
    oBrowse:AddColumn(TBColumnNew(aTitulos[01], {|| aColuna01[n]})) // CODCLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[02], {|| aColuna02[n]})) // NOMECLI
    oBrowse:AddColumn(TBColumnNew(aTitulos[03], {|| aColuna03[n]})) // ENDERECO
    oBrowse:AddColumn(TBColumnNew(aTitulos[04], {|| aColuna04[n]})) // CEP
    oBrowse:AddColumn(TBColumnNew(aTitulos[05], {|| aColuna05[n]})) // CIDADE
    oBrowse:AddColumn(TBColumnNew(aTitulos[06], {|| aColuna06[n]})) // ESTADO
    oBrowse:AddColumn(TBColumnNew(aTitulos[07], {|| aColuna07[n]})) // ULTICOMPRA
    oBrowse:AddColumn(TBColumnNew(aTitulos[08], {|| aColuna08[n]})) // SITUACAO
    oBrowse:GetColumn( 2 ):Picture := "@!"
    // needed since I've changed some columns _after_ I've added them to TBrowse object
    oBrowse:Configure()
  
    oBrowse:Freeze := 1
    nCursor := SetCursor( 0 )
    //cColor := SetColor( "W+/B" )
    nRow := Row()
    nCol := Col()
    hb_DispBox( nBrowseLinIni-01, nBrowseColIni-01,;
                nBrowseLinFim+02, nBrowseColFim+01,;
                hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    nQtdCliente := OBTER_QUANTIDADE_CLIENTE(hStatusBancoDados["pBancoDeDados"])
    hb_DispOutAt(nBrowseLinFim+01, nBrowseColIni+01, StrZero(nQtdCliente,4) +;
    " Clientes | [ESC]=Sair [ENTER]=Alterar ["+ SETAS + "]=Movimentar")
       
    oBrowse:SetKey( 0, {| ob, nkey | DefProc( ob, nKey ) } )
    WHILE .T.
       oBrowse:ForceStable()
       IF oBrowse:applykey( Inkey( 0 ) ) == -1
          EXIT
       ENDIF
    ENDDO

    SetPos( nRow, nCol )
    SetColor( cColor )
    SetCursor( nCursor )    
RETURN NIL

STATIC FUNCTION DefProc( oBrowse, nKey )
    IF nKey == K_TAB
       hb_DispOutAt( 0, 0, Time() )
       oBrowse:Refreshall()
    ENDIF
    IF nKey == K_ENTER
       Alert( "Linha atual na janela  : " + Transform( oBrowse:rowPos(), "@ 99999" ) + "|" + ;
          "Coluna atual na janela : " + Transform( oBrowse:colPos(), "@ 99999" ) + "|" + ;
          "Valor atual : "            + Transform( Eval( oBrowse:getColumn( oBrowse:colPos() ):block ), "@X" )  + "|" ,, "W+/N")
    ENDIF
 RETURN 1

FUNCTION MOSTRA_MENU_MODCLI()
    LOCAL nITEM
    LOCAL nProgramaEscolhido
    LOCAL aMenu := {{"1 - INCLUSAO ", "INCLUSAO DE CLIENTE"     },;
        {"2 - ALTERACAO", "ALTERACAO DE DADOS DE CLIENTE"},;
        {"3 - EXCLUSAO ", "EXCLUSAO DE CLIENTE"      },;
        {"4 - CONSULTA ", "CONSULTA DE CLIENTE"      },;
        {"5 - RETORNA  ", "RETORNA AO MENU ANTERIOR"}}

    MOSTRA_TELA_PADRAO()
  
    MOSTRA_QUADRO(aMenu)
  
    FOR nITEM := 1 TO LEN(aMenu)
        @ 09 + nITEM, 10 PROMPT aMenu[nITEM,01] message aMenu[nITEM,02]
    NEXT
    MENU TO nProgramaEscolhido
RETURN nProgramaEscolhido

PROCEDURE MANUTENCAO_CLIENTE(nProgramaEscolhido)
    LOCAL hClienteRegistro := {"CODCLI" => 0,; 
    "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
    "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
    "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .F.}

    MOSTRAR_TELA_CLI()

    hClienteRegistro := MOSTRAR_OBTER_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)

    GRAVAR_DADOS_CLIENTE(hClienteRegistro)

RETURN 

PROCEDURE MOSTRAR_TELA_CLI()
    @08, 37 TO 19, 98 DOUBLE
RETURN

FUNCTION MOSTRAR_OBTER_CAMPOS_CLI(nProgramaEscolhido, hClienteRegistro)
    LOCAL GetList := {}
    LOCAL nCODCLI := SPACE(04), cNOMECLI := SPACE(40), cENDERECO := SPACE(40)
    LOCAL cCEP := SPACE(09), cCIDADE := SPACE(20), cESTADO := SPACE(02) 
    LOCAL dULTICOMPRA := DATE(), lSITUACAO := .F.

    SET INTENSITY OFF

    @10,39 SAY "CODIGO.......: " GET nCODCLI      PICTURE "99999"         
    @11,39 SAY "NOME.........: " GET cNOMECLI     PICTURE "@!X"           
    @12,39 SAY "ENDERECO.....: " GET cENDERECO    PICTURE "@!X"           
    @13,39 SAY "CEP..........: " GET cCEP         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET cCIDADE      PICTURE "@!X"           
    @15,39 SAY "ESTADO.......: " GET cESTADO      PICTURE "AA"            
    @16,39 SAY "ULTIMA COMPRA: " GET dULTICOMPRA  PICTURE "DD/DD/DDDD"    
    //@17,39 SAY "SITUACAO.....: " GET lSITUACAO    PICTURE "L"
    READ

    hClienteRegistro["CODCLI"]     := nCODCLI
    hClienteRegistro["NOMECLI"]    := cNOMECLI
    hClienteRegistro["ENDERECO"]   := cENDERECO
    hClienteRegistro["CEP"]        := cCEP
    hClienteRegistro["CIDADE"]     := cCIDADE
    hClienteRegistro["ESTADO"]     := cESTADO
    hClienteRegistro["ULTICOMPRA"] := AJUSTAR_DATA(dULTICOMPRA)
    hClienteRegistro["SITUACAO"]   := lSITUACAO
    SET INTENSITY ON
RETURN hClienteRegistro
