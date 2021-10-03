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
    LOCAL cMsgRodape := "Clientes:#{qtdreg} " + COMANDOS_MENSAGEM
    LOCAL hAtributos := { ;
        "TITULO" => "Clientes", ;
        "QTDREGISTROS" => nQtdRegistros, ;
        "DIMENSIONS" => {}, ;
        "LOOKUP" => .F., ;
        "TITULOS" => {;
            "Cod.Cliente", ;
            "Nome Cliente", ;
            "Endereco", ;
            "CEP", ;
            "Cidade", ;
            "UF", ;
            "E-mail", ;
            "DDD",;
            "Fone" ;
        }, ;
        "TAMANHO_COLUNAS" => { 11, 25, 20, 10, 20, 3, 40, 03, 10 }, ;
        "VALORES" => { aValores, 1 }, ;
        "COMANDOS_MENSAGEM" => cMsgRodape, ;
        "COMANDOS_TECLAS" => { K_I, K_i, K_A, K_a, K_E, K_e } ;
    }

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_COUNT)
    if (lSair := nQtdRegistros == 0)
        modcliinc()
    ENDIF

    DO WHILE !lSair
        pRegistros := QUERY(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_SELECT_ALL)

        aValores := {}
        DO WHILE sqlite3_step(pRegistros) == 100
            AADD(aValores, { ;
                sqlite3_column_int(pRegistros,  01), ;  // CODCLI
                sqlite3_column_text(pRegistros, 02), ;  // NOMECLI
                sqlite3_column_text(pRegistros, 03), ;  // ENDERECO
                sqlite3_column_text(pRegistros, 04), ;  // CEP
                sqlite3_column_text(pRegistros, 05), ;  // CIDADE
                sqlite3_column_text(pRegistros, 06), ;  // ESTADO
                sqlite3_column_text(pRegistros, 07), ;  // EMAIL
                sqlite3_column_text(pRegistros, 08), ;  // DDD
                sqlite3_column_text(pRegistros, 09)  ;  // FONE
            })
        ENDDO
        sqlite3_clear_bindings(pRegistros)
        sqlite3_finalize(pRegistros) 

        hAtributos["QTDREGISTROS"]      := nQtdRegistros
        hAtributos["VALORES"]           := { aValores, 1 }
        hAtributos["COMANDOS_MENSAGEM"] := ;
            StrSwap2( cMsgRodape, { "qtdreg" => strzero(nQtdRegistros,4) } )

        hTeclaRegistro := VISUALIZA_DADOS(hAtributos)
        MENSAGEM(hTeclaRegistro["Message"]) IF hb_HHasKey(hTeclaRegistro, "Message") .AND. !Empty(hTeclaRegistro["Message"])
    
        lSair := (hTeclaRegistro["TeclaPressionada"] == K_ESC)
        IF !lSair
            &( NOME_PROGRAMA( ;
                hTeclaOperacao[hTeclaRegistro["TeclaPressionada"]], ;
                hTeclaRegistro["RegistroEscolhido"] ) )
            nQtdRegistros := QUERY_COUNTER(hStatusBancoDados["pBancoDeDados"], SQL_CLIENTE_COUNT)
            lSair := nQtdRegistros == 0     
        ENDIF
    ENDDO
RETURN