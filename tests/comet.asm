
;COMET Z80 assembler workdate 30 November 1992 v1.8 time 23.03
;by Edwin Blink.

oflo:          EQU  16384
ofhi:          EQU  32768

textmark:      EQU  &AF         ;sourcefile marker in palotab
assmark:       EQU  &AC         ;assembler marker in palotab

               ORG  &9039
               DUMP $

relocate:      LD   HL,&511F
freesearch:    LD   A,(HL)
               AND  A
               JR   Z,free
               DEC  L
               JR   NZ,freesearch
nofree:        RST  8
               DEFB 1
free:
               DI
               IN   A,(250)
               EX   AF,AF'
               LD   A,L
               LD   (asspage-oflo),A
               DEC  A
               OUT  (250),A
               LD   HL,start
               LD   DE,start-oflo
               LD   BC,length
               LDIR
               LD   (temp2-ofhi),A
               LD   HL,temp1-ofhi
               SUB  (HL)
               LD   (HL),A
               EX   AF,AF'
               OUT  (250),A
               EI
fontcomp:      LD   HL,20880         ;compress font to UDG " "
               LD   DE,&BA00         ;start of expanded font
               LD   A,96             ;96 chrs
cmpchr:        EX   AF,AF'
               LD   B,8              ;8 rows a chr
cmpbyte:       LD   A,(DE)           ;bits 6,4,2,0 of (DE) to
               INC  DE               ;high nibble of C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               LD   A,(DE)           ;bits 6,4,2,0 of (DE) to
               INC  DE               ;low nibble of C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               RLA
               RLA
               RL   C
               LD   (HL),C
               INC  HL              ;next row
               DJNZ cmpbyte
               EX   AF,AF'          ;next chr
               DEC  A
               JR   NZ,cmpchr
               RET
start:
               LD   A,254       ;print menu
               CALL &0112
               LD   A,16        ;pen 2
               RST  16
               LD   A,2
               RST  16
               LD   A,1         ;Set FATPIX temp
               LD   (&5A4D),A
               LD   HL,graptab  ;square table
drawsquare:    LD   C,(HL)      ;get pixel coord
               INC  HL
               LD   B,(HL)
               LD   A,B         ;done if coords are 0,0
               OR   C
               JR   Z,printmenu
               INC  HL          ;point to H len
               PUSH BC          ;plot pixel
               PUSH HL
               CALL &0139
               POP  HL
               POP  BC
               LD   A,C       ;add length to obtain TopRgt coord
               ADD  (HL)
               LD   C,A
               INC  HL         ;point to V len
               CALL drawline
               LD   A,B       ;add lenght to obtain BotRgt coord
               ADD  (HL)
               LD   B,A
               DEC  HL         ;point to H len
               CALL drawline
               LD   A,C       ;sub length to obtain BotLft coord
               SUB  (HL)
               LD   C,A
               INC  HL        ;point to V len
               CALL drawline
               LD   A,B       ;sub length to obtain TopLft coord
               SUB  (HL)
               LD   B,A
               INC  HL        ;point to next square data
               CALL drawline
               JR   drawsquare
drawline:      PUSH BC        ;save coords and data pointer
               PUSH HL
               CALL &013F     ;JP table DrawTo
               POP  HL
               POP  BC
               RET

printmenu:     LD   DE,startmess
               LD   BC,endmess-startmess
               JP   &0013

graptab:       DEFB 0,4,255,15       ;square tab x,y,l,d
               DEFB 2,6,251,11
               DEFB 48,36,103,103
               DEFB 50,38,99,99
               DEFB 164,36,87,47
               DEFB 166,38,83,43
               DEFB 164,92,87,47
               DEFB 166,94,83,43
               DEFB 0,164,255,15
               DEFB 2,166,251,11
               DEFB 0,0             ;end marker

startmess:     DEFB 16,3,22,1,9
               DEFM "Drive "
               DEFB 22,5,14
               DEFM "B Go to Basic"
               DEFB 22,5,43
               DEFM "COMET Z80 assembler"
               DEFB 22,6,14
               DEFM "C Change directory"
               DEFB 22,6,47
               DEFM "Version 1.8"
               DEFB 22,7,14
               DEFM "D Detailed directory"
               DEFB 22,7,48
               DEFM "written"
               DEFB 22,8,14
               DEFM "E Erase file"
               DEFB 22,8,50
               DEFM "by"
               DEFB 22,9,14
               DEFM "L Load sourcefile"
               DEFB 22,9,46
               DEFM "Edwin Blink"
               DEFB 22,10,14
               DEFM "M Merge sourcefile"
               DEFB 22,11,14
               DEFM "S Save sourcefile"
               DEFB 22,12,14
               DEFM "O Save objectcode"
               DEFB 22,12,43
               DEFM "Device :"
               DEFB 22,13,14
               DEFM "N Select new device"
               DEFB 22,13,43
               DEFM "File   :"
               DEFB 22,14,14
               DEFM "R Return to editor"
               DEFB 22,14,43
               DEFM "Length :"
               DEFB 22,15,14
               DEFM "Q Exit and Re-boot"
               DEFB 22,15,43
               DEFM "Free   :"
               DEFB 22,16,43
               DEFM "Symbols:"
               DEFB 22,21,16
               DEFM "  Copyright 1992 by Revelation"
endmess:       EQU  $
filehead:
               LD   DE,&4B00         ;start of uifa
               PUSH DE
               POP  IX
               LD   HL,filename      ;move file name
               LD   BC,15
               LDIR
               RST  8                ;get header from disk
               DEFB 129              ;hookcode HGTHD
               RET
filename:      DEFB 19               ;type code
               DEFM "No File       " ;name

palettetab:    DEFB 0,0,17,85,34,34,127,127;2 bytes a colour

removeswaps:   DI                       ;remove swap markers
               IN   A,(250)          ;ie bit 7 of the line len
               EX   AF,AF'
               LD   A,(startp-oflo)
               OR   32
               OUT  (250),A
               LD   HL,(starto-oflo)
               LD   B,0
removloop:     RES  7,(HL)
               LD   A,(HL)
               AND  A
               JR   Z,removend
               LD   C,A
               ADD  HL,BC
               BIT  6,H
               JR   Z,removloop
               RES  6,H
               IN   A,(250)
               INC  A
               OUT  (250),A
               JR   removloop
removend:      EX   AF,AF'
               OUT  (250),A
               EI
               RET

removeswapcom: CALL removeswaps
               DEFB 1
execret:       POP  HL               ;drop exec rout
               POP  HL
mainentry:     LD   HL,&0214         ;set repper & repdel
               LD   (23561),HL
               LD   A,255
               LD   (&5B41),A        ;disable ESC key
               LD   A,251            ;251 CTRL DEL
               LD   (22966),A
               DEC  A                ;250 SYM TAB
               LD   (22906),A
               LD   A,168            ;168 SYM C
               LD   (22936),A
               LD   A,165            ;SYN I
               LD   (22940),A
               DEC  A                ;SYM N
               LD   (22929),A
               LD   A,130            ;SYM E
               LD   (22943),A
               LD   A,148            ;SYM S
               LD   (22953),A
               LD   HL,palettetab
               LD   E,0
paletteloop:   LD   A,255
               LD   C,(HL)
               INC  HL
               LD   B,(HL)
               INC  HL
               PUSH DE
               PUSH HL
               CALL &0154
               POP  HL
               POP  DE
               INC  E
               BIT  2,E
               JR   Z,paletteloop
               LD   HL,(asspage-oflo)
               LD   H,&51            ;set marker in alloct
               LD   (HL),assmark
               LD   A,251            ;open bytes channel
               CALL &0112
               DI
               IN   A,(250)          ;save lomem temporary
warmflag:      AND  A                ;cp a/and a warm/cold entry
               EX   AF,AF'
               IN   A,(252)          ;select screen at lomem
               AND  31
               OUT  (250),A
               LD   HL,&A000         ;move editor to screen page
               LD   DE,&6000         ;2. last 8K
               LD   BC,&2000
               LDIR
               JP   editentry-32768  ;continue in lomem
mequexit:      EX   AF,AF'           ;return to exit BC = 0 menu
               OUT  (250),A
               POP  BC
               LD   A,191            ; set warm re-entry (CP A)
               LD   (warmflag),A
               EI
               LD   A,C              ;BC=command char-65
               CP   25               ;test for remove swap
               JP   Z,removeswapcom  ;markers command
               AND  A                ;or 0 for execute
               RET  NZ
               LD   HL,&C9FB         ;stack  POP AF
               PUSH HL               ;       OUT (FB),A
               LD   HL,&D3F1         ;       RET
               PUSH HL
               LD   HL,0             ;stack SP (re-entry addr)
               ADD  HL,SP
               PUSH HL
               LD   HL,execret       ;re-entry
               EX   (SP),HL          ;stack execret gain SP
               LD   A,(asspage-oflo)
               PUSH AF               ;stack asspag
               PUSH HL               ;stack retaddr
               LD   A,(temp1-oflo)   ;fetch page offset of address
               LD   HL,(tempo1-oflo)
               JP   &005C            ;execute

;=== the assembler =============================================

               ORG  $+&4000          ;assembler runs at C000+

assentry:      LD   (asp),SP
               LD   IY,asflag
               LD   HL,0
               LD   (asflag),HL      ;reset asflag & errcount
               LD   (bytecount),HL   ;reset number of bytes
               LD   (labcount),HL    ;reset number of labels
               LD   A,(symstrtp)
               LD   HL,(symstarto)   ;clear symbol table
               LD   (symendp),A
               LD   (symendo),HL
               OR   32               ;set end marker
               OUT  (250),A
               LD   (HL),0
pass2:         XOR  A                ;pass two re-entry
               LD   H,A
               LD   L,A
               LD   (listflag),A
               LD   (findtype),A     ;reset include
               INC  A                ;HL=0 A=1
               LD   (dum),A          ;set dump to 32768
               LD   (dumo),HL
               LD   H,128            ;set org to 32768
               LD   (aspc),HL
               LD   A,(startp)       ;point to start of source
               LD   HL,(starto)
inclust:       CALL setcurpo
               OR   32               ;select source at lomem
               OUT  (250),A
               EX   DE,HL            ;DE=address
asnxtlin:
               LD   A,(asflag)       ;clear all flags exept the
               AND  1                ;pass flag
               LD   (asflag),A
               LD   HL,(aspc)        ;instruction addr = PC
               LD   (aspcl),HL
               LD   A,(DE)
               INC  DE
               AND  127
               CP   3                ;jp if blank line or end
               JP   C,aslinend
               LD   A,(DE)           ;fetch possible label length
               CP   15               ;jp if not a label
               JP   NC,ascom         ;else move label
               LD   HL,compbuff      ;start of label buff
               LD   (HL),A           ;store label length
               INC  DE
               INC  HL
               LD   B,A              ;B=length
asnxt:         LD   A,(DE)           ;char to buff
               LD   (HL),A
               INC  DE               ;next char
               INC  HL
               DJNZ asnxt            ;repeat until label moved
               CALL asfinlab         ;find the label
               JR   C,aslabmak       ;create if not found
               JR   Z,aslabs         ;found but not defined
               BIT  0,(IY+0)         ;test pass
               JR   NZ,aslabs        ;jp if it is pass1
               EXX                     ;retore registers
               LD   A,C              ;restore lomem
               OUT  (250),A
               JP   ermullab         ;error

aslabs:        IN   A,(250)
               INC  A
               RES  6,D
               JR   aslabset

aslabmak:      LD   HL,(endo)        ;test if room for another
               LD   BC,18            ;label.
               ADD  HL,BC
               LD   A,(symendp)
               LD   C,A
               LD   DE,(symendo)     ;CDE=end of symbols
               LD   A,(endp)
               CALL adjustpo         ;adjust AHL
               CALL testpo           ;AHL<CDE ?
               EXX
               JP   NC,eroutsym      ;error if not
               EXX
               EX   DE,HL            ;HL = symend
               LD   A,(compbuff)
               ADD  4                ;add 4 to length
               LD   E,A
               LD   D,0
               LD   A,C              ;AHL=symbol end
               LD   C,D              ;CDE=label length
               CALL subpo            ;get new symbol end
               LD   (symendp),A      ;store it
               LD   (symendo),HL
               OR   32                 ;select symbolpage
               OUT  (250),A
               LD   (HL),C           ;set endmarker
               LD   DE,(aspcl)
               INC  HL               ;last byte of symbol entry
               PUSH HL               ;save it
               LD   (HL),D           ;store origin as default
               INC  HL
               LD   (HL),E
               INC  HL
               LD   (HL),255         ;signal defined
               INC  HL
               EX   DE,HL
               LD   HL,compbuff
               LD   B,C
               LD   C,(HL)
               ADD  HL,BC            ;HL = last byte of label
               LD   B,C
               INC  B                ;move label chars
aslbm:         LD   A,(HL)
               LD   (DE),A
               INC  DE
               DEC  HL
               DJNZ aslbm
               LD   HL,(labcount)    ;increase number of labels
               INC  HL
               LD   (labcount),HL
               POP  DE               ;DE=last byte symbol entry
               IN   A,(250)
aslabset:      LD   (labpage),A      ;set labpage & offset EQU
               LD   (laboffs),DE
               SET  1,(IY+0)         ;signal label defined EQU
               EXX
               LD   A,C
               OUT  (250),A          ;retore lomem
ascom:         CALL checken          ;check end of line
               INC  DE
               ADD  A                ;bit 7 to carry
               JR   NC,ascer         ;error if no token
               CP   201              ;test last token-1
               JR   NC,ascer
               LD   B,0
               LD   C,A
               LD   HL,opcotab
               ADD  HL,BC
               SRL  C
               ADD  HL,BC            ;HL=HL+3*(token-128)
               LD   C,(HL)           ;fetch mask
               INC  HL
               LD   A,(HL)           ;fetch service address
               INC  HL
               LD   H,(HL)
               LD   L,A
               LD   A,(DE)           ;get char after the token
               CALL jumphl           ;go to service routine
               CALL checken          ;checkend
ascer:         JP   erbadsor         ;error if bad end
testen:        LD   A,(DE)           ;testend Z if propper end
               CP   32
               RET  Z
               CP   ";"
               RET  Z
               AND  A
               RET
checken:       CALL testen
               RET  NZ               ;return if not end of line
               LD   SP,(asp)
aslinend:      LD   A,247            ;test escape key
               IN   A,(249)
               AND  32
               JP   Z,erescape       ;exit if escape pressed
               LD   A,(printerflag)  ;do not print if there is
               AND  A                ;not list on or printer
               JR   Z,jnoprint       ;not connected
               LD   A,(listflag)     ;0 no print,1 prepare print
               AND  A                ;255 print line
jnoprint:      JR   Z,noprint
               BIT  0,(IY)           ;print only on pass2
               JR   Z,noprint
               SUB  2                ;prepare to print from next
               JR   NC,doprint       ;line
               LD   (listflag),A
               JR   noprint
doprint:       LD   HL,(currado)
               CALL explinehl        ;get line in linebuffer
               LD   HL,compbuff+22   ;clear number area
               LD   B,22
               DEC  L
               LD   (HL),32
               DJNZ $-3
               EX   DE,HL
               LD   HL,(aspcl)
               PUSH HL
HEXselDEC1:    CALL get10000         ;gethex/get 10000
               POP  HL
               EX   DE,HL
               LD   HL,(aspc)
               AND  A
               SBC  HL,DE
               EX   DE,HL            ;de=lenght of bytes
               IN   A,(250)
               EX   AF,AF'           ;save lomem
               BIT  7,(IY)
               JR   NZ,nobytes
               LD   A,E
               AND  A
               JR   Z,nobytes
               LD   A,(dum)
               LD   HL,(dumo)
               LD   C,D
               CALL subpo            ;AHL-CDE
               OR   32               ;select dump page
               OUT  (250),A
               LD   B,E              ;=number of bytes
               LD   DE,compbuff+6
morebytes:     LD   A,(HL)
               PUSH HL
               LD   H,C
               LD   L,A
               PUSH BC
HEXselDEC2:    CALL get100           ;store hex byte chars
               POP  BC
               POP  HL
               INC  HL
               INC  DE
               DJNZ morebytes
nobytes:       LD   H,B              ;LD HL,SP
               LD   L,B
               ADD  HL,SP
               LD   SP,(sproom)
               LD   A,31
               OUT  (250),A          ;ROM 0 RAM 1
               EX   AF,AF'           ;get lomem back
               PUSH AF               ;stack lomem
               PUSH IY               ;save asflag pointer
               LD   DE,compbuff
               LD   B,22
lprtbyte:      LD   A,(DE)
               RST  16
               INC  DE
               DJNZ lprtbyte
               CALL lprintlin
               POP  IY
               POP  AF
               OUT  (250),A          ;restore lomem
               LD   SP,HL
noprint:       LD   A,(findtype)
               AND  A
               JR   Z,noprint2
               LD   HL,(currado)
               LD   A,(HL)
               AND  127
               JR   Z,includoff
               LD   C,A
               LD   B,0
               ADD  HL,BC
               LD   (currado),HL
               EX   DE,HL
               JP   asnxtlin
includoff:     CALL includeswap
               XOR  A
               LD   (findtype),A
noprint2:      CALL findnext         ;next line
               EX   DE,HL            ;DE =line addres
               JP   NC,asnxtlin      ;jp if not at source end
               LD   A,(errcount)     ;get error status
               BIT  0,(IY+0)
               JR   NZ,report        ;jp if second pass done
               AND  A
               JR   NZ,report        ;jp if errors have occured in
               SET  0,(IY+0)         ;first pass else signal 2nd
               JP   pass2            ;pass and jp
report:        DEFB 1
erescape:      LD   A,128
               DEFB 1
eroutsym:      LD   A,64
               DEFB 1
eroutmem:      LD   A,32
               LD   (errcount),A
               LD   SP,(asp)
               LD   A,"E"
               LD   (findtype),A
               JP   assexit
aserhan:       POP  HL
               LD   SP,(asp)
               LD   A,(HL)
               INC  HL
               PUSH HL
               LD   DE,compbuff+1
               LD   HL,ermes
               LD   BC,13
               LDIR
               POP  HL
               LD   C,A
               LDIR
               ADD  15
               LD   (compbuff),A
               LD   C,A
               XOR  A
               LD   (DE),A
               CALL includeswap
               PUSH BC
               CALL makebcspace
               POP  BC
               JR   C,eroutmem
               CALL getcurpo
               OR   32
               OUT  (250),A
               EX   DE,HL
               LD   HL,compbuff
               LDIR
               EX   DE,HL
               AND  31
               CALL adjustpo
               CALL setcurpo
               CALL includeswap
               LD   A,(errcount)
               INC  A
               LD   (errcount),A
               BIT  0,(IY)
               JR   NZ,report
               CP   10
               JP   C,aslinend
               JR   report
ermes:         DEFM " ** Error ** "
erbadsor:      CALL aserhan
               DEFB 20
               DEFM "Bad source statement"
erbadexp:      CALL aserhan
               DEFB 14
               DEFM "Bad expression"
erintout:      CALL aserhan
               DEFB 19
               DEFM "Number out of range"
erinvdmp:      CALL aserhan
               DEFB 16
               DEFM "Bad dump address"
erlabnof:      CALL aserhan
               DEFB 13
               DEFM "No such label"
ermullab:      CALL aserhan
               DEFB 14
               DEFM "Multiple label"
erdisout:      CALL aserhan
               DEFB 25
               DEFM "Displacement out of range"
includeswap:   LD   A,(findtype)
               AND  A
               RET  Z
               CALL getcurpo
               EX   AF,AF'
               EX   DE,HL
               CALL tempcur
               OR   32
               OUT  (250),A
               EX   AF,AF'
               EX   DE,HL
               JP   settemp1
evasnxt:       INC  DE
evas:          PUSH HL
               CALL evab
               LD   A,H
               ADD  1
               CCF
               SBC  0
               LD   A,L
               POP  HL
               RET  Z
               JR   evadder
evabnxt:       INC  DE
evab:          LD   HL,0
               RES  2,(IY+0)
               PUSH BC
               LD   A,(DE)
               CP   "-"
               JR   Z,evasub
               CALL fetchnum
eval:          LD   A,(DE)
               CP   "+"
               JR   Z,evadd
               CP   "-"
               JR   Z,evasub
               CP   "*"
               JR   Z,evamul
               CP   "/"
               JR   Z,evadiv
               CP   "\"
               JR   Z,evamod
               POP  BC
               RET
evadd:         CALL fetchnxt
               ADD  HL,BC
               JR   NC,eval
evadder:       JP   erintout
evasub:        CALL fetchnxt
               LD   A,C
               SUB  L
               LD   L,A
               LD   A,B
               SBC  H
               LD   H,A
               JR   eval
evamul:        CALL fetchnxt
               PUSH DE
               EX   DE,HL
               LD   A,B
               LD   B,16
               LD   HL,0
evam1:         ADD  HL,HL
               RL   C
               RLA
               JR   NC,evam2
               ADD  HL,DE
evam2:         DJNZ evam1
               POP  DE
               JR   eval
evadiv:        CALL calcdimo
               JR   eval
evamod:        CALL calcdimo
               LD   H,B
               LD   L,C
               JR   eval
fetchnxt:      PUSH HL
               INC  DE
               CALL fetchnum
               POP  BC
               RET
fetchnum:      LD   A,(DE)
               CP   "$"
               JR   Z,pcnum
               CALL testalfa
               JR   C,getlab
               CALL getnum
               JR   C,evadder
               RET  Z
fetchnumer:    JP   erbadexp
getlab:        LD   HL,compbuff+1
               LD   B,14
getl1:         LD   (HL),A
               INC  HL
               INC  DE
               LD   A,(DE)
               CALL vallabchar
               JR   NC,getl2
               DJNZ getl1
               JR   fetchnumer
getl2:         LD   A,15
               SUB  B
               LD   (compbuff),A
               CALL asfinlab
               PUSH HL
               EXX
               POP  HL
               LD   A,C
               OUT  (250),A
               RET  NZ
               LD   HL,0
               SET  2,(IY+0)
               BIT  0,(IY+0)
               RET  Z
               JP   erlabnof
pcnum:         LD   HL,(aspcl)
               INC  DE
               RET                   ;on exit: flags:
asfinlab:      IN   A,(250)        ;C  Z  > not found
               LD   C,A            ;NC Z  > found not defined
               EXX                   ;NC NC > found and defined
               LD   A,(symstrtp)
               LD   HL,(symstarto) ;C  > HL end of symboltable
               DEC  A              ;NC > DE last byte of symbol
               OR   32
               OUT  (250),A
               SET  6,H
               LD   C,-4
               LD   DE,compbuff
aststlab:      LD   A,(HL)
               AND  A
               JR   Z,labexit
               LD   A,(DE)
               LD   B,(HL)
               CP   B
               JR   Z,aschklab
asnotmat:      LD   A,C
               SUB  B
               ADD  L
               LD   L,A
               JP   C,aststlab
               DEC  H
               BIT  6,H
               JP   NZ,aststlab
               SET  6,H
               IN   A,(250)
               DEC  A
               OUT  (250),A
               JR   aststlab
aschklab:      INC  E
               DEC  HL
               LD   A,(DE)
               CP   (HL)
               JR   NZ,aschknxt
               DJNZ aschklab
               DEC  HL
               LD   A,(HL)
               DEC  HL
               LD   E,(HL)
               DEC  HL
               BIT  6,H             ;jump forward if no page
               JR   NZ,aslabnop     ;boundary took place
               LD   D,A             ;else adjust lomem and HL
               IN   A,(250)
               DEC  A
               OUT  (250),A
               SET  6,H
               LD   A,D
aslabnop:      LD   D,(HL)
               EX   DE,HL
               AND  A
               RET
aschknxt:      LD   E,compbuff\256   ;start of searched label
               DEC  B
               JP   asnotmat
labexit:       SCF
               RET

opcotab:       DEFB 0                ;128 A
               DEFW erbadsor         ;
               DEFB 136              ;129 ADC
               DEFW serxdc
               DEFB 128              ;130 ADD
               DEFW seradd
               DEFB 0                ;131 AF
               DEFW erbadsor
               DEFB 160              ;132 AND
               DEFW serlog
               DEFB 0                ;133 B
               DEFW erbadsor
               DEFB 0                ;134 BC
               DEFW erbadsor
               DEFB 64               ;135 BIT
               DEFW serbit
               DEFB 0                ;136 C
               DEFW erbadsor
               DEFB 196              ;137 CALL
               DEFW sercal
               DEFB 63               ;138 CCF
               DEFW astorc
               DEFB 184              ;139 CP
               DEFW serlog
               DEFB 169              ;140 CPD
               DEFW nomoped
               DEFB 185              ;141 CPDR
               DEFW nomoped
               DEFB 161              ;142 CPI
               DEFW nomoped
               DEFB 177              ;143 CPIR
               DEFW nomoped
               DEFB 47               ;144 CPL
               DEFW astorc
               DEFB 0                ;145 D
               DEFW erbadsor
               DEFB 39               ;146 DAA
               DEFW astorc
               DEFB 0                ;147 DE
               DEFW erbadsor
               DEFB 5                ;148 DEC
               DEFW serxxc
               DEFB 0                ;149 DEFB
               DEFW dirdb
               DEFB 0                ;150 DEFM
               DEFW dirdm
               DEFB 0                ;151 DEFS
               DEFW dirds
               DEFB 0                ;152 DEFW
               DEFW dirdw
               DEFB 243              ;153 DI
               DEFW astorc
               DEFB 16               ;154 DJNZ
               DEFW serdjnz
               DEFB 0                ;155 DUMP
               DEFW dirdmp
               DEFB 0                ;156 E
               DEFW erbadsor
               DEFB 251              ;157 EI
               DEFW astorc
               DEFB 0                ;158 EQU
               DEFW direqu
               DEFB 8                ;159 EX
               DEFW serex
               DEFB 217              ;160 EXX
               DEFW astorc
               DEFB 0                ;161 H
               DEFW erbadsor
               DEFB 118              ;162 HALT
               DEFW astorc
               DEFB 0                ;163 HL
               DEFW erbadsor
               DEFB 0                ;164 I
               DEFW erbadsor
               DEFB 70               ;165 IM
               DEFW serim
               DEFB 64               ;166 IN
               DEFW serin
               DEFB 4                ;167 INC
               DEFW serinc
               DEFB 170              ;168 IND
               DEFW nomoped
               DEFB 186              ;169 INDR
               DEFW nomoped
               DEFB 162              ;170 INI
               DEFW nomoped
               DEFB 178              ;171 INIR
               DEFW nomoped
               DEFB 0                ;172 IX
               DEFW erbadsor
               DEFB 0                ;173 IY
               DEFW erbadsor
               DEFB 194              ;174 JP
               DEFW serjp
               DEFB 32               ;175 JR
               DEFW serjr
               DEFB 0                ;176 L
               DEFW erbadsor
               DEFB 64               ;177 LD
               DEFW serld
               DEFB 168              ;178 LDD
               DEFW nomoped
               DEFB 184              ;179 LDDR
               DEFW nomoped
               DEFB 160              ;180 LDI
               DEFW nomoped
               DEFB 176              ;181 LDIR
               DEFW nomoped
               DEFB 0                ;182 LIST
               DEFW dirlis
               DEFB 0                ;183 M
               DEFW erbadsor
               DEFB 0                ;184 MDAT
               DEFW dirmd
               DEFB 0                ;185 NC
               DEFW erbadsor
               DEFB 68               ;186 NEG
               DEFW nomoped
               DEFB 0                ;187 NOP
               DEFW astorc
               DEFB 0                ;188 NZ
               DEFW erbadsor
               DEFB 0                ;189 OFF
               DEFW erbadsor
               DEFB 0                ;190 ON
               DEFW erbadsor
               DEFB 176              ;191 OR
               DEFW serlog
               DEFB 0                ;192 ORG
               DEFW dirorg
               DEFB 187              ;193 OTDR
               DEFW nomoped
               DEFB 179              ;194 OTIR
               DEFW nomoped
               DEFB 65               ;195 OUT
               DEFW serout
               DEFB 171              ;196 OUTD
               DEFW nomoped
               DEFB 163              ;197 OUTI
               DEFW nomoped
               DEFB 0                ;198 P
               DEFW erbadsor
               DEFB 0                ;199 PE
               DEFW erbadsor
               DEFB 0                ;200 PO
               DEFW erbadsor
               DEFB 193              ;201 POP
               DEFW serpop
               DEFB 197              ;202 PUSH
               DEFW serpop
               DEFB 0                ;203 R
               DEFW erbadsor
               DEFB 128              ;204 RES
               DEFW serbit
               DEFB 192              ;205 RET
               DEFW serret
               DEFB 77               ;206 RETI
               DEFW nomoped
               DEFB 69               ;207 RETN
               DEFW nomoped
               DEFB 16               ;208 RL
               DEFW serrot
               DEFB 23               ;209 RLA
               DEFW astorc
               DEFB 0                ;210 RLC
               DEFW serrot
               DEFB 7                ;211 RLCA
               DEFW astorc
               DEFB 111              ;212 RLD
               DEFW nomoped
               DEFB 24               ;213 RR
               DEFW serrot
               DEFB 31               ;214 RRA
               DEFW astorc
               DEFB 8                ;215 RRC
               DEFW serrot
               DEFB 15               ;216 RRCA
               DEFW astorc
               DEFB 103              ;217 RRD
               DEFW nomoped
               DEFB 199              ;218 RST
               DEFW serrst
               DEFB 152              ;219 SBC
               DEFW serxdc
               DEFB 55               ;220 SCF
               DEFW astorc
               DEFB 192              ;221 SET
               DEFW serbit
               DEFB 32               ;222 SLA
               DEFW serrot
               DEFB 48               ;223 SLL
               DEFW serrot
               DEFB 0                ;224 SP
               DEFW erbadsor
               DEFB 40               ;225 SRA
               DEFW serrot
               DEFB 56               ;226 SRL
               DEFW serrot
               DEFB 144              ;227 SUB
               DEFW serlog
               DEFB 168              ;228 XOR
               DEFW serlog

dirlis:        SUB  189               ;OFF
               JP   C,erbadsor
               CP   2
               JP   NC,erbadsor
               LD   (listflag),A
               INC  DE
               RET
dirorg:        CALL evab             ;ORG nn
               LD   (aspc),HL
setnobytes:    SET  7,(IY)
               RET

direqu:        BIT  1,(IY+0)         ;label defined ?
               JR   Z,dmer           ;error if not
               CALL evab             ;get the value
               PUSH DE               ;save lineaddr
               EX   DE,HL            ;DE=value
               IN   A,(250)
               LD   C,A              ;save lomemtemp
               LD   A,(labpage)
               OUT  (250),A          ;select labelpage
               LD   HL,(laboffs)
               LD   (HL),D           ;give label the value
               INC  HL
               LD   (HL),E
               POP  DE               ;get line addr back
               INC  HL
               XOR  A
               BIT  2,(IY+0)         ;undef label used as value?
               JR   NZ,equcont       ;use 0 to signal undefined
               DEC  A                ;else FF as defined
equcont:       LD   (HL),A           ;store status
               LD   A,C
               OUT  (250),A          ;restore lomem
               RET

dirdb:         CALL evas             ;DEFB n,..,n
               CALL astora
               LD   A,(DE)
               CP   ","              ;More?
               JR   NZ,setnobytes    ;exit if not
               INC  DE
               JR   dirdb

dirdw:         CALL evab             ;DEFW nn,..,nn
               CALL astorhl
               LD   A,(DE)
               CP   ","
               JR   NZ,setnobytes
               INC  DE
               JR   dirdw

dirdm:         LD   A,(DE)           ;DEFM $
               CP   ""
               JR   NZ,dmer
               INC  DE
dmloop:        LD   A,(DE)
               INC  DE
               CP   ""
               JR   Z,setnobytes
               AND  A
               JR   Z,dmer
               CALL astora
               JR   dmloop
dmer:          JP   erbadsor

dirds:         CALL evab             ;DEFS 0<nn<16384
               LD   A,H
               CP   64
               JP   NC,erintout
               LD   B,H
               LD   C,L
               LD   HL,(aspc)
               ADD  HL,BC
               LD   (aspc),HL
               BIT  0,(IY+0)
               RET  Z                ;ret if on first pass
               LD   A,(dum)
               LD   HL,(dumo)
               ADD  HL,BC
               PUSH BC
               CALL adjustpo
               POP  BC
               LD   (dum),A
               LD   (dumo),HL
               LD   HL,(bytecount)
               ADD  HL,BC
               LD   (bytecount),HL
               JP   setnobytes

dirdmp:        CALL evab             ;DUMP [n],nn
               LD   A,(DE)
               CP   ","
               JR   NZ,dirdmpo
               INC  H                ;handle n,nn
               DEC  H
               JP   NZ,erinvdmp      ;error if page>255
               LD   A,L
               PUSH AF
               CALL evabnxt          ;get ofset
               LD   A,H
               CP   64
dirdmper:      JP   NC,erinvdmp      ;error if nn>16383
               POP  AF
               CP   32
               JR   NC,dirdmper      ;error if page>31
setdumpo:      LD   (dum),A
               LD   (dumo),HL
               RET
dirdmpo:       LD   A,H              ;hanle nn only
               RLCA
               RLCA
               AND  3                ;get page
               JR   Z,dirdmper       ;error if page=0
               DEC  A                ;get real page
               LD   (dum),A
               LD   A,H              ;get ofset
               AND  63
               LD   H,A
               LD   (dumo),HL
               RET

erinclud:      CALL aserhan
               DEFB 18
               DEFM "Include in include"
ertoola:       CALL aserhan
               DEFB 14
               DEFM "File too large"

include:       LD   A,(findtype)
               AND  A
               JR   NZ,erinclud
               LD   A,(DE)
               CALL fileheader
               LD   A,(linebuff+34)
               CP   2
               JR   NC,ertoola
               RRCA
               RRCA
               LD   H,A
               LD   A,(linebuff+36)
               AND  127
               OR   H
               CP   96
               JR   NC,ertoola
               IN   A,(250)
               PUSH AF
               LD   A,31
               OUT  (250),A
               PUSH DE
               LD   HL,0
               ADD  HL,SP
               LD   SP,(sproom)
               PUSH HL
               CALL prepare
               IN   A,(252)
               AND  31
               LD   B,A
               LD   HL,32768
               LD   A,(linebuff+34)
               LD   C,A
               LD   DE,(linebuff+35)
               RES  7,D
               CALL 20224
               CALL dier
               LD   SP,(asp)
               LD   A,255
               LD   (findtype),A
               CALL curtemp
               IN   A,(252)
               AND  31
               LD   HL,1
               JP   inclust

dirmd:         CALL fileheader
               LD   A,(linebuff+34)
               AND  3               ;keep bits 0 and 1 only
               RRCA
               RRCA
               LD   BC,(linebuff+35)
               RES  7,B             ;reset bit 15 (samdos)
               OR   B
               LD   B,A
               LD   HL,(aspc)
               ADD  HL,BC
               LD   (aspc),HL
               BIT  0,(IY)
               RET  Z
               LD   HL,(bytecount)
               ADD  HL,BC
               LD   (bytecount),HL
               IN   A,(250)
               PUSH AF
               LD   A,31
               OUT  (250),A
               PUSH DE
               LD   HL,0
               ADD  HL,SP
               LD   SP,(sproom)
               PUSH HL
               CALL prepare
               LD   A,(dum)
               LD   B,A
               LD   HL,(dumo)
               SET  7,H
               LD   A,(linebuff+34)
               LD   C,A
               LD   DE,(linebuff+35)
               RES  7,D
               CALL 20224
               CALL dier
               POP  HL
               LD   SP,HL
               POP  DE
               POP  AF
               OUT  (250),A
               LD   A,(dum)
               LD   BC,(dumo)
               LD   L,A
               LD   A,(linebuff+34)
               ADD  L
               LD   HL,(linebuff+35)
               RES  7,H              ;reset bit 15 (samdos)
               ADD  HL,BC
               CALL adjustpo
               CALL setdumpo
               JP   setnobytes

prepare:       LD   HL,loaddata
               LD   DE,20224
               LD   BC,15
               LDIR
               LD   HL,20224+13
               LD   (&5BC0),HL
               RET

loaddata:      IN   A,(251)
               PUSH AF
               LD   A,B
               OUT  (251),A
               RST  8
               DEFB 130
               EX   AF,AF'
               POP  AF
               OUT  (251),A
               EX   AF,AF'
               DI
               RET

fileheader:    CP   ""
               JR   NZ,hder
               LD   B,11
               LD   HL,linebuff
headchar:      INC  DE
               LD   A,(DE)
               CP   ""
               JR   Z,headcont
               AND  A
               JR   Z,hder
               LD   (HL),A
               INC  L
               DJNZ headchar
hder:          JP   erbadsor
headcont:      INC  DE
               CALL testen
               JR   NZ,hder
               DEC  B
               JR   Z,nospaces
               LD   (HL),32
               INC  L
               DJNZ $-3
nospaces:
               IN   A,(250)
               PUSH AF
               PUSH DE
               LD   A,31
               OUT  (250),A
               LD   HL,linebuff
               LD   DE,&4B00
               PUSH DE
               POP  IX
               LD   A,19
               LD   (DE),A
               INC  DE
               LD   C,10
               LDIR
               LD   HL,0
               ADD  HL,SP
               LD   SP,(sproom)
               PUSH HL
               LD   HL,dier
               LD   (&5BC0),HL
               RST  8
               DEFB 129
               LD   HL,&4B50
               LD   DE,linebuff
               LD   BC,48
               LDIR
               POP  HL
               LD   SP,HL
               POP  DE
               POP  AF
               OUT  (250),A
               RET

dier:          DI
               EX   AF,AF'
               LD   A,128
               OUT  (254),A
               ADD  A
               LD   (&5BC3),A
               LD   H,A
               LD   L,A
               LD   (&5BC0),HL
               EX   AF,AF'
               LD   IY,asflag
               AND  A
               RET  Z
               POP  HL
               POP  HL
               LD   SP,HL
               POP  DE
               EX   AF,AF'
               POP  AF
               OUT  (250),A
               EX   AF,AF'
               CP   91
               JR   Z,erdevice
               CP   94
               JR   Z,ertype
               CP   103
               JR   Z,erdevice
               CP   107
               JR   Z,erfilno
               CALL aserhan
               DEFB 10
               DEFM "Disk error"
erdevice:      CALL aserhan
               DEFB 14
               DEFM "Invalid device"
erfilno:       CALL aserhan
               DEFB 14
               DEFM "File not found"
ertype:        CALL aserhan
               DEFB 15
               DEFM "Wrong file type"

nxtsep:        INC  DE            ;skip next seperator
chksep:        LD   A,(DE)
               CP   ","
               JP   NZ,erbadsor   ;error if no seperator
               INC  DE
               LD   A,(DE)
               RET

expcc:         LD   B,0           ;conditions NZ,Z,NC,C,PO,et
               CP   188           ;NZ > 0    Z if found
               RET  Z             ;          NZ if not found
               INC  B
               CP   229           ;Z  > 1
               RET  Z
               INC  B
               CP   185           ;NC > 2
               RET  Z
               INC  B
               CP   136           ;C  > 3
               RET  Z
               INC  B
               CP   200           ;PO > 4
               RET  Z
               INC  B
               CP   199           ;PE > 5
               RET  Z
               INC  B
               CP   198           ;P  > 6
               RET  Z
               INC  B
               CP   183           ;M  > 7
               RET

expr:          LD   B,0           ;register B,C,D,E,H,L,A
               CP   133           ;B > 0
               RET  Z
               INC  B
               CP   136           ;C > 1
               RET  Z
               INC  B
               CP   145           ;D > 2
               RET  Z
               INC  B
               CP   156           ;E > 3
               RET  Z
               INC  B
               CP   161           ;H > 4
               RET  Z
               INC  B
               CP   176           ;L > 5
               RET  Z
               LD   B,7
               CP   128           ;A > 7
               RET
exps:          CALL expr          ;test reg
               RET  Z             ;ret if reg found
               CP   "("           ;test contents
               SCF
               CCF
               RET  NZ            ;exit with NZ NC =notfound
expm:          INC  DE
               LD   A,(DE)
               DEC  B             ;B was 7 for expr
               CALL expind
               JR   NZ,expex
               JR   C,exppos
clsbrk:        INC  DE
               LD   A,(DE)
               CP   ")"
               RET  Z
               JP   erbadsor
exppos:        INC  DE
               LD   A,(DE)
               LD   L,0
               CP   "+"
               JR   NZ,expneg
               CALL evasnxt
               CP   128
               JR   C,setdis
               JP   erdisout
expneg:        CP   "-"
               JR   NZ,brakcl
               CALL evasnxt
               CP   129
               JP   NC,erdisout
               NEG
setdis:        LD   L,A
               LD   A,(DE)
brakcl:        CP   ")"
               JP   NZ,erbadsor
expex:         SCF
               RET

expind:        CP   163           ;HL
               RET  Z
               CP   172           ;IX
               JR   NZ,getiy
               LD   A,221
               JR   astora
getiy:         CP   173           ;IY
               SCF
               RET  NZ
               LD   A,253
               JR   astora

exprr:         LD   B,0
               CP   134           ;BC
               RET  Z
               INC  B
               CP   147           ;DE
               RET  Z
               INC  B
               CALL expind        ;HL/IX/IY
               RET  Z
               INC  B
               CP   H             ;AF/SP
               RET

mixbc:         LD   A,B
               JR   mix1
mixbc8:        LD   A,B
               JR   mix8
mixbc16:       LD   A,B
               ADD  A
mix8:          ADD  A
               ADD  A
               ADD  A
mix1:          OR   C
               INC  DE
               JR   astora

evstnumb:      CALL evab
astorhl:       LD   A,L
               CALL astora
               LD   A,H
               JR   astora
astored:       LD   A,237
               JR   astora
nomoped:       LD   A,237
               CALL astora
astorc:        LD   A,C
astora:        EXX                  ;Swap to alternative reg
               LD   HL,(aspc)     ;inc PC
               INC  HL
astor1:        LD   (aspc),HL
               BIT  0,(IY+0)      ;exit if firstpass
               JR   Z,astor4
               LD   B,A           ;move byte to B
               IN   A,(250)
               LD   C,A           ;save lomem
               LD   A,(dum)
               OR   32            ;select dump page
               OUT  (250),A
               LD   HL,(dumo)     ;get dumpoffset
               LD   (HL),B        ;store the byte
               INC  HL
               BIT  6,H           ;test page boundery
               JP   Z,astor2
               RES  6,H           ;adjust offset and page
               SUB  31
               LD   (dum),A
astor2:        LD   (dumo),HL
               LD   HL,(bytecount)
               INC  HL            ;inc the number of bytes
astor3:        LD   (bytecount),HL
               LD   A,C
               OUT  (250),A       ;restore lomem
astor4:        EXX
               XOR  A             ;set Z C flags
               SCF
               RET

seradd:        LD   H,A           ;preset token for expss
               CALL expind        ;get HL IX IY
               JR   NZ,serxdc2    ;jump if other
               LD   C,9           ;ADD HL,ss
               CALL getss
               JR   Z,mixbc16
               JP   erbadsor
serxdc:        CP   163           ; HL
               JR   NZ,serxdc2
               LD   H,A           ;preset for expss
               CALL astored       ;store ED
               LD   A,66
               BIT  4,C
               JR   NZ,xdccont
               OR   8
xdccont:       LD   C,A
               CALL getss
               JP   Z,mixbc16
               JP   erbadsor
serxdc2:       CP   128           ;=A: ADD ADC SBC entry
               JR   NZ,serlog     ;jp if not token A
               INC  DE            ;test for ... A,s
               LD   A,(DE)
               DEC  DE
               CP   ","
               LD   A,(DE)
               JR   NZ,serlog     ;jp if it was ... A
               INC  DE            ;skip sep.
               INC  DE
               LD   A,(DE)        ;get s
serlog:        CALL exps
               JR   NZ,logcont    ;jump for ... num
               JP   NC,mixbc      ;jump for not indexed
               CALL mixbc
               JR   serlog1         ;store displacement
logcont:       JP   C,erbadsor
               CALL evas          ;fetch byte
               LD   L,A
               LD   A,C           ;store opcode for ... num
               OR   70
               CALL astora
serlog1:       LD   A,L           ;store byte
               JP   astora
getss:         CALL nxtsep
               LD   B,0
               CP   134           ;BC
               RET  Z
               INC  B
               CP   147           ;DE
               RET  Z
               INC  B
               CP   H             ;HL/IX/IY
               RET  Z
               INC  B
               CP   224           ;SP
               RET
serbit:        CALL evas
               CP   8
               JP   NC,erintout
               ADD  A
               ADD  A
               ADD  A
               OR   C
               LD   C,A
               CALL chksep
serrot:        CALL exps
               JR   NZ,xxcer
               JR   C,rotcont
               LD   A,203
               JR   serrot1
rotcont:       LD   A,203
               CALL astora
               LD   A,L
serrot1:       CALL astora
               JP   mixbc
sercal:        CALL expcc
               JR   Z,calcont
               LD   A,205
               CALL astora
calnum:        CALL evab
               JP   astorhl
calcont:       CALL mixbc8
               CALL chksep
               JR   calnum
serjp:         CALL expcc
               JR   Z,calcont
               CP   "("
               LD   A,195
               JR   NZ,calnum-3
               INC  DE
               LD   A,(DE)
               CALL expind
xxcer:         JP   NZ,erbadsor
               CALL clsbrk
               INC  DE
               LD   A,233
               JR   stodis
serinc:        CP   ""
               JP   Z,include
serxxc:        LD   H,224        ;SP
               CALL exprr
               JR   NZ,xxccont
               LD   A,3
               BIT  0,C
               JR   Z,xxcont
               OR   8
xxcont:        LD   C,A
               JP   mixbc16
xxccont:       CALL exps
               JR   NZ,xxcer
               JP   NC,mixbc8
               CALL mixbc8
               LD   A,L
stodis:        JP   astora
serjr:         CALL expcc
               JR   NZ,jronly
               BIT  2,B
               JR   NZ,xxcer
               CALL nxtsep
               DEC  DE
               CALL mixbc8
               JR   relcont
jronly:        LD   C,24
serdjnz:       CALL astorc
relcont:       CALL evab
               LD   BC,(aspc)
               SCF
               SBC  HL,BC
               LD   A,L
               RLA
               LD   A,H
               ADC  0
               LD   A,L
               JR   Z,stodis
               BIT  0,(IY+0)
               JR   Z,stodis
               JP   erdisout
serex:         CP   131          ;AF
               JR   Z,exaf
               CP   147
               JR   Z,exde
               CP   "("
               JR   NZ,exaf-3
               INC  DE
               LD   A,(DE)
               CP   224          ;SP
               JP   NZ,exaf-3
               CALL clsbrk
               CALL nxtsep
               CALL expind
               INC  DE
               LD   A,227
               JR   Z,stodis
               JP   erbadsor
exaf:          CALL nxtsep
               CP   131          ;AF
               JR   NZ,exaf-3
               INC  DE
               LD   A,(DE)
               CP   "'"
               JR   NZ,exaf-3
               INC  DE
               JP   astorc
exde:          CALL nxtsep
               CP   163          ;DE
               JR   NZ,exaf-3
               INC  DE
               LD   A,235
               JR   stodis
serim:         CALL evas
               CP   3
               JR   NC,exaf-3
               CP   1
               JR   C,imcont+2
               JR   Z,imcont-2
               ADD  7
               ADD  15
imcont:        OR   C
               LD   C,A
               JP   nomoped
serin:         CP   128          ;A
               JR   NZ,incont
               CALL nxtsep
               LD   A,(DE)
               JR   NZ,exaf-3
               INC  DE
               LD   A,(DE)
               CP   136          ;C
               LD   B,7
               JR   Z,incont2
               LD   A,219
inport:        CALL astora
               CALL evas
               CALL astora
               CALL clsbrk+1
               INC  DE
               RET
incont:        CALL expr
               JR   NZ,exaf-3
               CALL nxtsep
               CP   "("
               JR   NZ,exaf-3
               INC  DE
               LD   A,(DE)
               CP   136          ;C
               JR   NZ,exaf-3
incont2:       CALL clsbrk
               CALL astored
               JP   mixbc8
serout:        CP   "("
               JR   NZ,outer
               INC  DE
               LD   A,(DE)
               CP   136          ;C
               JR   Z,outcont
               LD   A,211
               CALL inport
               CALL chksep
               CP   128          ;A
               JR   NZ,outer
               INC  DE
               RET
outcont:       CALL clsbrk
               CALL nxtsep
               CALL expr
               JR   Z,incont2+3
outer:         JP   erbadsor
serpop:        LD   H,131        ;AF
               CALL exprr
               JP   Z,mixbc16
               JR   outer
serret:        CALL expcc
               JR   Z,incont2+6
               LD   A,201
               JP   astora
serrst:        CALL evas
               LD   B,A
               AND  C
               JR   NZ,outer
               DEC  DE
               JP   mixbc
serld:         CP   128          ;A
               JR   Z,lda
               JP   C,ldbrk
               CALL expr
               JR   Z,ldr
               LD   H,224        ;SP
               CALL exprr
               JR   Z,ldrr
               LD   C,71
               CP   164          ;I
               JR   Z,xreg
               CP   203          ;R
               JR   NZ,lder
               LD   C,79
xreg:          CALL nxtsep
               CP   128          ;A
regir:         INC  DE
               JP   Z,nomoped
lder:          JP   erbadsor
lda:           CALL nxtsep
               CALL exps
               JR   NZ,lda2
               LD   C,120
lda1:          JP   NC,mixbc
               CALL mixbc
               LD   A,L
               JP   astora
lda2:          JR   NC,lda3
               LD   C,10
               CP   134          ;BC
               JR   Z,ldbc
               CP   147          ;DE
               JR   NZ,ldan
               LD   C,26
ldbc:          CALL astorc
               CALL clsbrk
               INC  DE
               RET
ldan:          LD   A,58
               CALL astora
               CALL evstnumb
               CALL clsbrk+1
               INC  DE
               RET
lda3:          CP   164          ;I
               JR   NC,lda4
               LD   A,62
ldnums:        CALL astora
               CALL evas
               JP   astora
lda4:          LD   C,87
               JR   Z,regir
               CP   203          ;R
               LD   C,95
               JR   regir
ldr:           LD   A,B
               ADD  A
               ADD  A
               ADD  A
               OR   C
               LD   C,A
               CALL nxtsep
               CALL exps
               JR   Z,lda1
ldrnum:        LD   A,C
               XOR  70
               LD   C,A
               JR   ldnums
ldrr:          CALL nxtsep
               CP   "("
               JR   NZ,ldrr2
               INC  DE
               LD   A,B
               CP   2
               LD   A,42
               JR   Z,ldan+2
               CALL astored
               LD   C,75
               CALL mixbc16
               DEC  DE
               JR   ldan+5
ldrr2:         LD   L,A
               LD   A,B
               CP   3
               LD   A,L
               JR   NZ,ldrr3
               CALL expind
               JR   NZ,ldrr3
               LD   A,249
               INC  DE
               JP   astora
ldrr3:         LD   C,1
               DEC  DE
               CALL mixbc16
               JP   evstnumb
ldbrk:         CP   "("
               JR   NZ,brker
               CALL expm
               JR   NZ,ldbcde
               LD   C,112
               JR   C,ldbrk2
               CALL nxtsep
               CALL expr
               JR   NZ,ldrnum
               JP   mixbc
ldbrk2:        CALL nxtsep
               CALL expr
               JR   NZ,ldbrk3
               CALL mixbc
               LD   A,L
               JP   astora
ldbrk3:        LD   A,54
               CALL astora
               LD   A,L
               JP   ldnums
ldbcde:        CP   134          ;BC
               JR   NZ,ldbrk4
               LD   C,2
brkm:          CALL clsbrk
               CALL nxtsep
               CP   128          ;A
               INC  DE
               JP   Z,astorc
brker:         JP   erbadsor
ldbrk4:        CP   147          ;DE
               LD   C,18
               JR   Z,brkm
               CALL evab
               CALL clsbrk+1
               CALL nxtsep
               CP   128          ;A
               JR   NZ,ldbrk5
               LD   A,50
ldbrkhl:       CALL astora
               INC  DE
               JP   astorhl
ldbrk5:        PUSH HL
               LD   H,224        ;SP
               CALL exprr
               POP  HL
               JR   NZ,brker
               LD   A,B
               CP   2
               LD   A,34
               JR   Z,ldbrkhl
               CALL astored
               LD   C,67
               CALL mixbc16
               JP   astorhl

;******  Comet editor ******************************************

;Assemble: CTRL A and command A
;EX AF,AF' under CTRL E
;blockmarker under F2
;delete line under CTRL DELETE
;Execute command better checkend
;Editor line calculator and number conversion
;When command has a parameter the command needs not to be
;entered on a blank line, space after parameter is enough.
;Hex numbers are not tokenized if there are spaces inside number

comx:          AND  A            ;0 bytes free in editor
               JR   Z,comcer
               EX   DE,HL
               CALL getnum
               JR   C,comner
               LD   A,(DE)
               CP   ","
               JR   Z,pagofexec
               CP   " "
               JR   Z,comxadr
               AND  A
               JR   NZ,comcer
comxadr:       LD   A,1
               LD   (temp1),A
               JR   comxpo
pagofexec:     INC  DE
               INC  H
               DEC  H
               JR   NZ,comner
               LD   A,L
               CP   32
               JR   NC,comner
               LD   (temp1),A
               CALL getnum
               JR   C,comner
               LD   A,(DE)
               CP   " "
               JR   Z,comxpo
               AND  A
               JR   NZ,comcer
comxpo:        LD   (tempo1),HL
               LD   E,0            ;BC is 0 for execute
comm:          XOR  A              ;BC is command char-65
               LD   B,A
               LD   C,E
               POP  HL             ;drop command ret addr
               POP  HL             ;drop editor return addr
               LD   (comflag),A    ;clear command mode
               PUSH BC
               IN   A,(250)        ;maincode at 16384 to
               EX   AF,AF'
               LD   A,(asspage)
               DEC  A
               DI
               OUT  (250),A       ;move vars from editor to main
               LD   HL,listflag
               LD   DE,listflag-ofhi
               LD   BC,laboffs-listflag+1
               LDIR
               JP   comqcont-ofhi;switch HIMEM to maincode
comcer:        JP   comerror
comner:        JP   numerror
comqcont:      INC  A
               OUT  (251),A
               JP   mequexit
;For coldentry TEMP1/TEMP2 must hold workspace strt/end see main
editentry:     OUT  (251),A      ;called in lomem sel scr page
               JP   editentr1    ;continue in himem
editentr1:     EX   AF,AF'       ;get old lomem back and restore
               OUT  (250),A
               EI
               JR   Z,warmentry  ;NZ cold Z =warm entry
               CALL message
               CALL waitonkey
               CALL sourceinit
               JR   waitkey
warmentry:     CALL printpage
waitkey:       XOR  A            ;Editor main loop
wait1:         CALL cursor
               LD   HL,&5C3B
               LD   B,7          ;cursor toggle after 7 frames
wait2:         BIT  5,(HL)
               JR   NZ,key       ;go key
               HALT
               DJNZ wait2
               JR   wait1
cursor:        LD   HL,(scrpos)  ;toggle cursor A =printed flag
               LD   BC,&0380
               ADD  HL,BC
               EX   AF,AF'
               LD   A,(HL)
               XOR  63
               LD   (HL),A
               INC  L
               LD   A,(HL)
               XOR  252
               LD   (HL),A
               EX   AF,AF'
               CPL
               RET
key:           RES  5,(HL)        ;signal next key
               AND  A             ;remove cursor if visible
               CALL NZ,cursor
               LD   HL,200        ;perform a click
               LD   DE,5
               CALL &016F
               LD   A,(23560)     ;fetch the key
               LD   HL,waitkey    ;stack return address
               PUSH HL
               LD   (errorsp),SP
               LD   HL,(scrpos)
               CP   32
               JP   C,deletechar  ;all codes from 32 to 127 are
               CP   128           ;printed on the screen and are
               JR   C,prtchra     ;put in the line buffer
               CP   200
               JR   NZ,funk9       ;F8
               LD   A,"("
               JR   prtchra
funk9:         CP   201            ;F9
               JR   NZ,funk5
               LD   A,")"
               JR   prtchra
funk5:         CP   197            ;F5
               JR   NZ,funk6
               LD   A,"%"
               JR   prtchra
funk6:         CP   198            ;F6
               JR   NZ,insertspace
               LD   A,"&"
prtchra:       JP   printchar
insertspace:   CP   253            ;INV
               JR   NZ,righttab
               LD   (altflag),A
               EX   DE,HL
               LD   L,E
               SRL  L
               LD   H,linebuff/256
               LD   C,(HL)
               LD   A,32
insloop:       LD   (HL),A
               INC  L
               BIT  6,L
               JP   NZ,prtlinebuff
               LD   A,C
               LD   C,(HL)
               JR   insloop
righttab:      CP   252              ;TAB
               JR   NZ,lefttab
               LD   A,L
               CP   126
               RET  Z
               LD   HL,tabtable-1
nxttabpos1:    INC  HL
               CP   (HL)
               JR   NC,nxttabpos1
               LD   A,(HL)
settab:        LD   (scrpos),A
               RET
lefttab:       CP   250              ;SYM TAB
               JR   NZ,comkey
               CALL comfirst
               LD   C,A
               LD   HL,tabtable+5
nxttabpos2:    LD   A,(HL)
               DEC  HL
               CP   C
               JR   NC,nxttabpos2
               AND  A
               JR   NZ,settab
               LD   A,(comflag)
               AND  A
               JR   Z,settab
               LD   A,2
               JR   settab
comkey:        CALL commode
               CP   168
               JR   NZ,deleteline
               LD   A,L
               LD   (tabtemp),A
               CALL interline
               LD   A,255
               LD   (comflag),A
               JP   comline
deleteline:    CP   251             ;CTRL DEL  not com
               JR   NZ,insertline
               CALL removeline
               CALL lineaddr
               LD   D,H
               LD   E,L
               LD   BC,1024
               ADD  HL,BC
               LD   C,E
               LD   A,&DC
               SUB  D
               LD   B,A
               CALL NZ,ldi128
               LD   A,(scrpos+1)
               AND  124
               RRCA
               RRCA
               CPL
               ADD  24
               JR   Z,dellin
               LD   B,A
               CALL getcurpo
               PUSH AF
               PUSH HL
delnxt:        PUSH BC
               CALL nextline
               POP  BC
               JR   C,delcnt
               DJNZ delnxt
delcnt:        CALL getline
               POP  HL
               POP  AF
               CALL setcurpo
               LD   HL,&DC00
               CALL prtlinebuff+3
dellin:        JP   prtcurlin
insertline:    CP   195               ;F3  not com
               JR   NZ,insertblock
               CALL interline
               LD   HL,blankline
inslin:        CALL createline
               JP   C,ooferror
               CALL lineaddr
               LD   A,&DC
               SUB  H
               LD   B,A
               LD   C,L
               LD   HL,&DBFF
               LD   DE,&DFFF
               CALL NZ,ldd128
               CALL prtcurlin
               XOR  A
               JP   settab
insertblock:   CP   194              ;F2 not com
               JR   NZ,toppage
               CALL interline
               LD   HL,blockmarker
               JR   inslin
toppage:       CP   199              ;F7  not comm
               JR   NZ,pageup
               CALL interline
tppag:         LD   A,(startp)
               LD   HL,(starto)
               CALL setwinpo
pgexit:        JP   printpage
pageup:        CP   196              ;F4  not com
               JR   NZ,pagedown
               CALL interline
pgup:          CALL lastpage
               JR   pgexit
pagedown:      CP   193              ;F1  not com
               JR   NZ,botpage
               CALL interline
               CALL nextpage
               JR   pgexit
botpage:       CP   192              ;F0  not com
               JR   NZ,symboli
               CALL interline
               LD   A,(endp)
               LD   HL,(endo)
               CALL setwinpo
               JR   pgup
symboli:       CP   165           ;toggle insert mode not com
               JR   NZ,symboln
               LD   A,(insertflag)
               CPL
               LD   (insertflag),A
               RET
symboln:       CP   164            ;find next item not com
               JR   NZ,symbole
               CALL interline
               XOR  A
               JP   comf
symbole:       CP   130            ;insert EX AF,AF' not com
               JR   NZ,symbols
               LD   DE,exafaf
symel:         LD   A,(DE)
               PUSH DE
               CALL printchar
               POP  DE
               INC  DE
               LD   A,(DE)
               RLA
               JR   NC,symel
               RET
symbols:       CP   148
               RET  NZ
               CALL interline
               LD   A,(windowp)
               CALL getset
               LD   HL,(windowo)
               CALL setcurpo
               LD   A,(HL)
               AND  A
               JR   Z,symsend
               SET  7,(HL)
nomark:        CALL findnext
               JR   C,swapstart
testmark:      BIT  7,(HL)
               JR   Z,nomark
               LD   C,A
               LD   A,(windowp)
               CP   C
               JR   NZ,sympag
               LD   DE,(windowo)
               SBC  HL,DE
sympag:        CALL getcurpo
               JR   Z,samemark
               RES  7,(HL)
samemark:      CALL setwinpo
symsend:       CALL restore
               JP   printpage
swapstart:     LD   A,(startp)
               LD   HL,(starto)
               LD   B,A
               OR   32
               CALL selsetcurpo
               JR   testmark
deletechar:    CP   14             ;SYM DEL
               JR   NZ,linenter
               LD   (altflag),A
               EX   DE,HL
               LD   L,E
               SRL  L
               LD   H,linebuff/256
delchrloop:    INC  HL
               LD   A,(HL)
               BIT  6,L
               DEC  HL
               JR   NZ,delchrcont
               LD   (HL),A
               INC  HL
               JR   delchrloop
delchrcont:    LD   (HL),32
               JR   prtcurlin+3
linenter:      CP   13               ;RETURN
               JR   NZ,backspace
               LD   A,(comflag)
               AND  A
               JP   NZ,comhandler
               LD   (scrpos),A
               CALL interline
               LD   A,(insertflag)
               AND  A
               JR   Z,curdowncont
               CALL curdowncont
               RET  C
               JP   inslin-3
curdowncont:   CALL nextline
               RET  C
               LD   A,(scrpos+1)
               ADD  4
               CP   224
               JR   C,linent
               LD   DE,&8000
               LD   HL,&8400
               LD   BC,&5C00
               CALL ldi128
               CALL getcurpo
               PUSH AF
               PUSH HL
               LD   B,23
               CALL lstpg
               POP  HL
               POP  AF
               CALL setcurpo
               LD   A,&DC
linent:        LD   (scrpos+1),A
               JR   prtcurlin
interline:     LD   A,(altflag)  ;return if line was not altered.
               AND  A
               RET  Z
               CALL comprline
               CALL storeline
               JP   C,ooferror   ;jp if no room for the new line
prtcurlin:     CALL getline      ;get current line from source
               JP   prtlinebuff  ;and print it.

backspace:     CP   12
               JR   NZ,cursorright
               CALL comfirst
               DEC  L
               DEC  L
               LD   A,32
               CALL printchar
               JR   curslft
cursorright:   CP   9
               JR   NZ,cursorleft
               LD   A,L
               CP   126
               RET  NC
               ADD  2
               JP   settab
cursorleft:    CP   8
               JR   NZ,clearline
curslft:       CALL comfirst
               SUB  2
               JP   settab
clearline:     CP   7
               JR   NZ,togglecaps
               LD   (altflag),A
comline:       CALL clrlinebuff
               CALL prtlinebuff
               XOR  A
               CALL settab
               LD   A,(comflag)
               AND  A
               RET  Z
               LD   HL,(scrpos)
               LD   A,">"
               JP   printchar
togglecaps:    CP   6
               JR   NZ,restline
               LD   A,(23658)
               XOR  8
               LD   (23658),A
               RET
restline:      CALL commode
               CP   15             ;SYM EDIT   not com
               JP   Z,prtcurlin
cursorup:      CP   11               ;not com
               JR   NZ,cursordown
               CALL interline
               CALL lastline
               RET  C
               LD   A,(scrpos+1)
               SUB  4
               CP   128
               JR   NC,curup
               LD   HL,&DBFF
               LD   DE,&DFFF
               LD   BC,&5C00
               CALL ldd128
               CALL curwin
               LD   A,128
curup:         LD   (scrpos+1),A
               JP   prtcurlin
cursordown:    CP   10                  ;not com
               RET  NZ
               CALL interline
               JP   curdowncont
commode:       LD   C,A
               LD   A,(comflag)
               AND  A
               LD   A,C
               RET  Z
               POP  BC
               RET
comfirst:      LD   A,L
               CP   3
               RET  NC
               AND  A
               JR   Z,dropfirst
               LD   A,(comflag)
               AND  A
               LD   A,L
               RET  Z
dropfirst:     POP  HL
               RET
clearscr:      LD   HL,&8000
               LD   (scrpos),HL
               LD   DE,&8001
               LD   A,E
               LD   (scrlcount),A
               LD   BC,&5FFF
               LD   (HL),L
               JP   ldi128+1
lineaddr:      LD   HL,(scrpos)
               LD   L,0
               RET
clrlinebuff:   LD   HL,linebuff
clbloop:       LD   (HL),32
               INC  L
               BIT  6,L
               JR   Z,clbloop
               RET
setendmark:    LD   HL,linebuff+63
               LD   DE,compbuff+1
setendloop:    LD   A,(HL)           ;search backwards for last
               CP   32               ;character and set end marker
               JR   NZ,setend
               DEC  L
               BIT  7,L
               JR   Z,setendloop
setend:        INC  L
               XOR  A                ;set endmarker
               LD   (HL),A
               LD   L,A
               RET
comprline:     CALL setendmark
               CALL skipspaces
               PUSH HL
               LD   B,15
               LD   A,(HL)
               CALL testalfa
               JR   NC,nolabel
               INC  L
               DEC  B
findlabloop:   LD   A,(HL)
               CALL vallabchar
               JR   C,validchar
               CP   ":"
               JR   NZ,nolabel
               LD   A,15
               SUB  B
               JR   Z,nolabel
               POP  HL
               LD   (DE),A
               INC  E
               LD   B,0
               LD   C,A
               LDIR
               INC  L
               JR   findtoken
validchar:     INC  L
               DJNZ findlabloop
nolabel:       POP  HL
findtoken:     CALL testend1
               PUSH DE
               LD   B,128
               LD   DE,tokentab
testnext:      PUSH HL
testnextchr:   LD   C,(HL)
               RES  5,C
               LD   A,(DE)
               AND  127
               CP   C
               JR   NZ,nomatch
               LD   A,(DE)
               INC  DE
               INC  L
               RLA
               JR   NC,testnextchr
               DEC  DE
               LD   A,(HL)
               CALL vallabchar
               JR   C,nomatch
               POP  DE
               POP  DE
storetoken:    LD   A,B
               LD   (DE),A
               INC  E
               JR   findtoken
nomatch:       POP  HL
               JR   NC,notoken
nexttoken:     LD   A,(DE)
               INC  DE
               RLA
               JR   NC,nexttoken
               INC  B
               JR   testnext
notoken:       POP  DE
               LD   A,(HL)              ;test db etc.
               AND  223
               CP   "D"
               JR   NZ,nostok2
               INC  L
               LD   A,(HL)
               AND  223
               LD   B,149
               CP   "B"
               JR   Z,stok
               INC  B
               CP   "M"
               JR   Z,stok
               INC  B
               CP   "S"
               JR   Z,stok
               INC  B
               CP   "W"
               JR   NZ,nostok1
stok:          INC  L
               LD   A,(HL)
               CALL vallabchar
               JR   NC,storetoken
               DEC  L
nostok1:       DEC  L
nostok2:       LD   A,(HL)
movetonext:    LD   (DE),A
               INC  L
               INC  E
               CP   "("
               JR   Z,findtoken
               CP   ","
               JR   Z,findtoken
               CP   "&"
               JR   NZ,teststring
fithex:        LD   A,(HL)
               CP   32
               JR   Z,joinhex
               CALL testalfanum
               JR   NC,teststring
               CP   "Z"+1
               JR   C,nocap
               AND  223
nocap:         LD   (DE),A
               INC  E
joinhex:       INC  L
               JR   fithex
teststring:    CP   ""
               JR   NZ,testmore
stringloop:    LD   A,(HL)
               AND  A
               JR   Z,nomore
movechr:       LD   (DE),A
               INC  E
               INC  L
               CP   ""
               JR   NZ,stringloop
testmore:      LD   A,(HL)
               CP   32
               JP   Z,findtoken
nomore:        CALL testend2
               JR   movetonext
testend1:      CALL skipspaces
testend2:      LD   A,(HL)
               AND  A
               JR   NZ,testremark
lineend:       LD   (DE),A
               LD   A,E
               SUB  64
               LD   (compbuff),A
               POP  HL
               XOR  A
               RET
testremark:    CP   ";"
               RET  NZ
               LD   B,1
               LD   (DE),A
               INC  E
remspace:      DEC  L
               BIT  7,L
               JR   NZ,remspend
               LD   A,(HL)
               CP   " "
               JR   NZ,remspend
               INC  B
               JR   remspace
remspend:      LD   A,L
               ADD  B
               LD   L,A
               LD   A,B
movechars:     LD   (DE),A
               INC  L
               INC  E
               LD   A,(HL)
               AND  A
               JR   NZ,movechars
               JR   lineend
explinehl:     XOR  A
               LD   (altflag),A
               LD   B,A
               EX   DE,HL
               CALL clrlinebuff
               EX   DE,HL
               LD   E,15
               OR   (HL)
               SCF
               RET  Z
               INC  HL
               LD   A,(HL)
               AND  A
               RET  Z
               CP   15
               JR   NC,expentry
               INC  HL
               LD   C,A
               LD   A,E
               SBC  C
justify:       LD   E,B            ;ld E,B/ld E,A left/rightjust
               LDIR
               LD   A,":"
               LD   (DE),A
               INC  E
               LD   A,(HL)
               CP   ";"
               JR   Z,exprem
               LD   E,15
               INC  B
               JR   expcont
expentry:      INC  B
               BIT  7,A
               JR   NZ,exptoken
               DEC  B
               LD   E,B
expcont:       LD   A,(HL)
               AND  A
               RET  Z
               JP   M,exptoken
               CP   ""
               JR   NZ,tstrem
insquote:      LD   (DE),A
               INC  E
               INC  HL
               LD   A,(HL)
               CP   ""
               JR   Z,endquote
               AND  A
               JR   NZ,insquote
               RET
tstrem:        CP   ";"
               JR   Z,exprem
endquote:      LD   (DE),A
               INC  E
               INC  HL
               JR   expcont
exprem:        INC  HL
               LD   A,(HL)
               DEC  A
               ADD  E
               LD   E,A
               LD   A,(semiflag)
               AND  A
               JR   Z,expend
               LD   (DE),A
expend:        INC  E
               INC  HL
               LD   A,(HL)
               AND  A
               RET  Z
               LD   (DE),A
               JR   expend
exptoken:      PUSH HL
               LD   HL,tokentab
               SUB  128
               JR   Z,exptode
expfindtoken:  BIT  7,(HL)
               INC  HL
               JR   Z,expfindtoken
               DEC  A
               JR   NZ,expfindtoken
exptode:       LD   A,(HL)
               AND  127
               LD   (DE),A
               INC  E
               BIT  7,(HL)
               INC  HL
               JR   Z,exptode
               POP  HL
               INC  HL
               DJNZ expcont
               LD   A,(HL)
               CP   ";"
               JR   Z,exprem
               LD   E,20
               JR   expcont
getline:       LD   A,(curradp)
               CALL getset
               LD   HL,(currado)
               CALL explinehl
               JR   roomexit
storeline:     LD   A,(curradp)
               CALL getset
               LD   HL,(currado)
               LD   A,(compbuff)
               LD   B,(HL)
               RES  7,B
               SUB  B
               LD   B,0
               JR   Z,moveline
               JR   NC,makeroom
               NEG
               LD   C,A
               CALL reclaimbc
               JR   moveline
makeroom:      LD   C,A
               CALL makebcspace
               JR   C,noroomc
moveline:      LD   A,(curradp)
               OR   32
               LD   HL,compbuff
               OUT  (250),A
               LD   DE,(currado)
               LD   B,0
               LD   C,(HL)
               LDIR
roomexit:      CALL restore
               RET
removeline:    LD   A,(curradp)
               CALL getset
               LD   HL,(currado)
               XOR  A
               LD   B,A
               LD   C,(HL)
               RES  7,C
               OR   C
               CALL NZ,reclaimbc
               JR   roomexit

;insert line from hl :bllnk line/errors/block markers
createline:    LD   C,(HL)
               LD   A,(curradp)
               EX   DE,HL
               CALL getset
               LD   B,0
               PUSH DE
               CALL makebcspace
               POP  DE
               JR   C,noroomc
               CALL getcurpo
               OR   32
               OUT  (250),A
               EX   DE,HL
               LD   B,0
               LD   C,(HL)
               LDIR
noroomc:       JP   nxtlnex

;insert BC spaces  note source page at LOMEM no check lm

makebcspace:   LD   A,(symendp)
               LD   DE,(symendo)
               LD   HL,(endo)
               PUSH HL
               ADD  HL,BC
               PUSH BC
               LD   C,A
               LD   A,(endp)
               OR   32
               OUT  (250),A
               AND  223
               CALL adjustpo
               CALL testpo
               POP  BC
               POP  HL
               CCF
               RET  C
               JR   makeroom1
makeroom0:     LD   HL,16383
               IN   A,(250)
               DEC  A
               OUT  (250),A
makeroom1:     LD   A,(curradp)
               LD   E,A
               IN   A,(250)
               AND  223
               CP   E
               LD   DE,0
               JR   NZ,makeroom2
               LD   DE,(currado)
makeroom2:     PUSH BC
               PUSH HL
               PUSH HL
               OR   A
               SBC  HL,DE
               LD   D,B
               LD   E,C
               LD   B,H
               LD   C,L
               POP  HL
               ADD  HL,DE
               EX   DE,HL
               POP  HL
               INC  BC
               CALL blockdown
               POP  BC
               LD   A,(curradp)
               LD   E,A
               IN   A,(250)
               AND  223
               CP   E
               JR   NZ,makeroom0
               LD   A,(endp)
               LD   HL,(endo)
               ADD  HL,BC
               CALL adjustpo
setendpo:      LD   (endp),A
               LD   (endo),HL
               AND  A
               RET
;reclaim bc note:  source page at LOMEM
reclaimbc:     PUSH BC
               LD   DE,(currado)
               JR   reclaim1
reclaim0:      LD   DE,0
               IN   A,(250)
               INC  A
               OUT  (250),A
reclaim1:      LD   A,(endp)
               LD   L,A
               IN   A,(250)
               AND  223
               CP   L
               LD   HL,16384
               JR   NZ,reclaim2
               LD   HL,(endo)
reclaim2:      PUSH BC
               PUSH BC
               OR   A
               SBC  HL,DE
               LD   B,H
               LD   C,L
               POP  HL
               ADD  HL,DE
               CALL blockup
               POP  BC
               LD   A,(endp)
               LD   L,A
               IN   A,(250)
               AND  223
               CP   L
               JR   NZ,reclaim0
               XOR  A
               POP  HL
               CALL adjustpo
               LD   C,A
               EX   DE,HL
               LD   A,(endp)
               LD   HL,(endo)
               CALL subpo
               JR   setendpo
prtlinebuff:   CALL lineaddr
               LD   DE,linebuff
prtlibuloop:   LD   A,(DE)
               PUSH DE
               CALL prtathl
               POP  DE
               INC  E
               BIT  6,E
               JR   Z,prtlibuloop
               AND  A
               RET
printchar:     LD   (altflag),A
               LD   E,L
               SRL  E
               LD   D,linebuff/256
               LD   (DE),A
               CALL prtathl
setscrpos:     LD   (scrpos),HL
               RET
prtathl:       LD   E,A
               XOR  A
               RL   E
               RLA
               RL   E
               RLA
               RL   E
               RLA
               RL   E
               RLA
               ADD  chartabel/256-2
               LD   D,A
               LD   BC,127
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  E
               ADD  HL,BC
               LD   A,(DE)
               LD   (HL),A
               INC  E
               INC  L
               LD   A,(DE)
               LD   (HL),A
               INC  HL
               LD   A,L
               AND  C
               LD   BC,&FC80
               JR   NZ,prtatend
               LD   C,&7E
prtatend:      ADD  HL,BC
               RET

printpage:     CALL printfirst
               LD   B,23
prtpge:        PUSH BC
               CALL curdowncont
               POP  BC
               JR   C,prtpgcnt
               DJNZ prtpge
printfirst:    LD   HL,&8000
               LD   (scrpos),HL
               LD   A,(windowp)
               LD   HL,(windowo)
               CALL setcurpo
               JP   prtcurlin
prtpgcnt:      LD   A,32+24
               SUB  B
               RLCA
               RLCA
               LD   D,A
               LD   E,1
               LD   HL,&E000
               SBC  HL,DE
               LD   B,H
               LD   C,L
               LD   H,D
               LD   L,E
               DEC  HL
               LD   (HL),L
               JP   ldi128+1
nextpage:      LD   A,(windowp)
               LD   HL,(windowo)
               CALL setcurpo
               LD   B,24
nxtpg:         PUSH BC
               CALL nextline
               POP  BC
               JR   C,curwin
               DJNZ nxtpg
curwin:        CALL getcurpo
setwinpo:      LD   (windowp),A
               LD   (windowo),HL
               RET
getcurpo:      LD   A,(curradp)
               LD   HL,(currado)
               RET
lastpage:      LD   A,(windowp)
               LD   HL,(windowo)
               CALL setcurpo
               LD   B,24
lstpg:         PUSH BC
               CALL lastline
               POP  BC
               JR   C,curwin
               DJNZ lstpg
               JR   curwin
nextline:      LD   A,(curradp)
               CALL getset
               CALL findnext
nxtlnex:       RL   C
               CALL restore
               RR   C
               RET


findnext:      LD   A,(endp)
               LD   C,A
               LD   DE,(endo)
               CALL getcurpo
               CALL testpo
               CCF
               RET  C
               LD   B,0
               LD   C,(HL)
               RES  7,C
               ADD  HL,BC
               CALL adjustpo
               LD   B,A
               IN   A,(250)
               ADC  0
selsetcurpo:   OUT  (250),A
               LD   A,B
setcurpo:      LD   (curradp),A
               LD   (currado),HL
               RET
lastline:      LD   A,(curradp)
               CALL getset
               CALL findlast
               JR   nxtlnex
findlast:      CALL getcurpo
               LD   C,A
               EX   DE,HL
               LD   A,(startp)
               LD   HL,(starto)
               CALL testpo
               CCF
               RET  C
               DEC  C
               LD   A,C
               EX   DE,HL
               OR   32
               OUT  (250),A
               SET  6,H
               DEC  HL
lstln:         DEC  HL
               LD   A,(HL)
               AND  A
               JR   NZ,lstln
               INC  HL
               LD   A,C
               CALL adjustpo
               AND  A
               JR   setcurpo

blockup:       PUSH HL
               LD   HL,ldi128
               JR   block
blockdown:     PUSH HL
               LD   HL,ldd128
block:         LD   A,C
               NEG
               SLA  A
               ADD  L
               LD   L,A
               JR   NC,blck1
               INC  H
blck1:         EX   (SP),HL
               RET
ldi128:        DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               DEFB 237,160,237,160,237,160,237,160
               JP   PE,ldi128
               RET
ldd128:        DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               DEFB 237,168,237,168,237,168,237,168
               JP   PE,ldd128
               RET
getset:        DI
               POP  HL
               LD   (sproom),SP
               LD   SP,chartabel
               LD   B,A
               IN   A,(250)
               PUSH AF
               LD   A,B
               OR   32
               OUT  (250),A
               LD   A,B
jumphl:        JP   (HL)
restore:       POP  HL
               POP  AF
               LD   SP,(sproom)
               OUT  (250),A
               EI
               JP   (HL)

adjustpo:      LD   B,A
               LD   A,H
adjsub:        SUB  64
               JR   C,adjend
               INC  B
               LD   H,A
adjend:        CCF
               LD   A,B
               RET
testpo:        CP   C
               RET  C
               RET  NZ
               SBC  HL,DE
               RLA
               ADD  HL,DE
               SRL  A
               RET
subpo:         AND  A
               SBC  HL,DE
               JR   NC,subend
               RES  7,H
               RES  6,H
               DEC  A
subend:        SUB  C
               RET
skipspaces:    LD   A,(HL)
               CP   32
               RET  NZ
               INC  L
               JR   skipspaces
vallabchar:    CALL testalfanum
               RET  C
seperator:     CP   33               ;nc if seperator
               CCF                     ;C if not
               RET  NC
               CP   34
               RET  C
               RET  Z
               CP   36
               RET  C
               CP   46
               CCF
               RET  NC
               RET  Z
               CP   47
               RET  Z
               CP   60
               CCF
               RET  NC
               CP   65
               RET  C
               CP   92
               RET  Z
               SCF
               RET

testalfanum:   CP   "0"
               CCF
               RET  NC
               CP   "9"+1
               RET  C
testalfa:      CP   "A"
               CCF
               RET  NC
               CP   "Z"+1
               RET  C
testlower:     CP   "a"
               CCF
               RET  NC
               CP   "z"+1
               RET
stringlen:     PUSH HL
               LD   B,255
strlen:        LD   A,(HL)
               INC  L
               INC  B
               CP   32
               JR   Z,strlend
               AND  A
               JR   NZ,strlen
strlend:       POP  HL
               RET
get10000:      LD   BC,10000
               CALL divide
get1000:       LD   BC,1000
               CALL divide
get100:        LD   BC,100
               CALL divide
get10:         LD   C,10
               CALL divide
               LD   A,L
               JR   divend+1
divide:        XOR  A
               SBC  HL,BC
               JR   C,divend
               INC  A
               JR   divide+1
divend:        ADD  HL,BC
               ADD  48
               LD   (DE),A
               INC  DE
               RET
gethex:        LD   A,H
               CALL gthxdh
               LD   A,H
               CALL gthxdl
gethexl:       LD   A,L
               CALL gthxdh
               LD   A,L
               JR   gthxdl
gthxdh:        RRCA
               RRCA
               RRCA
               RRCA
gthxdl:        AND  15
               ADD  48
               CP   58
               JR   C,gthxn
               ADD  7
gthxn:         LD   (DE),A
               INC  DE
               RET
getnum1:       CALL getnum
               RET  C
               RET  NZ
               XOR  A
               CP   H
               LD   A,L
               RET
getnum:        LD   HL,0
               LD   A,(DE)
               CP   "&"
               JR   Z,hexnum
               CP   "%"
               JR   Z,binnum
               CP   ""
               JR   Z,chrnum
               CALL decdig
               JR   NC,invdig
               LD   L,A
decnxt:        INC  DE
               LD   A,(DE)
               CALL decdig
               JR   NC,digdon
               LD   B,H
               LD   C,L
               ADD  HL,HL
               RET  C
               ADD  HL,HL
               RET  C
               ADD  HL,BC
               RET  C
               ADD  HL,HL
               RET  C
               LD   B,0
               LD   C,A
               ADD  HL,BC
               JR   NC,decnxt
               RET
hexnum:        INC  DE
               LD   A,(DE)
               CALL hexdig
               RET  NC
hexnxt:        LD   L,A
               INC  DE
               LD   A,(DE)
               CALL hexdig
               JR   NC,digdon
               ADD  HL,HL
               RET  C
               ADD  HL,HL
               RET  C
               ADD  HL,HL
               RET  C
               ADD  HL,HL
               RET  C
               OR   L
               JR   hexnxt
hexdig:        OR   32
               SUB  48
               JR   C,invdig
               CP   10
               RET  C
               SUB  39
               CP   10
               JR   C,invdig
               CP   16
               RET  C
invdig:        XOR  A
               DEC  A
               RET
decdig:        SUB  48
               JR   C,invdig
               CP   10
               RET
binnum:        INC  DE
               LD   A,(DE)
               SUB  49
               ADC  0
               RET  NZ
binnxt:        CCF
               ADC  HL,HL
               RET  C
               INC  DE
               LD   A,(DE)
               SUB  49
               ADC  0
               JR   Z,binnxt
digdon:        CP   A
               RET
chrnum:        INC  DE
               LD   A,(DE)
               INC  DE
               LD   L,A
               CP   ""
               RET  Z
               AND  A
               JR   Z,invdig
               LD   A,(DE)
               INC  DE
               CP   ""
               RET

calcnxt:       INC  DE
calcnum:       PUSH HL
               CALL getnum
               POP  BC
               JP   C,numerror
               JP   NZ,comerror
               RET

calcadd:       CALL calcnxt
               ADD  HL,BC
               JR   NC,calcloop
               JP   numerror
calcsub:       CALL calcnxt
               LD   A,C
               SUB  L
               LD   L,A
               LD   A,B
               SBC  H
               LD   H,A
               JR   calcloop
calcmul:       CALL calcnxt
               PUSH DE
               EX   DE,HL
               LD   A,B
               LD   B,16
               LD   HL,0
clcm1:         ADD  HL,HL
               RL   C
               RLA
               JR   NC,clcm2
               ADD  HL,DE
clcm2:         DJNZ clcm1
               POP  DE
               JR   calcloop
calcdiv:       CALL calcdimo
               JR   calcloop
calcmod:       CALL calcdimo
               LD   H,B
               LD   L,C
               JR   calcloop
calcdimo:      CALL calcnxt
               PUSH DE
               EX   DE,HL
               LD   A,B
               LD   B,16
               LD   HL,0
clcd1:         RL   C
               RLA
               ADC  HL,HL
               SBC  HL,DE
               JR   NC,clcd2
               ADD  HL,DE
clcd2:         CCF
               DJNZ clcd1
               RL   C
               RLA
               EX   DE,HL
               LD   L,C
               LD   H,A
               LD   B,D
               LD   C,E
               POP  DE
               RET

comhandler:    CALL setendmark
               INC  L
               CALL skipspaces
               AND  A
               JR   NZ,contcom
               CALL prtcurlin
               JP   comout
contcom:       CALL testalfa
               JP   C,comhand
               EX   DE,HL
               LD   HL,0
               LD   A,(DE)
               CP   "-"
               JR   Z,calcsub
               CALL calcnum
calcloop:      LD   A,(DE)
               CP   "+"
               JR   Z,calcadd
               CP   "-"
               JR   Z,calcsub
               CP   "*"
               JR   Z,calcmul
               CP   "/"
               JR   Z,calcdiv
               CP   "\"
               JR   Z,calcmod
               CP   " "
               JR   Z,calcend
               AND  A
               JP   NZ,comerror
calcend:       LD   DE,nummes
               PUSH HL            ;decimal word
               CALL get10000
               INC  DE
               POP  HL
               PUSH HL
               LD   L,H
               LD   H,0
               CALL get100         ;decimal high byte
               LD   DE,nummes+13
               POP  HL
               PUSH HL
               LD   H,0
               CALL get100         ;decimal low byte
               LD   DE,nummes+21
               POP  HL
               PUSH HL
               CALL gethex
               LD   DE,nummes+27
               POP  HL
               LD   C,L
               CALL getbin
               LD   DE,nummes+40
               CALL getbin
               LD   A,C
               AND  127
               CP   32
               JR   NC,valascii
               LD   A,32
valascii:      LD   (nummes+59),A
               CALL lineaddr
               LD   DE,nummes
               CALL prtstr
               CALL errcont
               JP   comline
getbin:        LD   B,8
calcbin:       XOR  A
               ADD  HL,HL
               ADC  "0"
               LD   (DE),A
               INC  DE
               DJNZ calcbin
               RET

comhand:       CALL execom
comout:        XOR  A
               LD   (comflag),A
               LD   A,(tabtemp)
               LD   (scrpos),A
               RET
execom:        AND  95
               SUB  65
               LD   E,A
               ADD  A
               LD   B,0
               LD   C,A
               INC  L
               PUSH HL
               LD   HL,commandtab
               ADD  HL,BC
               LD   C,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,C
               EX   (SP),HL
               JP   skipspaces
ooferror:      CALL errorhandler
memerr:        DEFM "Out of memor"
               DEFB "y"+128
comc:          CALL core
               PUSH HL
               LD   A,(symendp)
               LD   DE,(symendo)
               LD   BC,(endo)
               ADD  HL,BC
               LD   C,A
               LD   A,(endp)
               CALL adjustpo
               CALL testpo
               CALL NC,tempcur
               JR   NC,ooferror
               CALL removeline
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL setcurpo
               CALL lastline
               CALL removeline
               CALL getcurpo
               CALL settemp2
               LD   BC,28
               CALL adtempsub
               CALL tempcur
               POP  DE
               CALL getset
               LD   B,D
               LD   C,E
               PUSH BC
               CALL makebcspace
               POP  BC
               PUSH BC
               CALL adtempadd
               POP  BC
               PUSH BC
               CALL getblock
               POP  BC
               CALL putblock
               JP   blockdone
core:          CALL firstmark
blocker:       JP   C,blockerror
               CALL nextline
               CALL getcurpo
               CALL settemp2
               CALL seeker
               JR   C,blocker
               LD   A,(temp2)
               LD   C,A
               LD   DE,(tempo2)
               LD   A,(temp1)
               LD   HL,(tempo1)
               CALL testpo
               JR   C,outside
               LD   C,A
               EX   DE,HL
               CALL getcurpo
               CALL testpo
               JR   C,outside
               CALL tempcur
               CALL errorhandler
               DEFM "Inside bloc"
               DEFB "k"+128
outside:       CALL blocklenght
               JR   C,blocker
               LD   A,H
               OR   L
               SCF
               JR   Z,blocker
               RET
adtempsub:     PUSH BC
               LD   A,(temp1)
               LD   C,A
               LD   DE,(tempo1)
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL testpo
               POP  HL
               RET  NC
               LD   A,C
               EX   DE,HL
               LD   C,0
               CALL subpo
               JP   settemp1
adtempadd:     PUSH BC
               LD   A,(temp1)
               LD   C,A
               LD   DE,(tempo1)
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL testpo
               POP  BC
               RET  C
               ADD  HL,BC
               CALL adjustpo
settemp2:      LD   (temp2),A
               LD   (tempo2),HL
               RET
getblock:      LD   A,(temp2)
               OR   32
               OUT  (250),A
               LD   HL,(tempo2)
               LD   DE,32768
               JP   blockup
putblock:      CALL getcurpo
               OR   32
               OUT  (250),A
               LD   DE,32768
               EX   DE,HL
               JP   blockup
blcerror:      CALL errorhandler
               DEFM "Invalid bloc"
               DEFB "k"+128
comr:          CALL core
               EX   DE,HL
               LD   HL,28
               ADD  HL,DE
               BIT  6,H
               CALL NZ,tempcur
               JR   NZ,blcerror
               LD   A,(temp2)
               CALL getset
               LD   B,D
               LD   C,E
               PUSH BC
               CALL getblock
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL setcurpo
               CALL findlast
               CALL getcurpo
               CALL settemp2
               OR   32
               OUT  (250),A
               POP  BC
               PUSH BC
               LD   HL,28
               ADD  HL,BC
               LD   B,H
               LD   C,L
               PUSH HL
               CALL reclaimbc
               POP  BC
               CALL adtempsub
               CALL tempcur
               POP  BC
               PUSH BC
               CALL makebcspace
               POP  BC
               CALL putblock
               JP   blockdone
comp:          CP   ";"
               JR   NZ,compcont
               XOR  A
               LD   (semiflag),A
compcont:      CALL firstmark
               JR   C,printall
               CALL getcurpo
               CALL settemp2
               CALL nextline
               CALL seeker
               JP   C,blocker
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL setcurpo
               CALL removeline
               CALL seeker
               CALL removeline
               LD   A,(temp2)
               LD   HL,(tempo2)
               JR   printcont
printall:      LD   A,(startp)
               LD   HL,(starto)
printcont:     CALL settemp1
               CALL getcurpo
               CALL settemp2
               LD   A,(temp1)
               LD   HL,(tempo1)
               CALL setcurpo
               LD   A,(printerflag);do not print if there is not
               AND  A              ;a printer connected
               JR   Z,endprint
               LD   HL,printinit
               LD   A,(HL)
               AND  A
               JR   Z,printloop
               LD   B,A
initloop:      INC  HL
               LD   A,(HL)
               RST  16
               DJNZ initloop
printloop:     CALL getline
               CALL lprintlin
nofeed:        CALL prtlinebuff
               LD   HL,&5C3B
               BIT  5,(HL)
               JR   Z,contprint
               RES  5,(HL)
               LD   HL,prtmess
               CALL question
               JR   C,endprint
contprint:     CALL nextline
               LD   A,(temp2)
               LD   C,A
               LD   DE,(tempo2)
               CALL getcurpo
               CALL testpo
               JR   C,printloop
endprint:      LD   A,";"
               LD   (semiflag),A
               CALL tempcur
               JP   blockdone+3
lprintlin:     LD   DE,linebuff
               LD   B,64
prtchr:        LD   A,(DE)
               RST  16
               INC  DE
               DJNZ prtchr
carret:        LD   A,13
               RST  16
               LD   A,(feedflag)
               AND  A
               RET  Z
               LD   A,10
               RST  16
               RET
comu:          CALL firstmark
blockerror:    CALL C,tempcur
               JP   C,blcerror
               CALL getcurpo
               CALL settemp2
               CALL nextline
               CALL seeker
               JR   C,blockerror
               CALL nextline
               CALL blocklenght
               JR   C,blockerror
               EX   DE,HL
               LD   A,(temp2)
               LD   HL,(tempo2)
               CALL setcurpo
               CALL getset
               LD   B,D
               LD   C,E
               CALL reclaimbc
blockdone:     CALL restore
               CALL curwin
               JP   printpage
firstmark:     CALL curtemp
               LD   A,"B"
               LD   (findtype),A
               CALL startcur
               JP   seeker
blocklenght:   LD   A,(temp2)
               LD   C,A
               LD   DE,(tempo2)
               CALL getcurpo
               CALL subpo
               CP   1
               CCF
               RET

scrchan:       LD   C,A
               LD   HL,(scrpos)
               LD   A,H
               CP   224
               JR   C,scrchncont
               LD   H,220
               LD   A,(scrlcount)
               DEC  A
               JR   NZ,scrchnscl
               CALL waitonkey
               LD   A,22
scrchnscl:     LD   (scrlcount),A
               PUSH BC
               LD   DE,&8800
               LD   HL,&8C00
               LD   BC,&5400
               CALL ldi128
               LD   H,220
               LD   (HL),L
               INC  DE
               LD   B,4
               CALL ldi128
               LD   H,220
               POP  BC
scrchncont:    LD   A,C
               CP   13
               JR   NZ,scrchnprt
               LD   L,0
               LD   A,H
               ADD  4
               LD   H,A
               JR   scrchnend
scrchnprt:     BIT  7,H
               JR   Z,scrchnend
               PUSH BC
               CALL prtathl
               POP  BC
scrchnend:     LD   (scrpos),HL
               RET

comf:          AND  A
               EX   DE,HL
               CALL curtemp
               JR   NZ,seekstart
               CALL nextline
               JR   seek
seekstart:     CALL startcur
               EX   DE,HL
               CALL stringlen
               LD   A,B
               CP   1
               JR   NZ,labelword
               LD   A,(HL)
               CALL testalfa
               CALL NC,tempcur
               JP   NC,comerror
               AND  95
               LD   (findtype),A
               JR   seek
labelword:     LD   C,A
               LD   B,L
               DEC  A
               ADD  L
               LD   L,A
               LD   A,(HL)
               CP   ":"
               LD   A,0
               JR   NZ,word
               DEC  C
               LD   A,":"
word:          LD   (findtype),A
               LD   L,B
               LD   B,0
               LD   A,C
               CP   15
               CALL NC,tempcur
               JP   NC,strerror
               LD   DE,findbuff
               LD   (DE),A
               INC  DE
               LDIR
seek:          LD   DE,findbuff
               CALL seeker
               CALL C,tempcur
               JR   C,fnderror
               CALL curwin
               CALL printpage
               JP   printfirst
startcur:      LD   A,(startp)
               LD   HL,(starto)
               JP   setcurpo
curtemp:       CALL getcurpo
settemp1:      LD   (temp1),A
               LD   (tempo1),HL
               RET
fnderror:      CALL errorhandler
               DEFM "Not foun"
               DEFB "d"+128
tempcur:       LD   A,(temp1)
               LD   HL,(tempo1)
               JP   setcurpo
seeker:        LD   A,(curradp)
               CALL getset
               LD   HL,(currado)
seekloop:      PUSH DE
               INC  HL
               LD   A,(HL)
               CP   15
               JR   NC,seekword
               LD   A,(findtype)
               CP   ":"
               JR   NZ,seekword
               LD   A,(DE)
               LD   B,A
               INC  B
seeklab:       LD   A,(DE)
               CP   (HL)
               JR   Z,seeklab2
               XOR  32
               CP   (HL)
seeklab2:      INC  DE
               INC  HL
               JR   NZ,seeknxtln
               DJNZ seeklab
               JR   found
seekword:      CP   32
               JR   Z,seekmark
               LD   A,(findtype)
               AND  A
               JR   NZ,seeknxtln
               LD   A,(DE)
               LD   C,A
               INC  DE
               EX   DE,HL
wordfst:       LD   B,C
               LD   A,(DE)
               CP   (HL)
               INC  DE
               JR   Z,fstfnd
               CP   ";"
               JR   Z,seeknxtln
               AND  A
               JR   NZ,wordfst+1
               JR   seeknxtln
fstfnd:        PUSH DE
               PUSH HL
               INC  HL
               DEC  B
               JR   Z,wordfnd
               LD   A,(DE)
               CP   (HL)
               INC  DE
               JR   Z,fstfnd+2
               POP  HL
               POP  DE
               JR   wordfst
wordfnd:       POP  HL
               POP  DE
               JR   found
seekmark:      LD   A,(findtype)
               CP   "A"
               JR   C,seeknxtln
               INC  HL
               INC  HL
               INC  HL
               INC  HL
               CP   (HL)
               JR   NZ,seeknxtln
found:         POP  DE
               JR   seekexit
seeknxtln:     CALL findnext
               POP  DE
               JR   NC,seekloop
seekexit:      JP   nxtlnex
comn:
               LD   HL,clrsource
               CALL question
               JP   NC,prtcurlin
               LD   A,(symstrtp)
               LD   HL,(symstarto)
               CALL setendpo
               CALL settemp2
               LD   A,(startp)
               LD   HL,(starto)
               LD   DE,1
               LD   C,D
               CALL subpo
               CALL settemp1
               JP   sourceinit

question:      CALL pomessage
answer:        BIT  5,(HL)
               JR   Z,answer
               RES  5,(HL)
               LD   A,(23560)
               AND  95
               CP   "Y"
               SCF
               RET  Z
               CP   "N"
               JR   NZ,answer
               RET
wrkerror:      CALL errorhandler
               DEFM "Invalid Workspac"
               DEFB "e"+128
comwnumer:     JP   numerror
comwcomer:     JP   comerror
comw:          AND  A
               JP   Z,viewwork
               EX   DE,HL
               CALL smalnum
               CP   28
               JR   NC,comwnumer
               LD   (temp1),A
               LD   A,(DE)
               INC  DE
               CP   ","
               JR   NZ,comwcomer
               CALL getnum
               JR   C,comwnumer
               LD   A,H
               CP   64
               JR   NC,comwnumer
               LD   (tempo1),HL
               LD   A,(DE)
               INC  DE
               CP   ","
               JR   NZ,comwcomer
               CALL smalnum
               CP   28
               JR   NC,comwnumer
               LD   (temp2),A
               LD   A,(DE)
               INC  DE
               CP   ","
               JR   NZ,comwcomer
               CALL getnum
               JR   C,comwcomer
               LD   A,H
               CP   64
               JR   NC,comwnumer
               LD   (tempo2),HL
               LD   A,(DE)
               CP   32
               JR   Z,sourceinit
               AND  A
               JR   NZ,comwcomer
sourceinit:    LD   HL,(temp1)
               LD   H,81
               LD   A,(temp2)
               SUB  L
               JR   C,wrkerror
               JR   NZ,setwcont
               EX   DE,HL
               LD   HL,(tempo1)
               LD   BC,(tempo2)
               SBC  HL,BC
wrkerror2:     JR   NC,wrkerror
               EX   DE,HL
setwcont:      INC  A
               LD   B,A
               LD   C,A
setwloop:      LD   A,(HL)
               CP   textmark
               JR   Z,setwfree
               AND  A
               JR   NZ,wrkerror2
setwfree:      INC  HL
               DJNZ setwloop
               LD   DE,(startp)
               LD   D,81
               LD   A,(symstrtp)
               SUB  E
               INC  A
               LD   B,A
               XOR  A
setwclr:       LD   (DE),A
               INC  DE
               DJNZ setwclr
               LD   B,C
setwset:       DEC  HL
               LD   (HL),textmark
               DJNZ setwset
               LD   HL,0
               LD   (labcount),HL
               LD   A,(temp2)
               CALL getset
               LD   HL,(tempo2)
               LD   (HL),0
               LD   (symstrtp),A
               LD   (symstarto),HL
               LD   (symendp),A
               LD   (symendo),HL
               LD   C,A
               EX   DE,HL
               CALL restore
               LD   HL,0
               LD   (labcount),HL
               LD   A,(endp)
               LD   HL,(endo)
               CALL subpo          ;end<sym end
               JR   NC,clrwork
               LD   A,(temp1)
               LD   HL,(tempo1)
               INC  HL
               CALL adjustpo
               LD   C,A
               EX   DE,HL
               LD   A,(startp)
               LD   HL,(starto)
               CP   C
               JR   NZ,clrwork
               SBC  HL,DE
               JP   Z,prtcurlin
clrwork:       LD   A,(temp1)
               CALL getset
               LD   HL,(tempo1)
               LD   (HL),0
               INC  HL
               LD   (HL),0
               LD   C,A
               EX   DE,HL
               CALL restore
               LD   A,C
               EX   DE,HL
               CALL adjustpo
               LD   (startp),A
               LD   (starto),HL
               CALL setendpo
               JP   tppag
smalnum:       PUSH HL
               CALL getnum1
               POP  HL
               JP   C,numerror
               RET  Z
comwer:        JP   comerror
viewwork:      CALL clrlinebuff
               LD   L,0
               LD   (HL),">"
               INC  L
               LD   (HL),"W"
               INC  L
               INC  L
               EX   DE,HL
               LD   A,(startp)
               LD   HL,(starto)
               DEC  HL
               BIT  7,H
               JR   Z,comwcont
               RES  7,H
               RES  6,H
               DEC  A
comwcont:      PUSH HL
               LD   L,A
               LD   H,0
               CALL get100
               POP  HL
               LD   A,","
               LD   (DE),A
               INC  E
               CALL get10000
               LD   A,","
               LD   (DE),A
               INC  E
               LD   HL,(symstrtp)
               LD   H,B
               CALL get100
               LD   A,","
               LD   (DE),A
               INC  E
               LD   HL,(symstarto)
               CALL get10000
               JR   viewi
comt:          LD   DE,compbuff
               CALL datastr
               LD   A,L            ;fetch the the number of
               SUB  65             ;data to transmit
               LD   B,A
               LD   HL,compbuff    ;start of transmit data
               LD   A,(printerflag);do not print if there is not
               AND  A              ;a printer connected
               JR   Z,nocomt
comtloop:      LD   A,(HL)
               RST  16
               INC  HL
               DJNZ comtloop
nocomt:        JP   prtcurlin
datastr:       EX   DE,HL
               LD   A,15
cominxt:       EX   AF,AF'
               CALL smalnum
               LD   (HL),A
               INC  HL
               LD   A,(DE)
               INC  DE
               CP   ","
               JR   NZ,comcont
               EX   AF,AF'
               DEC  A
               JR   NZ,cominxt
strerror:      CALL errorhandler
               DEFM "String too lon"
               DEFB "g"+128
comcont:       AND  A
               RET  Z
               CP   32
               RET  Z
               JP   comerror
comi:          AND  A
               JR   Z,viewinit
               LD   DE,printinit
               CALL datastr
               JP   prtcurlin
viewinit:      CALL clrlinebuff
               LD   DE,printinit
               LD   L,0
               LD   (HL),">"
               INC  L
               LD   (HL),"I"
               INC  L
               INC  L
               LD   A,15
viewloop:      EX   AF,AF'
               EX   DE,HL
               LD   A,(HL)
               PUSH HL
               LD   L,A
               LD   H,0
               CALL get100
               POP  HL
               EX   DE,HL
               EX   AF,AF'
               INC  DE
               DEC  A
               JR   NZ,viewcont
viewi:         DEC  A
               LD   (altflag),A
               POP  HL
               JP   prtlinebuff
viewcont:      LD   (HL),","
               INC  L
               JR   viewloop
comv:          XOR  A
               LD   DE,labchan
               LD   (DE),A
               INC  DE
               LD   A,2
               LD   (DE),A
               INC  DE
               LD   (DE),A
               LD   A,(HL)
               CP   "*"
               JR   NZ,vlabscreen
               INC  HL
               LD   (labchan),A
               LD   A,(printerflag);do not print if there is not
               AND  A              ;a printer connected
               JR   Z,vlabscreen-3
               LD   A,(HL)
               CALL labview
               CALL carret
               JP   prtcurlin
vlabscreen:    CALL labview
               CALL waitonkey
               JP   printpage
labview:       AND  A
               JR   Z,vlabset
               CALL testalfa
               JR   C,vlabcont
               EX   DE,HL
               CALL smalnum
               EX   DE,HL
               LD   (labcol),A
               LD   (labcolt),A
               LD   A,(HL)
               CP   32
               JR   Z,vlabset
               AND  A
               JR   Z,vlabset
               CP   ","
               JP   NZ,comerror
               INC  HL
vlabcont:      CALL stringlen
               LD   C,B
               LD   DE,compbuff+1
vlablop:       LD   A,(HL)
               LD   (DE),A
               INC  HL
               INC  DE
               DJNZ vlablop
               LD   A,32
               LD   (DE),A
               DEC  DE
               LD   A,(DE)
               CP   ":"
               JR   NZ,vlablup
               DEC  C
vlablup:       LD   A,C
               CP   15
               JP   NC,strerror
vlabset:       LD   (compbuff),A
               LD   A,(symstrtp)
               LD   HL,(symstarto)
               LD   (labpage),A
               LD   (laboffs),HL
               LD   A,(labchan)
               AND  A
               JR   NZ,vlabloop
               CALL clearscr
               LD   DE,lablen
               LD   HL,(labcount)
               CALL get10000
               LD   HL,symlab
vlabmes:       LD   A,(HL)
               AND  127
               PUSH HL
               CALL scrchan
               POP  HL
               LD   A,(HL)
               RLA
               INC  HL
               JR   NC,vlabmes
               LD   A,13
               CALL scrchan
               LD   A,13
               CALL scrchan
vlabloop:      LD   A,(labpage)
               DEC  A
               CALL getset
               LD   HL,(laboffs)
               SET  6,H
               LD   A,(HL)
               AND  A
               JP   Z,vlabex
               LD   DE,compbuff
               LD   A,(DE)
               AND  A
               JR   Z,vlabfound
               LD   B,A
               PUSH HL
vlabchk:       INC  DE
               DEC  HL
               LD   A,(DE)
               CP   (HL)
               JP   NZ,vlabnxt
               DJNZ vlabchk
               INC  DE
               LD   A,(DE)
               CP   ":"
               JR   NZ,vlabsta
               DEC  HL
               LD   A,(HL)
               INC  A
               JP   NZ,vlabnxt
vlabsta:       POP  HL
vlabfound:     LD   DE,linebuff
               LD   B,(HL)
               LD   C,B
vlabfl:        DEC  HL
               LD   A,(HL)
               LD   (DE),A
               INC  DE
               DJNZ vlabfl
               LD   A,16
               SUB  C
               LD   B,A
               LD   A,32
vlabsp1:       LD   (DE),A
               INC  DE
               DJNZ vlabsp1
               DEC  HL
               DEC  HL
               PUSH DE
               LD   E,(HL)
               DEC  HL
               LD   D,(HL)
               DEC  HL
               EX   (SP),HL
               EX   DE,HL
               PUSH HL
               CALL get10000
               LD   A,32
               LD   (DE),A
               INC  DE
               LD   (DE),A
               INC  DE
               LD   A,"&"
               LD   (DE),A
               INC  DE
               POP  HL
               CALL gethex
               LD   B,4
               LD   A,32
vlabsp2:       LD   (DE),A
               INC  DE
               DJNZ vlabsp2
               POP  HL
               LD   A,(labpage)
               BIT  6,H
               RES  6,H
               JR   NZ,vlabpg1
               DEC  A
vlabpg1:       LD   (labpage),A
               LD   (laboffs),HL
               CALL restore
               LD   HL,linebuff
               LD   B,32
vlabprt:       LD   A,(labchan)
               AND  A
               LD   A,(HL)
               JR   Z,vlabdis
               RST  16
               JR   vlabbot
vlabdis:       PUSH HL
               CALL scrchan
               POP  HL
vlabbot:       INC  HL
               DJNZ vlabprt
               LD   A,(labcolt)
               DEC  A
               JR   NZ,vlablin
               LD   A,(labchan)
               AND  A
               JR   Z,vlabcrs
               CALL carret
               JR   vlablin-3
vlabcrs:       LD   A,13
               CALL scrchan
               LD   A,(labcol)
vlablin:       LD   (labcolt),A
               LD   A,247
               IN   A,(249)
               AND  32
               RET  Z
               JP   vlabloop
vlabnxt:       POP  HL
               LD   A,(HL)
               ADD  4
               LD   B,0
               LD   C,A
               SBC  HL,BC
               LD   A,(labpage)
               BIT  6,H
               RES  6,H
               JR   NZ,vlabpg2
               DEC  A
vlabpg2:       LD   (labpage),A
               LD   (laboffs),HL
               CALL restore
               JP   vlabloop
vlabex:        CALL restore
               RET

errorhandler:  POP  HL
               LD   SP,(errorsp)
               CALL pomessage
               LD   A,(comflag)
               AND  A
               JP   Z,prtcurlin
               JP   comline

pomessage:     EX   DE,HL
               CALL lineaddr
               CALL redprtstr
               LD   A,32
               CALL redprint
               LD   A,(beepflag)
               AND  A
               JR   Z,errcont
               LD   HL,soundtab
               LD   BC,&0EFF
               OTIR
               INC  B
               LD   D,24
               LD   A,16
beepdel:       HALT
               CP   12
               JR   C,beepcnt
               HALT
beepcnt:       OUT  (C),D
               DEC  A
               JR   NZ,beepdel
errcont:       LD   HL,&5C3B
errwait:       BIT  5,(HL)
               JR   Z,errwait
               RET
waitonkey:     LD   HL,&5C3B
               LD   A,247
               IN   A,(249)
               AND  32
               RET  Z
               BIT  5,(HL)
               JR   Z,waitonkey+3
               RES  5,(HL)
               RET
redprtstr:     LD   A,(DE)
               AND  127
               PUSH DE
               CALL redprint
               POP  DE
               LD   A,(DE)
               INC  DE
               RLA
               JR   NC,redprtstr
               RET
prtstr:        LD   A,(DE)
               AND  127
prtstr2:       PUSH DE
               CALL prtathl
               POP  DE
               LD   A,(DE)
               INC  DE
               RLA
               JR   NC,prtstr
               RET
redprint:      LD   E,A
               XOR  A
               RL   E
               RLA
               RL   E
               RLA
               RL   E
               RLA
               RL   E
               RLA
               ADD  chartabel/256-2
               LD   D,A
               LD   BC,127
               LD   A,8
errprtchr:     EX   AF,AF'
               EX   DE,HL
               LD   A,(HL)
colmask1:      XOR  170
               AND  (HL)
               LD   (DE),A
               INC  E
               INC  L
               LD   A,(HL)
colmask2:      XOR  170
               AND  (HL)
               LD   (DE),A
               EX   DE,HL
               INC  E
               ADD  HL,BC
               EX   AF,AF'
               DEC  A
               JR   NZ,errprtchr
               LD   BC,-1022
               ADD  HL,BC
               RET

blankline:     DEFB 2,0
blockmarker:   DEFB 14
               DEFM " ** Block **"
               DEFB 0
exafaf:        DEFM "EX AF,AF'"
               DEFB 128

;-- editor errors --

comerror:      CALL errorhandler
               DEFM "Not understoo"
               DEFB "d"+128
numerror:      CALL errorhandler
               DEFM "Number out of rang"
               DEFB "e"+128

clrsource:     DEFM "Delete source (Y/N)"
               DEFB "?"+128
prtmess:       DEFM "Abort printing (Y/N)"
               DEFB "?"+128
cometstr:      DEFM "* *   C O M E T   * "
               DEFB "*"+128
assestr:       DEFM "Assembler for the SAM Coup"
               DEFB "e"+128
writestr:      DEFM "Written by Edwin Blin"
               DEFB "k"+128
keystr:        DEFM "Press any key to continue.."
               DEFB "."+128
ascomp:        DEFM "Assembly completed, no error"
               DEFB "s"+128
objlen:        DEFM "Object code 00000 byte"
               DEFB "s"+128
symlab:        DEFM "Comet symbol tabel "
lablen:        DEFM "00000 Labels use"
               DEFB "d"+128
asabor:        DEFM "Assembly aborte"
               DEFB "d"+128
outsym:        DEFM "Out of symbol spac"
               DEFB "e"+128
checer:        DEFM "Check source for error"
               DEFB "s"+128
escerr:        DEFM "Escape presse"
               DEFB "d"+128
nummes:        DEFM "00000 000=Hi 000=Lo &0000 "
               DEFM "%00000000=Hi %00000000=Lo ASCII ' '=L"
               DEFB "o"+128

coma:          LD   A,128
               OUT  (254),A
               LD   A,(asspage)
               DEC  A
               CALL getset
               LD   HL,listflag
               LD   DE,listflag-ofhi
               LD   BC,laboffs-listflag+1
               LDIR
               OUT  (251),A
               JP   assentry

assexit:       IN   A,(252)
               AND  31
               OUT  (251),A
               LD   A,(asspage)
               DEC  A
               OUT  (250),A
               LD   HL,listflag-ofhi
               LD   DE,listflag
               LD   BC,laboffs-listflag+1
               LDIR
               CALL restore
               CALL message
               XOR  A
               OUT  (254),A
               LD   A,(errcount)
               AND  A
               LD   HL,45090
               LD   DE,ascomp
               JR   NZ,exitcont
               CALL redprtstr
               LD   HL,(bytecount)
               LD   DE,objlen+12
               CALL get10000
               LD   HL,47144
               LD   DE,objlen
               CALL redprtstr
               LD   HL,(labcount)
               LD   DE,lablen
               CALL get10000
               LD   HL,49198
               LD   DE,lablen
               CALL redprtstr
               JR   escaped+3
exitcont:      LD   HL,46126
               LD   DE,asabor
               PUSH AF
               LD   A,85
               LD   (colmask1+1),A
               LD   (colmask2+1),A
               CALL redprtstr
               LD   A,170
               LD   (colmask1+1),A
               LD   (colmask2+1),A
               POP  AF
               LD   HL,48176
               LD   DE,escerr
               RL   A
               JR   C,escaped
               LD   HL,48172
               LD   DE,outsym
               RL   A
               JR   C,escaped
               LD   HL,48178
               LD   DE,memerr
               RLA
               JR   C,escaped
               LD   HL,48168
               LD   DE,checer
escaped:       CALL pomessage+4
               CALL waitonkey
               JP   tppag

message:       CALL clearscr
               LD   HL,34858
               LD   DE,cometstr
               CALL prtstr
               LD   HL,36952
               DEC  DE
               LD   A,","
               CALL prtstr2
               LD   HL,37924
               CALL prtstr
               LD   HL,41000
               CALL prtstr
               LD   HL,54308
               JP   prtstr

commandtab:    DEFW coma           ;command jump table
               DEFW comm
               DEFW comc
               DEFW comm
               DEFW comm
               DEFW comf
               DEFW comm
               DEFW comerror
               DEFW comi
               DEFW comerror
               DEFW comerror
               DEFW comm
               DEFW comm
               DEFW comn
               DEFW comm
               DEFW comp
               DEFW comm
               DEFW comr
               DEFW comm
               DEFW comt
               DEFW comu
               DEFW comv
               DEFW comw
               DEFW comx
               DEFW comerror
               DEFW comm

tokentab:      DEFB "A"+128               ;98 tokens
               DEFB "A","D","C"+128       ;ASCII values for each
               DEFB "A","D","D"+128       ;token last char has
               DEFB "A","F"+128           ;bit 7 set
               DEFB "A","N","D"+128
               DEFB "B"+128
               DEFB "B","C"+128
               DEFB "B","I","T"+128
               DEFB "C"+128
               DEFB "C","A","L","L"+128
               DEFB "C","C","F"+128
               DEFB "C","P"+128
               DEFB "C","P","D"+128
               DEFB "C","P","D","R"+128
               DEFB "C","P","I"+128
               DEFB "C","P","I","R"+128
               DEFB "C","P","L"+128
               DEFB "D"+128
               DEFB "D","A","A"+128
               DEFB "D","E"+128
               DEFB "D","E","C"+128
               DEFB "D","E","F","B"+128
               DEFB "D","E","F","M"+128
               DEFB "D","E","F","S"+128
               DEFB "D","E","F","W"+128
               DEFB "D","I"+128
               DEFB "D","J","N","Z"+128
               DEFB "D","U","M","P"+128
               DEFB "E"+128
               DEFB "E","I"+128
               DEFB "E","Q","U"+128
               DEFB "E","X"+128
               DEFB "E","X","X"+128
               DEFB "H"+128
               DEFB "H","A","L","T"+128
               DEFB "H","L"+128
               DEFB "I"+128
               DEFB "I","M"+128
               DEFB "I","N"+128
               DEFB "I","N","C"+128
               DEFB "I","N","D"+128
               DEFB "I","N","D","R"+128
               DEFB "I","N","I"+128
               DEFB "I","N","I","R"+128
               DEFB "I","X"+128
               DEFB "I","Y"+128
               DEFB "J","P"+128
               DEFB "J","R"+128
               DEFB "L"+128
               DEFB "L","D"+128
               DEFB "L","D","D"+128
               DEFB "L","D","D","R"+128
               DEFB "L","D","I"+128
               DEFB "L","D","I","R"+128
               DEFB "L","I","S","T"+128
               DEFB "M"+128
               DEFB "M","D","A","T"+128
               DEFB "N","C"+128
               DEFB "N","E","G"+128
               DEFB "N","O","P"+128
               DEFB "N","Z"+128
               DEFB "O","F","F"+128
               DEFB "O","N"+128
               DEFB "O","R"+128
               DEFB "O","R","G"+128
               DEFB "O","T","D","R"+128
               DEFB "O","T","I","R"+128
               DEFB "O","U","T"+128
               DEFB "O","U","T","D"+128
               DEFB "O","U","T","I"+128
               DEFB "P"+128
               DEFB "P","E"+128
               DEFB "P","O"+128
               DEFB "P","O","P"+128
               DEFB "P","U","S","H"+128
               DEFB "R"+128
               DEFB "R","E","S"+128
               DEFB "R","E","T"+128
               DEFB "R","E","T","I"+128
               DEFB "R","E","T","N"+128
               DEFB "R","L"+128
               DEFB "R","L","A"+128
               DEFB "R","L","C"+128
               DEFB "R","L","C","A"+128
               DEFB "R","L","D"+128
               DEFB "R","R"+128
               DEFB "R","R","A"+128
               DEFB "R","R","C"+128
               DEFB "R","R","C","A"+128
               DEFB "R","R","D"+128
               DEFB "R","S","T"+128
               DEFB "S","B","C"+128
               DEFB "S","C","F"+128
               DEFB "S","E","T"+128
               DEFB "S","L","A"+128
               DEFB "S","L","L"+128
               DEFB "S","P"+128
               DEFB "S","R","A"+128
               DEFB "S","R","L"+128
               DEFB "S","U","B"+128
               DEFB "X","O","R"+128
               DEFB "Z"+128
               DEFB 255            ;end marker

;System variables editor and assembler

listflag:      DEFB 0              ;list on off flag on assemble
tabtemp:       DEFB 0              ;temporary colum save(commands)
comflag:       DEFB 0              ;<>0 if in command mode
insertflag:    DEFB 0              ;insert line after return
startp:        DEFB 5              ;start of source and work-
starto:        DEFW 16379          ;space
endp:          DEFB 5              ;end of source points to a 0
endo:          DEFW 16383          ;byte which is the end marker
windowp:       DEFB 5              ;current 24 source lines
windowo:       DEFW 16379          ;(displayed)
curradp:       DEFB 5              ;current line (the line that
currado:       DEFW 16379          ;is been edited)
symendp:       DEFB 5              ;end of symboltable grows
symendo:       DEFW 16383          ;down wards to endpo
symstrtp:      DEFB 5              ;start of symboltable always
symstarto:     DEFW 16383          ;end of workspace less one
temp1:         DEFB 4              ;on init workspace len else
tempo1:        DEFW 0              ;used by block coms & execute
temp2:         DEFB 27             ;on init worspace end else
tempo2:        DEFW 16383          ;used by block coms
scrpos:        DEFW &8000          ;screen position
altflag:       DEFB 0              ;alterflag(eline)/includeflag
semiflag:      DEFB ";"            ;supress semicolon(print com)
beepflag:      DEFB 255            ;error beeps on
printerflag:   DEFB 255            ;printer connected if <>0
feedflag:      DEFB 255            ;linefeed after cariage return
findtype:      DEFB "E"            ;used by find command
findbuff:      DEFB 14             ;length for find string
               DEFM "Edwin Blink...";Notused anymore
asspage:       DEFB 31             ;page of assembler/editor
sproom:        DEFW 0              ;temporary stack save editor
errorsp:       DEFW 0              ;error stack
printinit:     DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ;ctrlcodes
tabtable:      DEFB 0,30,40,52,70,126                 ;tabs
soundtab:      DEFB 28,1,24,0,2,255,10,95,17,4,20,4,24;beep data
               DEFB 164
asp:           DEFW 0              ;assembler stack
asflag:        DEFB 0              ;assembler flag
errcount:      DEFB 0              ;number of errors/error type
               DEFW 0              ;fill up
dum:           DEFB 1              ;dump address for objectcode
dumo:          DEFW 0
scrlcount:     EQU  $              ;scroll counter used by print
labchan:       EQU  $+1            ;label output channel
labcol:        EQU  $+2            ;number of label columns
labcolt:       EQU  $+3            ;temporary label column
aspc:          DEFW 0              ;origin program counter
aspcl:         DEFW 0              ;line program counter
bytecount:     DEFW 0              ;length of objectcode
labcount:      DEFW 0              ;number of labels
labpage:       DEFB 0              ;current label addres
laboffs:       DEFW 0

linebuff:      DEFS 65             ;edit line(block address)
compbuff:      DEFS 68             ;compress buffer
               DEFS 123            ;stack room(61 pushes)
chartabel:     MDAT "chardata"     ;expanded character set
length:        EQU  $-start-&4000
