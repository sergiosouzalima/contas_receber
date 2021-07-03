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
#include "global.ch"

PROCEDURE CRMENU()
    LOCAL lBancoDadosOK := .F.
    LOCAL aProgramas := {"modfat", "modcli", "modcon", "moduti"}
    LOCAL nProgramaEscolhido := 0

    CONFIGURACAO_INICIAL()

    lBancoDadosOK := INICIALIZA_BANCO_DE_DADOS()
    
    IF lBancoDadosOK
        nProgramaEscolhido := MOSTRA_MENU_CRMENU()
        
        WHILE !(nProgramaEscolhido == SAIR)
            EXECUTA_PROGRAMA(nProgramaEscolhido, aProgramas)
            
            nProgramaEscolhido := MOSTRA_MENU_CRMENU()
        ENDDO
    ENDIF

    FINALIZA()

RETURN

FUNCTION MOSTRA_MENU_CRMENU()
  LOCAL nITEM
  LOCAL nProgramaEscolhido
  LOCAL aMenu := {{"1 - FATURA     ","MANUTENCAO DE FATURAS"        },;
      {"2 - CLIENTE   ", "MANUTENCAO DE CLIENTES"                   },;
      {"3 - CONSULTA  ", "CONSULTA EM VIDEO E EMISSAO DE RELATORIOS"},;
      {"4 - UTILITARIO", "ROTINAS DE BACKUP E REINDEXACAO"          },;
      {"5 - FIM       ", "RETORNA AO SISTEMA OPERACIONAL"           }}

  MOSTRA_TELA_PADRAO()

  MOSTRA_QUADRO(aMenu)

  FOR nITEM := 1 TO LEN(aMenu)
      @ 09 + nITEM, 10 PROMPT aMenu[nITEM,01] message aMenu[nITEM,02]
  NEXT    
  MENU TO nProgramaEscolhido

  nProgramaEscolhido := iif(nProgramaEscolhido == SAIR .AND. !CONFIRMA(), 0, nProgramaEscolhido)
RETURN nProgramaEscolhido

PROCEDURE FINALIZA()
  CLEAR SCREEN 
  ?
  @01, 00 SAY "*** SISTEMA ENCERRADO!"
  ? 
  ?
RETURN