
    //Nome do arquivo: CRMENU.PRG
    //POR: EXTRAÍDO DO LIVRO CLIPPER 5.0 DO RAMALHO
    local empresa := "BLOGUEIRO SAMURAI"
    local sistema := "CONTAS A RECEBER"
    local telapadrao
    LOCAL Menu, amenu, tam, novapos
    local op := 0
    local inidce2, indice3
    local les,ces,largjan,telavelha
           
        SET SCOREBOARD OFF
        SET DATE BRITISH
        SET WRAP oN 
        SET DELETED ON 
        SET MESSAGE TO 23 CENTER 
        SET KEY 28 TO AJUDA 
        DO WHILE .T.
           TELAPADRAO(PROCNAME())
            MENU:= {{"FATURAS     ","MANUTENCAO DE FATURAS"                   },;
                    {"CLIENTES   ","MANUTENCAO DO ARQUIVO DE CLIENTES"        },;
                    {"CONS/RELAT ","CONSULTA EM VIDEO E EMISSAO DE RELATORIOS"},;
                    {"UTILITARIOS","ROTINAS DE BACKUP E REINDEXACAO"          },;
                    {"FIM        ","RETORNA AO SISTEMA OPERACIONAL  "         }}
    
                    MONTAMENU(6,5,MENU)
                    MENU TO OP
                    
                    DO CASE 
                        CASE OP=1
                            DO MODFAT
                        CASE OP=2
                            DO MODCLI
                        CASE OP=3
                            DO MODCON
                        CASE OP=4
                            DO MODUTI
                        CASE OP=5
                            IF CONFIRMA("ABANDONA O SISTEMA")=1
                                EXIT  
                            ENDIF 
                        ENDCASE 
                    ENDDO
                    FUNCTION MONTAMENU (LS, cs, aMENU)
                        LOCAL I := 0
                        LOCAL retangulo :=  CHR(213)+CHR(205)+CHR(184)+CHR(179)+;
                        CHR(190)+CHR(205)+CHR(212)+CHR(179)+CHR(32)
                        @ls,cs,ls+LEN(aMENU)+1,cs+LEN(aMENU [1,1])+1 box retangulo
                        FOR I=1 TO LEN(aMENU)
                        @ls+i,cs+1 PROMPT aMENU [I,1] message aMENU [1,2]
                    NEXT
                RETURN nil
    
        FUNCTION MENUMANUT(LS,cs,nome)
          local  tipo:=nome
            menu:={{"INCLUSAO    ","INCLUSAO DE &TIPO.                         "},;
                  {"ALTERACAO   ","ALTERACAO DE &TIPO.                        "},;
                  {"CONSULTA    ","CONSULTA DO ARQUIVO DE &TIPO.              "},;
                  {"EXCLUSAO    ","EXCLUSAO DOS REGISTROS DO ARQUIVO DE &TIPO."},;
                  {"FIM         ","RETORNA AO MENU ANTERIOR                   "}}
            MONTAMENU(ls,cs,MENU)
        RETURN nil
    
        FUNCTION QUADRO(LS,cs,li,ci,tipo)
            local q[6]
    
            q[1]=CHR(201)+CHR(205)+CHR(187)+CHR(186)+;
                 CHR(188)+chr(205)+CHR(200)+CHR(186)+CHR(32)
            q[2]=CHR(218)+CHR(186)+CHR(191)+CHR(179)+;
                 CHR(217)+CHR(196) +CHR(192)+CHR(179)
            q[3]=CHR(213)+CHR(205)+CHR(184)+CHR(179)+;
                 CHR(190)+CHR(205)+CHR(212)+CHR(179)+CHR(32)
            q[4]=CHR(214)+CHR(196)+CHR(183)+CHR(186)+;
                 CHR(189)+CHR(196)+CHR(211)+CHR(186)    
            q[5]=CHR(220)+CHR(220)+CHR(220)+CHR(219)
    
            IF tipo >= 176 .AND. tipo <= 179 .OR. tipo=219
                IF PCOUNT()=6
                    q[6]=REPLICATE(tipo,9)
                ELSE
                    q[6]=REPLICATE(tipo,8)
                ENDIF 
            ENDIF
            @ls,cs,li,ci box q[tipo]
        RETURN nil
        
        FUNCTION MOLDURA(topo,esq,DIR,baixo,duplo,texto)
            IF PCOUNT()<6
                @23,10 SAY "NUMERO DE PARAMETROS INVALIDOS"
                RETURN (nil)
            ENDIF
        
            IF duplo
                @topo,esq CLEAR TO DIR, baixo
                @topo,esq TO DIR, baixo double
            ELSE
                @topo,esq CLEAR TO DIR, baixo
                @topo,esq TO DIR, baixo
            ENDIF
    
            IF  LEN(texto)>0
                tam:=baixo-esq
                novapos:=(tam-LEN(texto))/2
                @topo,esq+novapos SAY texto
            ENDIF
        RETURN (nil)
    
        FUNCTION CONFIRMA(TEXTO)
        local les,ces,largjan,telavelha
            largjan=LEN(texto)+2
            IF largjan<16
                largjan=16
            ENDIF
            ces=(80-largjan)/2
            les=19
            telavelha=SAVESCREEN(les,0,les+4,79)
            corantg=SETCOLOR()
            corova="W/B,N/W"
            SET COLOR TO %CORNOVA
            @les,ces CLEAR TO les+3,ces+largjan
            @les,ces TO les+3,ces+lagjan double
            @les+1,ces+2 SAY texto
            coluna=(largjan-9)/2
            @les+2,ces+coluna PROMPT "Sim"
            @les+2,ces+coluna+6 PROMPT "Nao"
            MENU TO CONFIRM
            SET COLOR TO &CORANTIG
            RESTSCREEN( les,0,les+4,79,telavelha)
        RETURN(CONFIRM)
    
        FUNCTION TELAPADRAO(PROGRAMA)
            CLEAR
            @0,0 TO 3,39 double
            @0,40 TO 3,79 double
            @4,0,21,79 BOX replicate(chr(176),9)
            @4,0 TO 24,79 double
            @1,1 SAY empresa
            @1,41 SAY sistema
            @1,73 say left(time(),5)
            @2,41 say programa
            @2,70 SAY DATE()
            @23,1 SAY "MENSAGEM:"
        RETURN nil
    
        FUNCTION MENSAGEM(LS,cs,texto,tempo)
            @ls,cs SAY SPACE(60)
            @ls,cs SAY texto
            IF tempo<>nil
                INKEY(tempo)
            ELSE
                INKEY(0)
            ENDIF
            @ls,cs SAY SPACE(60)
        RETURN nil
    
        FUNCTION ABREARQ(ARQ,ind1,ind2,ind3)
        PRIVATE arquivo:=arq, inidce1:=ind1, indice2:=ind2, indice3:=ind3
            IF .NOT. FILE("&ARQUIVO..DBF")
                MENSAGEM(23,10,"ARQUIVO "+arquivo +" NAO ENCONTRADO..")
                RETURN(.F.)
            ENDIF
    
                IF indice3 <> nil
                    IF .NOT. FILE("&INDICE3..NTX")
                        MENSAGEM(23,10,"ARQUIVO INDICE "+indice3+" NAO ENCONTRADO")
                        MENSAGEM(23,10,"EXECUTAR ROTINA DE REINDEXACAO..ANTES DE CONTINUAR")
                       IF CONFIRMA("REINDEXA AGORA?")=1
                            //UTIREINDEX()
                            USE &ARQUIVO. INDEX &INDICE1.,&INDICE2. ,&INDICE3. new
                        ELSE
                            RETURN(.F.)
                        ENDIF
                    ELSE
                        USE &ARQUIVO. INDEX &INDICE1. ,&INDICE2. ,&INDICE3. new
                    RETURN(.T.)
            ENDIF
            IF indice2 <> nil
                IF .NOT. FILE("&INDICE2..NTX")    
                    MENSAGEM(23,10,"ARQUIVO INDICE "+indice2+" NAO ENCONTRADO")
                    MENSAGEM(23,10,"EXECUTAR ROTINA DE REINDEXACAO.. ANTES DE CONTINUAR")
                    IF CONFIRMA("REINDEXA AGORA?")=1
                       // UTIREINDEX()
                        USE &ARQUIVO. INDEX &INDICE1. new
                    ELSE
                        RETURN (.F. )
                    ENDIF
                ELSE
                    USE &ARQUIVO. INDEX &INDICE1. new
                ENDIF
                RETURN(.T.)
            ENDIF
    
            PROCEDURE AJUDA
                IF .NOT. FILE("AJUDA.TXT")
                    MENSAGEM(23,10,"ARQUIVO DE AJUDA NAO ENCONTRADO",1.5)
                    MENSAGEM(23,10,"CONSULTE O MANUAL PARA SANAR DUVIDAS",2)
                    RETURN
                ENDIF
    
                SAVE SCREEN TO TELAHELP
                MOLDURA(04,01,21,79,.T.,"TEXTO DE AUXUILIO")
                MEMOEDIT(MEMOREAD("AJUDA.TXT"),05,02,20,78,.F.)
                RESTORE SCREEN FROM TELAHELP
           RETURN
            
        RETURN(.T.)

    RETURN