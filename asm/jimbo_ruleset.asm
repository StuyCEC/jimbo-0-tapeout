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
    mov {r1: reg},      {r2: reg}
    mov {value: u4},    {r1: reg}
    sto {r1}
    sto {r1},           {value: u12}
    ld  {r1}
    ld  {r1},           {value: u12}
    add {r1: reg},      {r2: reg}
    add {r1: reg}       {value: u4}
    inc {r1: reg}
    adc {r1: reg},      {r2: reg}
    adc {r1: reg},      {value: u4}
    sub {r1: reg},      {r2: reg}
    sub {r1: reg}       {value: u4}
    sub {value: u4}}    {reg: r1}
    dec {r1: reg}
    sbb {r1: reg},      {r2: reg}
    sbb {r1: reg},      {value: u4}
    sbb {value: u4},    {reg: r1}
    shl {r1: reg}
    shr {r1: reg}    
    nand {r1: reg}, {r2: reg}
    nand {r1: reg}, {value: u4}

}