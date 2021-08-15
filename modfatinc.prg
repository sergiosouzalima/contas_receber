/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatinc.prg
    Finalidade...: Manutencao cadastro de faturas (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modfatinc()
    LOCAL GetList := {}
    LOCAL hFaturaRegistro := { ;
        "CODFAT" => 0, "CODCLI" => 0,;
        "DATA_VENCIMENTO" => DATE(), "DATA_PAGAMENTO" => DATE(),;
        "VALOR_NOMINAL" => 0.00, "VALOR_PAGAMENTO" => 0.00 }
    LOCAL hStatusBancoDados := ABRIR_BANCO_DADOS()

    hb_DispBox( LINHA_INI_CENTRAL, COLUNA_INI_CENTRAL,;
        LINHA_FIM_CENTRAL, COLUNA_FIM_CENTRAL, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    SET INTENSITY OFF
    @11,39 SAY "CODIGO CLIENTE....: " ;
        GET hFaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        VALID hFaturaRegistro["CODCLI"] > 0 .AND. ;
              OBTER_QUANTIDADE_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"]) == 1 .AND. ;
              MOSTRAR_NOME_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"])
    @12,39 SAY "DATA VENCIMENTO...: " ;
        GET hFaturaRegistro["DATA_VENCIMENTO"] ;
        PICTURE "99/99/9999" ;
        VALID !Empty(hFaturaRegistro["DATA_VENCIMENTO"])          
    @13,39 SAY "DATA_PAGAMENTO....: " ;
        GET hFaturaRegistro["DATA_PAGAMENTO"] ;
        PICTURE "99/99/9999"     
    @14,39 SAY "VALOR_NOMINAL.....: " ;
        GET hFaturaRegistro["VALOR_NOMINAL"]  ;
        PICTURE "@E 9,999,999.99"          
    @15,39 SAY "VALOR_PAGAMENTO...: " ;
        GET hFaturaRegistro["VALOR_PAGAMENTO"] ;
        PICTURE "@E 9,999,999.99"
    READ
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        //hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
        MENSAGEM("Fatura cadastrado com sucesso!")
    ENDIF 
RETURN NIL

FUNCTION MOSTRAR_NOME_CLIENTE(pBancoDeDados, nCODCLI)
    LOCAL pRegistro := OBTER_CLIENTE(pBancoDeDados, nCodCli)

    @11, 73 CLEAR TO 11, 112
    DO WHILE sqlite3_step(pRegistro) == 100
        @11, 73 SAY sqlite3_column_text(pRegistro, 2) // NOMECLI
    ENDDO
    sqlite3_clear_bindings(pRegistro)
    sqlite3_finalize(pRegistro) 
RETURN .T.