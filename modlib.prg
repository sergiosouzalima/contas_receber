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

FUNCTION DISPONIBILIZA_BANCO_DE_DADOS()
    LOCAL cMensagemErroBD := "Nao foi possivel criar banco de dados: " + BD_CONTAS_RECEBER
    LOCAL cMensagemErroTabela := "Nao foi possivel criar tabela."
    LOCAL pBancoDeDados := NIL
    LOCAL lBancoDadosOK := .F.
    LOCAL lTabelaClienteOK := .F.
    LOCAL nSqlCodigoErro := 0
    LOCAL lCriaBD := .T. // lCriaBD: criar se não existir
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}

    pBancoDeDados := sqlite3_open(BD_CONTAS_RECEBER, lCriaBD) //Abrir banco de dados.

    IF pBancoDeDados == NIL .OR. !File(BD_CONTAS_RECEBER)
        Alert(cMensagemErroBD,, "W+/N")
    ELSE
        nSqlCodigoErro := CRIAR_TABELA_CLIENTE(pBancoDeDados)
        IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL.
            Alert(cMensagemErroTabela + " Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                    "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
        ELSE 
            INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
        ENDIF
        lBancoDadosOK := nSqlCodigoErro == 0
	ENDIF
    
    hStatusBancoDados["lBancoDadosOK"] := lBancoDadosOK
    hStatusBancoDados["pBancoDeDados"] := pBancoDeDados
RETURN hStatusBancoDados

FUNCTION CRIAR_TABELA_CLIENTE(pBancoDeDados)
    LOCAL cSql := "CREATE TABLE IF NOT EXISTS CLIENTE( " +;
    " CODCLI INTEGER PRIMARY KEY AUTOINCREMENT, " +;
    " NOMECLI VARCHAR2(40), " +;
    " ENDERECO VARCHAR2(40), " +;
    " CEP CHAR(09), " +;
    " CIDADE VARCHAR2(20), " +;
    " ESTADO CHAR(20), " +;
    " ULTICOMPRA DATE, " +;
    " SITUACAO BOOLEAN DEFAULT(1)); "
RETURN sqlite3_exec(pBancoDeDados, cSql)

FUNCTION OBTER_QUANTIDADE_CLIENTE(pBancoDeDados)
    LOCAL nSqlCodigoErro := 0
    LOCAL cSql := "SELECT COUNT(*) AS 'QTD_CLIENTE' FROM CLIENTE;" 
    LOCAL pRegistros := NIL
    LOCAL nQTD_CLIENTE := 0

    pRegistros := sqlite3_prepare(pBancoDeDados, cSql)
    sqlite3_step(pRegistros)    
    nQTD_CLIENTE := sqlite3_column_int(pRegistros, 1) // QTD_CLIENTE  

    nSqlCodigoErro := sqlite3_errcode(pBancoDeDados)
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros)
RETURN nQTD_CLIENTE

FUNCTION INSERIR_DADOS_INICIAIS_CLIENTE(pBancoDeDados)
    LOCAL hClienteRegistro := {=>}
    LOCAL aNomes := {"JOSE", "JOAQUIM", "MATHEUS", "PAULO", "CRISTOVAO", "ANTONIO"}
    LOCAL aSobreNomes := {"SILVA", "SOUZA", "LIMA", "MARTINS", "GOMES", "PAIVA"}
    LOCAL I

    FOR I := 1 TO 10
        hClienteRegistro["NOMECLI"]    := aNomes[NUM_RANDOM()] + " " + aSobreNomes[NUM_RANDOM()] 
        hClienteRegistro["ENDERECO"]   := StrTran("RUA SANTO #1", "#1", aNomes[NUM_RANDOM()])
        hClienteRegistro["CEP"]        := "04040000"
        hClienteRegistro["CIDADE"]     := "SAO " + aNomes[NUM_RANDOM()]
        hClienteRegistro["ESTADO"]     := "SP"
        hClienteRegistro["ULTICOMPRA"] := AJUSTAR_DATA(Date())
        hClienteRegistro["SITUACAO"]   := .T.

        GRAVAR_DADOS_CLIENTE(pBancoDeDados, hClienteRegistro)    
    END LOOP

RETURN .T.

FUNCTION GRAVAR_DADOS_CLIENTE(pBancoDeDados, hClienteRegistro)
    LOCAL nSqlCodigoErro := 0
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL cSql := "INSERT INTO CLIENTE(" +;
    "NOMECLI, ENDERECO, " +;
    "CEP, CIDADE, ESTADO, " +;
    "ULTICOMPRA) VALUES(" +;
    "'#NOMECLI', '#ENDERECO', " +;
    "'#CEP', '#CIDADE', '#ESTADO', " +;
    "'#ULTICOMPRA'); "

    cSql := StrTran(cSql, "#NOMECLI", hClienteRegistro["NOMECLI"])
    cSql := StrTran(cSql, "#ENDERECO", hClienteRegistro["ENDERECO"])
    cSql := StrTran(cSql, "#CEP", hClienteRegistro["CEP"])
    cSql := StrTran(cSql, "#CIDADE", hClienteRegistro["CIDADE"])
    cSql := StrTran(cSql, "#ESTADO", hClienteRegistro["ESTADO"])
    cSql := StrTran(cSql, "#ULTICOMPRA", hClienteRegistro["ULTICOMPRA"])

    nSqlCodigoErro := sqlite3_exec(pBancoDeDados, cSql)
    IF nSqlCodigoErro > 0 .AND. nSqlCodigoErro < 100 // Erro ao executar SQL    
        Alert(" Erro: " + LTrim(Str(nSqlCodigoErro)) + ". " +;
                "SQL: " + sqlite3_errmsg(pBancoDeDados),, "W+/N")
    ENDIF
RETURN .T.

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
    LOCAL aOpcoes  := {"Sim", "Nao"}
    LOCAL nEscolha := 0  

    cPerguntaConfirma := iif(cPergunta == NIL, cPerguntaPadrao, cPergunta) + ";"

    nEscolha := HB_Alert(cPerguntaConfirma, aOpcoes, "W+/N")
RETURN nEscolha == 1

FUNCTION AJUSTAR_DATA(dULTICOMPRA)
    LOCAL STR_DT_INVERTIDA := DTOS(dULTICOMPRA)    
RETURN  SUBSTR(STR_DT_INVERTIDA,7,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,5,2) + "/" +;
        SUBSTR(STR_DT_INVERTIDA,1,4)  
