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
    LOCAL hAtributos := { ;
        "TITULOS" => {;
            "Cod.Fatura", ;
            "Cod.Cliente", ;
            "Nome Cliente", ;
            "Dt.Vencimento", ;
            "Dt.Pagamento", ;
            "Valor Nominal", ;
            "Valor Pagamento" ;
        } ,;
        "VALORES" => {{;
            0, ;
            0, ;
            "-----------", ;
            CTOD(space(8)), ;
            CTOD(space(8)), ;
            0.00, ;
            0.00 ;
        }} ,;
        "ATRIBUTOS_TABELA" => {;
            {|pReg| sqlite3_column_int(pReg, 01)}, ;
            {|pReg| sqlite3_column_int(pReg, 02)}, ;
            {|pReg| sqlite3_column_text(pReg, 03)}, ;
            {|pReg| sqlite3_column_text(pReg, 04)}, ;
            {|pReg| sqlite3_column_text(pReg, 05)}, ;
            {|pReg| FORMATAR_REAIS( sqlite3_column_double(pReg, 06) )}, ;
            {|pReg| FORMATAR_REAIS( sqlite3_column_double(pReg, 07) )} ;
        } ;
    }

    VISUALIZAR_CONSULTA_FATURAS(SQL_CONSULTA_FATURA_DATACLIENTE, hAtributos)
RETURN .T.