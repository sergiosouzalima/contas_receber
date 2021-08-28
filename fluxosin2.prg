/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: fluxosin2.prg
    Finalidade...: Consulta de faturas
                   CONSULTA SINTETICA TOTAL POR DATA VENCIMENTO
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "sql.ch"
#include "global.ch"
#require "hbsqlit3"

PROCEDURE FLUXOSIN2()
    LOCAL hTeclaOperacao := { => }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL hAtributos := { ;
        "TITULO" => "CONSULTA SINTETICA TOTAL POR DATA VENCIMENTO", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "DIMENSIONS" => {}, ;
        "LOOKUP" => .F., ;
        "TITULOS" => {;
            "Dt.Vencimento", ;
            "Qtd.Faturas", ;
            "Total Val.Nominal", ;
            "Total Val.Pagamento" ;
        }, ;
        "TAMANHO_COLUNAS" => { 14, 11, 19, 19 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM_CONSULTAR, ;
        "COMANDOS_TECLAS" => {} ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_SINTETICA_TOTAIS_DT_VENC_COUNT)

    pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_SINTETICA_TOTAIS_DT_VENC)

    aValores := {}
    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aValores, { ;
            sqlite3_column_text(pRegistros, 1), ;   // DATA_VENCIMENTO
            sqlite3_column_int(pRegistros, 2), ;    // QTD FATURAS
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 3) ), ; // VALOR_NOMINAL
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 4) )  ; // VALOR_PAGAMENTO            
        })
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 

    hAtributos["QTDREGISTROS"]  := nQtdRegistros
    hAtributos["VALORES"]       := { aValores, 1 }

    VISUALIZA_DADOS(hAtributos)
RETURN