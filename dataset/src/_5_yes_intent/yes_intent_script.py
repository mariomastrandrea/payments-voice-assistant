import random
from utils.utils import trim_punctuation, generate_BIO_tokens_from_template, \
    generate_grouped_intent_sentences_and_BIO_tokens, \
    YES_INTENT_LABEL

yes_intent_templates = [
    "Of course.",
    "Certainly.",
    "Definitely.",
    "That's my understanding.",
    "Yes, I agree.",
    "That is spot on.",
    "Sure thing, I do.",
    "Of course I do.",
    "That's true.",
    "Undoubtedly.",
    "Most certainly.",
    "Exactly.",
    "Precisely.",
    "That's correct.",
    "That's right.",
    "You've got it.",
    "Sure thing.",
    "You're right.",
    "Affirmative.",
    "Unquestionably.",
    "That is exactly right.",
    "Absolutely.",
    "Indeed.",
    "Yep, I agree.",
    "Confirmed.",
    "No question about it.",
    "Most definitely.",
    "Yes.",
    "Sure.",
    "Go ahead.",
    "Proceed.",
    "You can proceed.",
    "Go for it.",
    "Absolutely, no question.",
    "It is as you say, Affirmative.",
    "Indeed, that's just how it is.",
    "Indeed, beyond all doubt.",
    "Yes, that aligns with my thoughts.",
    "Unquestionably so.",
    "Indeed, just so.",
    "Sure, that's evident.",
    "For sure, Of course.",
    "It is as you say, Correct.",
    "For sure, Absolutely.",
    "I can confirm that, Certainly.",
    "Of course, it's undeniable.",
    "Certainly, as you say.",
    "For sure, Correct.",
    "For sure, Certainly.",
    "I can confirm that, Absolutely.",
    "For sure, Sure.",
    "Clearly, that's the situation.",
    "I can confirm that, Of course.",
    "Affirmative, that's my belief.",
    "It is as you say, Of course.",
    "It is as you say, Certainly.",
    "Surely, as you say.",
    "Most definitely, without any doubt.",
    "I can confirm that, Indeed.",
    "I can confirm that, Sure.",
    "I can confirm that, Correct.",
    "I can confirm that, Affirmative.",
    "Most assuredly, that's the case.",
    "Absolutely, no question., absolutely.",
    "Certainly, that's just the case.",
    "Yes, precisely as mentioned.",
    "Yes, it's confirmed.",
    "Definitely, without any doubt., absolutely.",
    "Affirmative, that's my belief., absolutely.",
    "For sure, Definitely.",
    "For sure, Affirmative.",
    "It is as you say, Sure.",
    "For sure, Indeed.",
    "It is as you say, Absolutely.",
    "I can confirm that, Definitely.",
    "Certainly, as you say., absolutely.",
    "Correct, as expected., absolutely.",
    "Naturally, it's undeniable.",
    "Definitely, without any doubt.",
    "Correct, as expected.",
    "Indeed, that's just how it is., absolutely.",
    "It is as you say, Definitely.",
    "Exactly, as you've stated.",
    "Sure, that's evident., absolutely.",
    "Truly, that's just how it is.",
    "Of course, it's undeniable., absolutely.",
    "Without a doubt, yes.",
    "It is as you say, Indeed.",
    "You bet, that's accurate.",
    "Affirmative",
    "That's a solid yes from me.",
    "Affirmatively speaking, yes.",
    "You have my yes.",
    "That would be a yes.",
    "Count me in, that's a yes.",
    "Yes, without reservation.",
    "A resounding yes, indeed.",
    "Yes, that's my final answer.",
    "Certainly, count it as a yes.",
    "Do it",
]


def generate_yes_intent_dataset(num_sentences=3000):
    dataset = []

    for _ in range(num_sentences):
        sentence = random.choice(yes_intent_templates)
        sentence = trim_punctuation(sentence)
        dataset.append(sentence)

    return dataset

# generate both a sentence and its tokens
def generate_yes_sentence_and_tokens(tokenizer):
    sentence = trim_punctuation(random.choice(yes_intent_templates))
    
    sentence, tokens, labels = generate_BIO_tokens_from_template(
        sentence,
        tokenizer
    )

    return sentence, tokens, labels

# generate a certain number of sentences + tokens + labels
def generate_yes_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        YES_INTENT_LABEL,
        generate_yes_sentence_and_tokens
    )
