#include "hbclass.ch"
#require "hbsqlit3"
#include "global.ch"

TESTE()

Inkey(0)

FUNCTION TESTE()
    LOCAL xRetornoBD := NIL
    LOCAL lCriaBD := .T. // lCriaBD: criar se não existir
    ? "=========="
    ? sqlite3_libversion()
    xRetornoBD := sqlite3_open(BD_CONTAS_RECEBER, lCriaBD)

    ? "---------"
    ? xRetornoBD
    ? "=========="
RETURN .T.