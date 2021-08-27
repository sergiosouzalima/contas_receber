/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcliinc.prg
    Finalidade...: Manutencao cadastro de clientes (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modcliinc()
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL hClienteRegistro := { ;
        "CODCLI" => 0,;
        "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
        "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
        "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => 'S'}

    MOSTRA_TELA_CADASTRO(ProcName())

    SET INTENSITY OFF
    @11,06 SAY "NOME.........: " ;
        GET hClienteRegistro["NOMECLI"] ;    
        PICTURE "@!" ;
        VALID !Empty(hClienteRegistro["NOMECLI"])
    @12,06 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!"           
    @13,06 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999"     
    @14,06 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!"           
    @15,06 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!"            
    @16,06 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999"
    READ
    SET INTENSITY ON

    IF hb_keyLast() == K_ENTER
        hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
        MENSAGEM("Cliente cadastrado com sucesso!")
    ENDIF 
RETURN NIL