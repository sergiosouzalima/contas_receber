/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcliinc.prg
    Finalidade...: Manutencao cadastro de clientes (inclusao)
    Autor........: Sergio Lima
    Atualizado em: Outubro, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modcliinc()
    LOCAL GetList := {}
    LOCAL hStatusBancoDados := NIL
    LOCAL hClienteRegistro := { ;
        "CODCLI"        => 0        ,   ;
        "NOMECLI"       => SPACE(40),   ;
        "ENDERECO"      => SPACE(40),   ;
        "FONE_DDI"      => "55"     ,   ;
        "FONE_DDD"      => "11"     ,   ;
        "FONE"          => SPACE(10),   ;
        "EMAIL"         => SPACE(40),   ;
        "DATA_NASC"     => DATE()   ,   ;
        "DOCUMENTO"     => SPACE(20),   ;
        "CEP"           => SPACE(09),   ;
        "CIDADE"        => PAD("SAO PAULO", 20), ;  
        "ESTADO"        => "SP"         ;
    }

    MOSTRA_TELA_CADASTRO(ProcName())

    hClienteRegistro := modcli_get_fields(hClienteRegistro, INSERTING_MODE)

    IF hb_keyLast() == K_ENTER
        hStatusBancoDados := ABRIR_BANCO_DADOS()
        GRAVAR_CLIENTE(hStatusBancoDados, hClienteRegistro)
        MENSAGEM("Cliente cadastrado com sucesso!")
    ENDIF 
RETURN NIL