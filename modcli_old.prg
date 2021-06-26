//NOME: MODCLI.PRG
function Main()
local op 
save screen 
do while .t.
    @02,41 say procname()
    menumanut(8,13,"CLIENTES")
    menu to op 
    televelha = savescreen(04,01,21,79)
    publvar()
    do case
        case op = 1
            do inccli
        case op = 2
            do altcli
        case op = 3
            do concli
        case op = 4
            do exccli
        case op = 5
            relevar()
        return
        restore screen
        
            
    endcase
enddo 

procedure inccli
    if .not. abrearq("CLIENTES","INDCODCL","INDNOMCL")
        return 
    endif 

    do while .t.
        publvar()
        inivar()
        mostratexto()
        pesquisa()
        if val(mcodcli) = 0
            exit
        endif

        if .not found()
            getvar()
            read 
        else
            mensagem(23,10,"CLIENTE JA CADASTRADO")
            loop 
        endif 

        if confirma("grava esse registro ?") = 1
            APPEND BLANK 
            replvar() 
        else
            loop
        endif 
    enddo 
    Use
    voltatela()
    relevar() 
    return

    procedure altcli 
        if .not. abrearq("CLIENTES","INDCODCL","INDNOMCL")
            RETURN
        ENDIF 
        do while .t.
            mostratexto()
            pesquisa()
            if val(mcodcli) = 0
                exit
            endif 
            if found()
                igualavar()
                getvar()
                read
            else
                mensagem(23,10,"CLIENTE NAO CADASTTRADO     ")
                loop 
            endif 

            if confirma("ALTERA ESSE REGISTRO ?") = 1
                replvar()
            else
                loop
            endif
        enddo 
        Use
        voltatela()
    return

    procedure concli 
        if .not. abrearq("CLIENTES","INDCODCL")
            return
        endif 
        do while .t.
            mostratexto()
            pesquisa()
            if val(mcodcli)=0
                exit
            endif 
            if found()
                igualavar()
                mostravar()
                read
            else
                mensagem(23,10,"PRESSIONE <ESPACO> PARA CONTINUAR ")
            enddo 
            Use
            voltatela()
            return 

            procedure exccli
                if .not. abrearq("CLIENTES","INDCODCL","INDNOMCL")
                    return 
                endif 
            do while .t.
                    mostratexto()
                    pesquisa()
                    if val(mcodcli) = 0
                        exit
                    endif 
                    if found()
                        igualavar()
                        mostravar()
                        read 
                    else
                        mensagem(23,10,"CLIENTE NAO CADASTRADO")
                            loop
                    endif 

                    if confirma("DELETA ESSE REGISTRO  ?") = 1
                        DELETE 
                    ELSE 
                        LOOP 
                    ENDIF 
                enddo 
                Use
                voltatela()
            return 

            procedure inicvar
                mcodcli = space(4)
                mnomecli = space(40)
                mendereco = space(40)
                mcep = space(5)
                mcidade = space(20)
                mestado = space(20) 
                mestado = space(2) 
                multicompra = ctod('  /  /  ')
                msituacao = .f.
            return

            procedure mostratexto
                set color to w/n
                @06,05 clear  to 17,65
                @06,05 to 17,65
                @08,09 say "CODIGO...:"
                @09,09 say "NOME.....:"
                @10,09 say "ENDERECO.:"
                @11,09 say "CEP......:"
                @12,09 say "CIDADE...:"
                @13,09 say "ESTADO...:"
                @15,09 say "ULTIMA COMPRA:"
                @16,09 say "SITUACAO.....:"
            return 

            procedure voltatela 
            RestScreen(04,01,21,79,televelha)

            procedure mostravar
                SetColor to w/n 
                @08,21 say mcodcli
                @09,21 say mnomecli
                @10,21 say mendereco
                @11,21 say mcep
                @12,21 say mcidade
                @13,21 say mestado
                @15,25 say multcompra picture 'dd/dd/dd'
                @16,25 say if(msituacao,"CLIENTE EM DIA","CLIENTE DEVEDOR")
                return

                procedure getvar
                    SetColor to w/n,n/w,,n/b
                    @09,21 get mnomecli picture "@!X"
                    @10,21 get mendereco picture "@!X"
                    @11,21 get mcep picture "99999999" valid id completa
                    @12,21 get mcidade picture "@A!"
                    @13,21 get mestado picture "AA"
                    @15,25 get multcompra picture 'DD/DD/DD'
                    @16,25 get msituacao picture 'L'
                return

                procedure igualavar 
                    store codcli to mcodcli
                    store nomecli to mnomecli
                    store endereco to mendereco 
                    store cep to mcep 
                    store cidade to mcidade
                    store estado to mestado
                    store ultcompra to multcompra
                    store situacao to msituacao
                return

                procedure replvar
                    replace codcli with mcodcli
                    replace nomecli with mnomecli
                    replace endereco with mendereco
                    replace cep with mcep
                    replace cidade with mcidade
                    replace ultcompra with msituacao
                return

                procedure publvar 
                    public mcodcli,mnomecli,mendereco,mcep,mcidade
                    public mestado,multicompra,msituacao 
                return

                procedure relevar 
                    release mcodcli,mnomecli,mendereco,mcep,mcidade
                    release mestado,multicompra,msituacao
                return 

                procedure pesquisa 
                    mcodcli = 0
                    @08,21 get mcodcli picture "99999-999"
                    read
                    mcodcli = StrZero(mcodcli,4)
                    setcolor("W/N")
                return

                function completa
                if val(mcep) <= 5999 //significa que e sao paulo capital
                    mestado = "SP"
                    mcidade = "SAO PAULO"
                    Keyboard chr(13)+chr(13)
                endif
            return(.t)

return Nil