# Trabalhando com arquivos no Servidor de Aplicação #



![ABAP](https://img.shields.io/badge/ABAP-0051B5?style=flat&logo=sap&logoColor=white)
![SAP](https://img.shields.io/badge/SAP-0FAAFF?style=flat&logo=sap&logoColor=white)
![ABAP OO](https://img.shields.io/badge/ABAP_OO-276DC3?style=flat&logo=sap&logoColor=white)
[![Development ABAP](https://img.shields.io/badge/Development-ABAP-blue?style=flat)](https://www.sap.com/index.html)
[![SAP on-premise](https://img.shields.io/badge/SAP-on--premise-blue?style=flat)](https://www.sap.com/index.html)
[![Commits](https://img.shields.io/github/commit-activity/t/edmilson-nascimento/file-application-server?style=flat)](https://github.com/edmilson-nascimento/file-application-server)

Serão criados exemplos básicos de como trabalhar com arquivos no servidor de aplicação. Tratando ações como criação de arquivo, deleção, renomear (linux). Antes de exemplificar, vou deixar informando 3 transações que podem ajudar muito ao trabalhar com arquivos em servidor:

| Transação | Descrição |
| ------ | ------ |
| AL11 Display SAP Directories| Essa transação proporciona uma visão dos arquivos e os diretórios no servidor |
| CG3Y Efetuar download file | Útil para salvar no seu computador arquivos que foram gerados no servidor |
| CG3Z Efetuar upload file | Necessária para enviar de forma direta arquivos para o servidor |

Para melhor organizar o código, será criada apenas uma classe e nela os métodos que fazem as ações.
* [criar arquivo](#criar-arquivo)
* [ler arquivo](#ler-arquivo)
* [renomear arquivo](#renomear-arquivo)
* [deletar arquivo](#deletar-arquivo)

## Criar arquivo ##
Existem algumas variações de como informar, mas, vou usar apenas a última. ~~porque eu to com preguiça de ficar exemplificando tudo.~~ As variações de utilizações ficam a critério de cada caso, mas para esse, será criado um arquivo de acordo com o parâmetro de entrada e dentro dele ficará uma _única linha_ de informação.
```abap
method create .

  if file is not initial .

    open dataset file for output in text mode encoding default .

    if sy-subrc eq 0 .

      transfer 'unica linha' to file .
      close dataset file .

    endif .

  endif .

endmethod .
```

## Ler arquivo ##
Essa parte, se diferencia principalmente na parte de criação por causa do `output in text` do `open dataset`, que para o modo de leitura vai ser alterado para `input in text`.
```abap
method read .

  data:
    line type string .

  if file is not initial .

    open dataset file for input in text mode encoding default .

    do.

      read dataset file into line .

      if sy-subrc eq 0 .
        write / line .
      else.
        exit.
      endif.

    enddo.

    close dataset file .

  endif .

endmethod .
```

## Renomear arquivo ##
A utilização que vou aplicar foi feita para a atender uma necessidade especifica. Existe um serviço que busca os arquivos com extensão `*.txt` e faz o processamento com as informações. Para evitar que esse serviço acesso o arquivo quando ele ainda esta sendo editado, o arquivo então é criado com extensão `*.tmp` e renomeado ao final do processo garantido que o serviço tenha acesso apenas quando ele tiver todas as informações necessárias.
```abap
  method rename .

    data:
      posicao   type i,
      nome_novo type char128,
      comando   type char300 .

    find first occurrence of '.tmp' in file match offset posicao .

    if sy-subrc eq 0 .

      concatenate file(posicao) '.txt'
             into nome_novo .

    else .

      find first occurrence of '.TMP' in file match offset posicao .

      if sy-subrc eq 0.

      concatenate file(posicao) '.TXT'
             into nome_novo .

      endif.

    endif .

*   "mv" + "Nome Antigo" + "Nome Novo" + "&& chmod 777" + "Nome Novo"
    if nome_novo is not initial .

      concatenate 'mv' file nome_novo
      '&& chmod 777' nome_novo
      into comando
      separated by space.

      call 'SYSTEM' id 'COMMAND' field comando.
      format reset.

    endif .

  endmethod .

  method delete .

    if file is not initial .

      delete dataset file .

    endif .

  endmethod .
```
## Deletar arquivo ##
É uma funcionalidade mais _simples_, porem bem util. Muitas das vezes eu tentei usar os comandos do Sistema Operacional mas achei essa menira mais fácil.
```abap
  method delete .

    if file is not initial .

      delete dataset file .

    endif .

  endmethod .
```
