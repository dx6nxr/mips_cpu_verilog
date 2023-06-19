jal func
lui $2, 0x1234
ori $2, 100
lui $3, 0x0000
ori $3, 238
multu $2, $3
mfhi $2
mflo $4
j exit

func:
addiu $5, $0, 7
lui $6, 0x0000
ori $6, 5
jr $ra

exit: