import random
from utils.names_utils import names
from utils.bank_names_utils import bank_names
from utils.utils import trim_punctuation, generate_BIO_tokens_from_template, generate_grouped_intent_sentences_and_BIO_tokens, \
    USER_ENTITY_LABEL, BANK_ENTITY_LABEL, CHECK_TRANSACTIONS_INTENT_LABEL

user_names = names

check_transactions_templates = [
    "Show me the recent transactions with {user} on my {bank} account.",
    "Show me the recent transactions with {user}.",
    "Show me the recent transactions on my {bank} account.",
    "Show me the recent transactions on my bank accounts.",
    "Can I see the last payments made to {user} from my {bank} account?",
    "Can I see the last payments made to {user}?",
    "Can I see the last payments made from my {bank} account?",
    "Can I see the last payments I made?",
    "I need the transaction history involving {user} on my {bank} account.",
    "I need the transaction history involving {user}.",
    "I need the transaction history of my {bank} account.",
    "I need the transaction history.",
    "What are the latest transactions with {user} using my {bank} account?",
    "What are the latest transactions with {user}?",
    "What are the latest transactions using my {bank} account?",
    "What are the latest transactions?",
    "Please display the most recent payments to {user} from my {bank}.",
    "Please display the most recent payments to {user}.",
    "Please display the most recent payments from my {bank} account.",
    "Please display the most recent payments.",
    "List all recent transfers to {user} from my account at {bank}.",
    "List all recent transfers to {user}.",
    "List all recent transfers from my account at {bank}.",
    "List all recent transfers.",
    "I want to review transactions to {user} involving my {bank} account.",
    "I want to review transactions to {user}.",
    "I want to review transactions involving my {bank} account.",
    "I want to review transactions.",
    "Can you check the last few transactions to {user} from {bank}?",
    "Can you check the last few transactions to {user}?",
    "Can you check the last few transactions from {bank}?",
    "Can you check the last few transactions?",
    "Find the recent payments I made to {user} from my {bank} account.",
    "Find the recent payments I made to {user}.",
    "Find the recent payments I made from my {bank} account.",
    "Find the recent payments I made.",
    "What transactions have occurred recently with {user} on {bank} account?",
    "What transactions have occurred recently with {user}?",
    "What transactions have occurred recently on {bank} account?",
    "What transactions have occurred recently?",
    "Are there any recent transactions involving my account {bank} and {user}?",
    "Are there any recent transactions involving my account {bank}?",
    "Are there any recent transactions involving {user}?",
    "Are there any recent transactions?",
    "Show the last few transfers from {bank} to {user}.",
    "Show the last few transfers from {bank}.",
    "Show the last few transfers to {user}.",
    "Show the last few transfers.",
    "Can you provide details of the recent transactions to {user} from {bank}?",
    "Can you provide details of the recent transactions to {user}?",
    "Can you provide details of the recent transactions from {bank}?",
    "Can you provide details of the recent transactions?",
    "I'd like to see the payment history with {user} using account {bank}.",
    "I'd like to see the payment history with {user}.",
    "I'd like to see the payment history using account {bank}.",
    "I'd like to see the payment history.",
    "Display all transactions from my {bank} to {user}.",
    "Display all transactions from my {bank}.",
    "Display all transactions to {user}.",
    "Display all transactions.",
    "Check if I have any transactions with {user} on my {bank} account recently.",
    "Check if I have any transactions with {user} recently.",
    "Check if I have any transactions on my {bank} account recently.",
    "Check if I have any transactions recently.",
    "Give me a summary of recent payments to {user} from my {bank}.",
    "Give me a summary of recent payments to {user}.",
    "Give me a summary of recent payments from my {bank}.",
    "Give me a summary of recent payments.",
    "What are my most recent transactions to {user} from account {bank}?",
    "What are my most recent transactions to {user}?",
    "What are my most recent transactions from account {bank}?",
    "What are my most recent transactions?",
]

def generate_check_transactions_sentence():
    user = random.choice(user_names)
    bank = random.choice(bank_names)
    
    template = random.choice(check_transactions_templates)

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using account {bank}" in template:
                template = template.replace("using account {bank}", "using {bank} account")
            elif "my account {bank}" in template:
                template = template.replace("my account {bank}", "my {bank} account")
            elif "account at {bank}" in template:
                template = template.replace("account at {bank}", "{bank} account")
            elif "from {bank}" in template:
                template = template.replace("from {bank}", "from my {bank} account")
            elif "from my {bank}" in template:
                template = template.replace("from my {bank}", "from my {bank} account")

    sentence = template.format(user=user, bank=bank)
    sentence = trim_punctuation(sentence)
    return sentence

def generate_check_transactions_dataset_of_at_most(num_sentences):
    unique_sentences = {generate_check_transactions_sentence() for _ in range(num_sentences)}
    return unique_sentences

# generate both a sentence and the corresponding tokens
def generate_check_transactions_sentence_and_tokens(tokenizer):
    # generate random entities
    user = random.choice(user_names)
    bank = random.choice(bank_names)

    # retrieve template
    template = trim_punctuation(random.choice(check_transactions_templates))

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using account {bank}" in template:
                template = template.replace("using account {bank}", "using {bank} account")
            elif "my account {bank}" in template:
                template = template.replace("my account {bank}", "my {bank} account")
            elif "account at {bank}" in template:
                template = template.replace("account at {bank}", "{bank} account")
            elif "from {bank}" in template:
                template = template.replace("from {bank}", "from my {bank} account")
            elif "from my {bank}" in template:
                template = template.replace("from my {bank}", "from my {bank} account")

    # create the formatted sentences, the corresponding tokens and their labels
    sentence, tokens, token_labels = generate_BIO_tokens_from_template(
        template,
        tokenizer,
        user=(user, USER_ENTITY_LABEL), 
        bank=(bank, BANK_ENTITY_LABEL)
    )

    return sentence, tokens, token_labels

# generate a certain number of sentences + tokens + labels
def generate_check_transactions_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        CHECK_TRANSACTIONS_INTENT_LABEL,
        generate_check_transactions_sentence_and_tokens
    )