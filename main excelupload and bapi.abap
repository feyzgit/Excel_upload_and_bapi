*&---------------------------------------------------------------------*
*& Report  ZCO_R016
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zco_r016.

INCLUDE zco_r016_top.
INCLUDE zco_r016_def.
INCLUDE zco_r016_imp.
INCLUDE zco_r016_mod.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  lcl_main=>get_file_path(
    CHANGING
      ch_fname = p_file ).

AT SELECTION-SCREEN OUTPUT.
  lcl_main=>at_selection_screen( ).

START-OF-SELECTION.
  lcl_main=>start( ).