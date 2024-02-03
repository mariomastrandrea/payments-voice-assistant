

file = open("adjusted_result.csv")
linesSet = set()

for line in file:
    linesSet.add(line)

file.close()

out = open("uniqueLines_result.csv", "w")

for uniqueLine in linesSet:
    out.write(uniqueLine)

out.close()

