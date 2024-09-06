#include "jimbo_ruleset.asm"

init:
    jmp adc_sbb_test

adc_sbb_test:

    ; Test ADC without carry
    mov 0x4, a
    mov 0x2, b
    adc a, b
    sto a, 0x200   ; Expect result 6 (4 + 2)

    ; Test ADC with carry
    mov 0xF, a      ; a = 15
    mov 0x1, b      ; b = 1
    adc a, b        ; 15 + 1 + carry (carry should be set to 1)
    sto a, 0x201    ; Expect result 0 (due to 4-bit overflow), carry = 1

    ; Test ADC with carry propagated
    mov 0x3, a      ; a = 3
    mov 0x2, b      ; b = 2
    adc a, b        ; 3 + 2 + carry = 6
    sto a, 0x202    ; Expect result 6

    ; Test SBB without borrow
    mov 0x9, a
    mov 0x3, b
    sbb a, b
    sto a, 0x203    ; Expect result 6 (9 - 3)

    ; Test SBB with borrow
    mov 0x2, a      ; a = 2
    mov 0x3, b      ; b = 3
    sbb a, b        ; 2 - 3 - borrow (borrow should be set to 1)
    sto a, 0x204    ; Expect result F (since it's a 4-bit, 2 - 3 = -1 or 0xF in 4-bit representation)

    ; Test SBB with borrow propagated
    mov 0x5, a      ; a = 5
    mov 0x4, b      ; b = 4
    sbb a, b        ; 5 - 4 - borrow = 0
    sto a, 0x205    ; Expect result 0

end:
    jmp 0x7FF