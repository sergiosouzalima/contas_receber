#define EMPRESA "BLOGUEIRO SAMURAI"
#define SISTEMA "SISTEMA DE CONTAS A RECEBER"
#define LINHA_MENSAGEM 04
#define LINHA_CONFIRMA 06
#define SAIR 5

PROCEDURE CONFIGURACAO_INICIAL
    SET DATE BRITISH
    SET CENTURY ON
    SET MESSAGE TO LINHA_MENSAGEM CENTER
    SET WRAP ON
RETURN

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
RETURN

FUNCTION CENTRALIZA(cTexto)
RETURN ((MaxCol() - LEN(cTexto)) / 2)

FUNCTION CONFIRMA(cPergunta)
    LOCAL cPerguntaPadrao := "CONFIRMA SAIR DO SISTEMA?"
    LOCAL cPerguntaConfirma, nOpcaoEscolhida
    LOCAL nPosicaoPergunta, nPosicaoSim, nPosicaoNao
    LOCAL nAjusteColuna := 4

    cPerguntaConfirma := iif(cPergunta == NIL, cPerguntaPadrao, cPergunta)
    nPosicaoPergunta := CENTRALIZA(cPerguntaConfirma) - nAjusteColuna
    nPosicaoSim := nPosicaoPergunta + LEN(cPerguntaConfirma) + 01 
    nPosicaoNao := nPosicaoPergunta + LEN(cPerguntaConfirma) + 05

    @ LINHA_CONFIRMA, nPosicaoPergunta SAY cPerguntaConfirma
    @ LINHA_CONFIRMA, nPosicaoSim PROMPT "Sim"
    @ LINHA_CONFIRMA, nPosicaoNao PROMPT "Nao"
    MENU TO nOpcaoEscolhida
    @ LINHA_CONFIRMA, 00 CLEAR 

RETURN nOpcaoEscolhida == 1