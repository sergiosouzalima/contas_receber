/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfatinc.prg
    Finalidade...: Manutencao cadastro de faturas (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#require "hbsqlit3"
#include "sql.ch"

FUNCTION modfatinc()
    LOCAL GetList := {}
    LOCAL hFaturaRegistro := { ;
        "CODFAT" => 0, "CODCLI" => 0,;
        "DATA_VENCIMENTO" => DATE(), "DATA_PAGAMENTO" => CTOD('  /  /    '),;
        "VALOR_NOMINAL" => 0.00, "VALOR_PAGAMENTO" => 0.00 }
    LOCAL hStatusBancoDados := ABRIR_BANCO_DADOS()

    MOSTRA_TELA_CADASTRO(ProcName())

    SET INTENSITY OFF
    @11,06 SAY "CODIGO CLIENTE <F2>.: " ;
        GET hFaturaRegistro["CODCLI"] ;    
        PICTURE "@!" ;
        VALID hFaturaRegistro["CODCLI"] > 0 .AND. ;
              QUERY_COUNTER( ;
                hStatusBancoDados["pBancoDeDados"], ;
                SQL_CLIENTE_COUNT_WHERE, ;
                { "CODCLI" => ltrim(str(hFaturaRegistro["CODCLI"])) }) == 1 .AND. ;  
              MOSTRAR_NOME_CLIENTE( ;
                hStatusBancoDados["pBancoDeDados"], ;
                hFaturaRegistro["CODCLI"])
    @12,06 SAY "DATA VENCIMENTO.....: " ;
        GET hFaturaRegistro["DATA_VENCIMENTO"] ;
        PICTURE "99/99/9999" ;
        VALID !Empty(hFaturaRegistro["DATA_VENCIMENTO"])          
    @13,06 SAY "DATA_PAGAMENTO......: " ;
        GET hFaturaRegistro["DATA_PAGAMENTO"] ;
        PICTURE "99/99/9999"     
    @14,06 SAY "VALOR_NOMINAL.......: " ;
        GET hFaturaRegistro["VALOR_NOMINAL"]  ;
        PICTURE "@E 9,999,999.99"          
    @15,06 SAY "VALOR_PAGAMENTO.....: " ;
        GET hFaturaRegistro["VALOR_PAGAMENTO"] ;
        PICTURE "@E 9,999,999.99"
    SET KEY K_F2 TO ACIONAR_VISUALIZAR_CLIENTES()
    READ
    SET KEY K_F2 TO
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        GRAVAR_FATURA(hStatusBancoDados, hFaturaRegistro)
        MENSAGEM("Fatura cadastrada com sucesso!")
    ENDIF 
RETURN NIL