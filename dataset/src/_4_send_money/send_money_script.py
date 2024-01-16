import random
from utils.names_utils import names
from utils.bank_names_utils import bank_names
from utils.amount_utils import random_amount
from utils.utils import trim_punctuation, generate_BIO_tokens_from_template, \
    generate_grouped_intent_sentences_and_BIO_tokens, \
    AMOUNT_ENTITY_LABEL, BANK_ENTITY_LABEL, USER_ENTITY_LABEL, SEND_MONEY_INTENT_LABEL

recipient_names = names

# Expanded set of templates
send_money_templates = [
    "Please send {amount} from my account at {bank} to {recipient}.",
    "Please send {amount} from my account at {bank},",
    "Please send {amount} to {recipient}.",
    "Please send some money from my account at {bank} to {recipient}.",
    "Please send some money from my account at {bank}.",
    "Please send some money to {recipient}.",
    "Please send {amount},",
    "Please send some money.",
    "I want to transfer {amount} to {recipient} using my {bank} account.",
    "I want to transfer {amount} to {recipient}.",
    "I want to transfer {amount} using my {bank} account.",
    "I want to transfer some money to {recipient} using my {bank} account.",
    "I want to transfer {amount}.",
    "I want to transfer some money to {recipient}.",
    "I want to transfer some money using my {bank} account.",
    "I want to transfer some money.",
    "Can you move {amount} from {bank} to {recipient}'s account?",
    "Can you move some money from {bank} to {recipient}'s account?",
    "Can you move {amount} from {bank}?",
    "Can you move {amount} to {recipient}'s account?",
    "Can you move some money from {bank}?",
    "Can you move some money to {recipient}'s account?",
    "Can you move {amount}?",
    "Can you move some money?",
    "I need to wire {amount} to {recipient} from my account with {bank}.",
    "I need to wire {amount} to {recipient}.",
    "I need to wire {amount} from my account with {bank}.",
    "I need to wire some money to {recipient} from my account with {bank}.",
    "I need to wire {amount}.",
    "I need to wire some money to {recipient}.",
    "I need to wire some money from my account with {bank}.",
    "I need to wire some money.",
    "Transfer {amount} from my {bank} account to {recipient}, please.",
    "Transfer {amount} from my {bank} account, please.",
    "Transfer {amount} to {recipient}, please.",
    "Transfer some money from my {bank} account to {recipient}, please.",
    "Transfer some money from my {bank} account, please.",
    "Transfer some money to {recipient}, please.",
    "Transfer {amount}, please.",
    "Transfer some money, please.",
    "I'm authorizing a payment of {amount} to {recipient} from {bank}.",
    "I'm authorizing a payment of {amount} to {recipient}.",
    "I'm authorizing a payment of {amount} from {bank}.",
    "I'm authorizing a payment to {recipient} from {bank}.",
    "I'm authorizing a payment of {amount}.",
    "I'm authorizing a payment to {recipient}",
    "I'm authorizing a payment from {bank}.",
    "I'm authorizing a payment.",
    "Kindly process a transaction of {amount} to {recipient} from my {bank} account.",
    "Kindly process a transaction to {recipient} from my {bank} account.",
    "Kindly process a transaction of {amount} from my {bank} account.",
    "Kindly process a transaction of {amount} to {recipient}.",
    "Kindly process a transaction of {amount}.",
    "Kindly process a transaction to {recipient}.",
    "Kindly process a transaction from my {bank} account.",
    "Kindly process a transaction.",
    "Arrange for a fund transfer of {amount} to {recipient} from {bank}.",
    "Arrange for a fund transfer to {recipient} from {bank}.",
    "Arrange for a fund transfer of {amount} from {bank}.",
    "Arrange for a fund transfer of {amount} to {recipient}.",
    "Arrange for a fund transfer of {amount}.",
    "Arrange for a fund transfer to {recipient}.",
    "Arrange for a fund transfer from {bank}."
    "Arrange for a fund transfer.",
    "I'd like to remit {amount} to {recipient} through {bank}.",
    "I'd like to remit {amount} to {recipient}.",
    "I'd like to remit {amount} through {bank}.",
    "I'd like to remit some money to {recipient} through {bank}.",
    "I'd like to remit {amount}.",
    "I'd like to remit some money to {recipient}.",
    "I'd like to remit some money through {bank}.",
    "I'd like to remit some money.",
    "Could you facilitate the transfer of {amount} to {recipient} from {bank}?",
    "Could you facilitate the transfer of {amount} to {recipient}?",
    "Could you facilitate the transfer of {amount} from {bank}?",
    "Could you facilitate the transfer of some money to {recipient} from {bank}?",
    "Could you facilitate the transfer of {amount}?",
    "Could you facilitate the transfer of some money to {recipient}?",
    "Could you facilitate the transfer of some money from {bank}?",
    "Could you facilitate the transfer of some money?",
    "I'm planning to send {amount} to {recipient} via {bank}.",
    "I'm planning to send {amount} to {recipient}.",
    "I'm planning to send {amount} via {bank}.",
    "I'm planning to send some money to {recipient} via {bank}.",
    "I'm planning to send {amount}.",
    "I'm planning to send some money to {recipient}.",
    "I'm planning to send some money via {bank}.",
    "I'm planning to send some money.",
    "Would you please execute a transfer of {amount} to {recipient} from my account at {bank}?",
    "Would you please execute a transfer of {amount} to {recipient}?",
    "Would you please execute a transfer of {amount} from my account at {bank}?",
    "Would you please execute a transfer to {recipient} from my account at {bank}?",
    "Would you please execute a transfer of {amount}?",
    "Would you please execute a transfer to {recipient}?",
    "Would you please execute a transfer from my account at {bank}?",
    "Would you please execute a transfer?",
    "Initiate a wire transfer of {amount} to {recipient} from {bank}, please.",
    "Initiate a wire transfer of {amount} to {recipient}, please.",
    "Initiate a wire transfer of {amount} from {bank}, please.",
    "Initiate a wire transfer to {recipient} from {bank}, please.",
    "Initiate a wire transfer of {amount}, please.",
    "Initiate a wire transfer to {recipient}, please.",
    "Initiate a wire transfer from {bank}, please.",
    "Initiate a wire transfer, please.",
    "Requesting to dispatch {amount} to {recipient} using {bank}.",
    "Requesting to dispatch {amount} to {recipient}.",
    "Requesting to dispatch {amount} using {bank}.",
    "Requesting to dispatch some money to {recipient} using {bank}.",
    "Requesting to dispatch {amount}.",
    "Requesting to dispatch some money to {recipient}.",
    "Requesting to dispatch some money using {bank}.",
    "Requesting to dispatch some money.",
    "I am instructing a payment of {amount} to {recipient} through my {bank} account.",
    "I am instructing a payment of {amount} to {recipient}.",
    "I am instructing a payment of {amount} through my {bank} account.",
    "I am instructing a payment to {recipient} through my {bank} account.",
    "I am instructing a payment of {amount}.",
    "I am instructing a payment to {recipient}.",
    "I am instructing a payment through my {bank} account.",
    "I am instructing a payment.",
    "I want to send {amount} from {bank} to {recipient}.",
    "I want to send some money from {bank} to {recipient}.",
    "I want to send {amount} to {recipient}.",
    "I want to send {amount} from {bank}.",
    "I want to send {amount}.",
    "I want to send some money from {bank}.",
    "I want to send some money to {recipient}.",
    "I want to send some money.",
    "Please arrange a payment of {amount} to {recipient} from {bank} account.",
    "Please arrange a payment of {amount} to {recipient}.",
    "Please arrange a payment of {amount} from {bank} account.",
    "Please arrange a payment to {recipient} from {bank} account.",
    "Please arrange a payment of {amount}.",
    "Please arrange a payment to {recipient}.",
    "Please arrange a payment from {bank} account.",
    "Please arrange a payment.",
    "I need you to send {amount} to {recipient} using my {bank} account.",
    "I need you to send some money to {recipient} using my {bank} account.",
    "I need you to send {amount} to {recipient}.",
    "I need you to send {amount} using my {bank} account.",
    "I need you to send {amount}.",
    "I need you to send some money to {recipient}.",
    "I need you to send some money using my {bank} account.",
    "I need you to send some money.",
    "Initiate a transaction of {amount} to {recipient} using {bank}.",
    "Initiate a transaction of {amount} to {recipient}.",
    "Initiate a transaction of {amount} using {bank}.",
    "Initiate a transaction to {recipient} using {bank}.",
    "Initiate a transaction of {amount}.",
    "Initiate a transaction to {recipient}.",
    "Initiate a transaction using {bank}.",
    "Initiate a transaction.",
]

# Function to generate a sentence
def generate_send_money_sentence():
    recipient = random.choice(recipient_names)
    bank = random.choice(bank_names)
    amount = random_amount()  # Using the random_amount function
    
    template = random.choice(send_money_templates)

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using {bank}" in template:
                template = template.replace("using {bank}", "using {bank} account")
            elif "account at {bank}" in template:
                template = template.replace("account at {bank}", "{bank} account")
            elif "account with {bank}" in template:
                template = template.replace("account with {bank}", "{bank} account")
            elif "from {bank}" in template:
                template = template.replace("from {bank}", "from my {bank} account")
            elif "via {bank}" in template:
                template = template.replace("via {bank}", "via {bank} account")
            elif "through {bank}" in template:
                template = template.replace("through {bank}", "through {bank} account")

    sentence = template.format(amount=amount, recipient=recipient, bank=bank)

    # remove quotes and unnecessary punctuation
    sentence = trim_punctuation(sentence)
    return sentence

# Function to generate the dataset
def generate_send_money_dataset_of_at_most(num_sentences):
    unique_sentences = {generate_send_money_sentence() for _ in range(num_sentences)}
    return unique_sentences

# generate both the sentence and the corresponding tokens
def generate_send_money_sentence_and_tokens(tokenizer):
    recipient = random.choice(recipient_names)
    bank = random.choice(bank_names)
    amount = random_amount()  
    
    template = trim_punctuation(random.choice(send_money_templates))

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using {bank}" in template:
                template = template.replace("using {bank}", "using {bank} account")
            elif "account at {bank}" in template:
                template = template.replace("account at {bank}", "{bank} account")
            elif "account with {bank}" in template:
                template = template.replace("account with {bank}", "{bank} account")
            elif "from {bank}" in template:
                template = template.replace("from {bank}", "from my {bank} account")
            elif "via {bank}" in template:
                template = template.replace("via {bank}", "via {bank} account")
            elif "through {bank}" in template:
                template = template.replace("through {bank}", "through {bank} account")

    sentence, tokens, token_labels = generate_BIO_tokens_from_template(
        template,
        tokenizer,
        amount=(amount, AMOUNT_ENTITY_LABEL), 
        recipient=(recipient, USER_ENTITY_LABEL),
        bank=(bank, BANK_ENTITY_LABEL)
    )

    return sentence, tokens, token_labels

# generate the grouped (random) sentences + tokens + token labels
def generate_send_money_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        SEND_MONEY_INTENT_LABEL,
        generate_send_money_sentence_and_tokens
    )