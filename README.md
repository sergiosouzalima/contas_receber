CONTAS A RECEBER
=============

### Sistema de Contas a Receber

#### Autor: Sergio Lima - Set., 2021

Harbour
-----------

Esta aplicação foi construída usando:

- Harbour versão 3.2 (Antigo Clipper)
- SQLite3 versão 3.8.2
- Desenvolvido em Linux.
- Preparado para ser executado em Linux e Windows

Para saber mais sobre [<a href="https://harbour.github.io">Harbour Compiler</a>].

Desafio
---------------

Desenvolver este sistema, usando o compilador Harbour, uma linguagem
xBase e que herda comandos e funções da antiga linguagem Clipper.

O desafio ainda compreende, usar como inspiração o livro
"Clipper 5.0 Volume 1 Release 5.01", do autor Autor Ramalho, 
publicado em 1991.

Motivação
-------------------------

Disponibilizar à comunidade Open Source, um sistema simples
com itens de uso comum na maioria dos sistemas comerciais.

Desenvolvedores iniciantes ou com dúvidas em comandos, classes,
funções, arquitetura e integração com o banco de dados SQLite3,
podem consultar e usar livremente os programas deste repositório.

Recursos mais avançados como uso de classes criadas pelo usuário,
serão usadas numa próxima versão.


Compilação
-------------------------

- No Linux ou Windows, execute o comando
  * hbmk2 contas_receber.hbp

- Pre-requisito para compilação
  * O compilador Harbour deve estar instalado.
  * Para saber mais sobre [<a href="https://harbour.github.io">Harbour Compiler</a>].


Instalação
-------------------------

O sistema de contas a receber não precisa ser instalado.

Ao ser executado o arquivo "contas_receber.exe" no Windows ou 
"./contas_receber" no Linux, o sistema entra em funcionamento imediatamente.


Banco de dados
-------------------------

Na primeira execução, o sistema "entende" que o banco de dados em SQLite3
deve ser criado.

Assim, o banco de dados "contas_receber.s3db" é criado automaticamente
na mesma pasta onde o executável do sistema está localizado.


Pedido do Autor
------------------------

Este repositório é mais uma contribuição livre para a
comunidade Open Source.

O autor solicita somente que façam referência a este trabalho,
ao usar ou apresentar trechos extraídos deste repositório.

Dúvidas, sugestões e críticas para melhorias também são bem-vindas.
