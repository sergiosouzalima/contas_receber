/*
    Sistema......: Sistema de Contas a Receber
    Programa.....: global.ch
    Finalidade...: Constantes disponiveis em todo o sistema
                   Constantes especificas contendo comandos SQL
    Autor........: Sergio Lima
    Atualizado em: Outubro, 2021
*/

// Comandos SQL para CLIENTE
#define SQL_CLIENTE_CREATE ;
        "CREATE TABLE IF NOT EXISTS CLIENTE( " + ;
        " CODCLI INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " + ;
        " NOMECLI VARCHAR2(40) NOT NULL, " + ;
        " ENDERECO VARCHAR2(40), " + ;
        " FONE_DDI CHAR(02), " + ;
        " FONE_DDD CHAR(02), " + ;
        " FONE VARCHAR2(10), " + ;
        " EMAIL VARCHAR2(40), " + ;
        " DATA_NASC DATE, " + ;
        " DOCUMENTO VARCHAR2(20), " + ;
        " CEP CHAR(09), " + ;
        " CIDADE VARCHAR2(20), " + ; 
        " ESTADO CHAR(20), " + ;
        " CREATED_AT datetime default current_timestamp, " + ;
        " UPDATED_AT datetime default current_timestamp); "
#define SQL_CLIENTE_INSERT ;
        "INSERT INTO CLIENTE(" +;
        "NOMECLI, ENDERECO, " +;
        "FONE_DDI, FONE_DDD, FONE, " +;
        "EMAIL, DATA_NASC, DOCUMENTO, " +;
        "CEP, CIDADE, ESTADO) VALUES(" +;
        "'#NOMECLI', '#ENDERECO', " +;
        "'#FONE_DDI', '#FONE_DDD', '#FONE', " +;
        "'#EMAIL', '#DATA_NASC', '#DOCUMENTO', " +;
        "'#CEP', '#CIDADE', '#ESTADO'); "
#define SQL_CLIENTE_UPDATE ;
        "UPDATE CLIENTE SET " +;
        "NOMECLI = '#NOMECLI', ENDERECO = '#ENDERECO', " +;
        "FONE_DDI = '#FONE_DDI', FONE_DDD = '#FONE_DDD', FONE = '#FONE', " +;
        "EMAIL = '#EMAIL', DATA_NASC = '#DATA_NASC', DOCUMENTO = '#DOCUMENTO', " +;
        "CEP = '#CEP', CIDADE = '#CIDADE', ESTADO = '#ESTADO', " +;
        "UPDATED_AT = current_timestamp "+;
        "WHERE CODCLI = #CODCLI;"
#define SQL_CLIENTE_DELETE ;
        "DELETE FROM CLIENTE WHERE CODCLI = #{CODCLI};"
#define SQL_CLIENTE_SELECT_ALL ;
        "SELECT CODCLI, "+;
        "NOMECLI || '     ' AS NOMECLI, ENDERECO, CEP, CIDADE, "+;
        "ESTADO, EMAIL, FONE_DDD, FONE "+;
        "FROM CLIENTE;"
#define SQL_CLIENTE_SELECT_WHERE ;
        "SELECT * FROM CLIENTE WHERE CODCLI = #{CODCLI};" 
#define SQL_CLIENTE_COUNT ;
        "SELECT COUNT(1) AS 'QTD_CLIENTE' FROM CLIENTE;"
#define SQL_CLIENTE_COUNT_WHERE ;
        "SELECT COUNT(1) AS 'QTD_CLIENTE' " +;
        "FROM CLIENTE " +;
        "WHERE CODCLI = #{CODCLI};"        
#define SQL_FATURA_CLIENTE_COUNT_WHERE ;
        "SELECT COUNT(1) AS 'QTD_CLIENTE' " +;
        "FROM FATURA F " +;
        "WHERE F.CODCLI = #{CODCLI};"

// Comandos SQL para FATURA
#define SQL_FATURA_CREATE ;
        "CREATE TABLE IF NOT EXISTS FATURA( " + ;
        " CODFAT INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " + ;
        " CODCLI INTEGER NOT NULL, " + ;
        " DATA_VENCIMENTO DATE NOT NULL, " + ;
        " DATA_PAGAMENTO DATE, " + ;
        " VALOR_NOMINAL NUMERIC(16,2), " + ;
        " VALOR_PAGAMENTO NUMERIC(16,2), " + ;
        " FOREIGN KEY (CODCLI) " + ;
        " REFERENCES CLIENTE (CODCLI) );"
#define SQL_FATURA_INSERT ;
        "INSERT INTO FATURA(" +;
        "CODCLI, " +;
        "DATA_VENCIMENTO, DATA_PAGAMENTO, VALOR_NOMINAL, " +;
        "VALOR_PAGAMENTO) VALUES(" +;
        "#{CODCLI}, " +;
        "'#{DATA_VENCIMENTO}', '#{DATA_PAGAMENTO}', #{VALOR_NOMINAL}, " +;
        "#{VALOR_PAGAMENTO}); "
#define SQL_FATURA_UPDATE ;
        "UPDATE FATURA SET " +;
        "CODCLI = #{CODCLI}, " +;
        "DATA_VENCIMENTO = '#{DATA_VENCIMENTO}', DATA_PAGAMENTO = '#{DATA_PAGAMENTO}', " +;
        "VALOR_NOMINAL = #{VALOR_NOMINAL}, " +;
        "VALOR_PAGAMENTO = #{VALOR_PAGAMENTO} "  +;
        "WHERE CODFAT = #{CODFAT};"
#define SQL_FATURA_DELETE ;
        "DELETE FROM FATURA WHERE CODFAT = #{CODFAT};"
#define SQL_FATURA_SELECT_ALL ;
        "SELECT F.CODFAT, F.CODCLI, C.NOMECLI, " +;
        "F.DATA_VENCIMENTO, F.DATA_PAGAMENTO, " +;
        "F.VALOR_NOMINAL, F.VALOR_PAGAMENTO " +;
        "FROM FATURA F, CLIENTE C " +;
        "WHERE F.CODCLI = C.CODCLI;"
#define SQL_FATURA_SELECT_WHERE ;
        "SELECT F.CODFAT, F.CODCLI, C.NOMECLI, " +;
        "F.DATA_VENCIMENTO, F.DATA_PAGAMENTO, " +;
        "F.VALOR_NOMINAL, F.VALOR_PAGAMENTO " +;
        "FROM FATURA F, CLIENTE C " +;
        "WHERE F.CODFAT = #{CODFAT} AND C.CODCLI = F.CODCLI;"        
#define SQL_FATURA_COUNT ;
        "SELECT COUNT(1) AS 'QTD_FATURA' FROM FATURA;"
#define SQL_CONSULTA_DATACLIENTE_COUNT ;
        "SELECT COUNT(1)" +;
        " FROM FATURA F, CLIENTE C" +;
        " WHERE C.CODCLI = F.CODCLI;"         
#define SQL_CONSULTA_DATACLIENTE ;
        "SELECT F.CODFAT, F.CODCLI, C.NOMECLI," +;
        " F.DATA_VENCIMENTO, F.DATA_PAGAMENTO," +;
        " F.VALOR_NOMINAL, F.VALOR_PAGAMENTO" +;
        " FROM FATURA F, CLIENTE C" +;
        " WHERE C.CODCLI = F.CODCLI" +;
        " ORDER BY" +;
        " SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,01,02), C.NOMECLI;"
#define SQL_CONSULTA_CLIENTEDATA_COUNT SQL_CONSULTA_DATACLIENTE_COUNT
#define SQL_CONSULTA_CLIENTEDATA ;
        "SELECT F.CODFAT, F.CODCLI, C.NOMECLI," +;
        " F.DATA_VENCIMENTO, F.DATA_PAGAMENTO," +;
        " F.VALOR_NOMINAL, F.VALOR_PAGAMENTO" +;
        " FROM FATURA F, CLIENTE C" +;
        " WHERE C.CODCLI = F.CODCLI" +;
        " ORDER BY" +;
        " C.NOMECLI," +;
        " SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,01,02);"
#define SQL_CONSULTA_TITUATRAS_COUNT ;
        "SELECT COUNT(1)" +;
        " FROM FATURA F, CLIENTE C" +; 
        " WHERE C.CODCLI = F.CODCLI" +;
        "  AND (F.DATA_PAGAMENTO = '  /  /    ' AND F.VALOR_PAGAMENTO = 0)" +;
        "  AND " +;
        "  SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        "  SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        "  SUBSTR(F.DATA_VENCIMENTO,01,02) <=" +;
        "  SUBSTR(date(),07,04) ||" +;
        "  SUBSTR(date(),04,02) ||" +;
        "  SUBSTR(date(),01,02);"
#define SQL_CONSULTA_TITUATRAS ;
        "SELECT F.CODFAT, F.CODCLI, C.NOMECLI," +; 
        " F.DATA_VENCIMENTO, F.DATA_PAGAMENTO," +; 
        " F.VALOR_NOMINAL, F.VALOR_PAGAMENTO" +;
        " FROM FATURA F, CLIENTE C" +; 
        " WHERE C.CODCLI = F.CODCLI" +;
        "  AND (F.DATA_PAGAMENTO = '  /  /    ' AND F.VALOR_PAGAMENTO = 0)" +;
        "  AND " +;
        "  SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        "  SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        "  SUBSTR(F.DATA_VENCIMENTO,01,02) <=" +;
        "  SUBSTR(date(),07,04) ||" +;
        "  SUBSTR(date(),04,02) ||" +;
        "  SUBSTR(date(),01,02);"
#define SQL_CONSULTA_TOTAIS_DT_VENC_COUNT ;
        "SELECT COUNT(1) FROM (" +; 
        " SELECT COUNT(1) AS QTD_FATURAS," +; 
        " SUM(F.VALOR_NOMINAL) AS TOTAL_VALOR_NOMINAL," +;  
        " SUM(F.VALOR_PAGAMENTO) AS TOTAL_VALOR_PAGAMENTO" +; 
        " FROM FATURA F, CLIENTE C" +;  
        " WHERE C.CODCLI = F.CODCLI" +; 
        " GROUP BY F.CODCLI, C.NOMECLI, F.DATA_VENCIMENTO);"
#define SQL_CONSULTA_TOTAIS_DT_VENC ;
        "SELECT F.CODCLI, C.NOMECLI, F.DATA_VENCIMENTO," +; 
        " COUNT(1) AS QTD_FATURAS," +; 
        " SUM(F.VALOR_NOMINAL) AS TOTAL_VALOR_NOMINAL," +;  
        " SUM(F.VALOR_PAGAMENTO) AS TOTAL_VALOR_PAGAMENTO" +; 
        " FROM FATURA F, CLIENTE C" +;  
        " WHERE C.CODCLI = F.CODCLI" +; 
        " GROUP BY F.CODCLI, C.NOMECLI, F.DATA_VENCIMENTO" +; 
        " ORDER BY F.CODCLI, " +;
        " SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,01,02);"
#define SQL_CONSULTA_SINTETICA_TOTAIS_DT_VENC_COUNT ;
        "SELECT COUNT(1) FROM (" +;
        " SELECT F.DATA_VENCIMENTO," +;
        " COUNT(1) AS QTD_FATURAS," +;
        " SUM(F.VALOR_NOMINAL) AS TOTAL_VALOR_NOMINAL," +;
        " SUM(F.VALOR_PAGAMENTO) AS TOTAL_VALOR_PAGAMENTO" +;
        " FROM FATURA F, CLIENTE C" +;
        " WHERE C.CODCLI = F.CODCLI" +;
        " GROUP BY F.DATA_VENCIMENTO" +;
        " ORDER BY" +;
        " SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,01,02));"
#define SQL_CONSULTA_SINTETICA_TOTAIS_DT_VENC ;
        "SELECT F.DATA_VENCIMENTO," +;
        " COUNT(1) AS QTD_FATURAS," +;
        " SUM(F.VALOR_NOMINAL) AS TOTAL_VALOR_NOMINAL," +;
        " SUM(F.VALOR_PAGAMENTO) AS TOTAL_VALOR_PAGAMENTO" +;
        " FROM FATURA F, CLIENTE C" +;
        " WHERE C.CODCLI = F.CODCLI" +;
        " GROUP BY F.DATA_VENCIMENTO" +;
        " ORDER BY" +;
        " SUBSTR(F.DATA_VENCIMENTO,07,04) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,04,02) ||" +;
        " SUBSTR(F.DATA_VENCIMENTO,01,02);"