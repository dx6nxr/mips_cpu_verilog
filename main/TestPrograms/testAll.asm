lui $2, 0x0000
ori $2, 493
lui $3, 0x0000
ori $3, 23
bltz $2, inc
jal mult

main:
mfhi $2
mflo $3
j exit


inc: 
addu $2, $2, $2
j main

mult:
multu $2, $3
jr $ra
exit:
