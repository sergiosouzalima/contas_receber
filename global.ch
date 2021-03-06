/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: global.ch
    Finalidade...: Constantes disponiveis em todo o sistema
    Autor........: Sergio Lima
    Atualizado em: Outubro, 2021
*/

// in line IF & UNLESS COMMANDS
#xcommand <Command1> [<Commandn>] IF <lCondition> => IF <lCondition> ; <Command1> [<Commandn>]; ENDIF ;

#xcommand <Command1> [<Commandn>] UNLESS <lCondition> => IF !(<lCondition>) ; <Command1> [<Commandn>]; ENDIF ;

// -------------------
#define EMPRESA "BLOGUEIRO SAMURAI"
#define VERSION "0.6.1"
#define SISTEMA "SISTEMA DE CONTAS A RECEBER"
#define LINHA_MENSAGEM 04
#define LINHA_CONFIRMA 06
#define SEM_ESCOLHA 0
#define BD_CONTAS_RECEBER "contas_receber.s3db"
#define MENSAGEM_ERRO_BD "Nao foi possivel criar banco de dados: " + BD_CONTAS_RECEBER
#define MENSAGEM_ERRO_TABELA "Nao foi possivel criar tabela."
#define SETAS CHR(24) + CHR(25) + CHR(27) + CHR(26)
#define COMANDOS_MENSAGEM "[ESC]=Sair [I]=Incluir [A]=Alterar [E]=Excluir [" + SETAS + "]=Movimentar"
#define COMANDOS_MENSAGEM_SELECIONAR "[ESC]=Sair [ENTER]=Selecionar [" + SETAS + "]=Movimentar"
#define COMANDOS_MENSAGEM_CONSULTAR "[ESC]=Sair [" + SETAS + "]=Movimentar"
#define INSERTING_MODE  "I"
#define UPDATING_MODE   "U"
#define DELETING_MODE   "D"
#xtranslate NUM_RANDOM() => (Random()%6+1)

// Tela Central
#define CENTRAL_LIN_INI             08
#define CENTRAL_COL_INI             03
#define CENTRAL_LIN_FIM             27
#xtranslate CENTRAL_COL_FIM => (MaxCol()-3)

// Comandos do Browse
#define K_a 97
#define K_A 65
#define K_E 69
#define K_e 101
#define K_I 73
#define K_i 105