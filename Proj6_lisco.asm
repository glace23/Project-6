TITLE String Primitives and Macros     (Proj6_lisco.asm)

; Author: Scott Li
; Last Modified: 11/22/20 - 15:00
; OSU email address: lisco@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  Project 5         
; Due Date: 11/22/20
; Description: This program outputs an array of random numbers, then output sorted array, and finally the count of each number.

INCLUDE Irvine32.inc

;	Macros
mGetString MACRO stringIn, stringOut, length
	;	preserve registers
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX

	; display input param
	MOV		EDX, stringIn
	CALL	WriteString

	; take input into memory
	MOV		EDX, stringOut
	MOV		ECX, 12
	CALL	ReadString
	MOV		length, EAX

	;	restore registers
	POP		EDX
	POP		ECX
	POP		EAX
ENDM


mDisplayString MACRO stringA
	;	preserve registers
	MOV		EBP, ESP
	PUSH	EDX

	MOV		EDX, OFFSET stringA
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	;	restore registers
	POP		EDX
	
ENDM

.data
	; Main program
	programTitle	BYTE	"Designing low-level I/O procedures, ",0Ah
					BYTE	"Written by Scott Li",0
	intro_1			BYTE	"Please provide 10 signed decimal integers. [-2,147,483,648, +2,147,483,647]",0Ah
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0Ah
					BYTE	"After you have finished inputting the numbers I will display a list of the integers, their sum, and their average value.",0 
	prompt			BYTE	"Please enter an signed number: ",0
	numString		BYTE	12 DUP(?)
	len				DWORD	?
	numArray		SDWORD	10 DUP(?)
	digit			DWORD	?
	error			BYTE	"Invalid input, please try again!",0



.code
main PROC
; (insert executable instructions here)

	;	introduction
	mDisplayString	programTitle
	mDisplayString	intro_1

	;	ReadVal
	PUSH	OFFSET error
	PUSH	OFFSET numArray
	PUSH	len
	PUSH	OFFSET numString
	PUSH	OFFSET prompt
	CALL	ReadVal

	Invoke	ExitProcess,0
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Output introduction to user
;
; Preconditions: 'programTitle', 'authorName', 'intro_1', are strings.
;
; Postconditions: None
;
; Receives: [EBP + 8] 'prompt'(macro reference, input), 
;			[EBP + 12] 'numString' (macro reference, output), 
;			[EBP + 16] 'len' (macro reference, output)
;			[EBP + 20] 'numArray' (reference, output)
;			[EBP + 24] 'error'	  (reference, input)
;
; Returns: None
; ---------------------------------------------------------------------------------
ReadVal PROC
	;	preserve registers
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	PUSHFD						; preserve all flags

	; initiate outer loop values
	MOV		ECX, 10				;	outer loop counter
	MOV		EDI, [EBP + 20]		;	numarray

	; outer loop
_prompt:
	; mGetString prompt, numString, len
	mGetString [EBP + 8], [EBP + 12], [EBP + 16]
	CLD
	MOV		EAX, 0
	MOV		ESI, [EBP + 12]		;	numString

_checkSign:
	MOV		AL,	[ESI]
	CMP		AL, 45				; - sign
	JE		_setNegative
	CMP		AL, 43				; + sign
	JE		_setPositive
	OR		EAX, 1				; if no sign, assume positive, set sign to positive
	JMP		_checkVal
_setNegative:
	; len - 1, ignore sign
	MOV		EAX, [EBP + 16]
	SUB		EAX, 1
	MOV		[EBP + 16], EAX

	MOV		EAX, 0
	ADD		ESI, 1				; increment to next byte after sign
	OR		EAX, -1				; set sign flag to 1

	JMP		_checkVal

_setPositive:
	; len - 1, ignore sign
	MOV		EAX, [EBP + 16]
	SUB		EAX, 1
	MOV		[EBP + 16], EAX

	MOV		EAX, 0
	ADD		ESI, 1				; increment to next byte after sign
	OR		EAX, 1				; set sign flag to 0
	JMP		_checkVal


	; inner loop
	_checkVal:		
		;	initialize innter loop values
		PUSH	ECX					; preserve outer loop counter
		PUSH	ESI					; preserve ESI and EDI and sign flag
		PUSH	EDI
		PUSHFD
		MOV		ECX, [EBP + 16]		;	inner loop counter = len

		; check and convert number from string to integer
	_convert:
		;	get digit at StringByte
		MOV		EAX, 0
		MOV		AL, [ESI]			; move digit to AL

		;	check if numeric
		CMP		EAX, 48				; 0
		JE		_isNum
		CMP		EAX, 49				; 1
		JE		_isNum
		CMP		EAX, 50				; 2
		JE		_isNum
		CMP		EAX, 51				; 3
		JE		_isNum
		CMP		EAX, 52				; 4
		JE		_isNum
		CMP		EAX, 53				; 5
		JE		_isNum
		CMP		EAX, 54				; 6
		JE		_isNum
		CMP		EAX, 55				; 7
		JE		_isNum
		CMP		EAX, 56				; 8
		JE		_isNum
		CMP		EAX, 57				; 9
		JE		_isNum

		JMP		_notNum

		; if string is a number, modify exisiting numArray 
	_isNum:
		;	calculate digit
		MOV		EDX, EAX
		SUB		EDX, 48

		PUSH	EDX					; preserve digit

		;	exisiting digit push one order higher
		MOV		EAX, [EDI]
		MOV		EBX, 10
		MUL		EBX

		POP		EDX					;	restore digit
		;	add digit to new number, move back to array
		ADD		EAX, EDX
		MOV		[EDI], EAX
					
		LODSB
		;JECXZ	_restore			; jump if ECX = 0
		LOOP	_convert

		; restore registers and flags, and go on to determine sign
	_restore:
		POPFD						; restore EDI and ESI and sign flag
		POP		EDI					
		POP		ESI
		POP		ECX					; restore outer loop counter
		JS		_negNum				; if sign flag is 1
		JNS		_posNum				; if sign flag is 0

		; restore registers and flags, clear exisiting value in position
	_notNum:
		POPFD						; restore EDI and ESI and sign flag
		POP		EDI					
		POP		ESI
		POP		ECX					; restore outer loop counter

		MOV		EAX, 0 
		MOV		[EDI], EAX

		MOV		EDX, [EBP + 24]
		CALL	WriteString
		CALL	CrLf

		JMP	_prompt

		; calculate value in position into negative
	_negNum:
	MOV		EAX, [EDI]
	ADD		EAX, [EDI]
	SUB		[EDI], EAX				; [EDI] - 2*[EDI] = -[EDI]
	MOV		EAX, [EDI]

	DEC		ECX						; decrease ECX and loop
	JECXZ	_pop
	ADD		EDI, 4					; move to next array element

	JMP	_prompt

		; 
	_posNum:
	MOV		EAX, [EDI]

	DEC		ECX						; decrease ECX and loop
	JECXZ	_pop

	ADD		EDI, 4					; move to next array elemnt
	JMP	_prompt


_pop:
	;	restore registers
	POPFD							; restore all flags
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP

	RET		20
ReadVal ENDP

WriteVal PROC


WriteVal ENDP


END main
