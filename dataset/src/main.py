import sys 
sys.dont_write_bytecode = True

from transformers import AutoTokenizer, BertTokenizer
from _1_check_balance.check_balance_script import generate_check_balance_intents_and_labelled_tokens
from _2_check_transactions.check_transactions_script import generate_check_transactions_intents_and_labelled_tokens
from _3_request_money.request_money_script import generate_request_money_intents_and_labelled_tokens
from _4_send_money.send_money_script import generate_send_money_intents_and_labelled_tokens
from _5_yes_intent.yes_intent_script import generate_yes_intents_and_labelled_tokens
from _6_no_intent.no_intent_script import generate_no_intents_and_labelled_tokens
from _0_none_intent.none_intent_script import generate_none_intents_and_labelled_tokens_including_entities
from utils.utils import write_grouped_intent_and_tokens_datasets
import random

if __name__ == "__main__":
    tokenizer: BertTokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
    num_sentences = 3000
    
    _0_check_balance_dataset = generate_check_balance_intents_and_labelled_tokens(num_sentences, tokenizer)
    _1_check_transactions_dataset = generate_check_transactions_intents_and_labelled_tokens(num_sentences, tokenizer)
    _2_request_money_dataset = generate_request_money_intents_and_labelled_tokens(num_sentences, tokenizer)
    _3_send_money_dataset = generate_send_money_intents_and_labelled_tokens(num_sentences, tokenizer)
    _4_yes_dataset = generate_yes_intents_and_labelled_tokens(num_sentences, tokenizer)
    _5_no_dataset = generate_no_intents_and_labelled_tokens(num_sentences, tokenizer)
    _6_none_dataset = generate_none_intents_and_labelled_tokens_including_entities(num_sentences * 4, tokenizer)

    # put sentences altogether 
    complete_dataset = _0_check_balance_dataset      + \
                       _1_check_transactions_dataset + \
                       _2_request_money_dataset      + \
                       _3_send_money_dataset         + \
                       _4_yes_dataset                + \
                       _5_no_dataset                 + \
                       _6_none_dataset
    # shuffle them
    random.shuffle(complete_dataset)
    
    # write the dataset to 2 csv files
    write_grouped_intent_and_tokens_datasets(
        complete_dataset,
        "./final_dataset/intents.csv",
        "./final_dataset/named_entities.csv"
    )


   
    
