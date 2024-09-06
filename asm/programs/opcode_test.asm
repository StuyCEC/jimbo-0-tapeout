#include "jimbo_ruleset.asm"

init:
    jmp alu_test

alu_test:

    ; Test ADD
    mov 0x5, a
    mov 0x2, b
    add a, b
    sto a, 0x0f1

    ; Test SUB
    mov 0x5, a
    mov 0x2, b
    sub a, b
    sto a, 0x0f2

    ; Test AND
    mov 0xf, a
    mov 0xf, b
    and a, b
    sto a, 0x0f3

    ; Test OR
    mov 0x5, a
    mov 0x2, b
    or a, b
    sto a, 0x0f4

    ; Test XOR
    mov 0xf, a
    mov 0x3, b
    xor a, b
    sto a, 0x0f5

    ; Test NOT
    mov 0xf, a
    not a
    sto a, 0x0f6

    ; Test SHL
    mov 0x3, a
    shl a
    sto a, 0x0f7

    ; Test SHR
    mov 0x8, a
    shr a
    sto a, 0x0f8

    ; Test INC
    mov 0x7, a
    inc a
    sto a, 0x0f9

    ; Test DEC
    mov 0x7, a
    dec a
    sto a, 0x0fa

    ; Test ADC
    mov 0x4, a
    mov 0x1, b
    adc a, b
    sto a, 0x0fb

    ; Test SBB
    mov 0x9, a
    mov 0x2, b
    sbb a, b
    sto a, 0x0fc

    ; Test NOP (shouldn't affect anything, just move to next instruction)
    nop

    ; Test STO and LD with immediate value
    mov 0x5, a
    sto a, 0x0fd
    ld a, 0x0fd
    sto a, 0x0fe

end:
    jmp 0x7ff
