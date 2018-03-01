*-----------------------------------------------------------
* Title      :  Main 2
* Written by :  Smriti Dahal, Sean Hoffman, Cate Yochum
* Date       :  2/28/2018
* Description:  Second attempt at Disassembler
*-----------------------------------------------------------

*****Test Code*****
* Uncomment one at a time and execute to test each command
TESTCODE
    *EXG.L     d0,d1            *   not required, but valid opcode - output should still be DATA
    *LEA       startAddr,A1
    *jsr       outputData
    *NOP
    *RTS
    *NEG.W     $00004000

***** Equates Section *****

*****MASKS*****
bitMask       EQU  $1
twoBitMask    EQU  $0003
threeBitMask  EQU  $0007
nibbleMask    EQU  $000F
sixBitMask    EQU  $003F
byteMask      EQU  $00FF
   
***** OPCODE Categories (by first 4 bits) *****
bits0   EQU  $00
bits1   EQU  $01
bits2   EQU  $02
bits3   EQU  $03
bits4   EQU  $04
bits5   EQU  $05
bits6   EQU  $06
bits7   EQU  $07
bits8   EQU  $08
bits9   EQU  $09
bitsA   EQU  $0A
bitsB   EQU  $0B
bitsC   EQU  $0C
bitsD   EQU  $0D
bitsE   EQU  $0E

* ***** Code Section *****
      ORG $400
START:

* Get User Input (Starting and ending address)
                LEA         startAddr,A1  ;Load A0 with starting address
                MOVE.B      #14,D0        ;move 14 onto D0 to be used for trap 15
                TRAP        #15           ;display contents of A0 (starting address)

                LEA         endAddr,A1   ;Load A1 with ending addresses
                MOVE.B      #14,D0        ;move 14 onto D0 to be used for trap 15
                TRAP        #15           ;display contents of A1 (ending address)

* Save starting/ending addresses to registers (Starting - A0, Ending - A6)
* **** TEMP FOR TESTING
                LEA         $00000000,A0
                LEA         $00000002,A6
                * CLR $00000000             * to test bad opcode, uncomment
                * MOVE.W  #$7123,$00000000  * to test bad opcode, uncomment
* Check to see if starting address is greater than ending addresses

* Check to see if our current address pointer (A0) is the same as the ending address
loopStart       CMP.L       A0,A6   * Using a Long here to avoid aliasing issues - might need to change it

*      If yes, output decoded data to console
                BEQ         finalOutput

*      If not, read a word (opcode) into D7 to pass to decoder function
                MOVE.W  (A0)+, D7
*           Call opcode decoder function (return number of operands to process)
                BRA         opCodeDecode


*
opCodeDecode    * decoder function here
*           Move bits 12-15 (opcode) to D1
                MOVE.W  D7,D1           * Move opcode to D0 so we can manipulate it but save it in D7
                ROL.W   #4,D1           * Rotate word so first four bits are now in the LSB spots
                ANDI.L  #nibbleMask,D1  * Mask the data in D0 so you have just the 4 opcode bits to work with
*           Move bits 9-11 (destination operand register) to D2 
                MOVE.W  D7,D2               * Move opcode to D2 so we can manipulate it but save it in D7
                ROL.W   #7,D2               * Rotate word so destination register bits are now in the LSB spots
                ANDI.L  #threeBitMask,D2    * Isolate destination register bits (bits 9-11)
*           Move bits 6-8 (destination operand mode) to D3
                MOVE.W  D7,D3               * Move opcode to D3 so we can manipulate it but save it in D7
                ROR.W   #6,D3               * Rotate word so destination mode bits are now in the LSB spots
                ANDI.L  #threeBitMask,D3    * Isolate destination mode bits (bits 6-8)   
*           Move bits 3-5 (source operand mode) to D4
                MOVE.W  D7,D4               * Move opcode to D4 so we can manipulate it but save it in D7
                ROR.W   #3,D4               * Rotate word so destination mode bits are now in the LSB spots
                ANDI.L  #threeBitMask,D4    * Isolate destination mode bits (bits 3-5)  
*           Move bits 0-2 (source operand register) to D5                  
                MOVE.W  D7,D5               * Move opcode to D4 so we can manipulate it but save it in D7
                ANDI.L  #threeBitMask,D5    * Isolate destination mode bits (bits 0-2)

*           This whole section does a compare on the first 4 bits of the opcode and branches to the appropriate category                
                CMPI.B  #bits0,D1
                BEQ     branch0
                CMPI.B  #bits1,D1
                BEQ     branch1
                CMPI.B  #bits2,D1
                BEQ     branch2
                CMPI.B  #bits3,D1
                BEQ     branch3
                CMPI.B  #bits4,D1
                BEQ     branch4
                CMPI.B  #bits5,D1
                BEQ     branch5
                CMPI.B  #bits6,D1
                BEQ     branch6
                CMPI.B  #bits8,D1
                BEQ     branch8
                CMPI.B  #bits9,D1
                BEQ     branch9
                CMPI.B  #bitsB,D1
                BEQ     branchB
                CMPI.B  #bitsC,D1
                BEQ     branchC
                CMPI.B  #bitsD,D1
                BEQ     branchD
                CMPI.B  #bitsE,D1
                BEQ     branchE
                BRA     outputDATA

* Branch for opcodes starting with 0000 - 0 - BCLR, CMPI, ORI                
branch0         BRA     outputDATA


* Branch for opcodes starting with 0001 - 1 - MOVE.B
branch1         BRA     outputDATA


* Branch for opcodes starting with 0010 - 2 - MOVE.L, MOVEA.L
branch2         BRA     outputDATA


* Branch for opcodes starting with 0011 - 3 - MOVE.W, MOVEA.W
branch3         BRA     outputDATA


* Branch for opcodes starting with 0100 - 4 - LEA, MOVEM, NEG, NOP, JSR, RTS
branch4         CMPI.B  #bits7,D3 * If 111, then first check if it is LEA
                BEQ     branch47LEA     * checks to see if opcode is valid LEA opcode
notLEA          CMPI.B  #bits4,D2 
                BEQ     branch44        *not done
                CMPI.B  #bits6,D2
                BEQ     branch46        * not done
                CMPI.B  #bits2,D2
                BEQ     branch42        * Checks for NEG
                CMPI.B  #bits7,D2
                BEQ     branch47        * checks for NOP, JSR, and RTS
                * If not, it could be MOVEM or NEG
                BRA     outputDATA
                
* branch47 - 4 = opcode (first 4 bits) 7 = destination register bits (9-11)
branch47        CMPI.B  #bits2,D3           * See if the mode bits are 111, it is probably LEA (branch47LEA)
                BEQ     branch47JSR
                CMPI.B  #bits1,D3  
                BEQ     branch471
                BRA     outputDATA
* branch47JSR - - 4 = opcode (first 4 bits) 7 = destination register bits (9-11) JSR - could be JSR
branch47JSR         * check to see if it is one of six valid source operand modes (D4)
                CMPI.B  #bits0,D4        * is it mode 000?
                BEQ     b47JSRModeTrue
                CMPI.B  #bits1,D4        * is it mode 001?
                BEQ     b47JSRModeTrue
                CMPI.B  #bits2,D4        * is it mode 010?
                BEQ     b47JSRModeTrue
                CMPI.B  #bits3,D4        * is it mode 011?
                BEQ     b47JSRModeTrue
                CMPI.B  #bits4,D4        * is it mode 100?
                BEQ     b47JSRModeTrue
                CMPI.B  #bits7,D4        * is it mode 111?
                BEQ     b47JSRMode111True
                BRA     outputDATA          * it is not a valid opcode for LEA
b47JSRModeTrue  BRA     outputJSR        *if it is a valid mode, but not 111 then we can proceed to print
b47JSRMode111True   * if it is mode 111 check to see if it is one of 3 valid Xn values (source operand registers) (D5)
                        * if yes, it is a valid opcode for LEA. print it
                CMPI.B  #bits4,D5
                BEQ     outputJSR
                CMPI.B  #bits1,D5
                BEQ     outputJSR
                CMPI.B  #bits0,D5
                BEQ     outputJSR
                        * if not, branch to notLEA
                BRA     outputDATA
branch471       *check to make sure src mode is 110
                CMPI.B  #bits6,D4
                BEQ     branch471ModeTrue
                BRA     outputDATA  * not a valid 471 opcode     
                    *if it is, check src reg
                    *if not, output data
branch471ModeTrue CMPI.B #bits1,D5  * check to see if it is a valid NOP opcode
                BEQ     outputNOP   * if it is, outputNOP
                CMPI.B  #bits5,D5   * check to see if it is a valid RTS opcode
                BEQ     outputRTS   * if it is, outputRTS
                BRA     outputDATA  * it is an unknown code, output DATA
* branch47LEA - - 4 = opcode (first 4 bits) 7 = destination register bits (9-11) LEA - could be LEA
    * We need to check first if this is a valid opcode for LEA before moving to other possibilites
    * branch back to branch47 notLEA if it is not LEA
branch47LEA     
                    * check to see if it is one of six valid source operand modes (D4)
                CMPI.B  #bits0,D4        * is it mode 000?
                BEQ     b47LEAModeTrue
                CMPI.B  #bits1,D4        * is it mode 001?
                BEQ     b47LEAModeTrue
                CMPI.B  #bits2,D4        * is it mode 010?
                BEQ     b47LEAModeTrue
                CMPI.B  #bits3,D4        * is it mode 011?
                BEQ     b47LEAModeTrue
                CMPI.B  #bits4,D4        * is it mode 100?
                BEQ     b47LEAModeTrue
                CMPI.B  #bits7,D4        * is it mode 111?
                BEQ     b47LEAMode111True
                BRA     notLEA          * it is not a valid opcode for LEA
b47LEAModeTrue  BRA     outputLEA        *if it is a valid mode, but not 111 then we can proceed to print
b47LEAMode111True   * if it is mode 111 check to see if it is one of 3 valid Xn values (source operand registers) (D5)
                        * if yes, it is a valid opcode for LEA. print it
                CMPI.B  #bits4,D5
                BEQ     outputLEA
                CMPI.B  #bits1,D5
                BEQ     outputLEA
                CMPI.B  #bits0,D5
                BEQ     outputLEA
                        * if not, branch to notLEA
                BRA     notLEA

branch44        BRA     branch46
branch46                
                BRA     outputDATA
* branch42 - 4 = opcode (first 4 bits) 2 = destination register bits (9-11) - Checks for NEG
branch42        CMPI.B  #bits0,D3
                BEQ     b42NEG 
                CMPI.B  #bits1,D3
                BEQ     b42NEG
                CMPI.B  #bits2,D3
                BEQ     b42NEG
                BRA     outputDATA * If it makes it here, the size is invalid, bad opcode, print DATA
b42NEG
                    * check to see if it is one of six valid source operand modes (D4)
                CMPI.B  #bits0,D4        * is it mode 000?
                BEQ     b42NEGModeTrue
                CMPI.B  #bits1,D4        * is it mode 001?
                BEQ     b42NEGModeTrue
                CMPI.B  #bits2,D4        * is it mode 010?
                BEQ     b42NEGModeTrue
                CMPI.B  #bits3,D4        * is it mode 011?
                BEQ     b42NEGModeTrue
                CMPI.B  #bits4,D4        * is it mode 100?
                BEQ     b42NEGModeTrue
                CMPI.B  #bits7,D4        * is it mode 111?
                BEQ     b42NEGMode111True
                BRA     outputDATA          * it is not a valid opcode for NEG
b42NEGModeTrue  BRA     outputNEG        *if it is a valid mode, but not 111 then we can proceed to print
b42NEGMode111True   * if it is mode 111 check to see if it is one of 3 valid Xn values (source operand registers) (D5)
                        * if yes, it is a valid opcode for LEA. print it
                CMPI.B  #bits4,D5
                BEQ     outputNEG
                CMPI.B  #bits1,D5
                BEQ     outputNEG
                CMPI.B  #bits0,D5
                BEQ     outputNEG
                        * if not, bad opcode, outputDATA
                BRA    outputDATA
* Branch for opcodes starting with 0101 - 5 - SUBQ
branch5         BRA     outputDATA


* Branch for opcodes starting with 0110 - 6 - Bcc's
branch6         BRA     outputDATA


* Branch for opcodes starting with 1000 - 8 - DIVS, OR
branch8         BRA     outputDATA


* Branch for opcodes starting with 1001 - 9 - SUB
branch9         BRA     outputDATA


* Branch for opcodes starting with 1011 - B - CMP, EOR
branchB         BRA     outputDATA


* Branch for opcodes starting with 1100 - C - MULS
branchC         BRA     outputDATA


* Branch for opcodes starting with 1101 - D - ADD, ADDA
branchD         BRA     outputDATA


* Branch for opcodes starting with 1110 - E - ASR, ASL, LSR, LSL, ROL, ROR
branchE         BRA     outputDATA


      
*            Increment address by appropriate number of bytes

*            Loop back to Checking current address against ending address
                BRA         loopStart
* If the program encounters a word not in the specifications it outputs "DATA" to the console
outputDATA      LEA DATAString,A1   * Load DATAString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart

* output LEA
outputLEA       LEA LEAString,A1   * Load DISString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart   
* output JSR
outputJSR       LEA JSRString,A1   * Load DISString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart  
* output NOP
outputNOP       LEA NOPString,A1   * Load DISString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart
* output RTS
outputRTS       LEA RTSString,A1   * Load DISString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart
* output NEG
outputNEG       LEA NEGString,A1   * Load DISString into A1 for printing
                MOVE.B      #14,D0  * Set trap task to 14
                TRAP        #15     * display contents of A1 (DATAString)
                BRA         loopStart
   
finalOutput     * output function here
                SIMHALT

***** Data Section *****

   ORG    $0F000

*****IO TOOLS*****
cr  EQU $0D
lf  EQU $0A
newLine DC.B  cr,lf,0

*****IO Messages*****
startAddr   DC.B    'Please enter a starting address for the program: ',CR,LF,0
endAddr     DC.B    'Please enter an ending address for the program: ',CR,LF,0

******Op Code Output Strings*****
ADDAString  DC.B  'ADDA',0
ADDString   DC.B  'ADD',0
ASLString   DC.B  'ASL',0
ASRString   DC.B  'ASR',0
BCSString   DC.B  'BCS',0
BGEString   DC.B  'BGE',0
BLTString   DC.B  'BLT',0
BRAString   DC.B  'BRA',0
BVCString   DC.B  'BVC',0
CMPString   DC.B  'CMP',0
CMPIString  DC.B  'CMPI',0
DATAString  DC.B  'DATA',0
DISString   DC.B  'DIS',0
DIVSString  DC.B  'DIVS',0
EORString   DC.B  'EOR',0
JSRString   DC.B  'JSR',0
LEAString   DC.B  'LEA',0
LSLString   DC.B  'LSL',0
LSRString   DC.B  'LSR',0
MOVEAString DC.B  'MOVEA',0
MOVEMString DC.B  'MOVEM',0
MOVEString  DC.B  'MOVE',0
MULSString  DC.B  'MULS',0
NEGString   DC.B  'NEG',0
NOPString   DC.B  'NOP',0
ORIString   DC.B  'ORI',0
ORString    DC.B  'OR',0
ROLString   DC.B  'ROL',0
RORString   DC.B  'ROR',0
RTSString   DC.B  'RTS',0
SUBString   DC.B  'SUB',0
SUBQString  DC.B  'SUBQ',0

*****Size Output Strings*****
byteModeString  DC.B  '.B ',0
longModeString  DC.B  '.L ',0
wordModeString  DC.B  '.W ',0

*****Register Output Strings*****
addressRegString  DC.B  'A',0
dataRegString     DC.B  'D',0

*****Other EA Output Strings*****
comma             DC.B  ',',0
decrementString   DC.B  '-',0
immediateString   DC.B  '#',0
incrementString   DC.B  '+',0
parenLeft         DC.B  '(',0
parenRight        DC.B  ')',0

******OP CODES******
nopOpCode  DC.W  $4E71   *OP CODE FOR NOP*
rtsOpCode  DC.W  $4E75   *OP CODE FOR RTS*

*****SIZE CODES*****
byte  DC.B  $0
word  DC.B  $1
long  DC.B  $2



    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
