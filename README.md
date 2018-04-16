# Trabalhando com arquivos no Servidor de Aplicação #

[![N|Solid](https://wiki.scn.sap.com/wiki/download/attachments/1710/ABAP%20Development.png?version=1&modificationDate=1446673897000&api=v2)](https://www.sap.com/brazil/developer.html)

Serão criados exemplos basicos de como trabar com arquivo no servidor de aplicação. Tratando ações como criação de arquivo, deleção, renomear (linux). Antes de exemplificar, vou deixar inforamdo 3 transações que podem ajudar muito ao trabalhar com arquivos em servidor: 

| Transação | Descrição |
| ------ | ------ |
| AL11 Display SAP Directories| Essa transação proporciona uma visão dos arquivos e os diretorios no servidor |
| CG3Y Efetuar download file | Útil para salvar no seu computador arquivos que foram gerados no servidor |
| CG3Z Efetuar upload file | Necessária para enviar de forma direta aquivos para o servidor |


Para melhor organizar o codigo, será criada apenas uma classe e nem os métodos que fazem as ações.
* [deletar aquivo](#)


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

endmethod .
```
