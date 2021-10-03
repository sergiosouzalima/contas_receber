/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcli_get_fields.prg
    Finalidade...: Mostrar tela e obter campos do cadastro de clientes (inclusao, alteracao, exclusao)
    Autor........: Sergio Lima
    Atualizado em: Outubro, 2021
*/

#include "inkey.ch"
#include "global.ch"

FUNCTION modcli_get_fields(hClienteRegistro, cMode)
    LOCAL GetList := {}

    SET INTENSITY OFF
    @11,05 SAY "NOME.....:" ;
        GET hClienteRegistro["NOMECLI"] ;    
        PICTURE "@!" ;
        VALID !Empty(hClienteRegistro["NOMECLI"])
    IF cMode != INSERTING_MODE
        @11,60 SAY "CODIGO:"                ;      
            GET hClienteRegistro["CODCLI"]  ;   
            PICTURE "@9"                    ;
            WHEN .F.
    ENDIF
    @13,05 SAY "DATA NASC:"         GET hClienteRegistro["DATA_NASC"]   PICTURE "99/99/9999"
    @15,05 SAY "DOCUMENTO:"         GET hClienteRegistro["DOCUMENTO"]   PICTURE "@!"
    @17,05 SAY "E-MAIL...:"         GET hClienteRegistro["EMAIL"]       
    @17,60 SAY "DDI:"               GET hClienteRegistro["FONE_DDI"]    PICTURE "99"
    @17,70 SAY "DDD:"               GET hClienteRegistro["FONE_DDD"]    PICTURE "99"
    @17,80 SAY "FONE:"              GET hClienteRegistro["FONE"]        PICTURE "@!"
    @19,05 SAY "CEP......:"         GET hClienteRegistro["CEP"]         PICTURE "99999-999"    
    @21,05 SAY "ENDERECO.:"         GET hClienteRegistro["ENDERECO"]    PICTURE "@!"           
    @21,60 SAY "CIDADE:"            GET hClienteRegistro["CIDADE"]      PICTURE "@!"           
    @21,92 SAY "UF:"                GET hClienteRegistro["ESTADO"]      PICTURE "!!"
    
    READ UNLESS cMode == DELETING_MODE
    
    SET INTENSITY ON

RETURN hClienteRegistro