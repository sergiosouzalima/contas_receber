#define EMPRESA "BLOGUEIRO SAMURAI"
#define SISTEMA "SISTEMA DE CONTAS A RECEBER"
#define LINHA_MENSAGEM 04
#define LINHA_CONFIRMA 06
#define INCLUSAO 1
#define ALTERACAO 2
#define EXCLUSAO 3
#define CONSULTA 4
#define SAIR 5
#define BD_CONTAS_RECEBER "contas_receber.s3db"
#define SETAS CHR(24) + CHR(25) + CHR(27) + CHR(26)
#xtranslate NUM_RANDOM() => (Random()%6+1)
#ifdef __PLATFORM__Linux
    #define MAX_ROW MaxRow()-3
#endif
#ifdef __PLATFORM__Windows
    #define MAX_ROW 20
#endif