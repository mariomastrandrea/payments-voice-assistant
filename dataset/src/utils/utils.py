import csv
import re

# Entity labels
AMOUNT_ENTITY_LABEL = "AMOUNT"
BANK_ENTITY_LABEL = "BANK"
CURRENCY_ENTITY_LABEL = "CURRENCY"
USER_ENTITY_LABEL = "USER"

ENTITY_LABEL_NUM = {
    "O": 0,
    "B-AMOUNT": 1,
    "I-AMOUNT": 2,
    "B-BANK": 3,
    "I-BANK": 4,
    "B-CURRENCY": 5,
    "I-CURRENCY": 6,
    "B-USER": 7,
    "I-USER": 8
}

# Intent labels
CHECK_BALANCE_INTENT_LABEL = "check_balance"
CHECK_TRANSACTIONS_INTENT_LABEL = "check_transactions"
SEND_MONEY_INTENT_LABEL = "send_money"
REQUEST_MONEY_INTENT_LABEL = "request_money"
YES_INTENT_LABEL = "yes"
NO_INTENT_LABEL = "no"
NONE_INTENT_LABEL = "none"

INTENT_LABEL_NUM = {
    "none": 0,
    "check_balance": 1,
    "check_transactions": 2,
    "send_money": 3,
    "request_money": 4,
    "yes": 5,
    "no": 6,
}

#################################

def trim_punctuation(sentence):
    sentence = sentence.removeprefix("\"")
    sentence = sentence.removesuffix("\"")
    sentence = sentence.removesuffix("?")
    sentence = sentence.removesuffix(".")
    sentence = sentence.replace(",", "")
    return sentence

def write_dataset(unique_sentences, csv_filename):
    list_of_sentences = [[x] for x in unique_sentences]

    with open(csv_filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Sentence"])  # Header    
        writer.writerows(list_of_sentences)

def generate_BIO_tokens_from_template(template: str, tokenizer, **kwargs):
    """
    Given a sentence template with placeholders, generate the both the formatted sentence and 
    the corresponding (labelled) tokens, according to the BIO scheme.
    args:
    - template: a string containing placeholders, each one enclosed in curly braces
    - tokenizer: the object used to tokenize a string
    - kwargs: a set of key-value pairs, one for each placeholder, having as key the name of the
      placeholder (as occurs in the template) and as value an iterable of two values: 
      (1) the value to substitute to the placeholder, and (2) a string representing the corresponding token label
    - output: the formatted sentence, a list of the corresponding bert tokens, and a list of the corresponding BIO labels
    """
    if len(kwargs) == 0:
        sentence = template
        tokens = tokenizer.tokenize(sentence)
        tokens_labels = ["O"] * len(tokens)
        return sentence, tokens, tokens_labels

    placeholders = {"{%s}" % x for x in kwargs.keys()}
    placeholders_regex = "(" + "|".join(["\{%s\}" % x for x in kwargs.keys()]) + ")"
    
    # split the template using the placeholders
    template_pieces = re.split(placeholders_regex, template)
    
    sentence = ""
    sentence_tokens = []
    tokens_labels = []

    for piece in template_pieces:
        if piece is None or len(piece) == 0:
            continue

        if piece in placeholders:
            placeholder_key = piece.removeprefix("{").removesuffix("}")

            # retrieve the placeholder value and the corresponding label
            placeholder_value = kwargs[placeholder_key][0]
            placeholder_label = kwargs[placeholder_key][1]

            # create BERT tokens for the entity and the corresponding labels, according to the BIO scheme
            piece_tokens = tokenizer.tokenize(placeholder_value)
            piece_tokens_labels = ["B-%s" % placeholder_label] + ["I-%s" % placeholder_label for _ in range(len(piece_tokens) - 1)]

            # update sentence
            sentence += placeholder_value
        else:
            # create BERT tokens for this piece and the corresponding labels, which are all 'O' (Outside)
            piece_tokens = tokenizer.tokenize(piece)
            piece_tokens_labels = ["O"] * len(piece_tokens)

            # update sentence
            sentence += piece
        
        # add them to the result
        sentence_tokens += piece_tokens
        tokens_labels += piece_tokens_labels
    
    return sentence, sentence_tokens, tokens_labels

def generate_intent_sentences_and_BIO_tokens(num_sentences, tokenizer, intent_generation_function):
    """
    Generate a certain number of random sentences expressing an intent, and the corresponding
    tokens and labels
    """

    sentences_count = 0
    sentences = []
    sentences_tokens = []
    sentences_tokens_labels = []

    while sentences_count < num_sentences:
        sentence, tokens, labels = intent_generation_function(tokenizer)

        sentences.append(sentence)
        sentences_tokens.append(tokens)
        sentences_tokens_labels.append(labels)
        sentences_count += 1

    return sentences, sentences_tokens, sentences_tokens_labels

def generate_grouped_intent_sentences_and_BIO_tokens(num_sentences, tokenizer, intent_label, intent_generation_function):
    """
    Generate a certain number of random sentences expressing an intent, and the corresponding
    tokens and labels. Obtain an iterable of (sentence, intent, tokens, tokens_labels)
    """

    sentences_count = 0
    grouped_sentences_tokens_and_labels = []

    while sentences_count < num_sentences:
        sentence, tokens, labels = intent_generation_function(tokenizer)
        element = (sentence, intent_label, tokens, labels)

        grouped_sentences_tokens_and_labels.append(element)
        sentences_count += 1

    return grouped_sentences_tokens_and_labels

def format_tokens_and_labels(tokens, token_labels):
    token_strings = []
    token_labels_strings = []

    for token, label in zip(tokens, token_labels):
        if len(token) < len(label):
            token += " " * (len(label) - len(token))
        
        if len(label) < len(token):
            label += " " * (len(token) - len(label))

        token_strings.append(token)
        token_labels_strings.append(label)
    
    return token_strings, token_labels_strings

def write_grouped_intent_and_tokens_datasets(grouped_elements, intents_csv_filepath, ner_csv_filepath):
    # open files and create csv writer utilities
    intents_file = open(intents_csv_filepath, "w")
    ner_file = open(ner_csv_filepath, "w")

    intents_writer = csv.writer(intents_file)
    ner_writer = csv.writer(ner_file)

    for sentence, intent_label, sentence_tokens, sentence_tokens_labels in grouped_elements:
        # write one row per intent
        intent_label_num = INTENT_LABEL_NUM[intent_label]
        intents_writer.writerow([sentence, intent_label, intent_label_num])

        # write one row per each token
        sentence_tokens_labels_nums = list(map(lambda label: ENTITY_LABEL_NUM[label], sentence_tokens_labels))
        ner_writer.writerows(zip(sentence_tokens, sentence_tokens_labels, sentence_tokens_labels_nums))
        # write a new line after each sentence
        ner_writer.writerow([])

    intents_file.close()
    ner_file.close()
        
    




    
