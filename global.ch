#define EMPRESA "BLOGUEIRO SAMURAI"
#define SISTEMA "SISTEMA DE CONTAS A RECEBER"
#define LINHA_MENSAGEM 04
#define LINHA_CONFIRMA 06
#define SAIR 5
#define BD_CONTAS_RECEBER "contas_receber.s3db"
#define MENSAGEM_ERRO_BD "Nao foi possivel criar banco de dados: " + BD_CONTAS_RECEBER
#define MENSAGEM_ERRO_TABELA "Nao foi possivel criar tabela."
#define SETAS CHR(24) + CHR(25) + CHR(27) + CHR(26)
#define LINHA_INI_CENTRAL 08
#define COLUNA_INI_CENTRAL 34
#define LINHA_FIM_CENTRAL 27
#xtranslate COLUNA_FIM_CENTRAL => (MaxCol()-3)
#define LINHA_INI_BROWSE LINHA_INI_CENTRAL + 01
#define COLUNA_INI_BROWSE COLUNA_INI_CENTRAL + 01
#define LINHA_FIM_BROWSE LINHA_FIM_CENTRAL - 02
#xtranslate COLUNA_FIM_BROWSE => (COLUNA_FIM_CENTRAL - 01)
#define LINHA_RODAPE_BROWSE LINHA_FIM_CENTRAL - 01
#define COLUNA_RODAPE_BROWSE COLUNA_INI_CENTRAL + 01
#define K_a 97
#define K_A 65
#define K_E 69
#define K_e 101
#define K_I 73
#define K_i 105
#xtranslate NUM_RANDOM() => (Random()%6+1)