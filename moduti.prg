// The example demonstrates the steps required for creating a
// browse view for a two dimensional array. Note that the data
// source and row pointer of the data source are stored in
// oTBrowse:cargo. The pseudo instance variables :data and :recno
// are translated by the preprocessor.

// Exemplo extraido e adaptado de "xHarbour Language Reference Guide" - Alexandre Santos

#include "global.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "tbrowse.ch"

#define DEF_CSEP " "+CHR(179)+" "             // define o caracter da coluna
#define FOOT_SEP CHR(196)+CHR(193)+CHR(196)   // define o caracter do horizontal
#define HEAD_SEP CHR(196)+CHR(194)+CHR(196)   // define o caracter do horizontal

#xtrans  :data   =>   :cargo\[1]
#xtrans  :recno  =>   :cargo\[2]

REQUEST HB_CODEPAGE_PTISO
REQUEST HB_LANG_PT

FUNCTION MODUTI()
   LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
   LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
   LOCAL pRegistros := NIL
   LOCAL aValores := {}
   LOCAL nQtdRegistros := 0
   LOCAL hAtributos := { ;
      "TITULO" => "Clientes", ;
      "QTDREGISTROS" => nQtdRegistros, ;
      "TITULOS" => {;
         "Cod.Cliente", ;
         "Nome Cliente", ;
         "Endereco", ;
         "CEP", ;
         "Cidade", ;
         "UF", ;
         "Dt.Ult.Compra", ;
         "Situacao Ok?" ;
      }, ;
      "TAMANHO_COLUNAS" => { 11, 25, 20, 10, 20, 3, 15, 15 }, ;
      "VALORES" => { aValores, 1 }, ;
      "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM, ;
      "COMANDOS_TECLAS" => { K_I, K_i, K_A, K_a, K_E, K_e } ;
   }

   hStatusBancoDados := ABRIR_BANCO_DADOS()

   pRegistros := OBTER_CLIENTES(hStatusBancoDados["pBancoDeDados"])

   DO WHILE sqlite3_step(pRegistros) == 100
      nQtdRegistros++
      AADD(aValores, { ;
         sqlite3_column_int(pRegistros, 1), ;   // CODCLI
         sqlite3_column_text(pRegistros, 2), ;  // NOMECLI
         sqlite3_column_text(pRegistros, 3), ;  // ENDERECO
         sqlite3_column_text(pRegistros, 4), ;  // CEP
         sqlite3_column_text(pRegistros, 5), ;  // CIDADE
         sqlite3_column_text(pRegistros, 6), ;  // ESTADO
         sqlite3_column_text(pRegistros, 7), ;  // ULTICOMPRA
         sqlite3_column_text(pRegistros, 8)  ;  // SITUACAO
      })
   ENDDO
   sqlite3_clear_bindings(pRegistros)
   sqlite3_finalize(pRegistros) 

   IF nQtdRegistros < 1
      IF hb_Alert( "Nenhum registro encontrado. Deseja incluir?", { " Sim ", " Não " }, "W+/N" ) == 1
         //
      ENDIF
   ELSE
      hAtributos["QTDREGISTROS"] := nQtdRegistros
      hAtributos["VALORES"]      := { aValores, 1 }
      hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
   ENDIF
   hb_Alert( StrSwap("Tecla pressionada #{1} e registro escolhido: #{2}", ;
      {ltrim(str(hTeclaRegistro["TeclaPressionada"])), ltrim(str(hTeclaRegistro["RegistroEscolhido"]))}) ,, "w/n" ;
   )
RETURN NIL

FUNCTION VISUALIZA_DADOS( hAtributos )
   LOCAL i, bBlock, oTBrowse, oTBColumn
   LOCAL cTitulo           := hAtributos["TITULO"]
   LOCAL aHeading          := hAtributos["TITULOS"]
   LOCAL nQtdRegistros     := hAtributos["QTDREGISTROS"]
   LOCAL aValues           := hAtributos["VALORES"]
   LOCAL aWidth            := hAtributos["TAMANHO_COLUNAS"]
   LOCAL cCommandsFooterMsg:= hAtributos["COMANDOS_MENSAGEM"]
   LOCAL aAvailableKeys    := hAtributos["COMANDOS_TECLAS"]
   LOCAL cSep := Chr(10), nCursor := SetCursor( SC_NONE )
   LOCAL nKey := 0
   LOCAL nSelectedRecord   := 0
   
   HB_CDPSELECT( 'PTISO' )
   HB_LANGSELECT( 'PT' )
   
   // Create TBrowse object
   oTBrowse := TBrowse():new( 3, 2, MaxRow()-2, MaxCol()-2 )

   // data source is the aValues array
   oTBrowse:cargo      := aValues
   oTBrowse:border     := B_SINGLE
   oTBrowse:headSep    := HEAD_SEP
   oTBrowse:colSep     := DEF_CSEP
   oTBrowse:footSep    := FOOT_SEP
   //oTBrowse:colorSpec  := "N/W,W+/N"
   oTBrowse:colorSpec  := "W+/N"
   
   // Navigation code blocks for array
   oTBrowse:goTopBlock    := {|| oTBrowse:recno := 1 }
   oTBrowse:goBottomBlock := {|| oTBrowse:recno := Len( oTBrowse:data ) }
   oTBrowse:skipBlock     := {|nSkip| ArraySkipper( nSkip, oTBrowse ) }
   
   // create TBColumn objects and add them to TBrowse object
   FOR i:=1 TO Len( aHeading )
      // code block for individual columns of the array
      bBlock    := ArrayBlock( oTBrowse, i )
      oTBColumn := TBColumn():new( aHeading[i], bBlock )
      oTBColumn:width := aWidth[i]
      oTBrowse:addColumn( oTBColumn )
   NEXT
   
   CLS
   DispOutAt( 1, 1, PadR( cTitulo, MaxCol()-2 ), "N/W" )
   DispOutAt( MaxRow(), 1, ;
      PadR( StrSwap("Registros: #{} | ", ltrim(str(nQtdRegistros))) + ;
            cCommandsFooterMsg + ;
            ". [ENTER]=Info", ;
            MaxCol()-2 ), "N/W" )
   
   // display browser and process user input
   DO WHILE .T.
      oTBrowse:forceStable()
   
      nKey := Inkey(0)

      nSelectedRecord := Eval( oTBrowse:getColumn( 1 ):block )
   
      IF oTBrowse:applyKey( nKey ) == TBR_EXIT .OR. ;
         hb_AScan( aAvailableKeys, nKey ) > 0
         EXIT
      ENDIF
   
      DO CASE
         CASE nKey == K_ENTER
            
              hb_Alert( "Linha atual na janela  : " + Transform( oTBrowse:rowPos(), "@ 99999" ) + cSep + ;
                        "Coluna atual na janela : " + Transform( oTBrowse:colPos(), "@ 99999" ) + cSep + ;
                        "Valor atual : "            + Transform( Eval( oTBrowse:getColumn( oTBrowse:colPos() ):block ), "@X" )  + cSep + ;
                        "Linha atual no ARRAY : "   + Transform( oTBrowse:recno, "@ 99999" ) + cSep + ;
                        "Cod. tabela do reg atual : " + Transform( nSelectedRecord, "@ 99999" ),, "W+/B" ;
                      )
      ENDCASE
   ENDDO

   SetCursor( nCursor )
   
RETURN {"TeclaPressionada" => nKey, "RegistroEscolhido" => nSelectedRecord}

// This code block uses detached LOCAL variables to
// access single elements of a two-dimensional array.
FUNCTION ArrayBlock( oTBrowse, nSubScript )
RETURN {|| oTBrowse:data[ oTBrowse:recno, nSubScript ] }

// This function navigates the row pointer of the
// the data source (array)
FUNCTION ArraySkipper( nSkipRequest, oTBrowse )
   LOCAL nSkipped
   LOCAL nLastRec := Len( oTBrowse:data ) // Length of array

   IF oTBrowse:recno + nSkipRequest < 1
      // skip requested that navigates past first array element
      nSkipped := 1 - oTBrowse:recno
   ELSEIF oTBrowse:recno + nSkipRequest > nLastRec
      // skip requested that navigates past last array element
      nSkipped := nLastRec - oTBrowse:recno
   ELSE
      // skip requested that navigates within array
      nSkipped := nSkipRequest
   ENDIF
   // adjust row pointer
   oTBrowse:recno += nSkipped
// tell TBrowse how many rows are actually skipped.
RETURN nSkipped