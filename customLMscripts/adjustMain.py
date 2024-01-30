

file = open("result.csv")
out = open("adjusted_result.csv", "w")

first_name_placeholder = "{name}"
surname_placeholder = "{surname}"
bank_placeholder = "{bank}"

for line in file:
    line = line.replace(first_name_placeholder, "<name>")
    line = line.replace(surname_placeholder, "<surname>")
    line = line.replace(bank_placeholder, "<bank>")
    out.write(line)

file.close()
out.close()