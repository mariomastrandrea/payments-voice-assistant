import random
from utils.utils import generate_BIO_tokens_from_template, generate_grouped_intent_sentences_and_BIO_tokens, \
    AMOUNT_ENTITY_LABEL, NONE_INTENT_LABEL

literal_digits = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
currencies_symbols = ["$", "€", "£", "AED"]
currencies_literals = ["dollars", "euros", "pounds", "dirhams"]

# Function to generate a random amount, sometimes with cents, sometimes without
def random_amount():
    whole_amount = random.randint(1, 500)
    cents = random.randint(0, 99)

    # half of the integer amounts between 1 and 9 are converted into literal digits with a literal currency
    if whole_amount < 10 and random.choice([True, False]):
        amount = literal_digits[whole_amount] + " " + random.choice(currencies_literals)
        if whole_amount == 1:
            amount = amount[:-1] # remove trailing 's'

        if cents > 0:
            cents_str = literal_digits[cents] if cents < 10 and random.choice([True, False]) else str(cents)
            amount += " and %s cents" % cents_str
            if cents == 1:
                amount = amount[:-1]    # remove trailing 's'        
    else:
        if random.choice([True, False]):
            # put numerical cents
            amount = f"{whole_amount}.{str(cents).zfill(2)}"

            # Randomly choose between symbol or literal currency
            if random.choice([True, False]):
                amount = random.choice(currencies_symbols) + amount
            else:
                amount = amount + " " + random.choice(currencies_literals)

        else:
            # put literal cents
            
            # Randomly choose between symbol or literal currency
            if random.choice([True, False]):
                amount = random.choice(currencies_symbols) + str(whole_amount)
            else:
                amount = str(whole_amount) + " " + random.choice(currencies_literals)

            if cents > 0:
                cents_str = literal_digits[cents] if cents < 10 and random.choice([True, False]) else str(cents)
                amount += " and %s cents" % cents_str
                if cents == 1:
                    amount = amount[:-1]    # remove trailing 's' 

    return amount


def generate_random_amounts(num):
    amount_sentences = [random_amount() for _ in range(num)]
    return amount_sentences

# generate a sentence and the corresponding (labelled) tokens according to the BIO scheme
def generate_random_amount_sentence_and_tokens(tokenizer):
    template = "{amount}"
    amount = random_amount()

    sentence, tokens, tokens_labels = generate_BIO_tokens_from_template(
        template,
        tokenizer,
        amount=(amount, AMOUNT_ENTITY_LABEL)
    )

    return sentence, tokens, tokens_labels

# generate sentences + tokens + labels
def generate_random_amount_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        NONE_INTENT_LABEL,
        generate_random_amount_sentence_and_tokens
    )


