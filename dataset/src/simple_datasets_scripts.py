from _3_request_money.request_money_script import generate_request_money_dataset_of_at_most
from _4_send_money.send_money_script import generate_send_money_dataset_of_at_most
from _1_check_balance.check_balance_script import generate_check_balance_dataset_of_at_most
from _2_check_transactions.check_transactions_script import generate_check_transactions_dataset_of_at_most
from _0_none_intent.none_intent_script import pick_none_intent_sentences
from _5_yes_intent.yes_intent_script import generate_yes_intent_dataset
from _6_no_intent.no_intent_script import generate_no_intent_dataset
from utils.utils import write_dataset
from utils.amount_utils import generate_random_amounts
from utils.names_utils import generate_random_names
from utils.bank_names_utils import generate_bank_accounts_dataset
import random


def run_send_money_script():
    # generate sentences
    dataset = generate_send_money_dataset_of_at_most(4000)

    # retain just 3000 sentences
    num_sentences = 3000

    if len(dataset) > num_sentences:
        dataset = list(dataset)[:num_sentences]
        
    write_dataset(dataset, "./send_money/send_money_intent_dataset.csv")   

def run_request_money_script():
    # generate sentences
    dataset = generate_request_money_dataset_of_at_most(4000)

    # retain just 3000 sentences
    num_sentences = 3000

    if len(dataset) > num_sentences:
        dataset = list(dataset)[:num_sentences]
        
    write_dataset(dataset, "./request_money/request_money_intent_dataset.csv")   

def run_check_balance_script():
    # generate sentences
    dataset = generate_check_balance_dataset_of_at_most(15000)

    # retain just 3000 sentences
    num_sentences = 3000

    if len(dataset) > num_sentences:
        dataset = list(dataset)[:num_sentences]

    write_dataset(dataset, "./check_balance/check_balance_intent_dataset.csv")

def run_check_transactions_script():
    # generate sentences
    dataset = generate_check_transactions_dataset_of_at_most(4000)

    # retain just 3000 sentences
    num_sentences = 3000

    if len(dataset) > num_sentences:
        dataset = list(dataset)[:num_sentences]

    write_dataset(dataset, "./check_transactions/check_transactions_intent_dataset.csv")

def run_null_intent_script():
    # retain just 3000 sentences
    num_sentences = 3000

    dataset = pick_none_intent_sentences(num_sentences)

    write_dataset(dataset, "./null_intent/null_intent_dataset.csv")

def run_yes_intent_script():
    # generate 3000 sentences (data augmentation)
    num_sentences = 3000

    dataset = generate_yes_intent_dataset(num_sentences)

    write_dataset(dataset, "./yes_intent/yes_intent_dataset.csv")

def run_no_intent_script():
    # generate 3000 sentences (data augmentation)
    num_sentences = 3000

    dataset = generate_no_intent_dataset(num_sentences)

    write_dataset(dataset, "./no_intent/no_intent_dataset.csv")

def run_util():
    file = open("additional_deny_sentences.csv")
    sentences = list({
        line.strip().removeprefix("'").removeprefix("\"").removesuffix("'").removesuffix("\"")
        for i,line in enumerate(file)
        if i > 0
    })

    random.shuffle(sentences)

    print(len(sentences))
    
    for x in sentences:
        print("\"%s\"," % x)

def run_spare_entities_script():
    # 3000 entities for each type
    num_entities = 3000

    # 1. generate random names
    num_names_per_type = num_entities // 5

    names = generate_random_names(
        english_first_names=num_names_per_type,
        english_full_names=num_names_per_type,
        italian_first_names=num_names_per_type,
        italian_full_names=num_names_per_type,
        common_names=num_names_per_type
    )

    # 2. generate random amounts
    amounts = generate_random_amounts(num_entities)

    # 3. generate random accounts
    accounts = generate_bank_accounts_dataset(num_entities)

    # print the obtained sentences
    write_dataset(names, "./null_intent/names_sentences.csv")
    write_dataset(amounts, "./null_intent/amounts_sentences.csv")
    write_dataset(accounts, "./null_intent/accounts_sentences.csv")
    

if __name__ == "__main__":
    # run_send_money_script()
    # run_request_money_script()
    # run_check_balance_script()
    # run_check_transactions_script()
    # run_null_intent_script()
    # run_yes_intent_script()
    # run_no_intent_script()
    # run_spare_entities_script()
    pass
    

