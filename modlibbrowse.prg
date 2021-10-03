/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modlibbrowse.prg
    Finalidade...: TBrowse disponivel para todo o sistema
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "global.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "tbrowse.ch"

#define COLUMN_SEP " "+CHR(179)+" "           
#define FOOT_SEP CHR(196)+CHR(193)+CHR(196)   
#define HEAD_SEP CHR(196)+CHR(194)+CHR(196)  

#xtrans  :data   =>   :cargo\[1]
#xtrans  :recno  =>   :cargo\[2]

REQUEST HB_CODEPAGE_PTISO
REQUEST HB_LANG_PT

FUNCTION VISUALIZA_DADOS( hAtributos )
   LOCAL i, bBlock, oTBrowse, oTBColumn
   LOCAL hDefaultDimensions:= {"Row1" => 3, "Col1" => 2, "Row2" => MaxRow()-2, "Col2" => MaxCol()-2}
   LOCAL cTitulo           := hAtributos["TITULO"]
   LOCAL aHeading          := hAtributos["TITULOS"]
   LOCAL nQtdRegistros     := hAtributos["QTDREGISTROS"]
   LOCAL aValues           := hAtributos["VALORES"]
   LOCAL aWidth            := hAtributos["TAMANHO_COLUNAS"]
   LOCAL cCommandsFooterMsg:= hAtributos["COMANDOS_MENSAGEM"]
   LOCAL aAvailableKeys    := hAtributos["COMANDOS_TECLAS"]
   LOCAL hDimensions       := iif( Empty(hAtributos["DIMENSIONS"]), ;
                              hDefaultDimensions, ;
                              hAtributos["DIMENSIONS"])
   LOCAL lLookup           := hAtributos["LOOKUP"]
   LOCAL cSep := Chr(10), nCursor := SetCursor( SC_NONE )
   LOCAL nKey := 0
   LOCAL nSelectedRecord   := 0

   IF nQtdRegistros <= 0
      RETURN {    "TeclaPressionada" => nKey, ;
                  "RegistroEscolhido" => nSelectedRecord, ;
                  "Message" => "Nao ha registros para visualizar" ;
               }
   ENDIF

   HB_CDPSELECT( 'PTISO' )
   HB_LANGSELECT( 'PT' )

   // Create TBrowse object
   oTBrowse := TBrowse():new(;
      hDimensions["Row1"], hDimensions["Col1"], hDimensions["Row2"], hDimensions["Col2"] )

   // data source is the aValues array
   oTBrowse:cargo      := aValues
   oTBrowse:border     := B_SINGLE
   oTBrowse:headSep    := HEAD_SEP
   oTBrowse:colSep     := COLUMN_SEP
   oTBrowse:footSep    := FOOT_SEP
   oTBrowse:colorSpec  := "W/N"

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

   IF !lLookup
      CLS
      DispOutAt( hDimensions["Row1"]-2, hDimensions["Col1"]-1, ;
         PadR( cTitulo, hDimensions["Col2"] ), "N/W" )
      DispOutAt( hDimensions["Row2"]+2, 1, ;
         PadR( StrSwap("Registros: #{} | ", ltrim(str(nQtdRegistros))) + ;
               cCommandsFooterMsg, ;
               hDimensions["Col2"] ), "N/W" )
   ENDIF

   // display browser and process user input
   DO WHILE .T.
      oTBrowse:forceStable()

      nKey := Inkey(0)

      nSelectedRecord := Eval( oTBrowse:getColumn( 1 ):block )

      IF oTBrowse:applyKey( nKey ) == TBR_EXIT .OR. ;
         hb_AScan( aAvailableKeys, nKey ) > 0
         EXIT
      ENDIF
   ENDDO

   IF lLookup
      @hDimensions["Row1"], hDimensions["Col1"] ;
      CLEAR TO ;
      hDimensions["Row2"], hDimensions["Col2"]
   ENDIF
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