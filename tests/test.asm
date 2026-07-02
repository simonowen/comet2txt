               ORG  &8000
               DUMP $

               LIST ON
               LIST OFF

; Start of line comment
  ; indented comment
; Comment           ; nested comment

abc:           EQU  123;touching comment
dot.label:     ADD  A,B    ; 4 spaces with overhang that is hidden
maxlabellength:ADC  HL,BC
               EX   AF,AF'
             ; EX   DE,HL  ; longer nested comment after opcode
               AND  D
               BIT  0,E
               CALL C,dot.label
               CCF
               CP   H
               CPD
               CPDR
               CPI
               CPIR
               CPL
               DAA
               DEC  DE
               DEFB ","
               DEFM "test"
               DEFS 4
               DEFW 12345
               DI
               DJNZ maxlabellength
               EI
               EXX
               HALT
               LD   I,A
               LD   R,A
               IM   2
               IN   A,(C)
               INC  SP
               IND
               INDR
               INI
               INIR
               ADD  IX,IX
               JP   Z,$
               JR   NZ,$
               LDD
               LDDR
               LDI
               LDIR
               JP   M,$
               JP   P,$
 ** Error ** File not found
               MDAT "test.s"
               NEG
               NOP
               OR   (IY)
               OTDR
               OTIR
               OUT  (C),A
               OUTD
               OUTI
               RET  NC
               RET  PE
               RET  PO
               POP  AF
               PUSH AF
               RES  0,L
               RETI
               RETN
               RL   A
               RLA
               RLC  A
               RLCA
               RLD
               RR   A
               RRA
               RRC  A
               RRCA
               RRD
               RST  0
               SBC  A,A
               SCF
               SET  0,C
               SLA  A
               SLL  A
               SRA  A
               SRL  A
               SUB  A
               XOR  A
