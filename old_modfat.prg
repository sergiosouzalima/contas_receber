//Nome do arquivo: MODFAT.PRG
//POR: EXTRAÍDO DO LIVRO CLIPPER 5.0 DO RAMALHO

FUNCTION MAIN()
    LOCAL OP
    LOCAL TELAVELHA
    LOCAL ULTCOMPRA
        
    FIELDS ULTCOMPRA IN CLIENTES
    SAVE SCREEN 
    DO WHILE .T.
        02,41 SAY PROCNAME ()
       MENU:={{"BAIXA    ","RETIRA A FATURA DA POSICAO DEVEDORA        "},;
               {"INCLUSAO ","INCLUSAO DE FATURAS                        "},;
               {"ALTERACAO","ALTERACAO DE CAMPOS                        "},;
               {"CONSULTA ","CONSULTA DE ARQUIVO DE FATURAS             "},;
               {"EXCLUSAO ","EXCLUSAO DE REGISTROS DO ARQUIVO           "},;
               {"FIM      ","RETORNA AO MENU ANTERIOR                   "}}
               MONTAMENU(09,13,MENU)                                                                           
               MENU TO OP
               TELAVELHA := SAVESCREEN(04,01,21,79)
               PUBLVAR()
               DO CASE
                    CASE OP = 1
                        DO BAIFAT
                    CASE OP = 2
                        DO INCFAT
                    CASE OP = 3 
                        DO ALTFAT
                    CASE OP = 4
                        DO CONFAT
                    CASE OP = 5
                        DO EXCFAT
                    CASE OP = 6
                        RELEVAR()
                    RETURN
                    RESTORE SCREEN
                    ENDCASE 
                ENDDO
    PROCEDURE INCFAT
        IF .NOT.ACREARQ("CLIENTES","INDCODCL")
            RETURN
        ENDIF 

        IF .NOT. ABREARQ("FARTURAS","INDCODFA","INDCLDAT","INDDATCL")
            RETURN
        ENDIF 

        DO WHILE .T.
            PUBLVAR()
            INICVAR()
            MOSTRATEXTO()
            PESQUISA()
            IF VAL(MCODFAT) = 0
                EXIT 
            ENDIF 

            IF .NOT. FOUND()
                GETVAR()
                READ 
            ELSE 
                MENSAGEM(23,10,"FATURA JA CADASTRADA")
                LOOP 
            ENDIF 

            IF CONFIRMA("GRAVA ESSE REGISTRO ?") = 1
                APPEND BLANK
                REPLVAR()
                IF DATE() > ULTCOMPRA
                    ULTCOMPRA := DATE()
                ENDIF 
            ELSE 
                LOOP 
            ENDIF 
        ENDDO 
        CLOSE All 
        VOLTATELA()
        RELEVAR()
    RETURN 

    PROCEDURE ALTFAT 
        IF .NOT. ABREARQ("CLIENTES","INDCODCL")
            RETURN
        ENDIF 

        IF .NOT. ABREARQ("FATURAS","INDCODFA","INDCLDAT","INDDATCL")
            RETURN
        ENDIF 
        SET RELATION TO CODCLI INTO CLIENTES 
        DO WHILE .T.
            MOSTRATEXTO()
            PESQUISA()
            IF VAL(MCODFAT) = 0
                EXIT 
            ENDIF 
            IF FOUND()
                IGUALAVAR() 
                MOSTRAVAR()
                GETVAR()
                READ 
            ELSE 
                MENSAGEM(23,10,"FATURA NAO CADASTRADA           ")
                LOOP 
            ENDIF 
            IF CONFIRMA("ALTERA ESSE REGISTRO ?") = 1
                REPLVAR()
            ELSE 
                LOOP 
            ENDIF 
        ENDDO 
        CLOSE ALL 
        VOLTATELA() 
    RETURN 

    PROCEDURE CONFAT 
        IF .NOT. ABREARQ("CLIENTES","INDCODCL")
            RETURN 
        ENDIF 

    IF .NOT. ABREARQ("FATURAS","INDCODFA")
        RETURN
    ENDIF 
    SET RELATION TO CODCLI INTO CLIENTES
    DO WHILE .T.
        MOSTRATEXTO()
        PESQUISA()
        IF VAL(MCODFAT) = 0
            EXIT 
        ENDIF 
        IF FOUDN()
            IGUALAVAR ()
            MOSTRAVAR ()
        ELSE 
            MENSAGEM(23,10,"FATURA NAO CADASTRADA       ")
            LOOP 
        ENDIF 
        MENSAGEM(23,10,"PRESSIONE <ESPACO> PARA CONTINUAR")
    ENDDO 
    CLOSE ALL 
    VOLTATELA()
RETURN

PROCEDURE EXCFAT 
    IF .NOT. ABREARQ("CLIENTES","INDCODCLI")
        RETURN 
    ENDIF 
    IF .NOT. ABREARQ("FATURAS","INDCODFA","INDCLDAT","INDDATCL")
        RETURN
    ENDIF 
    SET RELATION TO CODCLI INTO CLIENTES 
    DO WHILE .T.
        MOSTRATEXTO()
        PESQUISA()
        IF VAL(MCODFAT) = 0
            EXIT 
        ENDIF 
        IF FOUND()
            IGUALAVAR()
            MOSTRAVAR()
        ELSE 
            MENSAGEM(23,10,"FATURA NAO CADASTRADA")
            LOOP 
        ENDIF 
        IF CONFIRMA("DELETA ESSE REGISTRO ?") = 1
            DELETE 
        ELSE 
                LOOP 
        ENDIF 
    ENDDO 
    CLOSE ALL 
    VOLTA TELA()
RETURN 

PROCEDURE BAIFAT 
    IF .NOT. ABREARQ("CLIENTES","INDCODCL")
        RETURN
    ENDIF 
    IF .NOT. ABREARQ ("FATURAS","INDCODFA")
        RETURN 
    ENDIF 
    SET RELATION TO CODCLI INTO CLIENTES 
    DO WHILE .T. 
        MOSTRA TEXTO()
        PESQUISA()
        IF VAL(MCODFAT)=0
            EXIT 
        ENDIF 
        IF FOUND()
            IGUALAVAR()
            MOSTRAVAR()
            DO CASE 
            CASE  MPAGAMENTO <> CTOD("") .AND. (MVR_NOMINAL = MVR_PAGO)
                IF CONFIRMA("FATURA JA BAIXADA TOTALMENTE.CONTINUA ?") = 2
                    LOOP 
                ELSE 
                    @13,25 GET MPAGAMENTO PICTURE 'DD/DD/DD'
                    @15,25 GET MVR_PAGO PICTURE "@E 9,999,999.99"
                    READ 
                ENDIF 
            CASE MPAGAMENTO <> CTOD("") .AND. (MVR_NOMINAL <> MVR_PAGO)
                @16,38 SAY "VALOR EM ABERTO .:"
                CALC = VR_PAGO
                @16,58 SAY MVR_NOMINAL -MVR_PAGO PICTURE '@E 9,999,999.99'
                @13,58 GET PAGAMENTO PICTURE 'DD/DD/DD'
                @15,58 GET MVR_PAGO PICTUR '@E 9,999,999.99'
                READ 
                MVR_PAGO > MVR_NOMINAL 
                    IF CONFIRMA ("VALOR PAGO NAO PODE SER MAIOR QUE O NOMINAL, CONTINUA ?") = 2
                        MVR_PAGO = CALC 
                        LOOP 
                    ENDIF 
                ENDIF 
            OTHERWISE 
                @13,25 GET MPAGAMENTO PICTURE 'DD/DD/DD'
                @15,58 GET MVR_PAGO PICTURE '@E 9,999,999.99'
                READ
            END CASE 
        ELSE 
            MENSAGEM (23,10,"FATURA NAO CADASTRADA")
            LOOP 
        //ENDIF 
        IF CONFIRMA ("CONFIRMA BAIXA DESSA FATURA ?") == 1
            REPLACE PAGAMENTO WITH MPAGAMENTO
            REPLACE VR_PAGO WITH MVR_PAGO 
        ELSE 
            LOOP 
        END IF 
    END DO 
    CLOSE ALL 
    VOLTATELA() 
RETURN 

STATIC PROCEDURE INICVAR 
    MCODFAT = SPACE (5)
    MODCLI = SPACE(4)
    MVENCIMENTO = CTOD('  /  /  ')
    MPAGAMENTO = CTOD ('  /  /')
    MVR NOMINAL = 0
    MVR_PAGO = 0
RETURN 

STATIC PROCEDURE MOSTRATEXTO 

    SET COLOR RO W/N
    @05,02 CLEAR TO 17,74
    @11,02 TO 17,74
    @11,34 TO 17,74
    @05,02 TO 17,74 DOUBLE 
    @07,04 SAY "NUMERO........:"
    @09,04 SAY "COD. CLIENTE..:"
    @13,04 SAY "VENCIMENTO....:"
    @13,38 SAY "DATA PAGAMENTO:"
    @15,04 SAY "VALOR.........:"
RETURN 

STATIC PROCEDURE MOSTRAVAR 
    SET COLOR TO W/N 
    @07,19 SAY MCODFAT 
    @09,19 SAY MCODCLI
    @09,28 SAY CLIENTES -> NOMECLI
    @13,19 SAY MVENCIMENTO PICTURE 'DD/DD/DD'
    @13,58 SAY MPAGAMENTO PICTURE 'DD/DD/DD'
    @15,19 SAY MVR_NOMINAL PICTURE '@E 9,999,999.99'
    @15,58 SAY MVR_PAGO PICTURE '@E 9,999,999.99'
RETURN 

STATIC PROCEDURE GETVAR 
    SET COLOR TO W/N,N/W 
    @09,19 GET MCODCLI PICTURE "9999"
        VALID CLIENTES->(PESQCLI(@MCODCLI,9,28))
    @13,19 GET MVENCIMENTO PICTURE 'DD/DD/DD'
    @15,19 GET MVR_NOMINAL PICTURE '@E 9,999,999.99'
    @13,58 GET MPAGAMENTO PICTURE 'DD/DD/DD'
    @15,58 GET MVR_PAGO PICTURE '@E 9,999,999.99'
RETURN 

STATIC PROCEDURE IGUALAVAR
    STORE CODFAT TO MCODFAT
    STORE CODCLI TO MCODCLI
    STORE VENCIMENTO TO MPAGAMENTO
    STORE VR_NOMINAL TO MVR_NOMINAL
    STORE VR_PAGO TO MVR_PAGO
RETURN

STATIC PROCEDURE PUBIVAR
    PUBLIC MCODFAT,MCODCLI,MVENCIMENTO,MPAGAMENTO,MVR_NOMINAL 
    PUBLIC MVR_PAGO
RETURN 

STATIC PROCEDURE RELEVAR
    RELEASE MCODFAT,MCODCLI,MVENCIMENTO,MPAGAMENTO.MVR_NOMINAL
    RELEAE MVR_PAGO 
RETURN

STATIC PROCEDURE PESQUISA
    SET COLOR TO W/N,N/W
    DO MOSTRATEXTO
    MCODFAT = 0
    @07,19 GET MCODFAT PICTURE "99999"
    READ
    MCODFAT = STRZERO(MCODFAT,5)
    SETCOLOR("N/W")
    @07,19 SAY MCODFAT
    SETCOLOR("W/N")
    SEEK MCODFAT
RETURN

FUNCTION PESQCLI
    PARAMETERS MCODCLI,LIN,COL
    MCODCLI = STRZERO(VAL(MCODCLI),4)
    SETCOLOR("W/N")
    SEEK MCODCLI
    IF FOUND()
        @LIN,COL SAY "NAO ENCONTRADO....."
        INKEY(2)
        ACHOU = .F.
    ENDIF 
RETURN(ACHOU)