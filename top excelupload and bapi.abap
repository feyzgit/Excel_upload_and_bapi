*&---------------------------------------------------------------------*
*&  Include           ZCO_R016_TOP
*&---------------------------------------------------------------------*

*TABLES : .
TYPE-POOLS: slis.
**class definition defferred
CLASS lcl_event_receiver DEFINITION DEFERRED.

**CONSTANTS


**containers
DATA go_customcont   TYPE REF TO cl_gui_custom_container.
DATA: cont         TYPE scrfname,
      grid         TYPE REF TO cl_gui_alv_grid,
      gt_container TYPE REF TO cl_gui_custom_container.

**Field Catalogs
DATA: gs_fieldcat_cust TYPE lvc_s_fcat,
      gt_fieldcat_cust TYPE lvc_t_fcat,
      gt_fc            TYPE lvc_t_fcat,
      gs_fc            TYPE lvc_s_fcat.

**Class objects
DATA event_receiver     TYPE REF TO   lcl_event_receiver.
DATA: gr_events    TYPE REF TO lcl_event_receiver.

**Tables
DATA: gt_report TYPE TABLE OF zco_s_r016,
      it_row_no TYPE lvc_t_roid.

DATA: gt_message TYPE TABLE OF bapiret2,
      gs_message TYPE bapiret2.
*data: gt_log TYPE STANDARD TABLE OF ZCO_T_R016,
*      gs_log TYPE ZCO_T_R016.
**Structures

**Variables
DATA: gv_filename TYPE rlgrap-filename,
      ok_code     LIKE sy-ucomm.

TYPES:
  BEGIN OF ty_exceldat,
    col01    TYPE char24,
    col02(5) TYPE p DECIMALS 2,
  END OF ty_exceldat .
TYPES:
 tt_exceldat TYPE STANDARD TABLE OF ty_exceldat WITH DEFAULT KEY .


DATA: mt_exceldat TYPE tt_exceldat,
      ev_exceldat TYPE tt_exceldat,
      cv_fname    TYPE rlgrap-filename,
      im_fname    TYPE rlgrap-filename.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME.

PARAMETERS: p_file  TYPE rlgrap-filename MODIF ID md1 ,
            p_poper TYPE poper OBLIGATORY DEFAULT sy-datum+4(2),
            p_gjahr TYPE gjahr OBLIGATORY DEFAULT sy-datum(4),
            p_ch   AS CHECKBOX USER-COMMAND cm1.

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME.

*PARAMETERS:

SELECTION-SCREEN END OF BLOCK b02.