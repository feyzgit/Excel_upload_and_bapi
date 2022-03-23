*&---------------------------------------------------------------------*
*&  Include           ZCO_R016_DEF
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION .

  PUBLIC SECTION.

    METHODS : handle_double_click FOR EVENT double_click
                  OF cl_gui_alv_grid
      IMPORTING e_row e_column es_row_no.

    METHODS : handle_user_command
          FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
          e_ucomm .

    METHODS : handle_hotspot_click
                  FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id
                  e_column_id
                  es_row_no.

    METHODS handle_toolbar_set
          FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
          e_object
          e_interactive.

    METHODS handle_toolbar_set_popup
          FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
          e_object
          e_interactive.

    METHODS check_change_data
                  FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING sender er_data_changed e_onf4 e_onf4_before
                  e_onf4_after e_ucomm.


ENDCLASS.

CLASS lcl_main DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS :
      at_selection_screen,
      get_file_path CHANGING ch_fname TYPE rlgrap-filename,
      start,
      free_data,
      alv CHANGING alvtable TYPE STANDARD TABLE ,
      fcat IMPORTING strname TYPE tabname,
      excel_upload IMPORTING  im_fname    TYPE rlgrap-filename
                   EXPORTING  ev_exceldat TYPE tt_exceldat
                   EXCEPTIONS contains_error,
      save,
      reverse.
  PRIVATE SECTION.
    METHODS:
      get_data,
      display.

    CLASS-DATA: lr_main TYPE REF TO lcl_main.

ENDCLASS.