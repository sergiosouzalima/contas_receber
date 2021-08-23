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
                    IF OBTER_QUANTIDADE_CLIENTES(pBancoDeDados) < 1
                        INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
                    ENDIF
                    cSql := SQL_FATURA_CREATE
                    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
                    IF nSqlCodigoErro == SQLITE_OK
                        IF OBTER_QUANTIDADE_FATURAS(pBancoDeDados) < 1
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

PROCEDURE MOSTRA_NOME_PROGRAMA(cNomePrograma)
    @ 04,00 SAY cNomePrograma
RETURN

PROCEDURE MOSTRA_QUADRO(aMenu)
    LOCAL nTamMenu := LEN(aMenu)
    @08, 07 TO 10 + nTamMenu + 1, 26 DOUBLE
    @08, 12 SAY "[ " + ProcName(2) + " ]"
RETURN

FUNCTION CENTRALIZA(cTexto)
RETURN ((MaxCol() - LEN(cTexto)) / 2)

FUNCTION MENSAGEM(cMensagem, aOpcoes)
    LOCAL nOpcoes := 0, nEscolha := 0, I := 0
    LOCAL nCol := CENTRALIZA(cMensagem)
    LOCAL nIncCol := nCol

    IF ValType(aOpcoes) == 'U'
        aOpcoes = {"Ok"}
    ENDIF
    nOpcoes = LEN(aOpcoes)

    @ 19, nCol - 2 TO 23, nCol + Len(cMensagem) + 1
    @ 20, nCol CLEAR TO 22, nCol + Len(cMensagem) 
    @ 20, nCol SAY cMensagem
    FOR I := 1 TO nOpcoes
        @ 22, nIncCol PROMPT aOpcoes[I]
        nIncCol += 5
    NEXT
    MENU TO nEscolha 
RETURN nEscolha

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

FUNCTION TECLA_PERMITIDA_VISUALIZAR(nQtdRegistros, hTeclaOperacao, nTeclaPressionada)
    LOCAL lTeclaPermitida := .F.
    LOCAL lTabelaVazia := nQtdRegistros == 0
    LOCAL lTeclaPressionadaPermitida := hb_HPos( hTeclaOperacao, nTeclaPressionada ) > 0
    LOCAL lDesejaIncluir := ;
        nTeclaPressionada == K_I .OR.;
        nTeclaPressionada == K_i

    IF lTeclaPressionadaPermitida
        lTeclaPermitida := !lTabelaVazia .OR. (lTabelaVazia .AND. lDesejaIncluir)
    ENDIF
RETURN lTeclaPermitida

FUNCTION RODAPE_VISUALIZAR(nQtdRegistros, cPrograma)
LOCAL cTeclasDisp := iif(nQtdRegistros == 0, TECLAS_VISUALIZAR_INS, TECLAS_VISUALIZAR )

    hb_DispOutAt( LINHA_RODAPE_BROWSE, COLUNA_RODAPE_BROWSE, ;
        StrZero(nQtdRegistros,4) + ;
        " " + ;
        cPrograma + ;
        " | " + ;
        cTeclasDisp ;
    )
RETURN NIL

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
LOCAL lFewParams := (PCount() < 2)
LOCAL cFirstParamType := ValType(cString), cSecParamType := ValType(hSwap)
LOCAL cDemitedSubString := NIL, cFirstHashValue := NIL

    IF lFewParams .OR. ;
        !(cFirstParamType == "C" .AND. cSecParamType == "H")
        RETURN NIL
    ENDIF

    if Empty(hSwap) .OR. ;
        Empty( HB_Regex( cRegExpFindDelimiter, cString ) )
        RETURN cString
    ENDIF

    cDemitedSubString := "#{" + hb_HKeyAt( hSwap, 1) + "}"
    cFirstHashValue := hb_HValueAt( hSwap, 1)

    cString := StrTran(cString, cDemitedSubString, cFirstHashValue)
RETURN StrSwap2(cString, hb_HDelAt( hSwap, 1 ))