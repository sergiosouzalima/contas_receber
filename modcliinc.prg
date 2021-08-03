/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcliinc.prg
    Finalidade...: Manutencao cadastro de clientes (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Julho, 2021
*/

#include "global.ch"

FUNCTION modcliinc()
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL hClienteRegistro := { ;
        "CODCLI" => 0,;
        "NOMECLI" => SPACE(40), "ENDERECO" => SPACE(40),;
        "CEP" => SPACE(09), "CIDADE" => SPACE(20),;
        "ESTADO" => SPACE(02), "ULTICOMPRA" => DATE(), "SITUACAO" => .T.}

    hb_DispBox( LINHA_INI_CENTRAL, COLUNA_INI_CENTRAL,;
        LINHA_FIM_CENTRAL, COLUNA_FIM_CENTRAL, hb_UTF8ToStrBox( "┌─┐│┘─└│ " ) )

    SET INTENSITY OFF
    @10,39 SAY "NOME.........: " GET hClienteRegistro["NOMECLI"]     PICTURE "@!X"           
    @11,39 SAY "ENDERECO.....: " GET hClienteRegistro["ENDERECO"]    PICTURE "@!X"           
    @12,39 SAY "CEP..........: " GET hClienteRegistro["CEP"]         PICTURE "99999-999"     
    @13,39 SAY "CIDADE.......: " GET hClienteRegistro["CIDADE"]      PICTURE "@!X"           
    @14,39 SAY "ESTADO.......: " GET hClienteRegistro["ESTADO"]      PICTURE "!!"            
    @15,39 SAY "ULTIMA COMPRA: " GET hClienteRegistro["ULTICOMPRA"]  PICTURE "99/99/9999"
    READ
    SET INTENSITY ON

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)

    Alert("Cliente cadastrado",, "W+/N")
RETURN NIL