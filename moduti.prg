/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: moduti.prg
    Finalidade...: Utilitario do sistema
    Autor........: Sergio Lima
    Atualizado em: Agosto, 2021
*/

#include "inkey.ch"
#include "global.ch"
#include "sql.ch"
#include "hbver.ch"

FUNCTION moduti()
    LOCAL nOpc := 0
    LOCAL hStatusBancoDados := NIL
    LOCAL pBancoDeDados := NIL
    LOCAL nQtdCliente := 0, nQtdFatura := 0
    LOCAL cCurrentFolder := CURDIR()
    LOCAL lFileExists := File(BD_CONTAS_RECEBER)
    LOCAL cHabourInfo := ;
        "Build Date #{bdate}, major version:#{mjv}, minor version:#{mnv}, revision:#{rv}"
    LOCAL hHabourInfo := { ;
            "bdate" => hb_Version( HB_VERSION_COMPILER ),   ;
            "mjv"   => ltrim(str(hb_Version( HB_VERSION_MAJOR )))   ,   ;
            "mnv"   => ltrim(str(hb_Version( HB_VERSION_MINOR )))   ,   ;
            "rv"    => hb_Version( HB_VERSION_RELEASE )     ;
        }


    MOSTRA_TELA_CADASTRO(ProcName())

    hStatusBancoDados := ABRIR_BANCO_DADOS()

    pBancoDeDados := hStatusBancoDados["pBancoDeDados"]

    nQtdCliente := QUERY_COUNTER(pBancoDeDados, SQL_CLIENTE_COUNT)   
    nQtdFatura := QUERY_COUNTER(pBancoDeDados, SQL_FATURA_COUNT)  

    @10,06 SAY  "------ BANCO DE DADOS ------"
    @12,06 SAY  "NOME DO BANCO DE DADOS......: " + BD_CONTAS_RECEBER
    @13,06 SAY  "LOCALIZACAO.................: " + if(lFileExists, cCurrentFolder, BD_CONTAS_RECEBER + " nao encontrado")
    @14,06 SAY  "QUANTIDADE DE CLIENTES......: " + ltrim(str(nQtdCliente))
    @15,06 SAY  "QUANTIDADE DE FATURAS.......: " + ltrim(str(nQtdFatura))
    @16,06 SAY  "VERSAO DO SQLite3...........: " + sqlite3_libversion()

    @19,06 SAY  "-------- SISTEMA ------------"
    @21,06 SAY  "LOCALIZACAO DO EXECUTAVEL...: " + cCurrentFolder
    @22,06 SAY  "INFORMACOES DO Harbour......: " + StrSwap2( cHabourInfo, hHabourInfo )
    @23,06 SAY  "COMPILADOR USADO............: " + hb_Version( HB_VERSION_COMPILER )
    @24,06 SAY  "SISTEMA OPERACIONAL EM USO..: " + OS()

    @26,06 ;
        PROMPT  "  Tecle <ENTER> para voltar "
    MENU TO nOpc

RETURN NIL