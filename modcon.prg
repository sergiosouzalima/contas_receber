/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcon.prg
    Finalidade...: Mostrar menu de consultas
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/
#include "inkey.ch"
#include "global.ch"

PROCEDURE MODCON()
    LOCAL aProgramas := {"datacliente", "clientedata", "tituatras", "fluxosin"}
    LOCAL nProgramaEscolhido := 1

    nProgramaEscolhido := MOSTRA_MENU_MODCON(nProgramaEscolhido)
    
    WHILE !(nProgramaEscolhido == SAIR)

        IF nProgramaEscolhido != SEM_ESCOLHA
            MENSAGEM("Em desenvolvimento!")
            //&(NOME_PROGRAMA(aProgramas[nProgramaEscolhido]))
        END IF

        nProgramaEscolhido := MOSTRA_MENU_MODCON(nProgramaEscolhido)
    ENDDO
RETURN

STATIC FUNCTION MOSTRA_MENU_MODCON(nProgramaEscolhido)
  LOCAL nITEM
  LOCAL aMenu := {;
      {"1 - POSICAO DATA/CLIENTE", "CONSULTA ORGANIZADA POR DATA DE VENCIMENTO E CLIENTE"},;
      {"2 - POSICAO CLIENTE/DATA", "CONSULTA ORGANIZADA POR CLIENTE E DATA DE VENCIMENTO"},;
      {"3 - TITULOS EM ATRASO   ", "CONSULTA DE FATURAS EM ATRASO ATE A DATA INFORMADA"},;
      {"4 - FLUXO SINTETICO     ", "CONSULTA DE TOTAIS POR DATA VENCIMENTO/A VENCER"},;
      {"5 - VOLTAR              ", "RETORNA AO MENU ANTERIOR"}}
             
  MOSTRA_TELA_PADRAO()

  MOSTRA_QUADRO(aMenu)

  FOR nITEM := 1 TO LEN(aMenu)
      @ 09 + nITEM, 07 PROMPT aMenu[nITEM,01] message aMenu[nITEM,02]
  NEXT    
  MENU TO nProgramaEscolhido

  IF hb_keyLast() == K_ESC
    nProgramaEscolhido := SAIR
  ENDIF
RETURN nProgramaEscolhido
