#once
#bits 4

#subruledef reg
{
    A       => 0x0
	B       => 0x1
	ALU     => 0x2
	F       => 0x3
	ADDR_0  => 0x4
	ADDR_1  => 0x5
	ADDR_2  => 0x6
}


#ruledef 
{
    mov {r1: reg},      {r2: reg}       => 0x0`4 @ 0x0`2 @ r1`3  @ r2`3
    mov {value: u4},    {r1: reg}       => 0x0`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    sto {r1}                            => 0x1`4 @ 0x0`2 @ 0x0`3 @ r1`3
    sto {r1},           {value: u12}    => 0x1`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`12
    ld  {r1}                            => 0x2`4 @ 0x0`2 @ 0x0`3 @ r1`3
    ld  {r1},           {value: u12}    => 0x2`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`12
    add {r1: reg},      {r2: reg}       => 0x3`4 @ 0x0`2 @ r1`3  @ r2`3
    add {r1: reg}       {value: u4}     => 0x3`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    inc {r1: reg}                       => 0x3`4 @ 0x2`2 @ 0x0`3 @ r1`3
    adc {r1: reg},      {r2: reg}       => 0x4`4 @ 0x0`2 @ r1`3  @ r2`3
    adc {r1: reg},      {value: u4}     => 0x4`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    sub {r1: reg},      {r2: reg}       => 0x5`4 @ 0x0`2 @ r1`3  @ r2`3
    sub {r1: reg}       {value: u4}     => 0x5`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    sub {value: u4}}    {reg: r1}       => 0x5`4 @ 0x2`2 @ r1`3  @ r2`3 @ value`4
    dec {r1: reg}                       => 0x5`4 @ 0x3`2 @ 0x0`3 @ r1`3
    sbb {r1: reg},      {r2: reg}       => 0x6`4 @ 0x0`2 @ r1`3  @ r2`3
    sbb {r1: reg},      {value: u4}     => 0x6`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    sbb {value: u4},    {reg: r1}       => 0x6`4 @ 0x2`2 @ 0x0`3 @ r1`3 @ value`4
    shl {r1: reg}                       => 0x7`4 @ 0x0`2 @ 0x0`3 @ r2`3
    shr {r1: reg}                       => 0x7`4 @ 0x1`2 @ 0x0`3 @ r2`3
    nand {r1: reg}, {r2: reg}           => 0x8`4 @ 0x0`2 @ r1`3  @ r2`3
    nand {r1: reg}, {value: u4}         => 0x8`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    nor  {r1: reg}, {r2: reg}           => 0x8`4 @ 0x0`2 @ r1`3  @ r2`3
    nor  {r1: reg}, {value: u4}         => 0x8`4 @ 0x1`2 @ 0x0`3 @ r2`3 @ value`4
    and  {r1: reg}, {r2: reg}           => 0x9`4 @ 0x0`2 @ r1`3  @ r2`3
    and  {r1: reg}, {value: u4}         => 0x9`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    or   {r1: reg}, {r2: reg}           => 0x9`4 @ 0x0`2 @ r1`3  @ r2`3
    or   {r1: reg}, {value: u4}         => 0x9`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    xor  {r1: reg}, {r2: reg}           => 0xa`4 @ 0x0`2 @ r1`3  @ r2`3
    xor  {r1: reg}, {value: u4}         => 0xa`4 @ 0x1`2 @ 0x0`3 @ r1`3 @ value`4
    not  {r1: reg}                      => 0xa`4 @ 0x2`2 @ 0x0`3 @ r1`3
    jmp                                 => 0xb`4 @ 0x0`2 @ 0x0`2 @
    jmp  {value: u12}                   => 0xb`4 @ 0x1`2 @ 0x0`2 @ value`12
    jnz                                 => 0xc`4 @ 0x0`2 @ 0x0`2 @
    jnz  {value: u12}                   => 0xc`4 @ 0x1`2 @ 0x0`2 @ value`12
    jnc                                 => 0xd`4 @ 0x0`2 @ 0x0`2 @
    jnc  {value: u12}                   => 0xd`4 @ 0x1`2 @ 0x0`2 @ value`12
    jnb                                 => 0xd`4 @ 0x2`2 @ 0x0`2 @
    jnb  {value: u12}                   => 0xe`4 @ 0x3`2 @ 0x0`2 @ value`12
    jnl                                 => 0xe`4 @ 0x0`2 @ 0x0`2 @
    jnl  {value: u12}                   => 0xe`4 @ 0x1`2 @ 0x0`2 @ value`12 
    nop                                 => 0xf`12
}