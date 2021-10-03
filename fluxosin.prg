/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: fluxosin.prg
    Finalidade...: Consulta de faturas
                   CONSULTA DE TOTAIS POR CLIENTE, DATA VENCIMENTO/A VENCER
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "sql.ch"
#include "global.ch"
#require "hbsqlit3"

PROCEDURE FLUXOSIN()
    LOCAL hTeclaOperacao := { => }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL hAtributos := { ;
        "TITULO" => "CONSULTA DE TOTAIS POR CLIENTE, DATA VENCIMENTO/A VENCER", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "DIMENSIONS" => {}, ;
        "LOOKUP" => .F., ;
        "TITULOS" => {;
            "Cod.Cliente", ;
            "Nome Cliente", ;
            "Dt.Vencimento", ;
            "Qtd.Faturas", ;
            "Total Val.Nominal", ;
            "Total Val.Pagamento" ;
        }, ;
        "TAMANHO_COLUNAS" => { 11, 25, 14, 11, 19, 19 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM_CONSULTAR, ;
        "COMANDOS_TECLAS" => {} ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_TOTAIS_DT_VENC_COUNT)

    pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CONSULTA_TOTAIS_DT_VENC)

    aValores := {}
    DO WHILE sqlite3_step(pRegistros) == 100
        AADD(aValores, { ;
            sqlite3_column_int(pRegistros, 1), ;    // CODFAT
            sqlite3_column_text(pRegistros, 2), ;   // NOMECLI
            sqlite3_column_text(pRegistros, 3), ;   // DATA_VENCIMENTO
            sqlite3_column_int(pRegistros, 4), ;    // QTD FATURAS
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 5) ), ; // VALOR_NOMINAL
            FORMATAR_REAIS( sqlite3_column_double(pRegistros, 6) )  ; // VALOR_PAGAMENTO            
        })
    ENDDO
    sqlite3_clear_bindings(pRegistros)
    sqlite3_finalize(pRegistros) 

    hAtributos["QTDREGISTROS"]  := nQtdRegistros
    hAtributos["VALORES"]       := { aValores, 1 }

    hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
    MENSAGEM(hTeclaRegistro["Message"]) IF hb_HHasKey(hTeclaRegistro, "Message") .AND. !Empty(hTeclaRegistro["Message"])
RETURN