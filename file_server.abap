report file_server .

class file_server definition .

  public section .

    class-methods file_search
      changing
        !file type string .

    methods create
      importing
        !file type string .

    methods read
      importing
        !file type string .

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


  method file_search .

    data:
      path type dxfields-longpath .

    call function 'F4_DXFILENAME_TOPRECURSION'
      exporting
        i_location_flag       = 'A'
        i_server              = 'PANDBBOL01_BOL_01'
        i_path                = '//saptxt/procwork/'
*       filemask              = '*.*'
*       fileoperation         = 'R'
      importing
*       o_location_flag       =
*       o_server              =
        o_path                = path
*       abend_flag            =
      exceptions
        rfc_error             = 1
        error_with_gui        = 2
        others                = 3 .

    if sy-subrc eq 0 .
      file = path .
    else .

      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.


  endmethod .


  method create .


    if file is not initial .

      open dataset file for output in text mode encoding default .

      if sy-subrc eq 0 .

        transfer 'unica linha' to file .
        close dataset file .

      endif .

    endif .


  endmethod .


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

endclass .

data:
  obj type ref to file_server .


parameters:
  file type string lower case,
  create radiobutton group grp,
  read   radiobutton group grp,
  rename radiobutton group grp,
  delete radiobutton group grp .


initialization .


at selection-screen on value-request for file .
  file_server=>file_search(
    changing
      file = file
  ) .


start-of-selection .

  create object obj .

  if obj is bound .

    case if_salv_c_bool_sap=>true .

      when create .
        obj->create( file ) .

      when read .
        obj->read( file ) .

      when rename .
        obj->rename( file ) .

      when delete .
        obj->delete( file ) .

      when others .

    endcase .

  endif .
