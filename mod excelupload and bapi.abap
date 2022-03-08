*&---------------------------------------------------------------------*
*&  Include           ZCO_R016_MOD
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'PFB'.

  lcl_main=>free_data( ).
  lcl_main=>fcat( EXPORTING strname = 'ZCO_S_R016' ).
  lcl_main=>alv( CHANGING alvtable = gt_report ).


ENDMODULE.                 " STATUS_0100  OUTPUT
MODULE user_command_0100 INPUT.

  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN '&F03' OR '&F15' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.