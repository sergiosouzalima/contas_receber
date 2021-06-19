//Módulo de consultas

Function Main()
Local op 
@2,41 say procname()
SaveScreen
do while .t.
    menu := {{"POS.DATA/CLIENTE  ","RELATORIO ORDENADO POR FATA VENCIMENTO/CLIENTE"},;
             {"POS.CLIENTE/DATA ","RELATORIO ORDENADO POR CLIENTE/DATA VENCIMENTO"},;
             {"TITULOS EM ATRASO "},"RELACAO DE ATRASOS ATE A DATA INFORMADA",;
             {"FLUXO SINTETICO ","LISTAGEM DE TOTAIS POR DIA VENCIDO/A VENDER" },;
             {"RELACAO DE CLIENTES","LISTAGEM CLASSIFICADA POR NOME OU CODIGO"},;
             {"CONSULTA/CLIENTE ","CONSULTA SINTETICA POR CLIENTE/VENCIMENTO"},;
             {"CONSULTA/DATA ","CONSULTA SINTETICA TOTAL POR DATA VENCIMENTO"},;
             {"RETORNA","RETORNA AO MENU ANTERIOR"}}
    MONTAMENU(9,13,menu)
    menu to op
    do case
        
    case op = 1
        do datacliente
    case op = 2
        do clientedata
    case op = 3
        do tituatras 
    case op = 4
        do fluxosin
    case op = 5
        do reicli
    case op = 6
        do conclidat
    case op = 7
        do condatcli
    case op = 8
        restore Screen 
        //return 
    end case
end do


procedure conclidat
    private mcodcli := space(4),ddataini, dtafafim, filtro := ""
        if .not. abrearq("CLIENTES","INDCODCL")
            RestScreen(04,01,21,79,telavelha)
        return
        end if
    


set retation to codcli into clientes    
do while .t.
    modcli = space(4); ddataini := ddatafim := ctod("")
        QUADRO(6,3,14,45,3)
    @7,5 say "CODIGO DO CLIENTE: "
    @8,5 say "XXXX = TODOS"
    @7,26 get mcodcli picture "@N!"
   // READ 
    if Val(mcodcli)=0 .and. mcodcli <> "XXXX"
        close All 
        exit
    end if

    if modcli <> "XXXX"
        SEEK mcodcli
        if Found()
            @8,5 say clientes -> nomecli
            uico = .t.
        else
            loop
        end if
        filtro = "CODCLI = mCODCLI"
    else
        filtro = ""
    end if
    @10,5 say "DATA INICIAL.:" GET ddataini
    @11,5 say "DATA FINAL..:" GET ddatafim;
        valid ddatafim >= ddataini
    READ
    IF ddataini <> CTOD("") .AND. DDATAFIM <> ctod("")
        if len(filtro)>1
            filtro = filtro+" .and. VENCIMENTO >= cDATAINI .and. VENCIMENTO <= dDATAFIM"
        else
            filtro = "VENCIMENTO >= dDATAINI .and. VENCIMENTO <= dDATAFIM"
        end if
    end if
    if len(filtro) > 1
        set filter to &filtro
    end if
    quadro(6,2,20,77,3)
    CAMPOS := ("CODCLI","CLIENTES - > (LEFT(NOMECLI,18"))","CODFAT,;
        "VR_NOMINAL","VENCIMENTO","PAGAMENTO","VR_NOMINAL-VR_PAGO"
    matpic := ("","","","@E 9,999,999.99","","","@E 9,999,999.99")
    mattit := ("CODIGO","NOME DO CLIENTE","FATURA","VALOR",;
                "VENCIMENTO","DAT.PAGTO","EM ABERTO")
    DBEDIT(7,3,19,76,campos,,matpic,mattit)
    goto Top
end do
RestScreen(04,01,21,79,telavelha)

procedure condatcli
    if .not, ABREARQ("CLIENTES","INDCODCLI")
        RestScreen(04,01,21,79,telavelha   )
        return
    end if
    if .not. ABREARQ("FATURAS","INDDATCL")
        RestScreen(04,01,21,79,telavelha)
        return
    end if
    set retation to codcli into clientes
    select clientes
    do while .t.
        modcli = space(4)
        modcli := space(4);ddataini := ctod(""); dtatafim := ctod("")
            QUADRO(6,3,14,45,3)
        @7,5 say "DATA INICIAL.:"get dtataini
        @08,5 say "DATA FINAL..:"get ddatafim
        read 
        if LastKey()=27
            RestScreen(04,01,21,79,telavelha)
            close All
            return
        end if
        do case
            case ddataini=ctod("") .and. ddatafim = ctod("")
                testadata = 0
            case ddataini <> ctod("") .and. ddatafim = ctod("")
                testdata = 1
            case ddataini=ctod("") .and. ddatafim <> ctod("")
                testdata = 2
            case ddataini <> ctod("") .and. ddatafim <> ctod("")
                testdata = 3
            end case
            select clientes
            achou = .f.
            do while .not. achou
                @10,5 say "CODIGO DO CLIENTE: "
                @11,5 say "XXXX = TODOS"
                @10,26 get mcodcli picture "@N!"
                READ 
                if mcodcli <> "XXXX"
                    SEEK mcodcli
                    if Found()
                        @11,5 say clientes -> nomecli
                    achou= .t.
                    else
                        loop
                    end if
                else
                    unico = .f.
                    exit 
                end if
            end do
            select faturas
            goto Top
            quadro(6,02,19,77,3)
            @06,03 say "CODIGO"
            @06,19 say "NOME"
            @06,33 say "FATURA"
            @06,42 say "VENCIMENTO"
            @06,57 say "VALOR"
            @06,67 say "DATA PGTO"
            i = 7
            do while .not. Eof()
                do case
                    case pagamento <> ctod("")  .and. vr_nominal = vr_pago
                        skip 
                    case mcodcli <> "XXXX" .and. codcli <> mcodcli
                        skip
                    case (testdata = 1 .or. testadata = 3) .and. vencimento < ddataini
                        skip
                    case (testdata = 2) .or. (testdata = 3) .and. vencimento = ddatafim
                        skip
                    otherwise
                        if i=19
                            MENSAGEM(23,10,"PRESSIONE <ENTER> PARA VER OUTROS REGISTROS",0)
                            Scroll(07,03,18,76,12)
                            i = 7
                        end if
                        @i,04 say codcli +" "+chr(179)
                        @i,10 say clientes -> (LEFT(nomecli,20)) + " "+chr(179)
                        @i,33 say codfat +" "+chr(179)
                        @i,43 say dtoc(vencimento)+"+CHR(179)"
                        @i,54 SAY vr_nominal picture "@E 9,999,999.99"+CHR(179)
                        @i,67 say pagamento
                        SKIP 
                       i++

                    end case
                end do
                MENSAGEM(23,10,"PRESSIONE <ENTER> PARA A PROXIMA TELA",0)
            end do
            inkey(0)
            RestScreen(04,01,21,79,telavelha)

            procedure fluxosin
                if .not. ABREARQ("FATURAS","INDDATCL")
                    RETURN
                end if
                @23,10 SAY "IMPRIMINDO FLUXO SINTETICO...AGUARDE.."
                listaflu()

                procedure  listaflu
                    p=0; lin=61; totdata := totger := 0
                    titulo = "FLUXO SINTETICO DE VENCIMENTOS"
                nr = "CR-003"
                compvenc=vencimento
                set device to printer 
                pago = "PAGAMENTO=CTOD('')"
                pagparcial = "PAGAMENTO <> CTOD('') .and. vr_nominal <> vr_pago"
                do while .not. eof() .and. (&pago .or. &pagparcial)
                    if lin > 60
                        cabecger(titulo,nr)
                        cabecflu()
                    end if
                    detalheflu()
                end do
                totalfluxo()
                final()
                set device to Screen
                MENSAGEM(23,10,"FINAL DO RELATORIO DE CLIENTES",2)

                procedure cabecflu
                    @04,10 say "data de vencimento          MONTANTE"
                    @05,00 say Replicate("=",80)
                    lin = 7
                return

                procedure detalheflu
                    if compvenc<>vencimento
                        @lin, 14 say compvenc picture 'dd/dd/dd'
                        @lin, 23 say replicate(".",23)
                        @lin++,46 say totdata picture '999,999,999.99'
                        compovenc=vencimento
                        if &pagparcial
                     totger += vr_nominal-vr_pago ; totdata = vr_nominal-vr_pago
                        else
                     totger += vr_nominal ; totdata = vr_nominal
                        end if
                    else
                        if &pagparcial
                      totger += vr_nominal-vr_pago;totdata += vr_nominal-vr_pago
                        end if
                    end if
                    skip
                return

                procedure totalfluxo
                    @lin,14 say compvenc
                    @lin,23 say replicate(".",23)
                    @lin,46 say totdata picture '999,999,999.99'
                    @++lin,36 say "TOTAL......:"//aumenta valor de lin antes de imprimir
                    @lin++,46 say totger picture '999,999,999.99'

                procedure tituatras
                    if .not. abrearq("CLIENTES","INDCODCL")
                        retscreen(04,01,21,79,telavelha)
                        return
                    endif
                    if .not. ABREARQ("FATURAS","INDDATCL")
                        RestScreen(04,01,21,79,telavelha)
                        return
                    endif
                    set relation to codcli into clientes
                    select clientes
                    do while .t.
                        modcli := space(4); dataref := ctod("")
                            quadro(6,3,14,45,3)
                        @07,5 say "DATA REFERENCIA.:" get dataref
                        //read 
                        if lastkey()=27
                            RestScreen(04,01,21,79,telavelha)
                            close All
                            return 
                        end if
                        select clientes
                        achou = .f.
                        do while .not. achou
                            @10,5 say "CODIGO DO CLIENTE: "
                            @11,5 say "XXXX = TODOS"
                            @10,26 get mcodcli picture "@N!"
                            //read 
                            if mcodcli <> "XXXX"
                                SEEK mcodcli
                                if Found()
                                    @11,5 say clientes -> nomecli
                                    unico = .t.
                                    achou = .t.
                                else
                                    loop
                                end if
                            else
                                unico = .f.
                                exit
                            end if
                        end do
                        select faturas
                        goto Top
                        set device to printer
                        lin := 61; p := torger := totdia := 0 ; datacomp = ctod("") ; nr := "CR-005"
                            do while .not. eof()
                        do case
                            case pagamento=ctod("") .and. vencimento > dataref
                                skip
                            case pagamentoo <> ctod("") .and. codcli <> mcodcli
                                skip
                            otherwise
                                listatras()
                            endcase
                        end do

                        toralatras()
                        final()
                        set device to screen
                        mensagem(23,10,"FINAL DO RELATORIO DE ATRASADOS",2)
                    end do
                    retscreen(04,01,21,79,telavelha)

                    procedure listatras
                        if lin > 60
                            cabecger("RELACAO DE TITULOS EM ATRASO")
                            cabecatr()
                        end if
                        if datacomp <> vencimento
                            if datacomp <> ctod("")
                                @lin, 33 say "TOTAL......:"
                                @lin++, 43 say totdia picture "@E 99,999,999.99+"
                            end if
                            @lin++, 1 say "VENCIMENTO: "+dtoc(vencimento)
                            datacomp=vencimento
                            totdia=0
                        end if
                        @lin, 04 say codcli +" |"
                        @lin, 10 say clientes -> (left(nomecli,20)) + " |"
                        @lin, 33 say codfat +" |"
                        @lin, 44 say vr_nominal picture "@E 9,999,999.99" 
                        if pagamento <> ctod("")
                            @lin,57 say vr_pago picture "@E 9,999,999.99"
                        end if
                        totger += vr_ominal+vr_pago ; totdia += vr_nominal - vr_pago
                            skip
                        lin++
                    return

                    procedure cabecatr
                        @4,03 say "CODIGO"
                        @4,15 say "CLIENTE"
                        @4,33 say "FATURA"
                        @4,43 say " VALOR"
                        @4,57 say " PAGTO.PARCIAL"
                        @5,00 say replicate("=",80)
                        lin:=6
                    return

                    procedure totalatras
                        @lin,33 say "TOTAL.....:"
                        @lin++,43 say totdia picture "@E 99,999,999.99"
                        @++lin, 33 say "TOT.GERAL.:"
                        @lin++,43 say totger picture "@E 99,999,999.99"
                    return

                    procedure datacliente
                        if .not. abrearq("CLIETES","INDCODCL")
                            RESTSCREEN(04,01,21,79,telavelha)
                            return
                        end if
                        if .not. abrearq("FATURAS","IDATCL")
                            restscreen(04,01,21,79,telavelha)
                            return
                        end if
                        set relation to codcli into clientes
                        select clientes
                        do while .t.
                            mcodcli = space(4)
                            mcodcli := space(4);ddataini := ctod(""); ddatafim := ctod("")
                                quadro(6,3,14,45,3)
                            @07,5 say "DATA INICIAL.:"GET ddataini
                            @08,5 say "DATA FIAL....:"GET ddatafim
                            //Read 
                            if LastKey()=27
                                RestScreen(04,01,21,79,telavelha)
                                close All
                                return 
                            end if
                            do case
                                case ddataini = ctod("") .and. ddatafim = ctod("")
                                    testadata = 0
                                case ddataini <> ctod ("") .and. ddatafim = ctod("")
                                    testadata=1
                                case ddataini=ctod("") .and. ddatafim <> ctod("")
                                    testadata=2
                                case ddataini<>ctod("") .and. ddatafim <> ctod("")
                                    testadata = 3
                            end case

                            select clientes
                            achou = .f.
                            do while .not. achou
                                @10,5 say "CODIGO DO CLIENTE: "
                                @11,5 SAY "XXXX = TODOS"
                                @10,26 GET mcodcli PICTURE "@N!"
                                //read 
                                if modcli <> "XXXX"
                                    seek mcodcli
                                    if found()
                                        @11,5 say clientes -> nomecli
                                        unico = .t.
                                        achou =  .t.
                                    else
                                        loop
                                    end if
                                else
                                    unico = .f.
                                    exit
                                end if
                            end do
                            select faturas
                            goto Top
                            set device to printer
                            lin := 61; p:= totger:= totdia:=0; datacomp = ctod(""); nr := "cr-006"
                            do while .not. eof()
                                do case
                                    case pagamento <> ctod("") .and. vr_nominal = vr_pago
                                        skip
                                        case mcodcli <> "XXXX" .and. codcli <> mcodcli
                                            skip
                                            case (testadata=1 .or. testadata=3) .and. vencimento < ddataini
                                                skip
                                                case (testadata=2 .or. testadata a=3) .and. vencimento > ddatafim
                                                    skip
                                                    otherwise
                                                    listadatcl()                           
                                end case
                            end do
                            totalatras()
                            final()
                            set device to Screen
                            close All
                        end do
                        mensagem(23,10,"FINAL DO RELATORIO DE TITULOSA VECER",2)
                        restscreen(04,01,21,79,telavelha)

                        procedure listadatcl
                            if lin > 60
                                cabecger("RELACAO DE TITULOS A VENCER")
                                CABECDATCL()
                            end if

                            if datacomp <> vencimento
                                if datacomp <> ctod("")
                                    @lin, 33 say "TOTAL....:"
                                    @lin++, 43 say totdia picture "@E 99,999,999.99"+" |"
                                end if
                            @lin++, 1 say "VENCIMENTO:" + DTOC(vencimento)
                            datacomp = vencimento
                            totdia = 0
                            end if
                            @lin, 04 say codcli +" |"
                            @lin, 10 say clientes -> (LEFT(nomecli,20))+" |"
                            @lin, 33 say codfat +" |"
                            @lin, 44 say vr_nominal picture "@E 9,999,999.99"+" |"
                            totger += vr_nominal; tordia += vr_nominal
                            skip
                            lin++
                        return

                        procedure CABECDATCL
                            @07,03 say "CODIGO"
                            @04, 19 say "NOME"
                            @04, 33 say "FATTURA"
                            @04,45 say "VALOR"
                            @05,00 say replicate("=",79)
                            lin = 7
                        return

                        procedure clientedata
                            private mcodcli := space(4), ddataini, ddatafim, filtro := ""
                            if .not. abrearq("FATURAS","INDCLDAT")
                                RestScreen(04,01,21,79,telavelha)
                                return
                            end if
                            set relation to codcli into clientes

                            do while .t.
                                mcodcli = space(4); ddataini := ddatafim := ctod("")
                                    QUADRO(6,3,14,45,3)
                                @7,5 say "CODIGO DO CLIETE: "
                                @8,5 say "XXXX = TODOS"
                                @7,26 get mcodcli picture "@N!"
                           //read 
                                if Val(mcodcli) = 0 .and. mcodcli <> "XXXX"
                                    close all 
                                    exit
                                end if
                                if modcli <> "XXXX"
                                    seek mcodcli
                                    if found()
                                        @8,5 say clientes -> nomecli
                                        uico = .t.
                                    else
                                        loop
                                    end if
                                    filtro = "CODCLI = mCODCLI" 
                                ELSE
                                    filtro = ""
                                end if
                                @10,5 say "DATA INICIAL.:" GET ddataini
                                @11,5 say "DATA FINAL..:" GET ddatafim ;
                                valid ddatafim >= ddataini
                                //read 
                                if ddataini <> ctod("") .and. ddatafim <> ctod("")
                                    if len(filtro) > 1
                                        filtro = filtro+" .and. vencimento >= dDATAINI .and VENCIMENTO <= dDataFIM"
                                    else
                                        filtro="VENCIMENTO >= dDATAIN .and. VENCIMENTO <= dDATAFIM"
                                    end if
                                end if
                                if len(filtro) > 1
                                    set filter to &filtro
                                end if
                                lin:= 61; P :=     TOTGER := TOTDIA := TOTCLI := 0; COMPCLIENTE = SPACE(4)
                                    nr = "CR-007"; COMPDATA:= CTOD("")
                                    GOTO Top
                                SET DEVICE TO printer
                                do while .NOT. EOF()
                                    listacliente()
                                end do
                                totalcli()
                                final()
                                set filter to
                                set device to Screen
                            end do
                            close All
                            restscreen(04,01,21,79,telavelha)

                            procedure listacliente
                                if lin > 60
                                    cabecger("RELACAIO DE TITULOS A VENCER = POR CLIENTE",nr)
                                    CABECCLIENTE()
                                end if
                                if compdata <> vencimento .and. compdata <> ctod("")
                                    @lin, 15 say "TOTAL.DIA :"
                                    @lin++,29 say totdia picture "@E 99,999,999.99"+" |"
                                    totdia := 0
                                end if
                                if compcliente <> codcli
                                    if compcliente <> space(4)
                                        @lin, 15 say "TOTAL.CLIENTE:"
                                        @lin++, 29 say totcli picture "@e 99,999,999.99"+" |"
                                    end if
                                    @lin++, 1 say "CLIENTE...:"+clientes -> (nomecli)
                                    compcliente = codcli
                                    compdata = vencimen
                                    tototcli = 0
                                end if

                                @lin,04 say codcli +" |"
                                @lin,15 say codfat +" |"
                                @lin, 30 say vr_nominal picture "@E 9,999,999.99"+" |"
                                @lin, 52 say dtoc(vencimento)+" |"
                                totger += vr_nominal; totcli += vr_nominal; totdia += vr_nominal
                                    compcliente = codcli
                                    compdata = vencimento
                                    skip
                                    lin++
                            return

                            procedure CABECCLIENTE
                                @04,03 say "CODIGO"
                                @04,15 say "FATURA"
                                @04,30 say " VALOR"
                                @04,50 say "VENCIMENTO"
                                @05,00 say replicate("=",80)
                                lin := 6

                            procedure totalcli()
                                @lin, 15 say "TOTAL.DIA :"
                                @lin++, 29 say totdia picture "@E 99,999,999.99"+" |"
                                @lin, 15 say "TOTAL.CLIENTE"
                                @lin++, 29 say totcli picture "@E 99,999,999.99"+" |"
                                @lin, 15 say "TOTAL GERAL:"
                                @lin++, 29 say totger picture "@E 99,999,999.99"+" |"

                            procedure cabecgr(titulo,nr)
                                if p > 0
                                    @lin,0 say replicate("=",71)+nr
                                    EJECT 
                                end if
                                @01,00 say empresa
                                @01,70 say "PAG:"+StrZero(++p,3)
                                @02,15 say titulo
                                @02,60 say date()
                                @02,70 say LEFT(time(),5)
                                @03,00 say replicate("=",80)
                            return

                            procedure final(tampag)
                                if tampag = nil 
                                    tampag = 65
                                end if
                                pos = tampag-prow()//numero de linhas menos linha atual
                                pos = 60-pos //numero de colunas da pagina (80)-20 -pos
                                do while lin <= tampag-3
                                    @lin++, pos++ say "*"
                                end do
                                @lin,pos say replicate("*",13)+nr
                                EJECT
                            return  

Return
