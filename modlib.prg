#include "global.ch"
#include "sql.ch"
#include "hbgtinfo.ch"
#require "hbsqlit3"


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
    LOCAL lCriaBD := .T. // lCriaBD: criar se não existir
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL cSql := NIL

    BEGIN SEQUENCE
        pBancoDeDados := sqlite3_open(BD_CONTAS_RECEBER, lCriaBD) //Abrir banco de dados.

        IF pBancoDeDados == NIL .OR. !File(BD_CONTAS_RECEBER)
            Alert(MENSAGEM_ERRO_BD,, "W+/N")
        ELSE
            cSql := SQL_CLIENTE_CREATE
            nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
            IF nSqlCodigoErro == SQLITE_OK
                IF OBTER_QUANTIDADE_CLIENTE(pBancoDeDados) < 1
                    INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
                ENDIF
                cSql := SQL_FATURA_CREATE
                nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
                IF nSqlCodigoErro == SQLITE_OK
                    IF OBTER_QUANTIDADE_FATURA(pBancoDeDados) < 1
                        INSERIR_DADOS_INICIAIS_FATURA(pBancoDeDados)
                    ENDIF
                ELSE
                    BREAK
                ENDIF
            ELSE
                BREAK
            ENDIF
        ENDIF    
    RECOVER
        lBancoDadosOK := .F.
        Alert(MENSAGEM_ERRO_TABELA + ". Erro: " + ;
            LTrim(Str(nSqlCodigoErro)) + ". " + ;
            "Erro SQL: " + sqlite3_errmsg(pBancoDeDados) + ". " + ;
            cSql,, "W+/N")
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
    LOCAL cPerguntaPadrao := "Confirma sair do sistema?"
    LOCAL cPerguntaConfirma
    LOCAL aOpcoes  := {"Sim", "Nao"}
    LOCAL nEscolha := 0  

    cPerguntaConfirma := iif(cPergunta == NIL, cPerguntaPadrao, cPergunta)

    @ 19, 55 TO 23, 55 + Len(cPerguntaConfirma) + 3 
    @ 20, 57 SAY cPerguntaConfirma
    @ 22, 57 PROMPT aOpcoes[1]
    @ 22, 62 PROMPT aOpcoes[2]
    MENU TO nEscolha
RETURN nEscolha == 1

FUNCTION AJUSTAR_DATA(dULTICOMPRA)
    LOCAL STR_DT_INVERTIDA := DTOS(dULTICOMPRA)    
RETURN  SUBSTR(STR_DT_INVERTIDA,7,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,5,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,1,4)

FUNCTION OBTER_PROGRAMA_A_EXECUTAR(hTeclaOperacao, hTeclaRegistro) 
RETURN  hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]] + "(" + ;
        ltrim(str(hTeclaRegistro["RegistroEscolhido"])) + ")"

