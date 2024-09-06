#include "jimbo_ruleset.asm"

init:
    jmp test_conditions  ; Jump to the start of the test

test_conditions:

    ; Test INC and DEC (with conditional branches)
    mov 0x0, a           ; Initialize a = 0
    inc a
    sto a, 0x201
    dec a
    jnz poop
    jmp end
poop:
    mov 0xf, b 
    sto b, 0x201
    jmp end
end:
    jmp 0x7FF            ; End of test program
