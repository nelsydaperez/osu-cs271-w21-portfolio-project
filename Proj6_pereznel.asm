TITLE Sum and average calculator using low level I/O procedures    (Proj6_pereznel.asm)

; Author: Nelsyda Perez
; Last Modified: 3/16/2021
; OSU email address: pereznel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: 3/14/2021
; Description:  A program that takes 10 32-bit signed integers as user inputted strings and 
;               uses low level I/O to print out the valid inputs, the sum of all valid inputs
;               and the average (rounded down) of all valid inputs.

INCLUDE Irvine32.inc


; -------------------------- 
; Macro definitions
; -------------------------- 
; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Prompts the user for a signed integer value that will be stored as a string. Will also output
; the number of characters inputted by the user.
; 
; Preconditions: Do not use EAX, ECX and EDX as arguments 
; 
; Receives: 
;   prompt            =  address of string containing the prompt for user input
;   userKeyboardInput =  address of string where user input will be stored
;   maximumCharacters =  maximum number of characters to be accepted as user input
;   numberOfBytesRead =  variable that will take the numberOfBytesRead
; 
; Returns: 
;   userKeyboardInput =  Address of user inputted string
;   numberOfBytesRead =  The number of BYTES read by the macro
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, userKeyboardInput:REQ, maximumCharacters:REQ, numberOfBytesRead:REQ
  
  ; Store used registers to preserve old values
    PUSH  EDX
    PUSH  ECX
    PUSH  EBX
    PUSH  EAX

  ; Prompt the user
    mDisplayString prompt

  ; Get user inputted string
    MOV   EDX, userKeyboardInput
    MOV   ECX, maximumCharacters
    CALL  ReadString

  ; Store number of BYTES read into the output
    MOV   EBX, numberOfBytesRead
    MOV   [EBX], EAX

  ; Restore original values of used registers
    POP   EAX
    POP   EBX
    POP   ECX
    POP   EDX

ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Displays the string stored in a specified memory location.
; 
; Preconditions: Do not use EDX as an argument.
; 
; Receives: 
;   inputString =  address of string to display
; 
; Returns: None
; ---------------------------------------------------------------------------------
mDisplayString MACRO inputString:REQ

  ; Preserve original values of any used registers
    PUSH  EDX

  ; Print the string stored in address in EDX
    MOV   EDX, inputString
    CALL  WriteString

  ; Restore original values of any used registers
    POP   EDX

ENDM


; -------------------------- 
; Constant definitions
; -------------------------- 
NUMBER_OF_ELEMENTS = 10  ; Number of valid inputs that the program will accept from the user
MAX_INPUT_SIZE = 13      ; Accepts 12 characters (plus 1 for the trailing 0 character at the end of a string)


; -------------------------- 
; Data variables
; -------------------------- 
.data
    
  ; Project title and program introductions/descriptions
    projectTitle        BYTE    "Sum and average calculator using low level I/O procedures, by Nelsyda Perez",10,10,0
    intro               BYTE    "Please enter 10 signed integers small enough to fit in a 32-bit register. "
                        BYTE    "I will print display all valid entries, their sum and average (rounded down).",10,10,0

  ; Error message
    error               BYTE    "ERROR: You did not enter an signed number or your number was too big.",10
                        BYTE    "Please try again: ",0

  ; Variables used to store user inputs
    userInputPrompt     BYTE      "Please enter a signed integer: ",0
    userInputString     BYTE      MAX_INPUT_SIZE  DUP(0)
    userInputNumber     SDWORD    0
    numberOfCharacters  DWORD     ?
    inputArray          SDWORD    NUMBER_OF_ELEMENTS  DUP(?)
    sumOfNumbers        SDWORD    0
    average             SDWORD    0

  ; User outputs
    numberListPrompt    BYTE      "You entered the following numbers:",10,0
    sumPrompt           BYTE      "The sum of these numbers is: ",0
    averagePrompt       BYTE      "The average of these numbers is: ",0
    outputString        BYTE      MAX_INPUT_SIZE  DUP(0)
    commaSeparator      BYTE      44,32,0

  ; Goodbye message
    goodbye             BYTE      "Your business is appreciated. Thank you and goodbye.",10,10,0


.code
main PROC

  ; -------------------------- 
  ; Displays program title and description for the end user
  ; -------------------------- 
    mDisplayString OFFSET projectTitle
    mDisplayString OFFSET intro


  ; -------------------------- 
  ; Gets 10 32-bit signed integers from the user using ReadVal
  ;     and updates the inputArray every time a valid entry has been
  ;     provided by the user. The program also updates the running sum of
  ;     all numbers.
  ; -------------------------- 
  ; Preserve original value of used registers
    PUSH  ECX
    PUSH  EDI

  ; Initialize counter and have EDI point to inputArray address
    MOV   ECX, NUMBER_OF_ELEMENTS
    MOV   EDI, OFFSET inputArray
  
  ; Loop to prompt user NUMBER_OF_ELEMENTS amount of times
  _getUserInputLoop:

    PUSH  OFFSET userInputPrompt     ; address of prompt asking for user input
    PUSH  OFFSET error               ; error message for invalid input
    PUSH  OFFSET userInputString     ; address where user inputted string is stored
    PUSH  MAX_INPUT_SIZE             ; maximum character limit for user inputted string
    PUSH  OFFSET numberOfCharacters  ; number of characters inputted by the user
    PUSH  EDI                        ; address where user inputted number will be stored on the array
    CALL  ReadVal

  ; Add current number to running sum
    MOV   EAX, [EDI]
    ADD   sumOfNumbers, EAX

    ADD   EDI, 4  ; Update EDI to point to next element in the inputArray

    LOOP  _getUserInputLoop

  ; Add a line break at the end of the user input
    CALL  Crlf

  ; Restore used registers
    POP   EDI
    POP   ECX


  ; -------------------------- 
  ; Calculate the average value of all user inputs using the CalculateAverage
  ;     procedure, the sum of all numbers and the number of elements we requested
  ;     from the user.
  ; -------------------------- 
    PUSH  sumOfNumbers
    PUSH  NUMBER_OF_ELEMENTS
    PUSH  OFFSET average
    CALL  CalculateAverage


  ; -------------------------- 
  ; Display a list of all valid numbers inputted by the user, separated by a comma
  ; -------------------------- 
  ; Display prompt
    mDisplayString OFFSET numberListPrompt
  
  ; Preserve original value of used registers
    PUSH  ECX
    PUSH  ESI

  ; Initialize counter and have ESI point to inputArray address
    MOV   ECX, NUMBER_OF_ELEMENTS
    MOV   ESI, OFFSET inputArray

  ; Loop through ESI and display every number in the input array
  _displayUserInputLoop:
    PUSH  [ESI]
    PUSH  OFFSET outputString  ; address where outputString will be stored
    CALL  WriteVal

    CMP   ECX, 1
    JE    _finished
    mDisplayString OFFSET commaSeparator  ; Adds a comma as a separator between numbers

    ADD   ESI, 4

  _finished:  ; Last element has been printed

    LOOP  _displayUserInputLoop

  ; Print out line breaks
    CALL  Crlf
    CALL  Crlf

  ; Restore used registers
    POP   ESI
    POP   ECX


  ; -------------------------- 
  ; Display the sum of all user-inputted numbers
  ; -------------------------- 
    mDisplayString OFFSET sumPrompt
    PUSH   sumOfNumbers
    PUSH   OFFSET outputString
    CALL   WriteVal

  ; Print out line breaks
    CALL   Crlf
    CALL   Crlf


  ; -------------------------- 
  ; Display the average of all user-inputted numbers
  ; -------------------------- 
    mDisplayString OFFSET averagePrompt
    PUSH   average
    PUSH   OFFSET outputString
    CALL   WriteVal

  ; Print out line breaks
    CALL   Crlf
    CALL   Crlf
    CALL   Crlf


  ; -------------------------- 
  ; Display goodbye message
  ; -------------------------- 
    mDisplayString OFFSET goodbye


	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------------------------------- 
; Name: ReadVal
;  
; Reads a string, converts the string into a 32-bit signed integer and stores the value into
; memory.
; 
; Preconditions: None
; 
; Postconditions: Modifies the Direction Flag
; 
; Receives:
;   [EBP+28] =  address of prompt asking user to make an input
;   [EBP+24] =  address of error message
;   [EBP+20] =  address of string inputted by the user
;   [EBP+16] =  maximum number of characters the user can input
;   [EBP+12] =  address of number of characters in user input string
;   [EBP+8]  =  address of user inputted number
;
; 
; Returns:
;   [EBP+8]  =  User input as a 32-bit signed integer stored at this address
;   
; --------------------------------------------------------------------------------- 
ReadVal PROC

  ; Preserve the position of EBP to allow for referencing of passed parameters
    PUSH  EBP
    MOV   EBP, ESP

  ; Push used registers to the stack in order to preserve their original values
    PUSH  ECX
    PUSH  ESI
    PUSH  EDX
    PUSH  EBX
    PUSH  EAX

  ; Get user input using the mGetString macro
    mGetString [EBP+28], [EBP+20], [EBP+16], [EBP+12]
    JMP   _firstRun
  
  _invalidInputOverflow:
    POP   EDX
    POP   EBX
    POP   EAX

  _invalidInput:
    POP   ECX
  ; Get user input using mGetString, if the input was invalid
    mGetString [EBP+24], [EBP+20], [EBP+16], [EBP+12]

  _firstRun:

  ; Initialize the counter variable
    MOV   EBX, [EBP+12]
    MOV   ECX, [EBX]
    PUSH  ECX

    MOV   ESI, [EBP+20]  ; Point ESI to the user inputted string address
    MOV   EDX, [EBP+8]   ; Point EDX to the address where the converted SDWORD will be stored
    MOV   EAX, 0         ; Clear the EAX register prior to using
    MOV   [EDX], EAX     ; Clear the stored at the address stored in EDX prior to using
    CLD                  ; Clear direction flag to increment ESI after every LODSB

  _loopThroughInputString:
    MOV   EAX, 0
    LODSB
    CMP   ECX, [ESP]
    JNE   _notFirstCharacter

    MOV   EBX, 0
    CMP   AL, '-'
    JE    _signed
    CMP   AL, '+'
    JNE   _notSigned  ; No sign was typed by the user. Assumed to be positive
  
  _signed:
    MOV   BL, AL
    JMP   _validInput

  _notSigned:
    MOV   BL, 0

  _notFirstCharacter:
    
    CMP   AL, 48
    JB    _invalidInput
    CMP   AL, 57
    JA    _invalidInput
    SUB   AL, 48
   
  ; Store number in user inputted number
    PUSH  EAX
    PUSH  EBX
    PUSH  EDX
    MOV   EAX, [EDX]
    MOV   EBX, 10
    IMUL  EBX

    JO    _invalidInputOverflow  ; If overflow occurs, the number was too big to be stored into a 32-bit register

    POP   EDX
    POP   EBX

    MOV   [EDX], EAX
    POP   EAX

  ; Check if the user provided a sign at the beginning
    CMP   BL, '-'
    JE    _negative
    CMP   BL, '+'

    ADD   [EDX], EAX
    JMP   _positive

  _negative:
    SUB   [EDX], EAX

  _positive:
  
    JO    _invalidInput  ; If overflow occurs, the number was too big to be stored into a 32-bit register

  _validInput:
    LOOP  _loopThroughInputString
    
  ; Restore original register states
    POP   ECX
    POP   EAX
    POP   EBX
    POP   EDX
    POP   ESI
    POP   ECX
    POP   EBP

  RET  24     ; return to main
ReadVal ENDP

; --------------------------------------------------------------------------------- 
; Name: WriteVal
;  
; Converts a signed 32-bit signed integer into a string of ASCII digits, then invokes the 
; mDisplayString to display the string to the output.
; 
; Preconditions: None
; 
; Postconditions: Modifies the Direction Flag
; 
; Receives:
;   [EBP+12] =  Value of the 32-bit signed integer that will be displayed
;   [EBP+8]  =  Address of output string that will be generated for the inputted number
; 
; Returns:  
;   [EBP+8]  =  String containing the value of the integer
; --------------------------------------------------------------------------------- 
WriteVal PROC

  ; Preserve the position of EBP to allow for referencing of passed parameters
    PUSH  EBP
    MOV   EBP, ESP

  ; Push used registers to the stack in order to preserve their original values
    PUSH  ECX
    PUSH  EDI
    PUSH  EDX
    PUSH  EBX
    PUSH  EAX

    MOV   EDI, [EBP+8]   ; Point EDI to the user inputted string address
    ADD   EDI, 11        ; Point EDI to the second-to-last character on the string
    STD                  ; EDI will move backwards

    MOV   ECX, 12        ; Maximum number of characters for a string containing the largest possible SWORD
    
    MOV   EAX, [EBP+12]

  ; Check if a negative sign is required
    MOV   EBX, 0
    CMP   EAX, 0
    JGE   _getCharacter
    MOV   BL, '-'
    NEG   EAX

  _getCharacter:
    PUSH  EBX       ; Store value of EBX (may contain a negative sign)

    MOV   EBX, 10   ; Divisor
    MOV   EDX, 0    ; Clear EDX before using DIV (remanider stored here)
    DIV   EBX       ; Divide EAX by 10

    POP   EBX       ; Restore value of EBX

    PUSH  EAX       ; Store EAX value (contains quotient)
    MOV   EAX, EDX  ; Store remainder (which contains the value of the digit in EAX)
    ADD   EAX, 48   ; Convert digit to its ASCII value
    STOSB           ; Store character in string within EDI

    POP   EAX       ; Restore EAX value from division

  ; Check to see if last digit has been accounted for (EAX = 0 if it is)
    CMP   EAX, 0
    JNE   _continue
    MOV   ECX, 1     ; Change counter to 1 to end the loop

  _continue:         ; Skip modifying the counter and continue looping through the string
    
    LOOP  _getCharacter

  ; Upon exit, EDI is pointing at an address 4 BYTES backwards from the beginning of the string

  ; Check if the number was negative
    CMP   BL, '-'
    JNE   _noSign
    MOV   AL, BL   ; Store negative sign to AL register
    STOSB          ; Add the negative sign to the string
  
  _noSign:         ; Jump provided to skip adding the sign if there is none

    ADD   EDI, 1   ; Move pointer back to the beginning of the string

  ; Display the generated string
    mDisplayString EDI

  ; Restore original register states
    POP   EAX
    POP   EBX
    POP   EDX
    POP   EDI
    POP   ECX
    POP   EBP

  RET  8       ; return to main
WriteVal ENDP


; --------------------------------------------------------------------------------- 
; Name: CalculateAverage
;  
; Calculates the average when given the sum of all numbers and the number of elements
; rounded down (floor).
; 
; Preconditions: None
; 
; Postconditions: None
; 
; Receives:
;   [EBP+16] =  The sum of all numbers
;   [EBP+12] =  The number of elements
;   [EBP+8]  =  Address of string where the average is stored
; 
; Returns:
;   [EBP+8]  =  The calculated average of all numbers
; --------------------------------------------------------------------------------- 
CalculateAverage PROC

    ; Preserve the position of EBP to allow for referencing of passed parameters
    PUSH  EBP
    MOV   EBP, ESP

  ; Push used registers to the stack in order to preserve their original values
    PUSH  EAX
    PUSH  EDX
    PUSH  EBX
    PUSH  EDI

    MOV   EDI, [EBP+8]   ; Store address of average output variable
    
    MOV   EAX, [EBP+16]  ; Dividend: Sum of all numbers
    MOV   EBX, [EBP+12]  ; Divisor: Total number of elements
    CDQ
    IDIV  EBX

    CMP   EDX, 0
    JGE   _noRoundingNegative

    DEC   EAX  

  _noRoundingNegative:

    MOV   [EDI], EAX  ; Store average in address stored in EDI

  ; Restore original register values
    POP   EDI
    POP   EBX
    POP   EDX
    POP   EAX
    POP   EBP

  RET   12             ; return to main
CalculateAverage ENDP

END main
