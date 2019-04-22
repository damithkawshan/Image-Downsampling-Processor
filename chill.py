import re
import sys


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








def getValToAc(x):
    num = '{:016b}'.format(x)
    acommand = ''
    zeros = 0
    ones = False
    for i in range(0,16):
        c = num[i]
        if c == '1':
            if zeros and ones: acommand = acommand + 'shl ' + str(zeros) + '\n'
            acommand = acommand + 'add zr 1\n'
            zeros = 0
            if i == 15: ones = False
            else: ones = True
        zeros += 1
    if zeros and ones: acommand = acommand + 'shl ' + str(zeros) + '\n'
    return acommand





argCount = len(sys.argv)
infileName = ''
oufileName = 'precompiled.txt'
compfileName = 'compiled.coe'
if argCount < 2:
    print("no input file\nusage:\nchill.py <input file name(required)> <output file names(optional)>")
    exit()
elif argCount == 2:
    infileName = sys.argv[1]
    print('output files named as precompiled.txt and compiled.coe')
elif argCount == 3:
    infileName = sys.argv[1]
    oufileName = sys.argv[2]
    print('output file named as compiled.coe')
else:
    infileName = sys.argv[1]
    oufileName = sys.argv[2]
    compfileName = sys.argv[2]






# precompiling

infile = open(infileName, 'r')
oufile = open('temp.txt', 'w')
lineNo = 0
command = ''
jumpLines={}
writeLineCount=0
alllines=infile.readlines()

try:
    while(lineNo<len(alllines)):
        line=alllines[lineNo]
        line = line.lower().strip()
        x = (re.split("\s+", line))
        command=''

        if len(x[0])<1: lineNo += 1
        elif x[0][0]==':':
            jumpLines[x[0][1:]]=writeLineCount
            x=x[1:]
        else:
            # warn if x[0] is not in ops
            if not (x[0] in ops.keys()):
                print('Error:', lineNo, ':', x[0], ' is not a valid instruction')
                break


        if (x[0] == 'nop'):
            command = x[0] + '\n'



        elif (x[0] in ['add', 'sub', 'mul', 'div']):
            if x[1][0] == 'r':
                # warn if index is not numeric
                if not x[1][1:].isdecimal():
                    print('Error:', lineNo, ':', x[1], 'is not a valid register')
                    break

                regNum = int(x[1][1:])

                # warn if index>number of registers
                if regNum < 0 or regNum > 15:
                    print('Error:', lineNo, ':', x[1], 'exceeds valid register index range')
                    break

            else:
                # warn if not a valid registers
                if not x[1] in reg.keys():
                    print('Error:', lineNo, ':', x[1], 'is not a valid register')
                    break



            if int(x[2])<128:
                command  = x[0] + ' ' + x[1] + ' ' + x[2] + '\n'
            else:
                num = int(x[2])
                command = x[0] + ' ' + x[1] + ' ' + str(num % 127) + ' //'+ str(lineNo) + '.' + line + '\n'
                for kk in range(0, int(num / 127)):
                    command = command + x[0] + ' zr ' + str(127) + '\n'
                command = command[:-1] + ' //end\n'



        elif (x[0] in ['shr', 'shl']):
            # warn for shift range
            if int(x[1]) < 0 or int(x[1]) > 15:
                print('Error:', lineNo, ':', x[1], 'exceeds valid shift range')
                break
            command = x[0] + ' ' + x[1] + '\n'




        elif (x[0] in ['load', 'store']):
            num = int(x[1])
            #warn for address range
            if num < 0 or num > 131071:
                print('Error:', lineNo, ':', x[1], 'exceeds valid address range')
                break

            if num>4095:
                command = 'move mbr r15 //' + str(lineNo) + '.' + line + '\nmove ac r14\nmove zr ac\n'
                command = command + getValToAc(int(num / 2))
                command = command + 'move ac mbr\n'
                command = command + x[0] + ' ' + str(num%2) + '\n'
                command = command + 'move r15 mbr\nmove r14 ac //end\n'
            else:
                command = x[0] + ' ' + x[1] + '\n' #TODO: correct getValToAC()





        elif (x[0] in ['jump', 'jmpz', 'jmpdec']):
            # warn for address range
            if not x[1][0]==':':
                if not x[1].isdecimal():
                    print('Error:', lineNo, ':', x[1], 'is not a valid immediate accessible address')
                    break
                num = int(x[1])
                if num < 0 or num > 4095:
                    print('Error:', lineNo, ':', x[1], 'exceeds valid immediate accessible address range')
                    break

            command = x[0] + ' ' + x[1] + '\n'





        elif (x[0] == 'move'):
            breakAll = False
            for i in range(0, 2):
                if (x[i + 1][0] == 'r'):
                    # warn if index is not numeric
                    if not x[i + 1][1:].isdecimal():
                        print('Error:', lineNo, ':', x[i + 1], 'is not a valid register')
                        breakAll = True
                        break

                    regNum = int(x[i + 1][1:])

                    # warn if index>number of registers
                    if regNum < 0 or regNum > 15:
                        print('Error:', lineNo, ':', x[i + 1], 'exceeds valid register index range')
                        breakAll = True
                        break

                else:
                    # warn if not a valid registers
                    if not x[i + 1] in reg.keys():
                        print('Error:', lineNo, ':', x[i + 1], 'is not a valid register')
                        breakAll = True
                        break

            if breakAll:
                break


            command = x[0] + ' ' + x[1] + ' ' + x[2] + '\n'






        elif (x[0] in ['uartsend', 'uartread']):
            if x[0]=='uartsend' and len(x)>1 and x[1][0]==':':
                string = x[1]
                command = 'move ac r15 //' + str(lineNo) + '.' + line + '\n'
                for char in string:
                    asciival = ord(char)
                    command = command + 'move zr ac\nadd zr ' + str(asciival) + '\nmove ac uarttx\nuartsend\nnop\n'
                command = command + 'move r15 ac //end\n'
            else:
                command = x[0] + '\n'





        else:
            # warn about errors
            print('Error:', lineNo, ': \'', alllines[lineNo].strip(), '\' : invalid command.')
            break





        #print(thisLineNo, '.', x, REGS, GPR, MEM)
        #dd=str(thisLineNo)+'.\t'+line+'\n\t'+str(REGS)+' \n\tgpr:'+str(GPR)+' \n\tmem:'+str(MEM)+'\n\n'

        dd=command
        writeLineCount=writeLineCount+len(dd.strip().split('\n'))
        oufile.write(dd)
        print(str(lineNo) + '->\n' + dd)
        lineNo = lineNo + 1

except IndexError:
    print('Error:', lineNo, ': \'', alllines[lineNo].strip(), '\' : invalid command.')
    exit()

# precompilation ends


if lineNo==len(alllines):
    oufile.close()
    infile.close()




    # replaceing labels
    infile = open('temp.txt', 'r')
    oufile = open(oufileName, 'w')
    for line in infile:
        line = line.lower().strip()
        y = (re.split("\s+", line))
        if (y[0] in ['jump', 'jmpz', 'jmpdec']):
            if y[1][0]==':':
                if not y[1][1:] in jumpLines.keys():
                    print('label', y[1][1:], 'not found.')
                    print('precompilation interrupted')
                    exit()
                command = y[0] + ' ' + str(jumpLines[y[1][1:]]) + '\n'
            else:
                command = y[0] + ' ' + y[1] + '\n'
        else:
            command = line + '\n'

        oufile.write(command)
    oufile.close()
    infile.close()


    print('precompilation end\n')
    oufile.close()
    infile.close()


# compiling

    infile = open(oufileName, 'r')
    oufile = open(compfileName, 'w')
    oufile.write("memory_initialization_radix = 2;\nmemory_initialization_vector =\n")
    lineNo = 0
    for line in infile:
        lineNo = lineNo + 1
        line = line.lower()
        x = (re.split("\s+", line))

        command = '{:04b}'.format(ops[x[0]])
        if (x[0] == 'nop'):
            command = command + '000000000000'

        elif (x[0] in ['add', 'sub', 'mul', 'div']):
            if (x[1][0] == 'r'):
                regNum = int(x[1][1:])
                command = command + '1' + '{:04b}'.format(regNum)
            else:
                command = command + '0' + '{:04b}'.format(reg[x[1]])
            command = command + '' + '{:07b}'.format(int(x[2]))

        elif (x[0] in ['shr', 'shl']):
            num = '{:012b}'.format(int(x[1]))
            command = command + '' + num

        elif (x[0] in ['load', 'store']):
            command = command + '' + '{:012b}'.format(int(x[1]))


        elif (x[0] in ['jump', 'jmpz', 'jmpdec']):
            command = command + '' + '{:012b}'.format(int(x[1]))

        elif (x[0] == 'move'):
            for i in range(0, 2):
                if (x[i + 1][0] == 'r'):
                    regNum = int(x[i + 1][1:])
                    command = command + '01' + '{:04b}'.format(regNum)
                else:
                    command = command + '00' + '{:04b}'.format(reg[x[i + 1]])

        elif (x[0] in ['uartsend', 'uartread']):
            command = command + '000000000000'

        else:
            # warn about errors
            print('unknown compile error!')
            break

        print(lineNo, '.', x, command)
        oufile.write(command + ",\n")

    if not infile.readline():
        print('compilation end')
        oufile.write("0000000000000000;\n")

    else:
        print('compilation interrupted')

# compilation ends



else:
    print('precompilation interrupted\n')