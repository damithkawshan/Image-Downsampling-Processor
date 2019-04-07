import re
import sys
ops={
    'nop':0b0000,
    'add':0b0001,
    'sub':0b0010,
    'mul':0b0011,
    'div':0b0100,
    'shr':0b0101,
    'shl':0b0110,
    'load':0b0111,
    'store':0b1000,
    'jump':0b1001,
    'jmpz':0b1010,
    'jmpdec':0b1011,
    'move':0b1100,
    'uartsend':0b1101
}
reg={
    'zr':0b00000,
    'mbr':0b00001,
    'mdr':0b00010,
    'uarttx':0b00011,
    'uartrx':0b00100,
    'ac':0b00101,
    'lr':0b00110
}
argCount=len(sys.argv)
infileName=''
oufileName='compiled.txt'
if argCount<2:
    print("no input file\nusage:\npy_compile.py <input file name(required)> <output file name(optional)>")
    exit()
elif argCount==2:
    infileName = sys.argv[1]
    print('output file named as compiled.txt')
else:
    infileName=sys.argv[1]
    oufileName=sys.argv[2]

infile=open(infileName, 'r')
oufile=open(oufileName,'w')
lineNo=0
for line in infile:
    lineNo=lineNo+1
    line=line.lower()
    x=(re.split("\s+",line))

    #warn if x[0] is not in ops
    if not (x[0] in ops.keys()):
        print('Error:',lineNo,':',x[0],' is not a valid instruction')
        break

    command='{:04b}'.format(ops[x[0]])
    if(x[0]=='nop'):
        command=command+'000000000000'

    elif(x[0] in ['add', 'sub', 'mul', 'div']):
        if(x[1][0]=='r'):
            # warn if index is not numeric
            if not x[1][1:].isdecimal():
                print('Error:', lineNo, ':', x[1], 'is not a valid register')
                break

            regNum=int(x[1][1:])

            #warn if index>number of registers
            if regNum<0 or regNum>15:
                print('Error:', lineNo, ':', x[1], 'exceeds valid register index range')
                break

            command=command+'1'+'{:04b}'.format(regNum)
        else:
            # warn if not a valid registers
            if not x[1] in reg.keys():
                print('Error:', lineNo, ':', x[1], 'is not a valid register')
                break
            command = command + '0' + '{:04b}'.format(reg[x[1]])
        command = command + ''+'{:07b}'.format(int(x[2]))

    elif(x[0] in ['shr', 'shl']):
        # warn for shift range
        num='{:012b}'.format(int(x[1]))
        if int(x[1]) < 0 or int(x[1]) > 15:
            print('Error:', lineNo, ':', x[1], 'exceeds valid shift range')
            break
        command = command + '' + num

    elif(x[0] in ['load', 'store']):
        #TODO: warn for address range
        num=int(x[1])
        if num<0 or num>4095 :
            print('Error:', lineNo, ':', x[1], 'exceeds valid immediate accessible address range')
            break
        command = command + '' + '{:012b}'.format(int(x[1]))


    elif (x[0] in ['jump', 'jmpz', 'jmpdec']):
        #warn for address range
        num = int(x[1])
        if num < 0 or num > 4095:
            print('Error:', lineNo, ':', x[1], 'exceeds valid immediate accessible address range')
            break
        command = command + '' + '{:012b}'.format(int(x[1]))

    elif(x[0] == 'move'):
        breakAll=False
        for i in range(0,2):
            if (x[i+1][0] == 'r'):
                # warn if index is not numeric
                if not x[i+1][1:].isdecimal():
                    print('Error:', lineNo, ':', x[i+1], 'is not a valid register')
                    breakAll=True
                    break

                regNum = int(x[i+1][1:])

                # warn if index>number of registers
                if regNum < 0 or regNum > 15:
                    print('Error:', lineNo, ':', x[i+1], 'exceeds valid register index range')
                    breakAll = True
                    break

                command = command + '01' + '{:04b}'.format(regNum)
            else:
                # warn if not a valid registers
                if not x[1] in reg.keys():
                    print('Error:', lineNo, ':', x[1], 'is not a valid register')
                    breakAll = True
                    break

                command = command + '00' + '{:04b}'.format(reg[x[i+1]])

        if breakAll:
            break

    elif(x[0]=='uartsend'):
        command = command + '000000000000'
    else:
        #warn about errors
        print('unknown compile error!')
        break

    print(lineNo, '.', x,command)
    oufile.write(command+",\n")

if not infile.readline():
    print('compilation end')
else:
    print('compilation interrupted')
