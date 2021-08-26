/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: modcli.prg
    Finalidade...: Manutencao cadastro de clientes
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "sql.ch"
#include "global.ch"
#require "hbsqlit3"

PROCEDURE MODCLI()
    LOCAL hTeclaOperacao := { ;
        K_I => "modcliinc" , K_i => "modcliinc", ;
        K_A => "modclialt" , K_a => "modclialt", ;
        K_E => "modcliexc" , K_e => "modcliexc"  }    
    LOCAL hStatusBancoDados := {"lBancoDadosOK" => .F., "pBancoDeDados" => NIL}
    LOCAL hTeclaRegistro := {"TeclaPressionada" => 0, "RegistroEscolhido" => 0}
    LOCAL pRegistros := NIL
    LOCAL aValores := {}
    LOCAL nQtdRegistros := 0
    LOCAL lSair := .F.
    LOCAL hAtributos := { ;
        "TITULO" => "Clientes", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "TITULOS" => {;
            "Cod.Cliente", ;
            "Nome Cliente", ;
            "Endereco", ;
            "CEP", ;
            "Cidade", ;
            "UF", ;
            "Dt.Ult.Compra", ;
            "Situacao Ok?" ;
        }, ;
        "TAMANHO_COLUNAS" => { 11, 25, 20, 10, 20, 3, 15, 15 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => COMANDOS_MENSAGEM, ;
        "COMANDOS_TECLAS" => { K_I, K_i, K_A, K_a, K_E, K_e } ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    DO WHILE !lSair
        pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_SELECT_ALL)

        aValores := {}
        nQtdRegistros := 0
        DO WHILE sqlite3_step(pRegistros) == 100
            nQtdRegistros++
            AADD(aValores, { ;
                sqlite3_column_int(pRegistros, 1), ;   // CODCLI
                sqlite3_column_text(pRegistros, 2), ;  // NOMECLI
                sqlite3_column_text(pRegistros, 3), ;  // ENDERECO
                sqlite3_column_text(pRegistros, 4), ;  // CEP
                sqlite3_column_text(pRegistros, 5), ;  // CIDADE
                sqlite3_column_text(pRegistros, 6), ;  // ESTADO
                sqlite3_column_text(pRegistros, 7), ;  // ULTICOMPRA
                sqlite3_column_text(pRegistros, 8)  ;  // SITUACAO
            })
        ENDDO
        sqlite3_clear_bindings(pRegistros)
        sqlite3_finalize(pRegistros) 

        hAtributos["QTDREGISTROS"]  := nQtdRegistros
        hAtributos["VALORES"]       := { aValores, 1 }

        IF nQtdRegistros < 1
            hb_Alert( "Nenhum registro encontrado",, "W+/N" )
            modcliinc()
            lSair := (LastKey() == K_ESC)
        ELSE
            hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
            lSair := (hTeclaRegistro["TeclaPressionada"] == K_ESC)
            IF !lSair
                &( NOME_PROGRAMA( ;
                    hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
                    hTeclaRegistro["RegistroEscolhido"] ) )
            ENDIF
        ENDIF
    ENDDO
RETURN