import random
from utils.utils import trim_punctuation, generate_BIO_tokens_from_template, \
    generate_grouped_intent_sentences_and_BIO_tokens, NO_INTENT_LABEL

no_intent_templates = [
    "Please not.",
    "That's not the case, no.",
    "I'd have to say no, I'm not convinced",
    "Far from it, I can't agree with that.",
    "No, that's not in line with the truth.",
    "I can't confirm that, so no.",
    "That's not accurate.",
    "Far from it, not as far as I know.",
    "I'd have to say no, No",
    "By no means, I can't agree with that.",
    "Not exactly, not as far as I know.",
    "That wouldn't be correct.",
    "No, you've got it wrong.",
    "Not quite, that's off the mark.",
    "I don't confirm it",
    "That doesn't match my information.",
    "No, you're mistaken.",
    "Nope",
    "Not quite, not as far as I know.",
    "I don't think so.",
    "No, that's off the mark.",
    "I'm not convinced, so no.",
    "Not at all, that's off the mark.",
    "Absolutely not, that's off the mark.",
    "No, I have a different perspective.",
    "Not exactly, that doesn't seem right.",
    "Far from it, that's off the mark.",
    "No",
    "I disagree with that.",
    "Not quite, I can't agree with that.",
    "Not in this case, no.",
    "Not at all, that doesn't seem right.",
    "That's incorrect.",
    "No, I don't see it that way.",
    "Not at all, not as far as I know.",
    "No, I have to correct you there.",
    "By no means, that doesn't seem right.",
    "That's not how I see it.",
    "No, that's not my understanding.",
    "I'd have to say no, Regrettably",
    "No, that's not in line with the facts.",
    "Sadly, no.",
    "That's not my view.",
    "No, not as far as I know.",
    "No, that's a misconception.",
    "That's not the answer.",
    "I'd have to say no, That wouldn't be correct.",
    "Not in this case.",
    "Not at all, I can't agree with that.",
    "Not quite, that doesn't seem right.",
    "I'd have to say no, That's not accurate.",
    "I deny",
    "Absolutely not, that doesn't seem right.",
    "That's not my understanding.",
    "Nope, that's not it.",
    "You better not",
    "No, I think you're mistaken.",
    "Not at all.",
    "No way.",
    "Not in the slightest, that's off the mark.",
    "Not quite right.",
    "I don't believe so.",
    "No, that doesn't seem right.",
    "Absolutely not.",
    "Not in any way.",
    "Definitely not.",
    "Regrettably, no.",
    "I can't confirm that.",
    "Not by any means, that's off the mark.",
    "By no means, that's off the mark.",
    "Absolutely not, not as far as I know.",
    "No, that's not correct.",
    "Absolutely not, I can't agree with that.",
    "That's not true.",
    "Not by any means, I can't agree with that.",
    "I cannot agree with that.",
    "Not in the slightest, that doesn't seem right.",
    "No, that's not aligned with the facts.",
    "Not by any means, that doesn't seem right.",
    "Not exactly, I can't agree with that.",
    "No, that's not right.",
    "Don't do it",
    "Unfortunately, no.",
    "Not in the slightest, not as far as I know.",
    "By no means, not as far as I know.",
    "Far from it, that doesn't seem right.",
    "No, I can't confirm that.",
    "I wouldn't say so.",
    "I must disagree.",
    "Certainly not.",
    "I'm afraid that's not the case.",
    "Don't do that",
    "It's far from accurate.",
    "No, I can't agree with that.",
    "Not exactly, that's off the mark.",
    "That's false.",
    "That's wrong",
    "No, that's a misunderstanding.",
    "Not in the slightest, I can't agree with that.",
    "Not by any means, not as far as I know.",
    "I'd say no.",
    "I must say no.",
]

def generate_no_intent_dataset(num_sentences=3000):
    dataset = []

    for _ in range(num_sentences):
        sentence = random.choice(no_intent_templates)
        sentence = trim_punctuation(sentence)
        dataset.append(sentence)

    return dataset

# generate both a sentence and the corresponding tokens
def generate_no_sentence_and_tokens(tokenizer):
    sentence = trim_punctuation(random.choice(no_intent_templates))
    
    sentence, tokens, labels = generate_BIO_tokens_from_template(
        sentence,
        tokenizer
    )

    return sentence, tokens, labels

# generate a certain number of sentences + tokens + labels
def generate_no_intents_and_labelled_tokens(num_sentences, tokenizer):
    return generate_grouped_intent_sentences_and_BIO_tokens(
        num_sentences,
        tokenizer,
        NO_INTENT_LABEL,
        generate_no_sentence_and_tokens
    )