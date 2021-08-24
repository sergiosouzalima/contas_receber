/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: datacliente.prg
    Finalidade...: Consulta de faturas
                   CONSULTA ORGANIZADA POR DATA DE VENCIMENTO E CLIENTE
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "global.ch"
#include "sql.ch"

FUNCTION DATACLIENTE()    
    VISUALIZAR_CONSULTA_FATURAS(SQL_CONSULTA_FATURA_DATACLIENTE)
RETURN .T.