import random

# bank names with actual bank names, fictional names and primary/default
bank_names = [
    "Top Bank", "Future Bank", 
    "JPMorgan Chase", "Bank of America", "Wells Fargo", "Citigroup", "Goldman Sachs",
    "Morgan Stanley", "US Bancorp", "TD Bank", "PNC Financial Services", "Capital One",
    "HSBC", "Barclays", "Deutsche Bank", "Credit Suisse", "UBS",
    "BNP Paribas", "Santander Bank", "Standard Chartered", "Scotiabank", "ING",
    "RBC Royal Bank", "CIBC", "Bank of Montreal", "Westpac", "ANZ",
    "Commonwealth Bank", "NAB", "Lloyds Banking Group", "Royal Bank of Scotland", "Halifax",
    "Bank of China", "China Construction Bank", "Agricultural Bank of China", "ICBC", "Mizuho Financial Group",
    "Mitsubishi UFJ Financial Group", "Sumitomo Mitsui Financial Group", "Nomura Holdings", "SBI Group", "DBS Bank",
    "OCBC Bank", "UOB", "HSBC Singapore", "Standard Chartered Singapore", "CIMB Bank",
    "Maybank", "BNP Paribas Singapore", "Citibank Singapore", "RHB Bank", "Bank of East Asia",
    "Hang Seng Bank", "Bank of India", "ICICI Bank", "State Bank of India", "Axis Bank",
    "HDFC Bank", "Punjab National Bank", "Canara Bank", "Bank of Baroda", "Union Bank of India",
    "Kotak Mahindra Bank", "Yes Bank", "IDBI Bank", "Federal Bank", "IndusInd Bank",
    "CaixaBank", "Banco Sabadell", "Bankinter", "BBVA", "Banco Santander",
    "Nordea Bank", "Danske Bank", "Handelsbanken", "Swedbank", "SEB",
    "ABN AMRO", "Rabobank", "ING Group", "SNS Bank", "Triodos Bank",
    "BNP Paribas Fortis", "KBC Bank", "ING Belgium", "Argenta", "Dexia",
    "UniCredit", "Intesa Sanpaolo", "Banca Monte dei Paschi di Siena", "UBI Banca", "Banco BPM",
    "Credit Agricole", "Societe Generale", "BNP Paribas", "Groupe BPCE", "Credit Mutuel",
    "Raiffeisen Bank International", "Erste Group Bank", "UniCredit Bank Austria", "Bank Austria", "Bawag PSK",
    "Sberbank", "VTB Bank", "Gazprombank", "Alfa Bank", "Rossiya Bank"
]

def generate_bank_accounts_dataset(num_sentences):
    sentences = []

    while len(sentences) < num_sentences:
        bank_account = random.choice(bank_names)

        # add 'account' 1/3 of the times
        if random.choice([True, False, False]):
            bank_account += " account"

        sentences.append(bank_account)

    return sentences

