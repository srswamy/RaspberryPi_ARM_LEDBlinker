/* Make GetGpioAddress label accessible to all files */
.globl GetGpioAddress
GetGpioAddress:
/* Store base address of GPIO controller*/
ldr r0,=0x20200000
/* Set return address */
mov pc,lr
/* Used to set the function of a GPIO pin*/
.globl SetGpioFunction
SetGpioFunction:
/* Make sure we have inputs within 53 and 7*/
cmp r0,#53
cmpls r1,#7
movhi pc,lr
/* Store our lr on the stack before branching off */
push {lr}
mov r2,r0
bl GetGpioAddress
/* Find which pin we are dealing with and keep track of its address */
functionLoop$:
cmp r2,#9
subhi r2,#10
addhi r0,#4
bhi functionLoop$
/* Trick to multiple by three: r2 + (2 x r2)*/
add r2, r2,lsl #1
/* Move bit to correct location by shifting left r2 places */
lsl r1,r2
str r1,[r0]
pop {pc}

/* Used to turn the LED on or off */
.globl SetGpio
SetGpio:
/* Setting register aliases to use name */
pinNum .req r0
pinVal .req r1
cmp pinNum,#53
/* If pinNum > 53 then return */
movhi pc,lr
push {lr}
mov r2,pinNum
/* Re-assign our aliases */
.unreq pinNum
pinNum .req r2
bl GetGpioAddress
gpioAddr .req r0
pinBank .req r3
/* GPIO controller has two sets of 4 bytes for turning pins on and off
*  Divide by 32 (2^5) to determine which set our pin resides in. */
lsr pinBank,pinNum,#5
/* Multiply by 4 since set of 4 bytes */
lsl pinBank,#2
/* gpioAddr is 0x20200000 if pin number is 0 - 31
   gpioAddr is 0x20200004 if pin number is 32 - 53 */
add gpioAddr,pinBank
.unreq pinBank
/* Find bit position that needs to be set by taking pinNum % 32*/
and pinNum,#31
setBit .req r3
mov setBit,#1
lsl setBit,pinNum
.unreq pinNum
/* If pinVal is zero, we turn the pin off, otherwise on*/
teq pinVal,#0
.unreq pinVal
/* Turn pin off (LED on) */
streq setBit,[gpioAddr,#40]
/* Turn pin on (LED off) */
strne setBit,[gpioAddr,#28]
.unreq setBit
.unreq gpioAddr
pop {pc}
