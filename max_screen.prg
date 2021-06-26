/* 
Programa : max_screen.prg
*/


#include "hbgtinfo.ch"

REQUEST HB_LANG_PT
REQUEST HB_CODEPAGE_PT850
REQUEST HB_GT_WVT_DEFAULT

Function Main()
 Local nModo := 0

 HB_LANGSELECT('PT')
 HB_SETCODEPAGE('PT850')  // em portugues

 HB_GtInfo( HB_GTI_FONTNAME, "Lucida Console" )  // fonte
 HB_GtInfo( HB_GTI_WINTITLE, "Teste de Modo de Tela" ) // titulo da tela

 Do While LastKey() != 27

  SetColor( "GR+/N" )

  @ 10, 25 Say "0 = Modo Janela WideScreen"
  @ 11, 25 Say "1 = Modo Janela Pequena"
  @ 12, 25 Say "2 = Tela Cheia (Full Screen)"

  @ 14, 25 Say "Escolha o Modo:" GET nModo Pict "9" Valid nModo <= 2
  Read

  SetColor( "G+/N" )

  Do Case

   Case nModo = 0  // Modo Janela WideScreen
    HB_GtInfo( HB_GTI_MAXIMIZED, .F. )
    HB_GtInfo( HB_GTI_ISFULLSCREEN, .F. )
    HB_GtInfo( HB_GTI_MAXIMIZED, .T. )
    @ 16, 25 Say Space( 50 )
    @ 16, 25 Say "0 = Vocˆ est  em Modo Janela WideScreen"

   Case nModo = 1  // Modo Janela Pequena
    HB_GtInfo( HB_GTI_MAXIMIZED, .F. )
    HB_GtInfo( HB_GTI_ISFULLSCREEN, .F. )
    HB_GtInfo( HB_GTI_FONTSIZE, 26 )
    HB_GtInfo( HB_GTI_FONTWIDTH, 12 )
    /*
      Neste caso, e em caso de alternancia, precisa
      duplicar para restaurar a tela
    */
    HB_GtInfo( HB_GTI_FONTSIZE, 26 )
    HB_GtInfo( HB_GTI_FONTWIDTH, 12 )
    @ 16, 25 Say Space( 50 )
    @ 16, 25 Say "1 = Vocˆ est  em Modo Janela Pequena"

   Case nModo = 2  // Tela Cheia (Full Screen)
    HB_GtInfo( HB_GTI_MAXIMIZED, .F. )
    HB_GtInfo( HB_GTI_ISFULLSCREEN, .F. )
    HB_GtInfo( HB_GTI_ISFULLSCREEN, .T. )
    @ 16, 25 Say Space( 50 )
    @ 16, 25 Say "2 = Vocˆ est  em Tela Cheia (Full Screen)"

  End Case

 EndDo

Return Nil