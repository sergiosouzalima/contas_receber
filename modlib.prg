#include "global.ch"

PROCEDURE CONFIGURACAO_INICIAL
    SET DATE BRITISH
    SET CENTURY ON
    SET MESSAGE TO LINHA_MENSAGEM CENTER
    SET WRAP ON
    SET DELIMITERS ON
    SET DELIMITERS TO "[]"
    SET CONFIRM ON
    SET SCOREBOARD OFF
    SET ESCAPE OFF
    SETMODE(60, 132)
RETURN

FUNCTION INICIALIZA_BANCO_DE_DADOS()
    LOCAL aOpcoes := {"Ok"} 
    LOCAL cMensagemErroBD := "Nao foi possivel criar banco de dados: " + BD_CONTAS_RECEBER
    LOCAL cMensagemErroTabela := "Nao foi possivel criar tabela."
    LOCAL pBancoDeDados := NIL
    LOCAL lBancoDadosOK := .F.
    LOCAL lTabelaClienteOK := .F.
    LOCAL nSqlCodigoErro := 0

    pBancoDeDados := ABRIR_BANCO_DE_DADOS()

    IF pBancoDeDados == NIL
        HB_Alert(cMensagemErroBD, aOpcoes, "W+/N")
    ELSE
        nSqlCodigoErro := CRIAR_TABELA_CLIENTE(pBancoDeDados)
	    IF nSqlCodigoErro > 0 // Erro ao executar SQL
            HB_Alert(cMensagemErroTabela + " Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                    "SQL: " + sqlite3_errmsg(pBancoDeDados), aOpcoes, "W+/N")
        ENDIF
        lBancoDadosOK := nSqlCodigoErro == 0
	ENDIF
RETURN lBancoDadosOK

FUNCTION ABRIR_BANCO_DE_DADOS()
    LOCAL pBancoDeDados := NIL
    LOCAL lCriaBD := .T. // lCriaBD: criar se não existir

    pBancoDeDados := sqlite3_open(BD_CONTAS_RECEBER, lCriaBD)

    IF !File(BD_CONTAS_RECEBER)
        pBancoDeDados := NIL
    ENDIF    
RETURN pBancoDeDados

FUNCTION CRIAR_TABELA_CLIENTE(pBancoDeDados)
    LOCAL cSql := "CREATE TABLE IF NOT EXISTS CLIENTE( " +;
    " nCODCLI INTEGER PRIMARY KEY AUTOINCREMENT, " +;
    " cNOMECLI VARCHAR2(40), " +;
    " cENDERECO VARCHAR2(40), " +;
    " cCEP CHAR(09), " +;
    " cCIDADE VARCHAR2(20), " +;
    " cESTADO CHAR(20), " +;
    " dULTICOMPRA DATE, " +;
    " lSITUACAO BOOLEAN DEFAULT(1)); "
RETURN sqlite3_exec(pBancoDeDados, cSql)

PROCEDURE MOSTRA_TELA_PADRAO()
    LOCAL cSISTEMA := "*** " + SISTEMA + " ***"
    CLEAR SCREEN
    @ 00,00 TO 00, MaxCol() DOUBLE
    @ 01,CENTRALIZA(cSISTEMA) SAY cSISTEMA
    @ 02,CENTRALIZA(EMPRESA) SAY EMPRESA
    @ 03,00 TO 03, MaxCol()
    @ 04,00 SAY ProcName(2)
    @ 04, MaxCol() - 10 SAY Date()
    @ 05,00 TO 05, MaxCol() DOUBLE
RETURN

PROCEDURE MOSTRA_QUADRO(aMenu)
    LOCAL nTamMenu := LEN(aMenu)
    @08, 07 TO 10 + nTamMenu + 1, 26 DOUBLE
    @08, 12 SAY "[ " + ProcName(2) + " ]"
RETURN

FUNCTION CENTRALIZA(cTexto)
RETURN ((MaxCol() - LEN(cTexto)) / 2)

PROCEDURE EXECUTA_PROGRAMA(nProgramaEscolhido, aProgramas) 
    IF nProgramaEscolhido >= 1
      DO (aProgramas[nProgramaEscolhido])
    END IF
RETURN

FUNCTION CONFIRMA(cPergunta)
    LOCAL cPerguntaPadrao := "CONFIRMA SAIR DO SISTEMA?"
    LOCAL cPerguntaConfirma
    LOCAL aOpcoes  := { "Sim", "Nao" }
    LOCAL nEscolha := 0  

    cPerguntaConfirma := iif(cPergunta == NIL, cPerguntaPadrao, cPergunta) + ";"

    nEscolha := HB_Alert(cPerguntaConfirma, aOpcoes, "W+/N")
RETURN nEscolha == 1

FUNCTION AJUSTAR_DATA(dULTICOMPRA)
    LOCAL STR_DT_INVERTIDA := DTOS(dULTICOMPRA)    
RETURN SUBSTR(STR_DT_INVERTIDA,7,2) + "/" + SUBSTR(STR_DT_INVERTIDA,5,2) + "/" +;
    SUBSTR(STR_DT_INVERTIDA,1,4)  
