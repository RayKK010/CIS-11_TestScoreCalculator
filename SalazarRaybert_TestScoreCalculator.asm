;====================================================================
; Program: Test Score Calculator
; Author: Raybert Salazar
; Course: CIS 11
; Description:
; This LC-3 program prompts the user to input 5 test scores (3-digit format).
; For each score, it stores the value, calculates the sum, and classifies the
; corresponding letter grade. After all entries are received, it computes and
; displays the average, minimum, and maximum scores using subroutines.
;
; How to Run:
; - Load this file in the LC3 simulator (e.g., LC3Edit + LC3Tools).
; - Assemble the code.
; - Set the starting location to x2900.
; - Run the program and follow the prompts to enter five scores (000–100).
;====================================================================


;============================= MAIN PROGRAM =============================

; Initialize conversion constant for ASCII adjustment
.ORIG x2900

ADD R1, R1, #15
ADD R1, R1, #15
ADD R1, R1, #15
ADD R1, R1, #3
STI R1, CONVERT_ASCI

; Initialize index and sum
AND R1, R1, #0               ; R1 = loop counter = 0
ST  R1, IDX_SLOT            ; Initialize array index to 0
AND R5, R5, #0
;============================= INPUT LOOP ===============================

; Collects 5 numeric scores from user input
; For each score:
;   - Reads 3-digit number from console
;   - Stores score in array
;   - Adds to running sum
;   - Classifies score as A/B/C/D/F
;   - Displays corresponding letter
LOOP_START
        ADD R2, R1, #-5
        BRz END_LOOP                ; Exit after 5 iterations

        ; Prompt for numeric grade input
        JSR READ_3DIGIT_NUMBER
        LD  R3, INPUT_INTEGER       ; Load numeric score

        ST  R3, VAL_SLOT            ; Save to array value slot
        ST  R1, IDX_SLOT            ; Save index
        JSR STORE_BY_INDEX          ; Store score in SCORES array

		ADD R5, R5, R3 				; R5 = SUM SCORES

        ST  R3, GRADE_INPUT         ; Pass score to grading subroutine
        JSR CLASSIFY_GRADE          ; Get corresponding letter grade

        LEA R0, OUTPUT_LETTER_MSG
        PUTS
        LD  R0, LETTER_GRADE_OUT    ; Load resulting letter
        OUT                         ; Display letter grade
        ADD R1, R1, #1              ; Increment loop counter
        BR LOOP_START

;========================= POST PROCESSING ==============================

; After 5 scores entered:
;   - Computes average using integer division
;   - Displays average score
;   - Finds and displays max and min scores
END_LOOP
		AND R1, R1, #0
		ADD R1, R1, #5
		STI R1, Y
		STI R5, X
		JSR DIV
		LDI R1, XDIVY
		LD R6, STACK_BASE
		STI R1, NUMBER_TO_DISPLAY
		LEA R0, PROMPT_AVG_MSG
		PUTS
		JSR DISPLAY_NUMBER
        JSR FIND_MIN_MAX
        LD R2, RESULT_MAX
		LEA R0, PROMPT_MAX_MSG
		PUTS
		LD R6, STACK_BASE
		STI R2, NUMBER_TO_DISPLAY
		JSR DISPLAY_NUMBER
		LD R2, RESULT_MIN
		LEA R0, PROMPT_MIN_MSG
		PUTS
		LD R6, STACK_BASE
		STI R2, NUMBER_TO_DISPLAY
		JSR DISPLAY_NUMBER
		
		HALT 


;========================= MESSAGES & CONSTANTS ==========================
PROMPT_MAX_MSG      .STRINGZ "\nThe maximum grade was: "
PROMPT_MIN_MSG      .STRINGZ "\nThe minimum grade was: "
PROMPT_AVG_MSG      .STRINGZ "\nThe average grade was: "

;========================= DATA STORAGE LABELS ===========================
INPUT_INTEGER       .BLKW 1         ; Holds the 3-digit user input as an integer
VAL_SLOT            .BLKW 1         ; Temporary value storage for STORE_BY_INDEX
IDX_SLOT            .BLKW 1         ; Temporary index storage for STORE_BY_INDEX
SUM_SCORES			.BLKW 1

PROMPT              .STRINGZ "\nENTER GRADE (0-100) EX.(098, 100, ETC): \n"
OUTPUT_LETTER_MSG   .STRINGZ "Letter grade is: "
HUNDRED_CONST       .FILL #100
TEN_CONST           .FILL #10
ASCII_ZERO          .FILL #48       ; ASCII for '0'
;=======================================================
CONVERT_ASCI .FILL x3208
STACK_BASE   .FILL x3900

;----------------------- READ_3DIGIT_NUMBER ------------------------------
; Purpose: Read 3 ASCII digits and convert to a 3-digit integer (000–999)
; Input: Console characters
; Output: Integer stored in INPUT_INTEGER
; Uses: R0–R5, with values saved/restored at fixed memory slots

READ_3DIGIT_NUMBER
        ST   R0, SAVER0
        ST   R1, SAVER1
        ST   R2, SAVER2
        ST   R3, SAVER3
        ST   R4, SAVER4
        ST   R5, SAVER5

        LEA R0, PROMPT
        PUTS
		AND R1, R1, #0
		AND R2, R2, #0
		AND R3, R3, #0
        ;-------------------------------
        ; Read 3 characters (hundreds, tens, ones)
        ;-------------------------------
        GETC
        ADD R1, R0, #0        ; R1 = hundreds char

        GETC
        ADD R2, R0, #0        ; R2 = tens char

        GETC
        ADD R3, R0, #0        ; R3 = ones char

        ;-------------------------------
        ; Convert ASCII to numeric digits
        ; (Subtract 48 using 3 × 16)
        ;-------------------------------
        ADD R1, R1, #-16
        ADD R1, R1, #-16
        ADD R1, R1, #-16      ; R1 = hundreds digit

        ADD R2, R2, #-16
        ADD R2, R2, #-16
        ADD R2, R2, #-16      ; R2 = tens digit

        ADD R3, R3, #-16
        ADD R3, R3, #-16
        ADD R3, R3, #-16      ; R3 = ones digit

        ;-------------------------------
        ; Multiply hundreds digit by 100
        ; R5 = R1 × 100
        ;-------------------------------
        AND R5, R5, #0        ; R5 = 0
        LD R4, HUNDRED_CONST  ; R4 = 100


        HUNDRED_LOOP
                ADD R1, R1, #-1
                BRn HUNDRED_DONE   ; exit if R1 < 0
                ADD R5, R5, R4
                BR HUNDRED_LOOP

        HUNDRED_DONE
                ;-------------------------------
                ; Multiply tens digit by 10
                ; R5 += R2 × 10
                ;-------------------------------
                LD R4, TEN_CONST      ; R4 = 10

        TENS_LOOP
                        ADD R2, R2, #-1
                        BRn TENS_DONE
                ADD R5, R5, R4
                BR TENS_LOOP

        TENS_DONE

                ;-------------------------------
                ; Add ones digit
                ;-------------------------------
                ADD R5, R5, R3

                ;-------------------------------
                ; Store result into memory label
                ;-------------------------------
                ST R5, INPUT_INTEGER

                        ;-------------------------------------------------
                        ; Restore registers R0–R5, R7
                        ;-------------------------------------------------
                LD   R0, SAVER0
                LD   R1, SAVER1
                LD   R2, SAVER2
                LD   R3, SAVER3
                LD   R4, SAVER4
                LD   R5, SAVER5
                RET
NUMBER_TO_DISPLAY .FILL x3407
GRADE_INPUT         .BLKW 1         ; Holds input to be classified
X           .FILL   x3000
Y           .FILL   x3001
XY          .FILL   x3002
LETTER_GRADE_OUT    .BLKW 1         ; Holds ASCII output ('A'...'F')
XDIVY       .FILL   x3003
MODXY       .FILL   x3004
CONST_A             .FILL #65       ; ASCII 'A'
CONST_B             .FILL #66       ; ASCII 'B'
CONST_C             .FILL #67       ; ASCII 'C'
CONST_D             .FILL #68       ; ASCII 'D'
CONST_F             .FILL #70       ; ASCII 'F'
CONST_90            .FILL #90
CONST_80            .FILL #80
CONST_70            .FILL #70
CONST_60            .FILL #60

RESULT_MIN          .BLKW 1         ; Output: minimum score
RESULT_MAX          .BLKW 1         ; Output: maximum score

;----------------------- STORE_BY_INDEX ---------------------------------
; Purpose: Store a value at SCORES[index]
; Input: VAL_SLOT = value, IDX_SLOT = index
; Output: SCORES[index] = value
; Post: IDX_SLOT incremented
STORE_BY_INDEX
        ;── Save caller context ─────────────────────────────────────
        ST   R0,  SAVER0
        ST   R1,  SAVER1
        ST   R4,  SAVER4
        ;── Fetch parameters and array base ────────────────────────
        LD   R0,  VAL_SLOT        ; R0 ← value
        LD   R1,  IDX_SLOT        ; R1 ← index  i
        LD   R4,  ARRBASE         ; R4 ← &SCORES[0]

        ;── Compute address of SCORES[i] ────────────────────────────
        ADD  R4,  R4,  R1         ; R4 = base + i

        ;── Store value into array ─────────────────────────────────
        STR  R0,  R4,  #0         ; SCORES[i] ← value

        ;── Post-increment index and return it to caller ───────────
        ADD  R1,  R1,  #1
        ST   R1,  IDX_SLOT        ; IDX_SLOT ← i + 1

        ;── Restore caller context ─────────────────────────────────
        LD   R0,  SAVER0
        LD   R1,  SAVER1
        LD   R4,  SAVER4
        RET
;─────────────────────────────────────────────────────────────────────

NUM_SCORES          .FILL #10       ; Optional: Logical length of array
SCORES              .BLKW #10       ; Array to store all scores
ARRBASE             .FILL SCORES    ; Permanent pointer to array base


;----------------------- DIV ---------------------------------------------
; Purpose: Integer division R1 / R2 using repeated subtraction
; Input: X (dividend), Y (divisor)
; Output: XDIVY = quotient, MODXY = remainder
; Handles divide-by-zero cases

DIV
    STI R1, SAVE_R1
    STI R2, SAVE_R2
    STI R3, SAVE_R3
    STI R4, SAVE_R4
    STI R5, SAVE_R5
    LDI R1, X
    LDI R2, Y
    ADD R2, R2, #0
    BRnz QUIT_YZ
    ADD R1, R1, #0
    BRnz QUIT_XZ
    ADD R3, R1, #0
    AND R4, R4, #0
    NOT R2, R2
    ADD R2, R2, #1
	LOOP_DIV
		ADD R5, R3, #0
		ADD R3, R3, R2
		BRz QUIT_DIV_Z
		BRn QUIT_DIV_N
		ADD R4, R4, #1
		BR LOOP_DIV

	QUIT_DIV_Z
		ADD R4, R4, #1
		STI R3, MODXY
		STI R4, XDIVY
		BR RESTORE_DIV

	QUIT_DIV_N
		STI R5, MODXY
		STI R4, XDIVY
		BR RESTORE_DIV

	QUIT_YZ
		STI R2, MODXY
		STI R2, XDIVY
		BR RESTORE_DIV

	QUIT_XZ
		STI R1, MODXY
		STI R1, XDIVY

	RESTORE_DIV
		LDI R1, SAVE_R1
		LDI R2, SAVE_R2
		LDI R3, SAVE_R3
		LDI R4, SAVE_R4
		LDI R5, SAVE_R5
		RET
;----------------------- MULT --------------------------------------------
; Purpose: Integer multiplication using repeated addition
; Input: X and Y
; Output: XY = result of X * Y
MULT
    STI R1, SAVE_R1
    STI R2, SAVE_R2
    STI R3, SAVE_R3

    LDI R1, X
    LDI R2, Y
    LDI R3, X
    ADD R2, R2, #0
    BRn YNEG
    BRz YZERO

	LOOP_M
		ADD R2, R2, #-1
		BRz QUITM
		ADD R1, R1, R3
		BR LOOP_M

	QUITM
		STI R1, XY
		BR RESTORE_M

	YNEG
		NOT R2, R2
		ADD R2, R2, #1
	LOOPN_M
		ADD R2, R2, #-1
		BRz QUITM_N
		ADD R1, R1, R3
		BR LOOPN_M

	YZERO
		STI R2, XY
		BR RESTORE_M

	QUITM_N
		NOT R1, R1
		ADD R1, R1, #1
		STI R1, XY

	RESTORE_M
		LDI R1, SAVE_R1
		LDI R2, SAVE_R2
		LDI R3, SAVE_R3
		RET

;----------------------- DISPLAY_NUMBER ----------------------------------
; Purpose: Print integer as ASCII digits
; Input: NUMBER_TO_DISPLAY = value to print
; Uses stack-based digit extraction and PUSH/POP
;----------------------- DISPLA_NUMBER (STACK UTILITIES) ---------------------------------
; PUSH: Push value in R1 onto stack
; POP: Pop value from stack into R0
; ISEMPTY: Check if stack is empty
DISPLAY_NUMBER
    STI R7, GETBACKR7
    STI R4, SAVE_R4_D

    LDI R0, NUMBER_TO_DISPLAY
    ADD R0, R0, #0
    BRnp EXTRACT_LOOP
    LDI R0, CONVERT_ASCI
    OUT
    BR END_DISPLAY

	EXTRACT_LOOP
		STI R0, X
		AND R2, R2, #0
		ADD R2, R2, #10
		STI R2, Y
		JSR DIV

		LDI R0, XDIVY
		LDI R1, MODXY
		LDI R2, CONVERT_ASCI
		ADD R1, R1, R2
		JSR PUSH

		ADD R0, R0, #0
		BRp EXTRACT_LOOP

	DISPLAY_LOOP
		JSR ISEMPTY
		AND R1, R1, #0
		ADD R1, R0, #0
		BRnp END_DISPLAY

		JSR POP
		OUT
		BR DISPLAY_LOOP

	END_DISPLAY
		LDI R7, GETBACKR7
		LDI R4, SAVE_R4_D
		RET

	;--- Stack Support Utilities ---
	POP
		LDR R0, R6, #0
		ADD R6, R6, #1
		RET

	; Returns R0 = 1 if empty, R0 = 0 otherwise
	ISEMPTY
		AND R0, R0, #0
		LD R1, STACK_BASE
		NOT R1, R1
		ADD R1, R1, #1
		ADD R1, R1, R6
		BRz STACK_IS_EMPTY
		BRn STACK_NOT_EMPTY

	STACK_NOT_EMPTY
		AND R0, R0, #0
		BR ISEMPTY_DONE

	STACK_IS_EMPTY
		AND R0, R0, #0
		ADD R0, R0, #1
	ISEMPTY_DONE
		RET

	PUSH
		ADD R6, R6, #-1
		STR R1, R6, #0
		RET



SAVER0              .FILL #3800
SAVER1              .FILL #3801
SAVER2              .FILL #3802
SAVER3              .FILL #3803
SAVER4              .FILL #3804
SAVER5              .FILL #3805
SAVER6              .FILL #3806
SAVER7              .FILL #3807

;----------------------- FIND_MIN_MAX -----------------------------------
; Purpose: Iterate over SCORES array to find max and min values
; Output: RESULT_MAX and RESULT_MIN hold results
; Uses: Looping over 5 values using index R2
FIND_MIN_MAX

        ; Save caller context
        ST R0, SAVER0
        ST R1, SAVER1
        ST R2, SAVER2
        ST R3, SAVER3
        ST R6, SAVER6
        ST R7, SAVER7

        ; Load base address of SCORES
        LD R6, ARRBASE

        ; Initialize R4 and R5 with first array value
        LDR R4, R6, #0       ; R4 = min
        LDR R5, R6, #0       ; R5 = max

        AND R2, R2, #0       ; R2 = loop index = 0

        FIND_LOOP
                ADD R3, R2, #-5
                BRz DONE_FIND

                ; Load SCORES[i] into R1
                ADD R3, R2, #0
                LD R6, ARRBASE       ; R6 = base
                ADD R6, R6, R3       ; R6 points to SCORES[i]
                LDR R1, R6, #0       ; R1 = SCORES[i]

                ; Compare with max (R5)
                NOT R7, R5
                ADD R7, R7, #1
                ADD R7, R1, R7
                BRp UPDATE_MAX

        SKIP_MAX
                ; Compare with min (R4)
                NOT R7, R4
                ADD R7, R7, #1
                ADD R7, R1, R7
                BRn UPDATE_MIN

        SKIP_MIN
                ADD R2, R2, #1
                BR FIND_LOOP

        UPDATE_MAX
                ADD R5, R1, #0       ; R5 = new max
                BR SKIP_MAX

        UPDATE_MIN
                ADD R4, R1, #0       ; R4 = new min
                BR SKIP_MIN

        DONE_FIND
                ST R4, RESULT_MIN
                ST R5, RESULT_MAX

                ; Restore caller context
                LD R0, SAVER0
                LD R1, SAVER1
                LD R2, SAVER2
                LD R3, SAVER3
                LD R6, SAVER6
                LD R7, SAVER7
                RET

;----------------------- CLASSIFY_GRADE ---------------------------------
; Purpose: Convert numeric grade to ASCII letter ('A'–'F')
; Input: GRADE_INPUT = score (0–100)
; Output: LETTER_GRADE_OUT = ASCII letter code
; Logic: Conditional comparisons using BRzp
CLASSIFY_GRADE
        ST   R0, SAVER0
        ST   R1, SAVER1
        ST   R2, SAVER2

        LD   R0, GRADE_INPUT

        ;-------------------------------------------------
        ; Compare with 90: if score >= 90 → 'A'
        ;-------------------------------------------------
        LD   R1, CONST_90
        NOT  R1, R1
        ADD  R1, R1, #1        ; R1 = -90
        ADD  R1, R0, R1        ; R1 = score - 90
        BRzp ASSIGN_A

        ; Compare with 80: if score >= 80 → 'B'
        LD   R1, CONST_80
        NOT  R1, R1
        ADD  R1, R1, #1        ; R1 = -80
        ADD  R1, R0, R1        ; R1 = score - 80
        BRzp ASSIGN_B

        ; Compare with 70: if score >= 70 → 'C'
        LD   R1, CONST_70
        NOT  R1, R1
        ADD  R1, R1, #1        ; R1 = -70
        ADD  R1, R0, R1        ; R1 = score - 70
        BRzp ASSIGN_C

        ; Compare with 60: if score >= 60 → 'D'
        LD   R1, CONST_60
        NOT  R1, R1
        ADD  R1, R1, #1        ; R1 = -60
        ADD  R1, R0, R1        ; R1 = score - 60
        BRzp ASSIGN_D

        ; Otherwise → 'F'
        BR ASSIGN_F

        ASSIGN_A
                LD   R2, CONST_A
                ST   R2, LETTER_GRADE_OUT
                BR   RETURN_GRADE

        ASSIGN_B
                LD   R2, CONST_B
                ST   R2, LETTER_GRADE_OUT
                BR   RETURN_GRADE

        ASSIGN_C
                LD   R2, CONST_C
                ST   R2, LETTER_GRADE_OUT
                BR   RETURN_GRADE

        ASSIGN_D
                LD   R2, CONST_D
                ST   R2, LETTER_GRADE_OUT
                BR   RETURN_GRADE

        ASSIGN_F
                LD   R2, CONST_F
                ST   R2, LETTER_GRADE_OUT

        RETURN_GRADE
                ;-------------------------------------------------
                ; Restore caller's context
                ;-------------------------------------------------
                LD   R0, SAVER0
                LD   R1, SAVER1
                LD   R2, SAVER2
                RET

GETBACKR7    .FILL x3500
SAVE_R4_D    .FILL x3305

SAVE_R1 .FILL x3300
SAVE_R2 .FILL x3301
SAVE_R3 .FILL x3302
SAVE_R4 .FILL x3303
SAVE_R5 .FILL x3304

.END
