//MODUTI.PRG
//Cuida das operações de manutencao dos arquivos do sistema
Funcion Main()
    Local op 
    SaveScreen
    do while .t.
        @2,41 say procname()
        menu = {{"REINDEXA  ","REINDEXA TODOS OS INDICES DE TODOS OS ARQUIVOS"},;
                 {"COMPACTA ","ELIMINA REGISTROS DELETADOS DOS ARQUIVOS      "},;
                 {"BACKUP   ","CRIA COPIA DE SEGURANCA DOS ARQUIVOS          "},;
                 {"RESTAURA ","REVUPERA COPIA DE SEGURANCA                   "},;
                 {"ELIM.PAGOS ","ELIMINA FATURAS PAGAS ATE A DATA INFORMADA "},;
                 {"FIM        ","RETORNA AO MENU ANTERIOR                   "}}

                 MONTAMENU(11,13,menu)
                 menu to op 
                 telavelha=savesscreen(04,01,21,79)
                 publvar()
                 do case
                        case op = 1
                            do utreindex
                        case op = 2
                            do uticompac
                        case op = 3
                            do utibecape
                        case op = 4
                            do utirestau
                        case op = 5
                            do delfatpag
                        case op = 6
                        return
                        restore screen
                        endcase
                    end do
                     procedure utireindex
                        use clientes
                        set cursor off
                        moldura (10,40,14,65, .f. , "ARQUIVO : CLIENTES") 
                        @12,63 say chr(219)
                        index on codcli to indcodcl
                        setcolor ("W/N")
                        @12,63 say chr(251)
                        setcolor("W/N")
                        @13,63 say chr(219)
                        index on nomecli to indnomcl
                        setcolor("W/N")
                        @13,63 say chr(251)

                        use faturas
                        set cursor offmoldura(12,45,17,70, .f. , "ARQUIVO : FATURAS")
                        @14,47 say "POR.: COD. FATURA   "
                        @15,47 say "      DATA/CLIENTE  "
                        @16,47 say "      CLIENTE/DATA  "
                        setcolor("W/N")
                        @14,68 say chr(219)
                        index on codfat to indcodfa
                        setcolor("W/N")
                        @14,68 say chr(251)
                        setcolor("W/N")
                        @15,68 say chr(219)
                        index on dtos(vencimento)+codcli to inddatacl
                        setcolor("W/N")
                        @15,68 say(251)
                        setcolor("W/N")
                        @16,68 SAY CHR(251)
                        set cursor on
                        restscreen(04,01,21,79,telavelha)
                        close all 
                     return

                     procedure uticompacif .not. abrearq("CLIENTES","INDNOMCL")
                            MENSAGEM(23,10,"arquivo de clientes nao encontrado.rotina terminada")
                     return
                    end if

                    set cursor off
                    MOLDURA(10,40,14,65, .f. "COMPACTANDO")
                    @12,42 say "ARQUIVO: CLIENTES   "
                    @13,42 say "         FATURAS    "
                    setcolor("W/N")
                    @12,63 say chr(251)
                    use
                    if .not. ABREARQ("FATURAS","INDCODFA","INDDATCL","INDCLDAT")
                        MENSAGEM(23,10,"ARQUIVO DE CLIENTES NAO ENCONTRADO.ROTINA TERMINADA")
                        return
                    end if
                    setcolor("W*/N")
                    @13,63 say chr(219)
                    pack 
                    setcolor("W/N")
                    @13,63 say chr(251)
                    use
                    set cursor on
                    restscreen(04,01,21,79,telavelha)
                return

                procedure utibecape
                    // Esta parte esta voltada para o que costumava acontecer com
                    // os computadores da epoca (falta de memoria)
                    // Acho legal manter assim porque o meu conteudo fala de retrocomputacao
                    // Depois cada pessoa que tiver interesse em baixar o sistema para estudo
                    // pode altera-lo da maneira que preferir

                    MOLDURA(10,40,17,75, .f.," ATENCAO!")
                        @12,41 say "Essa rotina utiliza o programa"
                        @13,41 say "BACKUP .COM do sistema operacional"
                        @14,41 say "DOS. E necessaqrio 120 kb de "
                        @15,41 say "memoria livre para executa-lo"
                        @16,41 say "A memoria livre atual e "+Str(MEMORY(2),3)+" Kb"
                        if MEMORY(2) < 120
                            if CONFIRMA("O PROGRAMA PODE TRAVAR POR TER POUCA MEMORIA.CONTINUA?")=2
                                restscreen(04,01,21,79,telavelha)
                                return
                            end if
                        end if
                        if .not. file("C:\DOS\BACKUP.COM") //Aqui eu mantive o caminho original da época do DOS
                            MENSAGEM(23,10,"ARQUIVO BACKUP.COM NAO ENCONTRADO.OPERACAO CANCELADA")
                            restscreen(04,01,21,79,telavelha)
                            return
                        end if
                        mensagem (23,10,"Coloque um disquete no drive A: e tecle <enter>")
                        Run c:\dos\backup crmenu.exe a:
                        Run c:\dos\backup *.dbf a:
                        set console on
                        mensagem(23,10,"copias executadas..")
                        restscreen(04,01,21,79,telavelha)
                    return
                    procedure utirestau
                        MOLDURA(10,40,17,75 .f. , " ATENCAO!!! ")
                        @12,41 say "Essa rotina utiliza o programa"
                        @13,41 say "RESTORE.COM do sistema Operacional"
                        @14,41 say "DOS. e necessario 120 Kb de "
                        @15,41 say "memoria livre para executa-lo"
                        @16,41 say "A memoria livre atual e "+STR(MEMORY(2),3)+" kB"
                        IF MEMORY(2)<120
                            IF CONFIRMA("O PROGRAMA PODE TRAVAR POR TER POUCA MEMORIA.CONTINUA?")=2
                                restscreen(04,01,21,79,telavelha)
                                return
                            end if
                        end if
                        set console off
                        mensagem(23,10,"Coloque um disquete no drive A: e tecle <enter>")
                        Run restore a: c:\*.*
                        set console on
                        mensagem (23,10, "RESTAURACAO COMPLETADA")
                        restscreen(04,01,21,79,telavelha)
                    return

                    procedure delfatpag
                        local limite := ctod("")
                        if .not. ABREARQ("FATURAS","INDCODFA","INDDATCL","INDCLDAT")
                            MENSAGEM("FALTA ARQUIVO DE FATURA OU INDICE")
                            return
                        end if

                        MOLDURA(15,09,17,40 .f.," INFORME A ")
                        @16,10 say "DATA LIMITE:"Get limite
                        read 
                        if LastKey()=27
                            restscreen(04,01,21,79,telavelha)
                            return
                        end if

                        delete all for pagamento <= limite .and. vr_PAGO = VR_NOMINAL
                        UTIREINDEX()
                        MENSAGEM(23,10,"ELIMINACAO DE REGISTROS EFETUADA",2)
                        use
                    return
      
Return