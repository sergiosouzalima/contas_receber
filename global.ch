#define EMPRESA "BLOGUEIRO SAMURAI"
#define SISTEMA "SISTEMA DE CONTAS A RECEBER"
#define LINHA_MENSAGEM 04
#define LINHA_CONFIRMA 06
#define SAIR 5
#define SEM_ESCOLHA 0
#define BD_CONTAS_RECEBER "contas_receber.s3db"
#define MENSAGEM_ERRO_BD "Nao foi possivel criar banco de dados: " + BD_CONTAS_RECEBER
#define MENSAGEM_ERRO_TABELA "Nao foi possivel criar tabela."
#define SETAS CHR(24) + CHR(25) + CHR(27) + CHR(26)

// Tela Central
#define CENTRAL_LIN_INI             08
#define CENTRAL_COL_INI             34
#define CENTRAL_LIN_FIM             27
#xtranslate CENTRAL_COL_FIM => (MaxCol()-3)

// Browse
#define BROWSE_LIN_INI              CENTRAL_LIN_INI + 01
#define BROWSE_COL_INI              CENTRAL_COL_INI + 01
#define BROWSE_LIN_FIM              CENTRAL_LIN_FIM - 02
#define BROWSE_COL_FIM              CENTRAL_COL_FIM - 01

// Browse Rodape
#define LINHA_RODAPE_BROWSE         CENTRAL_LIN_FIM - 01
#define COLUNA_RODAPE_BROWSE        CENTRAL_COL_INI + 01

// Lookup
#define LOOKUP_LIN_INI              18
#define LOOKUP_COL_INI              39
#define LOOKUP_LIN_FIM              CENTRAL_LIN_FIM - 03
#define LOOKUP_COL_FIM              CENTRAL_COL_FIM - 20

// Lookup Rodape
#define LOOKUP_RODAPE_LIN           CENTRAL_LIN_FIM - 02
#define LOOKUP_RODAPE_COL           LOOKUP_COL_INI

// Lookup Contorno
#define LOOKUP_CONTORNO_LIN_INI     LOOKUP_LIN_INI  - 01
#define LOOKUP_CONTORNO_COL_INI     LOOKUP_COL_INI  - 01
#define LOOKUP_CONTORNO_LIN_FIM     LOOKUP_LIN_FIM  + 02
#define LOOKUP_CONTORNO_COL_FIM     LOOKUP_COL_FIM  + 01

// Comandos do Browse
#define K_a 97
#define K_A 65
#define K_E 69
#define K_e 101
#define K_I 73
#define K_i 105
#xtranslate NUM_RANDOM() => (Random()%6+1)
