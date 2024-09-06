#include "jimbo_ruleset.asm"

init:
    jmp alu_test

alu_test:

    ; Test ADD
    mov 0x5, a
    mov 0x2, b
    add a, b
    sto a, 0x0f1  ; Result: 0x7

    ; Test SUB (reg, reg)
    mov 0x5, a
    mov 0x2, b
    sub a, b
    sto a, 0x0f2  ; Result: 0x3

    ; Test SUB (reg, value)
    mov 0x7, a
    sub 0x2, a
    sto a, 0x0f3  ; Result: 0x5

    ; Test SUB (value, reg)
    sub 0x1, a
    sto a, 0x0f4  ; Result: 0x4

    ; Test AND
    mov 0xf, a
    mov 0xf, b
    and a, b
    sto a, 0x0f5  ; Result: 0xf

    ; Test OR
    mov 0x5, a
    mov 0x2, b
    or a, b
    sto a, 0x0f6  ; Result: 0x7

    ; Test XOR
    mov 0xf, a
    mov 0x3, b
    xor a, b
    sto a, 0x0f7  ; Result: 0xc

    ; Test NOT
    mov 0xf, a
    not a
    sto a, 0x0f8  ; Result: 0x0

    ; Test SHL
    mov 0x3, a
    shl a
    sto a, 0x0f9  ; Result: 0x6

    ; Test SHR
    mov 0x8, a
    shr a
    sto a, 0x0fa  ; Result: 0x4

    ; Test INC
    mov 0x7, a
    inc a
    sto a, 0x0fb  ; Result: 0x8

    ; Test DEC
    mov 0x7, a
    dec a
    sto a, 0x0fc  ; Result: 0x6

    ; Test ADC (reg, reg), handling carry overflow
    mov 0xf, a
    mov 0x1, b
    adc a, b
    sto a, 0x0fd  ; Lower 4 bits = 0x0, carry should be set

    mov 0xf, a
    adc a, 0  ; Add carry
    sto a, 0x0fe  ; Lower 4 bits = 0x1 (carry applied)

    ; Test SBB (reg, reg)
    mov 0x9, a
    mov 0x2, b
    sbb a, b
    sto a, 0x0ff  ; Result: 0x7

    ; Test SBB (reg, value)
    mov 0x8, a
    sbb a, 0x1
    sto a, 0x100  ; Result: 0x7

    ; Test SUB with borrow
    mov 0x7, a
    sbb 0x2, a
    sto a, 0x101  ; Result: 0x5
    
    ; Test SBB (value, reg)
    mov 0x6, a
    sbb 0x1, a
    sto a, 0x102  ; Result: 0x5

    ; Test STO and LD with immediate value
    mov 0x5, a
    sto a, 0x103  ; Store 0x5
    ld a, 0x103   ; Load from memory
    sto a, 0x104  ; Store loaded value back

end:
    jmp 0x7ff
