report file_server .

class file_server definition .

  public section .

    methods rename 
      importing
        !file type string .

    methods delete
      importing
        !file type string .

  protected section .

  private section .

endclass . 


class file_server implementation .

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

  method delete .

    if file is not initial .

      delete dataset file .

    endif .

  endmethod .

endclass .
