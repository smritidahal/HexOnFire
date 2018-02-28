*-----------------------------------------------------------
* Title      :  Main 1
* Written by :  Smriti Dahal, Sean Hoffman, Cate Yochum
* Date       :  2/24/2018
* Description:  First attempt at Disassembler
*-----------------------------------------------------------

*****Test Code*****
TESTCODE
  NOP

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
bits8   EQU  $08
bits9   EQU  $09
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
                CLR $00000000
                MOVE.W  #$7123,$00000000
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
*            Compare first 4 bits to each category of opcode
                MOVE.W  D7,D6           * Move opcode to D6 so we can manipulate it but save it in D7
                ROL.W   #4,D6           * Rotate word so first four bits are now in the LSB spots
                ANDI.L  #nibbleMask,D6  * Mask the data in D6 so you have just the 4 opcode bits to work with
*           This whole section does a compare on the first 4 bits of the opcode and branches to the appropriate category                
                CMPI.B  #bits0,D6
                BEQ     branch0
                CMPI.B  #bits1,D6
                BEQ     branch1
                CMPI.B  #bits2,D6
                BEQ     branch2
                CMPI.B  #bits3,D6
                BEQ     branch3
                CMPI.B  #bits4,D6
                BEQ     branch4
                CMPI.B  #bits5,D6
                BEQ     branch5
                CMPI.B  #bits6,D6
                BEQ     branch6
                CMPI.B  #bits8,D6
                BEQ     branch8
                CMPI.B  #bits9,D6
                BEQ     branch9
                CMPI.B  #bitsB,D6
                BEQ     branchB
                CMPI.B  #bitsC,D6
                BEQ     branchC
                CMPI.B  #bitsD,D6
                BEQ     branchD
                CMPI.B  #bitsE,D6
                BEQ     branchE
                BRA     outputDATA

* Branch for opcodes starting with 0000 - 0 - BCLR, CMPI, ORI                
branch0


* Branch for opcodes starting with 0001 - 1 - MOVE.B
branch1


* Branch for opcodes starting with 0010 - 2 - MOVE.L, MOVEA.L
branch2


* Branch for opcodes starting with 0011 - 3 - MOVE.W, MOVEA.W
branch3


* Branch for opcodes starting with 0100 - 4 - LEA, MOVEM, NEG, NOP, JSR, RTS
branch4


* Branch for opcodes starting with 0101 - 5 - SUBQ
branch5


* Branch for opcodes starting with 0110 - 6 - Bcc's
branch6


* Branch for opcodes starting with 1000 - 8 - DIVS, OR
branch8


* Branch for opcodes starting with 1001 - 9 - SUB
branch9


* Branch for opcodes starting with 1011 - B - CMP, EOR
branchB


* Branch for opcodes starting with 1100 - C - MULS
branchC


* Branch for opcodes starting with 1101 - D - ADD, ADDA
branchD


* Branch for opcodes starting with 1110 - E - ASR, ASL, LSR, LSL, ROL, ROR
branchE


      
*            Increment address by appropriate number of bytes

*            Loop back to Checking current address against ending address
                BRA         loopStart
* If the program encounters a word not in the specifications it outputs "DATA" to the console
outputDATA      LEA DATAString,A1   * Load DATAString into A1 for printing
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
