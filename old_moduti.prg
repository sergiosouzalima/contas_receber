// The example demonstrates the steps required for creating a
// browse view for a two dimensional array. Note that the data
// source and row pointer of the data source are stored in
// oTBrowse:cargo. The pseudo instance variables :data and :recno
// are translated by the preprocessor.

// Exemplo extraido e adaptado de "xHarbour Language Reference Guide" - Alexandre Santos

#include "global.ch"
#include "sql.ch"
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

   pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_SELECT_ALL)

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