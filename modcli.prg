/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcli.prg
    Finalidade...: Manutencao cadastro de clientes
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
*/
#include "global.ch"

PROCEDURE MODCLI()
    LOCAL nProgramaEscolhido := 0

   // ? sqlite3_libversion()
   //sqlite3_sleep( 3000 )
    
    nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    
    WHILE !(nProgramaEscolhido == SAIR)
        MANUTENCAO_CLIENTE(nProgramaEscolhido)
        
        nProgramaEscolhido := MOSTRA_MENU_MODCLI()
    ENDDO
RETURN

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
    MOSTRA_TELA_CLI()

    MOSTRA_DADOS_CLI(nProgramaEscolhido)
RETURN

PROCEDURE MOSTRA_TELA_CLI()
    @08, 37 TO 19, 98 DOUBLE

    @10,39 SAY "CODIGO.......: [____]" 
    @11,39 SAY "NOME.........:"
    @12,39 SAY "ENDERECO.....:"
    @13,39 SAY "CEP..........:" 
    @14,39 SAY "CIDADE.......:"
    @15,39 SAY "ESTADO.......:"
    @16,39 SAY "ULTIMA COMPRA:"
    @17,39 SAY "SITUACAO.....:"
RETURN

PROCEDURE MOSTRA_DADOS_CLI(nProgramaEscolhido)
    LOCAL GetList := {}
    LOCAL nCODCLI := SPACE(04), cNOMECLI := SPACE(40), cENDERECO := SPACE(40)
    LOCAL cCEP := SPACE(09), cCIDADE := SPACE(20), cESTADO := SPACE(02) 
    LOCAL dULTICOMPRA := DATE(), lSITUACAO := .F.

    SET INTENSITY OFF

    @10,54 GET nCODCLI      PICTURE "99999"         
    @11,54 GET cNOMECLI     PICTURE "@!X"           
    @12,54 GET cENDERECO    PICTURE "@!X"           
    @13,54 GET cCEP         PICTURE "99999-999"     
    @14,54 GET cCIDADE      PICTURE "@!X"           
    @15,54 GET cESTADO      PICTURE "AA"            
    @16,54 GET dULTICOMPRA  PICTURE "DD/DD/DDDD"    
    @17,54 GET lSITUACAO    PICTURE "L"             
    READ

    SET INTENSITY ON
RETURN
