import random
from utils.names_utils import names
from utils.bank_names_utils import bank_names
from utils.amount_utils import random_amount
from utils.utils import trim_punctuation, write_dataset, generate_BIO_tokens_from_template, \
    generate_grouped_intent_sentences_and_BIO_tokens, \
    AMOUNT_ENTITY_LABEL, USER_ENTITY_LABEL, BANK_ENTITY_LABEL, REQUEST_MONEY_INTENT_LABEL

sender_names = names

# Expanded set of templates 
request_money_templates = [
    "Please request {amount} from {sender}'s account at {bank}.",
    "Please request {amount} from {sender} at {bank}.",
    "Please request {amount} from {sender}.",
    "Please request some money from {sender}'s account at {bank}.",
    "Please request some money from {sender} at {bank}.",
    "Please request some money from {sender}.",
    "Please request {amount}.",
    "Please request some money.",
    "I need to receive {amount} from {sender} using my {bank} account.",
    "I need to receive {amount} from {sender}.",
    "I need to receive {amount} through my {bank} account.",
    "I need to receive some money from {sender} using my {bank} account.",
    "I need to receive {amount}.",
    "I need to receive some money from {sender}.",
    "I need to receive some money through my {bank} account.",
    "I need to receive some money.",
    "Can you request {amount} from {sender}'s account at {bank}?",
    "Can you request some money from {sender}'s account at {bank}?",
    "Can you request {amount} from {sender}?",
    "Can you request {amount} from {sender}'s account?",
    "Can you request some money from {sender}?",
    "Can you request some money from {sender}'s account?",
    "Can you request {amount}?",
    "Can you request some money?",
    "I'm seeking to collect {amount} from {sender} through my account with {bank}.",
    "I'm seeking to collect {amount} from {sender}.",
    "I'm seeking to collect {amount} through my account with {bank}.",
    "I'm seeking to collect some money from {sender} through my account with {bank}.",
    "I'm seeking to collect {amount}.",
    "I'm seeking to collect some money from {sender}.",
    "I'm seeking to collect some money through my account with {bank}.",
    "I'm seeking to collect some money.",
    "Request to receive {amount} to my {bank} account from {sender}, please.",
    "Request to receive {amount} to my {bank} account, please.",
    "Request to receive {amount} from {sender}, please.",
    "Request to receive some money to my {bank} account from {sender}, please.",
    "Request to receive some money to my {bank} account, please.",
    "Request to receive some money from {sender}, please.",
    "Request to receive {amount}, please.",
    "Request to receive some money, please.",
    "I'm authorizing a collection of {amount} from {sender} to {bank}.",
    "I'm authorizing a collection of {amount} from {sender}.",
    "I'm authorizing a collection of {amount} to {bank}.",
    "I'm authorizing a collection from {sender} to {bank}.",
    "I'm authorizing a collection of {amount}.",
    "I'm authorizing a collection from {sender}.",
    "I'm authorizing a collection to {bank}.",
    "I'm authorizing a collection.",
    "Kindly process a request for {amount} from {sender} using my {bank} account.",
    "Kindly process a request from {sender} using my {bank} account.",
    "Kindly process a request for {amount} to my {bank} account.",
    "Kindly process a request for {amount} from {sender}.",
    "Kindly process a request for {amount}.",
    "Kindly process a request from {sender}.",
    "Kindly process a request for my {bank} account.",
    "Kindly process a request.",
    "Arrange to receive a fund of {amount} from {sender} at {bank}.",
    "Arrange to receive a fund from {sender} at {bank}.",
    "Arrange to receive a fund of {amount} at {bank}.",
    "Arrange to receive a fund of {amount} from {sender}.",
    "Arrange to receive a fund of {amount}.",
    "Arrange to receive a fund from {sender}.",
    "Arrange to receive a fund at {bank}.",
    "Arrange to receive a fund.",
    "I'd like to receive {amount} from {sender} through {bank}.",
    "I'd like to receive {amount} from {sender}.",
    "I'd like to receive {amount} through {bank}.",
    "I'd like to receive some money from {sender} through {bank}.",
    "I'd like to receive {amount}.",
    "I'd like to receive some money from {sender}.",
    "I'd like to receive some money through {bank}.",
    "I'd like to receive some money.",
    "Could you assist in receiving {amount} from {sender} at {bank}?",
    "Could you assist in receiving {amount} from {sender}?",
    "Could you assist in receiving {amount} at {bank}?",
    "Could you assist in receiving some money from {sender} at {bank}?",
    "Could you assist in receiving {amount}?",
    "Could you assist in receiving some money from {sender}?",
    "Could you assist in receiving some money at {bank}?",
    "Could you assist in receiving some money?",
    "I'm planning to receive {amount} from {sender} via {bank}.",
    "I'm planning to receive {amount} from {sender}.",
    "I'm planning to receive {amount} via {bank}.",
    "I'm planning to receive some money from {sender} via {bank}.",
    "I'm planning to receive {amount}.",
    "I'm planning to receive some money from {sender}.",
    "I'm planning to receive some money via {bank}.",
    "I'm planning to receive some money.",
    "Would you please execute a request for {amount} from {sender} using my account at {bank}?",
    "Would you please execute a request for {amount} from {sender}?",
    "Would you please execute a request for {amount} using my account at {bank}?",
    "Would you please execute a request from {sender} using my account at {bank}?",
    "Would you please execute a request for {amount}?",
    "Would you please execute a request from {sender}?",
    "Would you please execute a request from my account at {bank}?",
    "Would you please execute a request?",
    "Initiate a wire request for {amount} from {sender} at {bank}, please.",
    "Initiate a wire request for {amount} from {sender}, please.",
    "Initiate a wire request for {amount} at {bank}, please.",
    "Initiate a wire request from {sender} at {bank}, please.",
    "Initiate a wire request for {amount}, please.",
    "Initiate a wire request from {sender}, please.",
    "Initiate a wire request at {bank}, please.",
    "Initiate a wire request, please.",
    "Requesting to collect {amount} from {sender} using {bank}.",
    "Requesting to collect {amount} from {sender}.",
    "Requesting to collect {amount} using {bank}.",
    "Requesting to collect some money from {sender} using {bank}.",
    "Requesting to collect {amount}.",
    "Requesting to collect some money from {sender}.",
    "Requesting to collect some money using {bank}.",
    "Requesting to collect some money.",
    "I am instructing a collection of {amount} from {sender} through my {bank} account.",
    "I am instructing a collection of {amount} from {sender}.",
    "I am instructing a collection of {amount} through my {bank} account.",
    "I am instructing a collection from {sender} through my {bank} account.",
    "I am instructing a collection of {amount}.",
    "I am instructing a collection from {sender}.",
    "I am instructing a collection through my {bank} account.",
    "I am instructing a collection.",
    "I want to receive {amount} from {sender} using {bank}.",
    "I want to receive some money from {sender} using {bank}.",
    "I want to receive {amount} from {sender}.",
    "I want to receive {amount} using {bank}.",
    "I want to receive {amount}.",
    "I want to receive some money from {sender}.",
    "I want to receive some money using {bank}.",
    "I want to receive some money.",
    "Please arrange a collection of {amount} from {sender} using {bank} account.",
    "Please arrange a collection of {amount} from {sender}.",
    "Please arrange a collection of {amount} using my {bank} account.",
    "Please arrange a collection from {sender} usin {bank} account.",
    "Please arrange a collection of {amount}.",
    "Please arrange a collection from {sender}.",
    "Please arrange a collection using {bank} account.",
    "Please arrange a collection.",
    "I need you to request {sender} {amount} from  using my {bank} account.",
    "I need you to request {sender} some money using my {bank} account.",
    "I need you to request {sender} {amount}.",
    "I need you to request {amount} using my {bank} account.",
    "I need you to request {amount}.",
    "I need you to request {sender} some money.",
    "I need you to request some money using my {bank} account.",
    "I need you to request some money.",
    "Initiate a request of {amount} from {sender} using {bank}.",
    "Initiate a request of {amount} from {sender}.",
    "Initiate a request of {amount} using {bank}.",
    "Initiate a request from {sender} using {bank}.",
    "Initiate a request of {amount}.",
    "Initiate a request from {sender}.",
    "Initiate a request using {bank}.",
    "Initiate a request.",
]

# Function to generate a sentence
def generate_request_money_sentence():
    sender = random.choice(sender_names)
    bank = random.choice(bank_names)
    amount = random_amount()  # Using the random_amount function
    
    template = random.choice(request_money_templates)

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using {bank}" in template:
                template = template.replace("using {bank}", "using my {bank} account")
            elif "my account at {bank}" in template:
                template = template.replace("my account at {bank}", "my {bank} account")
            elif "account with {bank}" in template:
                template = template.replace("account with {bank}", "{bank} account")
            elif "via {bank}" in template:
                template = template.replace("via {bank}", "via {bank} account")
            elif "through {bank}" in template:
                template = template.replace("through {bank}", "through {bank} account")
            elif "at {bank}" in template:
                template = template.replace("at {bank}", "at {bank} account")
            elif "to {bank}" in template:
                template = template.replace("to {bank}", "to {bank} account")

    sentence = template.format(amount=amount, sender=sender, bank=bank)

    # remove quotes and unnecessary punctuation
    sentence = trim_punctuation(sentence)
    return sentence

# Function to generate the dataset
def generate_request_money_dataset_of_at_most(num_sentences):
    unique_sentences = {generate_request_money_sentence() for _ in range(num_sentences)}
    return unique_sentences

# generate both a sentence and the corresponding tokens
def generate_request_money_sentence_and_tokens(tokenizer):
    sender = random.choice(sender_names)
    bank = random.choice(bank_names)
    amount = random_amount()  # Using the random_amount function
    
    template = trim_punctuation(random.choice(request_money_templates))

    if "{bank}" in template and bank in ["default", "primary"]:
        if "{bank} account" not in template:
            if "using {bank}" in template:
                template = template.replace("using {bank}", "using my {bank} account")
            elif "my account at {bank}" in template:
                template = template.replace("my account at {bank}", "my {bank} account")
            elif "account with {bank}" in template:
                template = template.replace("account with {bank}", "{bank} account")
            elif "via {bank}" in template:
                template = template.replace("via {bank}", "via {bank} account")
            elif "through {bank}" in template:
                template = template.replace("through {bank}", "through {bank} account")
            elif "at {bank}" in template:
                template = template.replace("at {bank}", "at {bank} account")
            elif "to {bank}" in template:
                template = template.replace("to {bank}", "to {bank} account")

    sentence, tokens, token_labels = generate_BIO_tokens_from_template(
        template,
        tokenizer,
        amount=(amount, AMOUNT_ENTITY_LABEL),
        sender=(sender, USER_ENTITY_LABEL),
        bank=(bank, BANK_ENTITY_LABEL)
    )
    
    return sentence, tokens, token_labels

def generate_request_money_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        REQUEST_MONEY_INTENT_LABEL,
        generate_request_money_sentence_and_tokens
    )