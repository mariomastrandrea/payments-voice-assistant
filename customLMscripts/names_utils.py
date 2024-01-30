import random

# 100 male and 100 female English names
english_first_names = [
    "Liam", "Noah", "William", "James", "Oliver",
    "Benjamin", "Elijah", "Lucas", "Mason", "Logan",
    "Alexander", "Ethan", "Jacob", "Michael", "Daniel",
    "Henry", "Jackson", "Sebastian", "Aiden", "Matthew",
    "Samuel", "David", "Joseph", "Carter", "Owen",
    "Wyatt", "John", "Jack", "Luke", "Jayden",
    "Dylan", "Grayson", "Levi", "Isaac", "Gabriel",
    "Julian", "Mateo", "Anthony", "Jaxon", "Lincoln",
    "Joshua", "Christopher", "Andrew", "Theodore", "Caleb",
    "Ryan", "Asher", "Nathan", "Thomas", "Leo",
    "Isaiah", "Charles", "Josiah", "Hudson", "Christian",
    "Hunter", "Connor", "Eli", "Ezra", "Aaron",
    "Landon", "Adrian", "Jonathan", "Nolan", "Jeremiah",
    "Easton", "Elias", "Colton", "Cameron", "Carson",
    "Robert", "Angel", "Maverick", "Nicholas", "Dominic",
    "Jaxson", "Greyson", "Adam", "Ian", "Austin",
    "Santiago", "Jordan", "Cooper", "Brayden", "Roman",
    "Evan", "Ezekiel", "Xavier", "Jose", "Jace",
    "Jameson", "Leonardo", "Bryson", "Axel", "Everett",
    "Parker", "Kayden", "Miles", "Sawyer", "Jason",
    "Emma", "Olivia", "Ava", "Isabella", "Sophia",
    "Charlotte", "Mia", "Amelia", "Harper", "Evelyn",
    "Abigail", "Emily", "Elizabeth", "Mila", "Ella",
    "Avery", "Sofia", "Camila", "Aria", "Scarlett",
    "Victoria", "Madison", "Luna", "Grace", "Chloe",
    "Penelope", "Layla", "Riley", "Zoey", "Nora",
    "Lily", "Eleanor", "Hannah", "Lillian", "Addison",
    "Aubrey", "Ellie", "Stella", "Natalie", "Zoe",
    "Leah", "Hazel", "Violet", "Aurora", "Savannah",
    "Audrey", "Brooklyn", "Bella", "Claire", "Skylar",
    "Lucy", "Paisley", "Everly", "Anna", "Caroline",
    "Nova", "Genesis", "Emilia", "Kennedy", "Samantha",
    "Maya", "Willow", "Kinsley", "Naomi", "Aaliyah",
    "Elena", "Sarah", "Ariana", "Allison", "Gabriella",
    "Alice", "Madelyn", "Cora", "Ruby", "Eva",
    "Serenity", "Autumn", "Adeline", "Hailey", "Gianna",
    "Valentina", "Isla", "Eliana", "Quinn", "Nevaeh",
    "Ivy", "Sadie", "Piper", "Lydia", "Alexa",
    "Josephine", "Emery", "Julia", "Delilah", "Arianna",
    "Vivian", "Kaylee", "Sophie", "Brielle", "Madeline"
]

# 100 surnames
english_surnames = [
    "Smith", "Johnson", "Williams", "Brown", "Jones",
    "Miller", "Davis", "Garcia", "Rodriguez", "Wilson",
    "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez",
    "Moore", "Martin", "Jackson", "Thompson", "White",
    "Lopez", "Lee", "Gonzalez", "Harris", "Clark",
    "Lewis", "Robinson", "Walker", "Perez", "Hall",
    "Young", "Allen", "Sanchez", "Wright", "King",
    "Scott", "Green", "Baker", "Adams", "Nelson",
    "Hill", "Ramirez", "Campbell", "Mitchell", "Roberts",
    "Carter", "Phillips", "Evans", "Turner", "Torres",
    "Parker", "Collins", "Edwards", "Stewart", "Flores",
    "Morris", "Nguyen", "Murphy", "Rivera", "Cook",
    "Rogers", "Morgan", "Peterson", "Cooper", "Reed",
    "Bailey", "Bell", "Gomez", "Kelly", "Howard",
    "Ward", "Cox", "Diaz", "Richardson", "Wood",
    "Watson", "Brooks", "Bennett", "Gray", "James",
    "Reyes", "Cruz", "Hughes", "Price", "Myers",
    "Long", "Foster", "Sanders", "Ross", "Morales",
    "Powell", "Sullivan", "Russell", "Ortiz", "Jenkins",
    "Gutierrez", "Perry", "Butler", "Barnes", "Fisher"
]

italian_first_names = [
    "Giulia", "Luca", "Sofia", "Matteo", "Giorgia", "Francesco", "Giovanni", "Alessandro", "Federica", "Chiara",
    "Lorenzo", "Alessia", "Riccardo", "Martina", "Andrea", "Sara", "Gabriele", "Anna", "Marco", "Aurora",
    "Antonio", "Elisa", "Simone", "Giulia", "Davide", "Alice", "Stefano", "Beatrice", "Luigi", "Caterina",
    "Giacomo", "Francesca", "Vincenzo", "Elena", "Pietro", "Claudia", "Maurizio", "Valentina", "Paolo", "Silvia",
    "Angelo", "Lucia", "Salvatore", "Roberta", "Domenico", "Chiara", "Gianluca", "Simona", "Massimo", "Laura",
    "Fabio", "Daniela", "Roberto", "Giulia", "Sergio", "Cristina", "Emanuele", "Barbara", "Edoardo", "Alessandra",
    "Federico", "Valeria", "Michele", "Giada", "Raffaele", "Carla", "Giorgio", "Teresa", "Guido", "Elisabetta",
    "Luigi", "Loredana", "Enrico", "Federica", "Gennaro", "Sonia", "Franco", "Bianca", "Vito", "Rosa",
    "Umberto", "Patrizia", "Stefania", "Mario", "Anna Maria", "Nicola", "Monica", "Flavio", "Luciana", "Daniele",
    "Arianna", "Alfredo", "Sandra", "Cesare", "Valeria", "Enzo", "Silvia", "Carlo", "Daniela", "Paola",
    "Luisa", "Pietro", "Carmela", "Marco", "Sabrina", "Nino", "Elena", "Gaetano", "Marina", "Gianni",
    "Rosaria", "Aldo", "Nadia", "Ernesto", "Valentina", "Vincenzo", "Angela", "Dario", "Giuseppina", "Luciano",
    "Sara", "Pasquale", "Giorgia", "Giuseppe", "Paola", "Agostino", "Francesca", "Arturo", "Carmen", "Carmine",
    "Cinzia", "Diego", "Raffaella", "Riccardo", "Rita", "Rosario", "Sergio", "Sofia", "Tommaso", "Veronica",
    "Rocco", "Rosanna", "Adriano", "Beatrice", "Silvio", "Emanuela", "Guglielmo", "Cecilia", "Rodolfo", "Concetta",
    "Bruno", "Assunta", "Carmelo", "Cristina", "Dante", "Domenica", "Elio", "Elvira", "Emilio", "Fabiola",
    "Fausto", "Fiammetta", "Filippo", "Fiorella", "Flavio", "Fulvia", "Gaspare", "Gilda", "Gregorio", "Ilaria",
    "Ivano", "Lavinia", "Leonardo", "Liliana", "Lino", "Livia", "Lorenza", "Lucrezia", "Manfredi", "Mara",
    "Marcello", "Mirella", "Moreno", "Natalia", "Nazzareno", "Nicoletta", "Norberto", "Ornella", "Osvaldo", "Palma",
    "Pamela", "Patrizio", "Priscilla", "Quintino", "Renata", "Renzo", "Rodolfo", "Rosario", "Sante", "Saverio",
    "Secondo", "Tiziana", "Tullio", "Ugo", "Valerio", "Vanda", "Vincenza", "Vittorio", "Ylenia", "Zeno",
    "Adele", "Alba", "Alda", "Alessio", "Alfio", "Anita", "Armando", "Asia", "Basilio", "Benedetta",
    "Beniamino", "Calogero", "Carla", "Celeste", "Ciro", "Claudio", "Clelia", "Corrado", "Cosimo", "Damiano",
    "Daria", "Demetrio", "Desiderio", "Dino", "Donato", "Edda", "Edoardo", "Elsa", "Enrica", "Ermanno",
    "Erminia", "Ettore", "Eugenio", "Fabrizia", "Faustino", "Federigo", "Filomena", "Flaminia", "Franca", "Fulvio",
    "Gabriella", "Gastone", "Gennara", "Gerardo", "Giacinta", "Giancarlo", "Gianfranco", "Gianmaria", "Giuliana", "Giulio",
    "Giustino", "Grazia", "Guido", "Iacopo", "Ida", "Irene", "Irma", "Isaia", "Ivo", "Ivonne",
    "Jacopo", "Lamberto", "Lara", "Lelia", "Letizia", "Lia", "Liborio", "Lino", "Loris", "Luana",
    "Lucio", "Ludovico", "Manuela", "Marcello", "Margherita", "Marianna", "Marino", "Martino", "Massimiliano", "Matilde",
    "Mauro", "Maurizio", "Melania", "Michela", "Mirco", "Monica", "Morena", "Nadia", "Nando", "Natalino"
]

italian_surnames = [
    "Rossi", "Russo", "Ferrari", "Esposito", "Bianchi", "Romano", "Colombo", "Ricci", "Marino", "Greco",
    "Bruno", "Gallo", "Conti", "De Luca", "Costa", "Giordano", "Mancini", "Rizzo", "Lombardi", "Moretti",
    "Barbieri", "Fontana", "Santoro", "Mariani", "Rinaldi", "Caruso", "Ferrara", "Galli", "Martini", "Leone",
    "Longo", "Gentile", "Martinelli", "Vitale", "Lombardo", "Serra", "Coppola", "De Santis", "D'Angelo", "Marchetti",
    "Parisi", "Villa", "Conte", "Ferraro", "Ferretti", "Marini", "Grasso", "Valentini", "Messina", "Sala",
    "De Angelis", "Gatti", "Pellegrini", "Palumbo", "Sanna", "Farina", "Riva", "Monti", "Cattaneo", "Morelli",
    "Amato", "Silvestri", "Mazza", "Testa", "Grassi", "Pellegrino", "Carbone", "Giuliani", "Benedetti", "Barone",
    "Rossetti", "Caputo", "Montanari", "Guerra", "Palmieri", "Bernardi", "Martino", "Fiore", "De Rosa", "Ferrero",
    "Ferri", "Fabbri", "Bianco", "Marconi", "Giuliano", "Ceccarelli", "Donati", "Amico", "D'Amico", "Orlando",
    "Damiani", "Marino", "Moro", "Bassi", "Brunetti", "Carli", "Galli", "Vitale", "Bertolini", "Fabbri",
    "Sorrentino", "Neri", "Pizzo", "Catalano", "Costanzo", "De Simone", "Maggiore", "Bellini", "Basile", "Ruggiero"
]

common_relative_names = [
    "mum", "dad", "mother", "father", "sister", "brother", "grandmother", "grandfather", "aunt", "uncle", "cousin", "niece",
    "nephew", "saughter", "son", "stepmother", "stepfather", "stepsister", "stepbrother", "granddaughter", "grandson", "sister-in-law",
]

common_english_names = [
    "doctor", "nurse", "professor", "engineer", "artist",
    "lawyer", "journalist", "chef", "musician", "writer",
    "scientist", "teacher", "photographer", "designer", "architect",
]

def pick_names(**kwargs):
    all_selected_names = []

    if 'english_first_names' in kwargs:
        num_english_first_names = kwargs['english_first_names']
        all_selected_names += random.sample(english_first_names, num_english_first_names)
    
    if 'english_full_names' in kwargs:
        num_english_full_names = kwargs['english_full_names']
        selected_first_names = random.sample(english_first_names, num_english_full_names)
        selected_surnames = random.sample(english_surnames, num_english_full_names)
        all_selected_names += list(map(lambda first_name, surname: "%s %s" % (first_name, surname), selected_first_names, selected_surnames))

    if 'italian_first_names' in kwargs:
        num_italian_first_names = kwargs['italian_first_names']
        all_selected_names += random.sample(italian_first_names, num_italian_first_names)

    if 'italian_full_names' in kwargs:
        num_italian_full_names = kwargs['italian_full_names']
        selected_first_names = random.sample(italian_first_names, num_italian_full_names)
        selected_surnames = random.sample(italian_surnames, num_italian_full_names)
        all_selected_names += list(map(lambda first_name, surname: "%s %s" % (first_name, surname), selected_first_names, selected_surnames))

    if 'common_names' in kwargs:
        num_common_names = kwargs['common_names']
        all_common_names = common_relative_names + common_english_names
        selected_common_names = []

        while len(selected_common_names) < num_common_names:
            common_name = random.choice(all_common_names)
            selected_common_names.append(
                common_name 
                if random.choice([True, False]) 
                else common_name + " " + random.choice(
                    english_first_names 
                    if random.choice([True, False]) 
                    else italian_first_names
                )
            )
        
        all_selected_names += selected_common_names

    random.shuffle(all_selected_names)
    return all_selected_names

names = pick_names(
    english_first_names=100,
    english_full_names=100,
    italian_first_names=100,
    italian_full_names=100,
    common_names=50
)

def generate_random_names(**kwargs):
    all_selected_names = []

    if 'english_first_names' in kwargs:
        num_english_first_names = kwargs['english_first_names']
        selected_english_first_names = []

        while len(selected_english_first_names) < num_english_first_names:
            selected_english_first_names.append(random.choice(english_first_names))
        
        all_selected_names += selected_english_first_names
    
    if 'english_full_names' in kwargs:
        num_english_full_names = kwargs['english_full_names']
        selected_english_full_names = []

        while len(selected_english_full_names) < num_english_full_names:
            first_name = random.choice(english_first_names)
            last_name = random.choice(english_surnames)
            selected_english_full_names.append("%s %s" % (first_name, last_name))

        all_selected_names += selected_english_full_names

    if 'italian_first_names' in kwargs:
        num_italian_first_names = kwargs['italian_first_names']
        selected_italian_first_names = []

        while len(selected_italian_first_names) < num_italian_first_names:
            selected_italian_first_names.append(random.choice(italian_first_names))

        all_selected_names += selected_italian_first_names

    if 'italian_full_names' in kwargs:
        num_italian_full_names = kwargs['italian_full_names']
        selected_italian_full_names = []

        while len(selected_italian_full_names) < num_italian_full_names:
            first_name = random.choice(italian_first_names)
            last_name = random.choice(italian_surnames)
            selected_italian_full_names.append("%s %s" % (first_name, last_name))

        all_selected_names += selected_italian_full_names

    if 'common_names' in kwargs:
        num_common_names = kwargs['common_names']
        all_common_names = common_relative_names + common_english_names
        selected_common_names = []

        while len(selected_common_names) < num_common_names:
            common_name = random.choice(all_common_names)
            selected_common_names.append(
                common_name 
                if random.choice([True, False]) 
                else common_name + " " + random.choice(
                    english_first_names 
                    if random.choice([True, False]) 
                    else italian_first_names
                )
            )
        
        all_selected_names += selected_common_names

    random.shuffle(all_selected_names)
    return all_selected_names



