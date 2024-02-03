from names_utils import english_first_names, italian_first_names, english_surnames, italian_surnames
from bank_names_utils import bank_names
import re


inputFile = open("intents.csv", "r")
outputFile = open("result.csv", "w")

first_name_placeholder = "<name>"
surname_placeholder = "<surname>"
bank_placeholder = "<bank>"

for i,line in enumerate(inputFile):
    if i % 1000 == 0:
        print("#%d iteration" % i)

    # first names
    for enFirstName in english_first_names:
        pattern = "\\b%s\\b" % enFirstName
        line = re.sub(pattern, first_name_placeholder, line)

    for itaFirstName in italian_first_names:
        pattern = "\\b%s\\b" % itaFirstName
        line = re.sub(pattern, first_name_placeholder, line)

    # surnames
    for enSurname in english_surnames:
        pattern = "\\b%s\\b" % enSurname
        line = re.sub(pattern, surname_placeholder, line)
    
    for itaSurname in italian_surnames:
        pattern = "\\b%s\\b" % itaSurname
        line = re.sub(pattern, surname_placeholder, line)

    # banks
    for bankName in bank_names:
        pattern = "\\b%s\\b" % bankName
        line = re.sub(pattern, bank_placeholder, line)

    outputFile.write(line)

inputFile.close()
outputFile.close()