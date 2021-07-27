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
    LOCAL nBrowseLinFim := 25 //MaxRow()-3
    LOCAL nBrowseColFim := MaxCol()-3
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
    " Clientes | [ESC]=Sair [A]=Alterar [E]=Excluir ["+ SETAS + "]=Movimentar")
       
    //oBrowse:SetKey( 0, {| ob, nkey | DefProc( ob, nKey, aColuna01 ) } )
    WHILE .T.
        oBrowse:ForceStable()

        nKey := Inkey(0)

        IF oBrowse:applyKey( nKey ) == TBR_EXIT
            //If hb_Alert( "Fechar?", { " Sim ", " Nao " }, "W+/N" ) == 1
               EXIT
            //Endif
        ENDIF

        hb_Alert( str(nKey) + " - Array index: " + str(oBrowse:rowPos()),, "W+/N" )

       //Alert( Str( Inkey( 0 ) ) ,, "W+/N" )
       //IF oBrowse:applykey( Inkey( 0 ) ) == -1
          //Alert( "Bye!" ,, "W+/N")
          //Alert( str(oBrowse:rowPos()) ,, "W+/N")
          //EXIT
       //ENDIF
    ENDDO

    SetPos( nRow, nCol )
    SetColor( cColor )
    SetCursor( nCursor )    
RETURN NIL

STATIC FUNCTION DefProc( oBrowse, nKey, aColuna01 )
    LOCAL hTeclaOperacao := { ;
        K_LETTER_I => "INC" , K_LETTER_i => "INC", ;
        K_LETTER_A => "ALT" , K_LETTER_a => "ALT", ;
        K_LETTER_E => "EXC" , K_LETTER_e => "EXC"  }

    IF hb_HPos( hTeclaOperacao, nKey ) > 0 
        MANUTENCAO_CLIENTE( hTeclaOperacao[nKey], oBrowse:rowPos(), aColuna01 )
        oBrowse:Refreshall()
    ENDIF 
RETURN NIL

PROCEDURE MANUTENCAO_CLIENTE( cOperacao, nLinhaBrowser, aColuna01 )
    LOCAL hClienteRegistro := { ;
        "CODCLI" => 0, "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
        "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
        "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .F.}
    LOCAL hStatusBancoDados := NIL
 
    hClienteRegistro := MOSTRAR_OBTER_CAMPOS_CLI(cOperacao, hClienteRegistro)

    hStatusBancoDados := DISPONIBILIZA_BANCO_DE_DADOS()

    GRAVAR_DADOS_CLIENTE(hStatusBancoDados["pBancoDeDados"], hClienteRegistro)
RETURN NIL

FUNCTION MOSTRAR_OBTER_CAMPOS_CLI(cOperacao, hClienteRegistro)
    LOCAL GetList := {}
    LOCAL nCODCLI := SPACE(04), cNOMECLI := SPACE(40), cENDERECO := SPACE(40)
    LOCAL cCEP := SPACE(09), cCIDADE := SPACE(20), cESTADO := SPACE(02) 
    LOCAL dULTICOMPRA := DATE(), lSITUACAO := .F.

    @08, 37 TO 19, 98 DOUBLE
    @09, 38 CLEAR TO 18, 97

    @08, 40 SAY "[ " + cOperacao + " ]"

    SET INTENSITY OFF

    @10,39 SAY "CODIGO.......: " GET nCODCLI      PICTURE "99999"         
    @11,39 SAY "NOME.........: " GET cNOMECLI     PICTURE "@!X"           
    @12,39 SAY "ENDERECO.....: " GET cENDERECO    PICTURE "@!X"           
    @13,39 SAY "CEP..........: " GET cCEP         PICTURE "99999-999"     
    @14,39 SAY "CIDADE.......: " GET cCIDADE      PICTURE "@!X"           
    @15,39 SAY "ESTADO.......: " GET cESTADO      PICTURE "!!"            
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
