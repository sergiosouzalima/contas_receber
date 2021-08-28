/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modfat.prg
    Finalidade...: Manutencao cadastro de faturas
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "sql.ch"
#include "global.ch"
#require "hbsqlit3"

PROCEDURE MODFAT()
    LOCAL hTeclaOperacao := { ;
        K_I => "modfatinc" , K_i => "modfatinc", ;
        K_A => "modfatalt" , K_a => "modfatalt", ;
        K_E => "modfatexc" , K_e => "modfatexc"  }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL cMsgRodape := "Faturas:#{qtdreg} " + COMANDOS_MENSAGEM
    LOCAL hAtributos := { ;
        "TITULO" => "Faturas", ;
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
        "COMANDOS_MENSAGEM" => cMsgRodape, ;
        "COMANDOS_TECLAS" => { K_I, K_i, K_A, K_a, K_E, K_e } ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_FATURA_COUNT)
    if (lSair := nQtdRegistros == 0)
        modfatinc()
    ENDIF

    DO WHILE !lSair
        pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_FATURA_SELECT_ALL)

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
        hAtributos["COMANDOS_MENSAGEM"] := ;
            StrSwap2( cMsgRodape, { "qtdreg" => strzero(nQtdRegistros,4) } )

        hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
        lSair := (hTeclaRegistro["TeclaPressionada"] == K_ESC)
        IF !lSair
            &( NOME_PROGRAMA( ;
                hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
                hTeclaRegistro["RegistroEscolhido"] ) )
            nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_FATURA_COUNT)
            lSair := nQtdRegistros == 0   
        ENDIF
    ENDDO
RETURN