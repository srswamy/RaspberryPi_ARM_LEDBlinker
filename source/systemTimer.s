.globl GetTimerAddress
GetTimerAddress:
ldr r0,=0x20003000
mov pc,lr

.globl GetCurrentTime
GetCurrentTime:
push {lr}
bl GetTimerAddress
ldrd r0,r1,[r0,#4]
pop {pc}

.globl WaitFunction
WaitFunction:
delay .req r2
mov delay,r0
push {lr}
bl GetCurrentTime
start .req r3
mov start,r0
loop$:
	bl GetCurrentTime
	elapsed .req r1
	sub elapsed,r0,start
	cmp elapsed,delay
	.unreq elapsed
	bls loop$
.unreq delay
.unreq start
pop {pc}
