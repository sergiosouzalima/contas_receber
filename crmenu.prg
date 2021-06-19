/*
  Sistema de Contas a Receber
  --
  Autor: Sergio Lima. Julho, 2021.
  ---
  Sistema construido com base no 
  livro Clipper 5.0 Volume 1 Release 5.01, autor Ramalho, editora Makron Books.
*/
#define SAIR 5

PROCEDURE PRINCIPAL()
    LOCAL nProgramaEscolhido := 0
    LOCAL nFinalizaSistema := SAIR

    CONFIGURACAO_INICIAL()
    
    nProgramaEscolhido := MOSTRA_MENU_PRINCIPAL()
    
    WHILE nProgramaEscolhido != SAIR
        EXECUTA_PROGRAMA(nProgramaEscolhido)
        
        nProgramaEscolhido := MOSTRA_MENU_PRINCIPAL()
    ENDDO

RETURN

FUNCTION MOSTRA_MENU_PRINCIPAL()
  LOCAL i
  LOCAL nProgramaEscolhido
  LOCAL aMenu := {{"1 - FATURA     ","MANUTENCAO DE FATURAS"        },;
      {"2 - CLIENTE   ", "MANUTENCAO DO ARQUIVO DE CLIENTES"        },;
      {"3 - CONSULTA  ", "CONSULTA EM VIDEO E EMISSAO DE RELATORIOS"},;
      {"4 - UTILITARIO", "ROTINAS DE BACKUP E REINDEXACAO"          },;
      {"5 - FIM       ", "RETORNA AO SISTEMA OPERACIONAL"           }}

  MOSTRA_TELA_PADRAO()

  MOSTRA_QUADRO(aMenu)

  FOR i := 1 TO LEN(aMenu)
      @ 09 + i, 10 PROMPT aMenu[i,01] message aMenu[i,02]
  NEXT    
  MENU TO nProgramaEscolhido

  nProgramaEscolhido := iif(nProgramaEscolhido == SAIR .AND. CONFIRMA(), nProgramaEscolhido, 0)
RETURN nProgramaEscolhido

PROCEDURE EXECUTA_PROGRAMA(nProgramaEscolhido)
  ? "teste2"
RETURN