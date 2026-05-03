
import re
import warnings
warnings.filterwarnings("ignore")
 
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize

nltk.download("punkt",          quiet=True)
nltk.download("punkt_tab",      quiet=True)   # ← this is what's missing
nltk.download("stopwords",      quiet=True)
nltk.download("wordnet",        quiet=True)
nltk.download("averaged_perceptron_tagger", quiet=True)



DOMAIN_STOPWORDS = {
    "flight", "flights", "airline", "airlines", "delta", "plane",
    "aircraft", "airport", "flew", "fly", "flying", "traveled",
    "travel", "trip", "journey", "boarding", "boarded", "ticket",
    "passenger", "passengers", "would", "could", "also", "one",
    "got", "get", "said", "told", "asked", "us", "told", "back",
    "time", "way", "day", "hour", "minute", "year"
}
 
lemmatizer = WordNetLemmatizer()
stop_words  = set(stopwords.words("english")) | DOMAIN_STOPWORDS
 
 
def preprocess(text):
    """Clean, tokenize, lemmatize, remove stopwords."""
    text = text.lower()
    text = re.sub(r"http\S+|www\S+", "", text)        # remove URLs
    text = re.sub(r"[^a-z\s]", " ", text)             # keep letters only
    text = re.sub(r"\s+", " ", text).strip()
    tokens = word_tokenize(text)
    tokens = [
        lemmatizer.lemmatize(t)
        for t in tokens
        if t not in stop_words and len(t) > 2
    ]
    return " ".join(tokens)
 
 
def add_bigrams(tokens_list):
    """Add frequent bigrams like leg_room, customer_service."""
    from nltk.collocations import BigramCollocationFinder
    from nltk.metrics import BigramAssocMeasures
    all_tokens = [t for doc in tokens_list for t in doc.split()]
    finder = BigramCollocationFinder.from_words(all_tokens)
    finder.apply_freq_filter(10)
    bigrams = finder.nbest(BigramAssocMeasures.pmi, 50)
    bigram_set = {"_".join(b) for b in bigrams}
 
    result = []
    for doc in tokens_list:
        words = doc.split()
        new_words = []
        i = 0
        while i < len(words) - 1:
            candidate = words[i] + "_" + words[i+1]
            if candidate in bigram_set:
                new_words.append(candidate)
                i += 2
            else:
                new_words.append(words[i])
                i += 1
        result.append(" ".join(new_words))
    return result