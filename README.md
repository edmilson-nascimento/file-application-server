# Trabalhando com arquivos no Servidor de Aplicação #

[![N|Solid](https://wiki.scn.sap.com/wiki/download/attachments/1710/ABAP%20Development.png?version=1&modificationDate=1446673897000&api=v2)](https://www.sap.com/brazil/developer.html)

Serão criados exemplos basicos de como trabar com arquivo no servidor de aplicação. Tratando ações como criação de arquivo, deleção, renomear (linux). Antes de exemplificar, vou deixar inforamdo 3 transações que podem ajudar muito ao trabalhar com arquivos em servidor: 

| Transação | Descrição |
| ------ | ------ |
| AL11 Display SAP Directories| Essa transação proporciona uma visão dos arquivos e os diretorios no servidor |
| CG3Y Efetuar download file | Útil para salvar no seu computador arquivos que foram gerados no servidor |
| CG3Z Efetuar upload file | Necessária para enviar de forma direta aquivos para o servidor |


Para melhor organizar o codigo, será criada apenas uma classe e nem os métodos que fazem as ações.
* [criar arquivo](#criar-arquivo)
* [ler arquivo](#ler-arquivo)
* [renomear arquivo](#renomear-arquivo)
* [deletar arquivo](#deletar-arquivo)

## Criar arquivo ##
Existem algumas variações de como informar, mas, vou usar apenas a ultima ~~porque eu to com preguiça de ficar exemplificando tudo.~~ As variações de utilizações ficam a critério de cada caso, mas para esse, será criado um arquivo de acordo com o parâmetro de entrada e dentro dele ficará uma _unica linha_ de informação.
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
