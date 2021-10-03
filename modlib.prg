/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modlib.prg
    Finalidade...: Rotinas comuns e disponiveis para todo o sistema
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/


#include "global.ch"
#include "sql.ch"
#include "hbgtinfo.ch"
#require "hbsqlit3"
#include "inkey.ch"

PROCEDURE CONFIGURACAO_INICIAL
    SET DATE BRITISH
    SET CENTURY ON
    SET MESSAGE TO LINHA_MENSAGEM CENTER
    SET WRAP ON
    SET DELIMITERS ON
    SET DELIMITERS TO "[]"
    SET CONFIRM ON
    SET SCOREBOARD OFF
    SETMODE(40, 132)
RETURN

FUNCTION ABRIR_BANCO_DADOS()
    LOCAL pBancoDeDados := NIL
    LOCAL lBancoDadosOK := .T.
    LOCAL nSqlCodigoErro := 0
    LOCAL lBancoDadosExiste := File(BD_CONTAS_RECEBER)
    LOCAL lCriaBD := .T. // lCriaBD: criar se não existir
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL cSql := NIL

    BEGIN SEQUENCE
        pBancoDeDados := sqlite3_open(BD_CONTAS_RECEBER, lCriaBD) //Abrir banco de dados.

        IF pBancoDeDados == NIL .OR. !File(BD_CONTAS_RECEBER)
            MENSAGEM(MENSAGEM_ERRO_BD)
        ELSE
            if !lBancoDadosExiste
                cSql := SQL_CLIENTE_CREATE
                nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
                IF nSqlCodigoErro == SQLITE_OK
                    IF QUERY_COUNTER(pBancoDeDados, SQL_CLIENTE_COUNT) < 1
                        INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
                    ENDIF
                    cSql := SQL_FATURA_CREATE
                    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
                    IF nSqlCodigoErro == SQLITE_OK
                        IF QUERY_COUNTER(pBancoDeDados, SQL_FATURA_COUNT) < 1
                            INSERIR_DADOS_INICIAIS_FATURA(pBancoDeDados)
                        ENDIF
                    ELSE
                        BREAK
                    ENDIF
                ELSE
                    BREAK
                ENDIF
            ENDIF
        ENDIF    
    RECOVER
        lBancoDadosOK := .F.
        MENSAGEM(MENSAGEM_ERRO_TABELA + ". Erro: " + ;
            LTrim(Str(nSqlCodigoErro)) + ". " + ;
            "Erro SQL: " + sqlite3_errmsg(pBancoDeDados) + ". " + ;
            cSql)
    END SEQUENCE

    hStatusBancoDados["lBancoDadosOK"] := lBancoDadosOK
    hStatusBancoDados["pBancoDeDados"] := pBancoDeDados
RETURN hStatusBancoDados

PROCEDURE MOSTRA_TELA_PADRAO()
    LOCAL cSISTEMA := "*** " + SISTEMA + " ***"
    CLEAR SCREEN
    @ 00,00 TO 00, MaxCol() DOUBLE
    @ 01,CENTRALIZA(cSISTEMA) SAY cSISTEMA
    @ 02,CENTRALIZA(EMPRESA) SAY EMPRESA
    @ 03,00 TO 03, MaxCol()
    MOSTRA_NOME_PROGRAMA(ProcName(2))
    @ 04, MaxCol() - 10 SAY Date()
    @ 05,00 TO 05, MaxCol() DOUBLE
RETURN

PROCEDURE MOSTRA_NOME_PROGRAMA(cNomePrograma, cLinha)
    @ cLinha, 06 SAY cNomePrograma
RETURN

PROCEDURE MOSTRA_TELA_CADASTRO(cNomePrograma)
    hb_DispBox( CENTRAL_LIN_INI, CENTRAL_COL_INI,;
    CENTRAL_LIN_FIM, CENTRAL_COL_FIM, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    MOSTRA_NOME_PROGRAMA(cNomePrograma, CENTRAL_LIN_INI)
RETURN 

PROCEDURE MOSTRA_QUADRO(aMenu)
    LOCAL nTamMenu := LEN(aMenu)
    LOCAL nLin := 10 + nTamMenu + 1
    LOCAL nCol := 04 + LEN(aMenu[01,01]) + 04

    @08, 04 TO nLin, nCol DOUBLE
    @08, 09 SAY "[ " + ProcName(2) + " ]"
RETURN

FUNCTION CENTRALIZA(cTexto)
RETURN ((MaxCol() - LEN(cTexto)) / 2)

FUNCTION MENSAGEM(cMensagem, aOpcoes)
    aOpcoes := {"Ok"} IF ValType(aOpcoes) == 'U'
RETURN nEscolha :=  HB_Alert( cMensagem, aOpcoes, "W+/N")

FUNCTION CONFIRMA(cPergunta)
    LOCAL cPerguntaPadrao := "Confirma sair do sistema?"
    LOCAL aOpcoes  := {"Sim", "Nao"}
    LOCAL nEscolha := 0  
    LOCAL cPerguntaConfirma := iif(cPergunta == NIL, cPerguntaPadrao, cPergunta)
RETURN MENSAGEM(cPerguntaConfirma, aOpcoes) == 1

FUNCTION AJUSTAR_DATA(dULTICOMPRA)
    LOCAL STR_DT_INVERTIDA := DTOS(dULTICOMPRA)    
RETURN  SUBSTR(STR_DT_INVERTIDA,7,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,5,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,1,4)

FUNCTION NOME_PROGRAMA(cNomePrograma, cParamPrograma)
    LOCAL cParametros := "()"
    IF ValType(cParamPrograma) != "U"
        cParametros := StrTran("(#Param)","#Param",ltrim(str(cParamPrograma)))
    ENDIF
RETURN cNomePrograma + cParametros

FUNCTION FORMATAR_REAIS(nValor)
    LOCAL cRetValor := "0,00"

    IF ValType(nValor) == "N"
        cRetValor := transform(nValor,"@E 9,999,999.99")
    ENDIF
RETURN cRetValor

*****************************************************************************
* StrSwap2
*   Replaces delimited substrings in cString with elements in hSwap hash.
*   Substrings are demited with #{}
* Author:
*   Sergio Lima
* Last update:
*   Aug, 2021
* Example:
*   hNewValues := {"is super" => "is", "cool" => "awesome"}
*   ? StrSwap2( "This function #{is super} #{cool}!!!", aNewValues )
*   // results
*   // This function is awesome!!!
* params:
*   cString     <expC> - String with data to be changed
*   hSwap       <expH> - Hash with data to change cString
* Return:
*   expC        cString changed
*****************************************************************************
FUNCTION StrSwap2( cString, hSwap )
LOCAL cRegExpFindDelimiter := HB_RegexComp( "\#\{(.*?)\}" )
LOCAL lInvalidParamNumber := (PCount() < 1 .OR. PCount() > 2)
LOCAL lFirstParamTypeOk := (ValType(hb_PValue(1)) == "C")
LOCAL lSecParamTypeOk := (ValType(hb_PValue(2)) == "H")
LOCAL cDemitedSubString := NIL, cFirstHashValue := NIL

    IF lInvalidParamNumber 
        RETURN NIL
    ENDIF

    IF lFirstParamTypeOk .AND. !lSecParamTypeOk
        RETURN cString
    ENDIF

    if Empty(hSwap) .OR. ;
        Empty( HB_Regex( cRegExpFindDelimiter, cString ) )
        RETURN cString
    ENDIF

    cDemitedSubString := "#{" + hb_HKeyAt( hSwap, 1) + "}"
    cFirstHashValue := hb_HValueAt( hSwap, 1)

    cString := StrTran(cString, cDemitedSubString, cFirstHashValue)
RETURN StrSwap2(cString, hb_HDelAt( hSwap, 1 ))
