/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: datacliente.prg
    Finalidade...: Consulta de faturas
                   CONSULTA ORGANIZADA POR DATA DE VENCIMENTO E CLIENTE
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "sql.ch"
#include "global.ch"
#require "hbsqlit3"

PROCEDURE DATACLIENTE()
    LOCAL hTeclaOperacao := { => }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL hAtributos := { ;
        "TITULO" => "CONSULTA ORGANIZADA POR DATA DE VENCIMENTO E CLIENTE", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "DIMENSIONS" => {}, ;
        "LOOKUP" => .F., ;
        "TITULOS" => {;
            "Cod.Fatura", ;
            "Cod.Cliente", ;
            "Nome Cliente", ;
            "Dt.Vencimento", ;
            "Dt.Pagamento", ;
            "Valor Nominal", ;
            "Valor Pagamento" ;
        }, ;
        "TAMANHO_COLUNAS" => { 11, 11, 25, 14, 14, 15, 15 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM_CONSULTAR, ;
        "COMANDOS_TECLAS" => {} ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_DATACLIENTE_COUNT)

    pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_DATACLIENTE)

    aValores := {}
    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aValores, { ;
            sqlite3_column_int(pRegistros, 1), ;    // CODFAT
            sqlite3_column_int(pRegistros, 2), ;    // CODCLI
            sqlite3_column_text(pRegistros, 3), ;   // NOMECLI
            sqlite3_column_text(pRegistros, 4), ;   // DATA_VENCIMENTO
            sqlite3_column_text(pRegistros, 5), ;   // DATA_PAGAMENTO
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 6) ), ; // VALOR_NOMINAL
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 7) )  ; // VALOR_PAGAMENTO            
        })
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 

    hAtributos["QTDREGISTROS"]  := nQtdRegistros
    hAtributos["VALORES"]       := { aValores, 1 }

    VISUALIZA_DADOS(hAtributos)
RETURN