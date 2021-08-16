/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: crmenu.prg
    Finalidade...: Mostrar menu principal
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
    ---
    Sistema construido com base nos fontes do livro: 
    Clipper 5.0 Volume 1 Release 5.01.
    Autor Ramalho. Editora Makron Books.
    Publicado em 1991.
*/
#include "inkey.ch"
#include "global.ch"

PROCEDURE CRMENU()
    LOCAL lBancoDadosOK := .F.
    LOCAL aProgramas := {"modfat", "modcli", "modcon", "moduti"}
    LOCAL nProgramaEscolhido := 1
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}

    CONFIGURACAO_INICIAL()

    hStatusBancoDados := ABRIR_BANCO_DADOS()
    lBancoDadosOK := hStatusBancoDados["lBancoDadosOK"]

    IF lBancoDadosOK
        nProgramaEscolhido := MOSTRA_MENU_CRMENU(nProgramaEscolhido)
        
        WHILE !(nProgramaEscolhido == SAIR)
            IF nProgramaEscolhido != SEM_ESCOLHA
              &(NOME_PROGRAMA(aProgramas[nProgramaEscolhido]))
            END IF

            nProgramaEscolhido := MOSTRA_MENU_CRMENU(nProgramaEscolhido)
        ENDDO
    ENDIF

    FINALIZA()

RETURN

STATIC FUNCTION MOSTRA_MENU_CRMENU(nProgramaEscolhido)
  LOCAL nITEM
  LOCAL aMenu := {;
      {"1 - FATURA     ","MANUTENCAO DE FATURAS"          },;
      {"2 - CLIENTE   ", "MANUTENCAO DE CLIENTES"         },;
      {"3 - CONSULTA  ", "CONSULTA DE FATURAS E CLIENTES" },;
      {"4 - UTILITARIO", "ROTINAS DE BACKUP E REINDEXACAO"},;
      {"5 - FIM       ", "RETORNA AO SISTEMA OPERACIONAL" }}

  MOSTRA_TELA_PADRAO()

  MOSTRA_QUADRO(aMenu)

  FOR nITEM := 1 TO LEN(aMenu)
      @ 09 + nITEM, 10 PROMPT aMenu[nITEM,01] message aMenu[nITEM,02]
  NEXT    
  MENU TO nProgramaEscolhido

  IF hb_keyLast() == K_ESC
    nProgramaEscolhido := SAIR
  ENDIF

  nProgramaEscolhido := iif(nProgramaEscolhido == SAIR .AND. !CONFIRMA(), SEM_ESCOLHA, nProgramaEscolhido)
RETURN nProgramaEscolhido

STATIC PROCEDURE FINALIZA()
  CLEAR SCREEN 
  hb_DispOutAt( 01, 01, "*** SISTEMA ENCERRADO!" )
  ? " "
  ? " "
RETURN