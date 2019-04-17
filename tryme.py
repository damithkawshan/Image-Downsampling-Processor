import re
import sys
import time

ops = {
    'nop': 0b0000,
    'add': 0b0001,
    'sub': 0b0010,
    'mul': 0b0011,
    'div': 0b0100,
    'shr': 0b0101,
    'shl': 0b0110,
    'load': 0b0111,
    'store': 0b1000,
    'jump': 0b1001,
    'jmpz': 0b1010,
    'jmpdec': 0b1011,
    'move': 0b1100,
    'uartsend': 0b1101,
    'uartread': 0b1110
}
reg = {
    'zr': 0b00000,
    'mbr': 0b00001,
    'mdr': 0b00010,
    'uarttx': 0b00011,
    'uartrx': 0b00100,
    'ac': 0b00101,
    'lr': 0b00110
}
argCount = len(sys.argv)
infileName = ''
oufileName = 'results.txt'
if argCount < 2:
    print("no input file\nusage:\ncompileme.py <input file name(required)> <output file name(optional)>")
    exit()
elif argCount == 2:
    infileName = sys.argv[1]
    print('output file named as results.txt')
else:
    infileName = sys.argv[1]
    oufileName = sys.argv[2]

localtime = time.asctime( time.localtime(time.time()) )
infile = open(infileName, 'r')
oufile = open(oufileName, 'w')
oufile.write("******* simulation results - generated on "+localtime+"*********\n\nsimulation start\n\n")
lineNo = 0

#registers
REGS = {
    'zr': 0,
    'mbr': 0,
    'mdr': 0,
    'uarttx': 0,
    'uartrx': 0,
    'ac': 0,
    'lr': 0
}
GPR = {0:0,1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0,15:0}
#GPR = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
MEM = {0:7}

alllines=infile.readlines()
while(lineNo<len(alllines)):
    line=alllines[lineNo]
    thisLineNo=lineNo+1
    line = line.lower().strip()
    x = (re.split("\s+", line))

    # warn if x[0] is not in ops
    if not (x[0] in ops.keys()):
        print('Error at line', lineNo+1, ':', x[0], ' is not a valid instruction')
        break

    command = '{:04b}'.format(ops[x[0]])
    if (x[0] == 'nop'):
        command = command + '000000000000'
        lineNo = lineNo + 1




    elif (x[0] in ['add', 'sub', 'mul', 'div']):
        operand=0
        toac=0
        if (x[1][0] == 'r'):
            # warn if index is not numeric
            if not x[1][1:].isdecimal():
                print('Error at line', lineNo+1, ':', x[1], 'is not a valid register')
                break

            regNum = int(x[1][1:])

            # warn if index>number of registers
            if regNum < 0 or regNum > 15:
                print('Error at line', lineNo+1, ':', x[1], 'exceeds valid register index range')
                break

            command = command + '1' + '{:04b}'.format(regNum)
            operand=GPR[regNum]
        else:
            # warn if not a valid registers
            if not x[1] in reg.keys():
                print('Error at line', lineNo+1, ':', x[1], 'is not a valid register')
                break
            command = command + '0' + '{:04b}'.format(reg[x[1]])
            operand=REGS[x[1]]
        command = command + '' + '{:07b}'.format(int(x[2]))
        if x[0]=='add':
            toac=REGS['ac']+(operand+int(x[2]))
        elif x[0]=='sub':
            toac = REGS['ac'] - (operand + int(x[2]))
        elif x[0]=='mul':
            toac = REGS['ac'] * (operand + int(x[2]))
        elif x[0]=='div':
            toac = REGS['ac'] / (operand + int(x[2]))
        else:
            toac = REGS['ac']
        REGS['ac']=int(toac)
        lineNo = lineNo + 1



    elif (x[0] in ['shr', 'shl']):
        # warn for shift range
        num = '{:012b}'.format(int(x[1]))
        if int(x[1]) < 0 or int(x[1]) > 15:
            print('Error at line', lineNo+1, ':', x[1], 'exceeds valid shift range')
            break
        command = command + '' + num
        if x[0]=='shr': REGS['ac']=REGS['ac']>>int(x[1])
        else: REGS['ac']=REGS['ac']<<int(x[1])
        lineNo = lineNo + 1




    elif (x[0] in ['load', 'store']):
        # TODO: warn for address range
        num = int(x[1])
        if num < 0 or num > 4095:
            print('Error at line', lineNo+1, ':', x[1], 'exceeds valid immediate accessible address range')
            break
        command = command + '' + '{:012b}'.format(int(x[1]))
        mar = num + REGS['mbr'] * 2
        if x[0]=='store':
            MEM[mar]=REGS['mdr']
            oufile.write('storing mem data at address ' + str(mar) + '.\n')
            print('stroing mem data at address', mar, '.')
        else:
            if mar in MEM.keys():
                REGS['mdr']=MEM[mar]
                oufile.write('reading mem data at address ' + str(mar) + '.\n')
                print('reading mem data at address', mar, '.')
            else:
                REGS['mdr']=0
                oufile.write('no mem data at address '+str(mar)+'. so 0 assumed.\n')
                print('no mem data at address',mar,'. so 0 assumed.')

        lineNo = lineNo + 1





    elif (x[0] in ['jump', 'jmpz', 'jmpdec']):
        # warn for address range
        num = int(x[1])
        if num < 0 or num > 4095:
            print('Error at line', lineNo+1, ':', x[1], 'exceeds valid immediate accessible address range')
            break
        command = command + '' + '{:012b}'.format(int(x[1]))
        if x[0]=='jump': lineNo=num; oufile.write('jump to '+str(num)+'.\n')
        elif x[0]=='jmpz':
            if REGS['ac']==0: lineNo=num; oufile.write('jmpz to '+str(num)+'.\n')
            else:lineNo=lineNo+1
        else:
            if REGS['lr']>0:
                REGS['lr']-=1
                lineNo=num
                oufile.write('jmpdec to ' + str(num) + '.\n')
            else: lineNo=lineNo+1





    elif (x[0] == 'move'):
        breakAll = False
        sourceVal=0
        isGpr=[False, False]
        for i in range(0, 2):
            if (x[i + 1][0] == 'r'):
                # warn if index is not numeric
                if not x[i + 1][1:].isdecimal():
                    print('Error at line', lineNo+1, ':', x[i + 1], 'is not a valid register')
                    breakAll = True
                    break

                regNum = int(x[i + 1][1:])

                # warn if index>number of registers
                if regNum < 0 or regNum > 15:
                    print('Error at line', lineNo+1, ':', x[i + 1], 'exceeds valid register index range')
                    breakAll = True
                    break

                command = command + '01' + '{:04b}'.format(regNum)
                isGpr[i]=True
            else:
                # warn if not a valid registers
                if not x[i + 1] in reg.keys():
                    print('Error at line', lineNo+1, ':', x[i + 1], 'is not a valid register')
                    breakAll = True
                    break

                command = command + '00' + '{:04b}'.format(reg[x[i + 1]])

        if breakAll:
            break

        if isGpr[0]: sourceVal = GPR[int(x[1][1:])]
        else: sourceVal=REGS[x[1]]
        if isGpr[1]: GPR[int(x[2][1:])]=sourceVal
        else: REGS[x[2]]=sourceVal
        lineNo=lineNo+1






    elif (x[0] in ['uartsend', 'uartread']):
        command = command + '000000000000'
        lineNo=lineNo+1
        if x[0]=='uartsend':
            print('uartsend:',REGS['uarttx'])
            oufile.write('uart output sent. value:'+str(REGS['uarttx'])+'.\n')
        else:
            done=False
            while(not done):
                uinput=input('enter uart read number within range:0 to 255\n')
                if uinput.isdecimal() and int(uinput)>-1 and int(uinput)<256:
                    uinput=int(uinput)
                    REGS['uartrx']=uinput
                    oufile.write('uart input given. value:'+str(uinput)+'.\n')
                    done=True
                else:
                    print('invalid uart input!\n')




    else:
        # warn about errors
        print('unknown compile error!')
        break





    print(thisLineNo, '.', x, REGS, GPR, MEM)
    dd=str(thisLineNo)+'.\t'+line+'\n\t'+str(REGS)+' \n\tgpr:'+str(GPR)+' \n\tmem:'+str(MEM)+'\n\n'
    oufile.write(dd)

if lineNo==len(alllines):
    print('simulation end')
    oufile.write('simulation end.')
else:
    print('simulation interrupted')
    oufile.write('simulation interrupted.')
