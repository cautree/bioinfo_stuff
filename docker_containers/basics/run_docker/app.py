import sys
  
def print_sums(data):
    with open("row_sums",'w') as output:
        for line in data:
            row = 0
            for word in line.strip().split():
                row += int(word)
            output.write(str(row)+"\n")
            print("Sum of the row is ",row)

if len(sys.argv) > 1 and sys.argv[1] != "-":
    with open(sys.argv[1], 'r') as infile:
        print_sums(infile)
else:
    print_sums(sys.stdin)