import random
from utils.bank_names_utils import bank_names
from utils.amount_utils import currencies_symbols, currencies_literals
from utils.utils import trim_punctuation, generate_BIO_tokens_from_template, generate_grouped_intent_sentences_and_BIO_tokens, \
    BANK_ENTITY_LABEL, CURRENCY_ENTITY_LABEL, CHECK_BALANCE_INTENT_LABEL

# Expanded list of expressions to check the balance
check_balance_templates = [
    "What's my balance in the {bank} account?",
    "What's my balance in the {currency} account?",
    "What's my balance?",
    "Can you tell me the balance for my {bank} account?",
    "Can you tell me the balance for my bank account?",
    "Can you tell me the balance for my {currency} account?",
    "Can you tell me the balance for my {bank} account in {currency}?",
    "I'd like to know my current {bank} account balance in {currency}.",
    "I'd like to know my current {bank} account balance.",
    "I'd like to know my current {currency} account balance.",
    "I'd like to know my current bank account balance.",
    "Show my {bank} account balance in {currency}.",
    "Show my {bank} account balance.",
    "Show my {currency} account balance.",
    "Show my bank account balance.",
    "How much do I have in my {bank} account in {currency} right now?",
    "How much do I have in my {bank} account right now?",
    "How much do I have in my {currency} account right now?",
    "How much do I have in my bank account right now?",
    "Tell me the total in my {bank} account in {currency}.",
    "Tell me the total in my {bank} account.",
    "Tell me the total in my {currency} account.",
    "Tell me the total in my bank account.",
    "Display my {bank} account in {currency} balance.",
    "Display my {bank} account balance.",
    "Display my {currency} account balance.",
    "Display my bank account balance.",
    "Reveal the balance of my {bank} account in {currency}.",
    "Reveal the balance of my {bank} account.",
    "Reveal the balance of my {currency} account.",
    "Reveal the balance of my bank account.",
    "May I see the balance for my {bank} account in {currency}?",
    "May I see the balance for my {bank} account?",
    "May I see the balance for my {currency} account?",
    "May I see the balance for my bank account?",
    "What is the current balance of my {bank} account in {currency}?",
    "What is the current balance of my {bank} account?",
    "What is the current balance of my {currency} account?",
    "What is the current balance of my account?",
    "How much is in my {bank} account in {currency}?",
    "How much is in my {bank} account?",
    "How much is in my bank account in {currency}?",
    "How much is in my {bank} account?",
    "Check the balance of my {bank} account in {currency}.",
    "Check the balance of my bank account in {currency}.",
    "Check the balance of my {bank} account.",
    "Check the balance of my bank account.",
]


def generate_check_balance_sentence():
    template = random.choice(check_balance_templates)

    if random.choice([True, False]):
        currency = random.choice(currencies_symbols)
    else:
        currency = random.choice(currencies_literals)

    bank = random.choice(bank_names)

    sentence = template.format(currency=currency, bank=bank)

    # remove quotes and unnecessary punctuation
    sentence = trim_punctuation(sentence)
    return sentence

# Function to generate all the combinations
def generate_check_balance_dataset_of_at_most(num_sentences):
    unique_sentences = {generate_check_balance_sentence() for _ in range(num_sentences)}
    return unique_sentences

# generate both a sentence and the corresponding tokens
def generate_check_balance_sentence_and_tokens(tokenizer):
    template = trim_punctuation(random.choice(check_balance_templates))

    # select either literal or symbolic currency 
    if random.choice([True, False]):
        currency = random.choice(currencies_symbols)
    else:
        currency = random.choice(currencies_literals)

    bank = random.choice(bank_names)

    sentence, tokens, token_labels = generate_BIO_tokens_from_template(
        template,
        tokenizer,
        currency=(currency, CURRENCY_ENTITY_LABEL),
        bank=(bank, BANK_ENTITY_LABEL)
    )

    return sentence, tokens, token_labels

# generate a certain number of sentences + tokens + labels
def generate_check_balance_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        CHECK_BALANCE_INTENT_LABEL,
        generate_check_balance_sentence_and_tokens
    )

