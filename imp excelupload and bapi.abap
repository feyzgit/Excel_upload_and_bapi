*&---------------------------------------------------------------------*
*&  Include           ZCO_R016_IMP
*&---------------------------------------------------------------------*

CLASS lcl_main IMPLEMENTATION.

  METHOD get_file_path.

    DATA : lv_subrc LIKE sy-subrc,
           lt_path  TYPE filetable,
           lr_path  TYPE REF TO file_table.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title      = 'Select Source Excel File'
        default_extension = 'XLSX'
        initial_directory = 'C:\'
        multiselection    = abap_false
      CHANGING
        file_table        = lt_path
        rc                = lv_subrc.

    READ TABLE lt_path REFERENCE INTO lr_path INDEX 1.
    IF sy-subrc IS INITIAL.
      MOVE lr_path->filename TO ch_fname.
    ENDIF.

  ENDMETHOD.                    "get_file_path
  METHOD start.

    CREATE OBJECT lr_main.

    lr_main->get_data( ).
    lr_main->display( ).

  ENDMETHOD.
  METHOD display.

    CALL SCREEN 0100.

  ENDMETHOD.
  METHOD free_data.

    IF gt_container IS NOT INITIAL.

      CALL METHOD gt_container->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.

      CLEAR gt_container.
      FREE gt_container.

    ENDIF.

    IF grid IS NOT INITIAL.

      CALL METHOD grid->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.

      CLEAR grid.

    ENDIF.

  ENDMETHOD.
  METHOD alv.

    DATA : ls_layout  TYPE  lvc_s_layo,
           ls_variant TYPE  disvariant.
    DATA: lw_toolbar TYPE stb_button.

    ls_layout-zebra      = 'X'.
    ls_layout-cwidth_opt = 'X'.
    ls_layout-sel_mode   = 'A'.
*    ls_layout-excp_fname = 'LIGHT'.
*    ls_layout-box_fname  = 'SELKZ'.

    ls_variant-report = sy-repid.
*    ls_variant-handle = 'HDR'.
*
*    MOVE gc_sel_all      TO lw_toolbar-function.
*    MOVE icon_select_all TO lw_toolbar-icon.
*    APPEND lw_toolbar    TO e_object->mt_toolbar.


    IF gt_container IS INITIAL.

      CREATE OBJECT gt_container
        EXPORTING
          container_name              = 'CONT1'
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.

      CREATE OBJECT grid
        EXPORTING
          i_parent = gt_container.

      CREATE OBJECT event_receiver .

      SET HANDLER event_receiver->handle_double_click FOR grid.
      SET HANDLER event_receiver->handle_hotspot_click FOR grid.
      SET HANDLER event_receiver->handle_toolbar_set FOR grid.
      SET HANDLER event_receiver->handle_user_command FOR grid.

      CALL METHOD grid->set_table_for_first_display
        EXPORTING
          is_variant         = ls_variant
          i_buffer_active    = ' '
          is_layout          = ls_layout
          i_save             = 'U'
          i_bypassing_buffer = 'X'
        CHANGING
          it_fieldcatalog    = gt_fc[]
          it_outtab          = alvtable[].




    ELSE.

      CALL METHOD grid->refresh_table_display
        EXPORTING
          i_soft_refresh = ''.

    ENDIF.
    SET HANDLER event_receiver->check_change_data FOR grid.

    IF it_row_no[] IS NOT INITIAL.

      CALL METHOD grid->set_selected_rows
        EXPORTING
          it_row_no = it_row_no.

    ENDIF.

    CALL METHOD grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*
*    CALL METHOD grid->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*    CALL METHOD cl_gui_control=>set_focus
*      EXPORTING
*        control = grid.

  ENDMETHOD.
  METHOD fcat.

    REFRESH gt_fc.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = strname
      CHANGING
        ct_fieldcat            = gt_fc
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    LOOP AT gt_fc INTO gs_fc.
      CASE gs_fc-fieldname.
        WHEN 'KST001'.
          gs_fc-edit = 'X'.
      ENDCASE.
      MODIFY gt_fc FROM gs_fc.
    ENDLOOP.


  ENDMETHOD.
  METHOD get_data.

    SELECT SINGLE COUNT(*) FROM zco_t_r016
      WHERE poper EQ p_poper
        AND gjahr EQ p_gjahr.
    IF sy-subrc IS INITIAL.
      MESSAGE 'Bu dönem için önceden istatistiksel gösterge belgeleri kaydedildi!!!' TYPE 'E'.
    ENDIF.

    me->excel_upload(
      EXPORTING
        im_fname = p_file
      IMPORTING
        ev_exceldat = mt_exceldat
      EXCEPTIONS
        contains_error = 1
        OTHERS         = 2 ).
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. RETURN.
    ENDIF.

    LOOP AT mt_exceldat REFERENCE INTO DATA(r_exceldat).
      APPEND INITIAL LINE TO gt_report REFERENCE INTO DATA(r_report).

      CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
        EXPORTING
          input  = r_exceldat->col01
        IMPORTING
          output = r_exceldat->col01.

      r_report->posid = r_exceldat->col01.
      r_report->yuzde = r_exceldat->col02.
    ENDLOOP.

    IF NOT gt_report IS INITIAL.
      SELECT posid, post1
        FROM prps
          INTO TABLE @DATA(t_prpsdat)
            FOR ALL ENTRIES IN @gt_report
            WHERE posid = @gt_report-posid.
      LOOP AT gt_report REFERENCE INTO r_report.
        r_report->post1 = VALUE #( t_prpsdat[ posid = r_report->posid ]-post1 OPTIONAL ).
      ENDLOOP.
    ENDIF.



  ENDMETHOD.

  METHOD excel_upload .
    DATA: lt_raw TYPE truxs_t_text_data.

    TRY.
        FREE: ev_exceldat.
        CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
          EXPORTING
            i_tab_raw_data       = lt_raw
            i_filename           = im_fname
            i_line_header        = abap_true
          TABLES
            i_tab_converted_data = ev_exceldat
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
        IF sy-subrc = 1.
          MESSAGE e001(zco_206) RAISING contains_error.
        ELSEIF sy-subrc <> 0.
          MESSAGE e002(zco_206) RAISING contains_error.
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        MESSAGE e001(zco_206) RAISING contains_error.
    ENDTRY.

    IF ev_exceldat[] IS INITIAL.
      MESSAGE e003(zco_206) RAISING contains_error.
    ENDIF.



  ENDMETHOD.

  METHOD save.

    DATA ls_header       TYPE bapidochdrp.
    DATA ignore_warnings TYPE bapiiw-ignwarn.
    DATA lv_docno        TYPE bapidochdrp-doc_no.
    DATA lt_items        TYPE STANDARD TABLE OF bapiskfitm.
    DATA ls_items        TYPE bapiskfitm.
    DATA lt_return       TYPE STANDARD TABLE OF bapiret2.
    DATA ls_return       TYPE  bapiret2.
    DATA customer_fields TYPE STANDARD TABLE OF bapiextc.

    DATA day_in            TYPE sy-datum.
    DATA last_day_of_month TYPE sy-datum.
    DATA ls_date TYPE sy-datum.
    DATA ls_log TYPE zco_t_r016.

    CONCATENATE  p_gjahr p_poper+01(02) '01' INTO ls_date.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ls_date
      IMPORTING
        last_day_of_month = ls_header-postgdate.

    ls_header-co_area = 'BM00'.
    ls_header-doc_hdr_tx = 'BMC POWER ‘Çalıştırılan Ay/Yıl değeri’ Timesheet girişleri'.
    ls_header-username = sy-uname.

    LOOP AT gt_report REFERENCE INTO DATA(lr_report).

      ls_items-rec_wbs_el = lr_report->posid.
      ls_items-stat_qty = lr_report->yuzde.
      ls_items-statkeyfig = sy-uzeit.

      APPEND ls_items TO lt_items.

    ENDLOOP.

    CALL FUNCTION 'BAPI_ACC_STAT_KEY_FIG_POST'
      EXPORTING
        doc_header = ls_header
      IMPORTING
        doc_no     = lv_docno
      TABLES
        doc_items  = lt_items
        return     = lt_return.

    LOOP AT lt_return  INTO ls_return WHERE type CA 'EAX'.
     MOVE-CORRESPONDING ls_return to  gs_message .
     APPEND gs_message TO gt_message.
    ENDLOOP.

    IF sy-subrc IS INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      ls_log-belnr = lv_docno.
      ls_log-gjahr = p_gjahr.
      ls_log-poper = p_poper.
      MODIFY zco_t_r016 FROM ls_log.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_double_click.
  ENDMETHOD.
  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN '&IC1' OR '&ETA'.

      WHEN 'SAVE'.
        lcl_main=>save( ).

    ENDCASE.
    IF gt_message[] IS NOT INITIAL.
      CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
        EXPORTING
          it_message = gt_message.
    ENDIF.

  ENDMETHOD.
  METHOD handle_hotspot_click.
  ENDMETHOD.
  METHOD check_change_data.
  ENDMETHOD.
  METHOD handle_toolbar_set.
    DATA: ls_toolbar  TYPE stb_button.

    DEFINE add_button.

      CLEAR ls_toolbar.

      ls_toolbar-function = &1.
      ls_toolbar-icon     = &2.
      ls_toolbar-text     = &3.

      APPEND ls_toolbar TO e_object->mt_toolbar.

    END-OF-DEFINITION.

    add_button:
      'SAVE' 'ICON_SYSTEM_SAVE' 'KAYDET'.

    DELETE e_object->mt_toolbar WHERE function EQ '&CHECK'
                                   OR function EQ '&REFRESH'
                                   OR function EQ '&LOCAL&CUT'
                                   OR function EQ '&LOCAL&COPY'
                                   OR function EQ '&LOCAL&PASTE'
                                   OR function EQ '&LOCAL&UNDO'
                                   OR function EQ '&LOCAL&APPEND'
                                   OR function EQ '&LOCAL&INSERT_ROW'
                                   OR function EQ '&LOCAL&DELETE_ROW'
                                   OR function EQ '&LOCAL&COPY_ROW'.
  ENDMETHOD.
  METHOD handle_toolbar_set_popup.
    IF sy-ucomm EQ ''.

      REFRESH e_object->mt_toolbar.

    ELSE.

*      DELETE e_object->mt_toolbar WHERE function NE '&LOCAL&APPEND'
*                                    AND function NE '&LOCAL&INSERT_ROW'
*                                    AND function NE '&LOCAL&DELETE_ROW'
*                                    AND function NE '&LOCAL&COPY_ROW'.

    ENDIF.
  ENDMETHOD.
ENDCLASS.