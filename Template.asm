TITLE Program Template     (template.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

.data
str1     BYTE    "Introduction",0

.code
main PROC
  MOV   ESI, OFFSET str1
  ADD   ESI, 5
  MOV   ECX, 4
  CLD
_L1:
  LODSB
  CALL  WriteChar
  LOOP  _L1
  
  MOV   ECX, 4
  STD
_L2:
  LODSB
  CALL  WriteChar
  LOOP  _L2
; (insert executable instructions here)
main ENDP

; (insert additional procedures here)

END main
