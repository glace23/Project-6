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
	MOV		ECX, 13
	CALL	ReadString
	MOV		length, EAX

	;	restore registers
	POP		EDX
	POP		ECX
	POP		EAX
ENDM


mDisplayString MACRO stringA
	;	preserve registers
	PUSH	EDX

	MOV		EDX, stringA
	CALL	WriteString

	;	restore registers
	POP		EDX
	
ENDM

	MAX = 2		; max numbers to input

.data
	; Main program
	programTitle	BYTE	"Designing low-level I/O procedures, ",0Ah
					BYTE	"Written by Scott Li",0
	intro_1			BYTE	"Please provide 10 signed decimal integers. [-2,147,483,648, +2,147,483,647]",0Ah
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0Ah
					BYTE	"After you have finished inputting the numbers I will display a list of the integers, their sum, and their average value.",0 
	prompt			BYTE	"Please enter an signed number: ",0
	numString		BYTE	14 DUP(?),0
	len				DWORD	?
	numArray		SDWORD	10 DUP(?)
	digit			DWORD	?
	error			BYTE	"ERROR! Invalid input, please try again!",0
	display			BYTE	13 DUP(?),0
	space			BYTE	" ",0
	list			BYTE	"You have entered the following numbers: ",0
	sumStr			BYTE	"The sum of all values entered is: ",0
	sum				SDWORD	?	
	avgStr			BYTE	"The average of all values entered is: ",0
	avg				SDWORD	?
	

	;	EC
	count			DWORD	1
	bracket			BYTE	") ",0
	runningTotal	BYTE	"Total of valid numbers entered: ",0
	total			DWORD	0


.code
main PROC
; (insert executable instructions here)

	;	introduction
	PUSH	OFFSET intro_1
	PUSH	OFFSET programTitle
	CALL	introduction

	;	ReadVal
	PUSH	total
	PUSH	OFFSET runningTotal
	PUSH	OFFSET display
	PUSH	MAX
	PUSH	OFFSET bracket
	PUSH	count
	PUSH	OFFSET error
	PUSH	OFFSET numArray
	PUSH	OFFSET len
	PUSH	OFFSET numString
	PUSH	OFFSET prompt
	CALL	ReadVal

	;	display array
	PUSH	OFFSET space
	PUSH	OFFSET list
	PUSH	MAX
	PUSH	OFFSET numArray
	PUSH	OFFSET display
	CALL	displayArray

	;	display sum
	PUSH	OFFSET sum
	PUSH	OFFSET sumStr
	PUSH	MAX
	PUSH	OFFSET numArray
	PUSH	OFFSET display
	CALL	displaySum

	;	display avg
	PUSH	sum
	PUSH	OFFSET avgStr
	PUSH	MAX
	PUSH	OFFSET avg
	PUSH	OFFSET display
	CALL	displayAvg

	Invoke	ExitProcess,0
main ENDP


introduction PROC
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString	[EBP + 8]
	CALL	CrLf
	mDisplayString	[EBP + 12]
	CALL	CrLf
	CALL	CrLf

	POP		EBP

	RET		8
introduction ENDP


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
;			[EBP + 28] 'count'	  (reference, output)
;			[EBP + 32] 'bracket'  (macro reference input)
;			[EBP + 36] 'max'
;			[EBP + 40] 'display'
;			[EBP + 44] 'runningTotal'
;			[EBP + 48] 'total'
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
	MOV		ECX, [EBP + 36]		;	MAX, outer loop counter
	MOV		EDI, [EBP + 20]		;	numarray

	; outer loop
_prompt:	
	; display counted lines
	PUSH	[EBP + 28]
	PUSH	[EBP + 40]
	CALL	WriteVal
	
	; display prompt
	mDisplayString	[EBP + 32]

	; mGetString prompt, numString, len
	mGetString	[EBP + 8], [EBP + 12], [EBP + 16]


	CLD
	MOV		EAX, 0
	MOV		ESI, [EBP + 12]		;	numString

	;	checks if user input has sign value infront
_checkSign:
	MOV		AL,	[ESI]
	CMP		AL, 45				; - sign
	JE		_setNegative
	CMP		AL, 43				; + sign
	JE		_setPositive

	MOV		EAX, [EBP + 16]			; len = 11
	CMP		EAX, 11				;	if len > 11, sign + digit, then error
	JG		_error

	OR		EAX, 1				; if no sign, assume positive, set sign to positive

	JMP		_checkVal

_setNegative:
	; len - 1, ignore sign
	MOV		EAX, [EBP + 16]			
	CMP		EAX, 11				;	if len > 11, sign + digit, then error
	JG		_error
	SUB		EAX, 1
	MOV		[EBP + 16], EAX

	MOV		EAX, 0
	ADD		ESI, 1				; increment to next byte after sign
	OR		EAX, -1				; set sign flag to 1

	JMP		_checkVal

_setPositive:
	; len - 1, ignore sign
	MOV		EAX, [EBP + 16]			; len = 11
	CMP		EAX, 11				;	if len > 11, sign + digit, then error
	JG		_error
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

		; preserve ESI and EDI and sign flag for Pos/Neg check and if not num 
		PUSH	ESI					
		PUSH	EDI
		PUSHFD

		MOV		ECX, [EBP + 16]		;	inner loop counter = len

		;	if number length = 10 and first digit > 2 then error
		MOV		EAX, 0
		MOV		AL, [ESI]			; move digit to AL
		CMP		ECX, 10
		JNE		_convert			; if len < 10
		CMP		AL, 52					
		JA		_notNum				; if first digit > 2

	; check and convert number from string to integer
	_convert:
		;	get digit at StringByte
		MOV		EAX, 0
		MOV		AL, [ESI]			; move digit to AL

		CMP		ECX, 10

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

	; if string is a number, add num to numArray, and modify exisiting numArray if needed
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
		LOOP	_convert

; restore registers and flags, and go on to determine sign
_restore:		
	;	if num is out of range then error
	MOV		EAX, [EDI]
	CMP		EAX, 2147483648				; if [EDI] <= 2,147,483,648 for both negative and positive
	JA		_notNum
	
	; restore EDI and ESI and sign flag
	POPFD						
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

_error:
	MOV		EAX, 0				; clear [EDI]
	MOV		[EDI], EAX


	mDisplayString	[EBP + 24]	; ERROR prompt
	CALL	CrLf
		
	; valid numbers inputted 
	mDisplayString	[EBP + 44]	; runningTotal
	PUSH	[EBP + 48]			; total
	PUSH	[EBP + 40]			; display
	CALL	WriteVal
	CALL	CrLf

	JMP	_prompt

; calculate value in position into negative
_negNum:
	MOV		EDX, [EDI]
	XOR		EAX, EAX
	SUB		EAX, EDX				; negate EAX from positive to negative, same as NOT EAX
	MOV		[EDI], EAX				; move negated EAX back to [EDI]

	JMP	_displayValid

; positive number already added, continue loop 
_posNum:
	MOV		EAX, [EDI]
	CMP		EAX, 2147483647				; [EDI] <= 2,147,483,647 for positive
	JA		_error
	JNAE	_displayValid

_displayValid:
	; increase line number, count++
	MOV		EAX, [EBP +28]			
	ADD		EAX, 1
	MOV		[EBP + 28], EAX

	; increase total number, total++
	MOV		EAX, [EBP +48]			
	ADD		EAX, 1
	MOV		[EBP + 48], EAX

	; display valid numbers inputted 
	mDisplayString	[EBP + 44]	; runningTotal
	PUSH	[EBP + 48]
	PUSH	[EBP + 40]
	CALL	WriteVal
	CALL	CrLf

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

	RET		44
ReadVal ENDP

;	[EBP + 8] 'display'
;	[EBP + 12] some number
WriteVal PROC
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

	;	clears exisiting value in display
	MOV		ECX, 11
	MOV		EDI, [EBP + 8]			; display
_clear_memory:
	MOV		EAX, 0
	MOV		[EDI], EAX
	ADD		EDI, 1
	LOOP	_clear_memory


	CLD
	MOV		EDI, [EBP + 8]			; display
	ADD		EDI, 11					; move to display's 11th BYTE

	MOV		EAX, [EBP + 12]			; some number
	CMP		EAX, 0					; check number is negative or not
	JL		_negative
	JGE		_positive

_negative:
	MOV		EDX, [EBP + 12]
	XOR		EAX, EAX
	SUB		EAX, EDX				; negate EAX from negative to positive, same as NOT EAX
	MOV		ECX, 0
	JMP		_divide

_positive:
	MOV		EAX, [EBP + 12]
	MOV		ECX, 0
	JMP		_divide

_divide:
	CDQ
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX

	MOV		ECX, [EDI]				;	preserve [EDI]
	ADD		EDX, 48					;	remainder + 48
	MOV		[EDI], EDX
	ADD		[EDI], ECX				;	add preserved value next to the new value bytes
	SUB		EDI, 1
	CMP		EAX, 0
	JE		_sign
	JMP		_divide

_sign:
	MOV		EAX, [EBP + 12]
	CMP		EAX, 0					; if num > 0, then write. num < 0 add sign
	JGE		_write
	MOV		ECX, [EDI]				;	preserve [EDI]
	MOV		EDX, 45					;	remainder + 48
	MOV		[EDI], EDX
	ADD		[EDI], ECX				;	add preserved value next to the new value bytes
	SUB		EDI, 1

_write:
	ADD		EDI, 1
	mDisplayString	EDI


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

	RET		8
WriteVal ENDP


displayArray PROC
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

	; initialize registers
	MOV		ESI, [EBP + 12]		; numArray	
	MOV		ECX, [EBP + 16]		; MAX

	mDisplayString	[EBP + 20]	; 
	CALL	CrLf

	; print numbers from array
_list:
	PUSH	[ESI]
	PUSH	[EBP + 8]
	CALL	WriteVal
	mDisplayString	[EBP + 24]	;
	ADD		ESI, 4
	LOOP	_list
	CALL	CrLf

	;	restore registers
	POPFD						; restore all flags
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP

	RET		20
displayArray ENDP

displaySum PROC
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

	; initialize registers
	MOV		ESI, [EBP + 12]		; numArray	
	MOV		ECX, [EBP + 16]		; MAX 
	MOV		EAX, 0
	MOV		EDI, [EBP + 24]

	mDisplayString	[EBP + 20]	; 
	CALL	CrLf

	; add numbers from array to EAX
_sum:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_sum

	; move EAX to sum
	MOV		[EDI], EAX

	PUSH	[EDI]				; sum
	PUSH	[EBP + 8]			; display
	CALL	WriteVal
	CALL	CrLf

	;	restore registers
	POPFD						; restore all flags
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP

	RET		20
displaySum ENDP

displayAvg PROC
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
	
	;	initialize registers
	MOV		EDI, [EBP + 12]		; avg 
		
	mDisplayString	[EBP + 20]	;
	CALL	CrLf

	;	get average by sum/MAX
	MOV		EAX, [EBP + 24]		; sum
	CDQ
	MOV		EBX, [EBP + 16]		; MAX
	IDIV	EBX

	;	move EAX to avg
	MOV		[EDI], EAX

	PUSH	[EDI]				; avg
	PUSH	[EBP + 8]			; display
	CALL	WriteVal

	;	restore registers
	POPFD						; restore all flags
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP

	RET		20
displayAvg ENDP

END main
