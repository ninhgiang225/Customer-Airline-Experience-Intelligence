import pandas as pd
import numpy as np
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import spacy
nlp = spacy.load("en_core_web_sm")

analyzer = SentimentIntensityAnalyzer()

ASPECTS = {
    "Seat Comfort":    ["seat", "legroom", "leg_room", "comfortable",
                        "space", "recline", "cushion", "cramped", "narrow"],
    "Cabin Staff":     ["staff", "crew", "attendant", "stewardess",
                        "flight_attendant", "rude", "friendly", "helpful"],
    "Food":            ["food", "meal", "snack", "drink", "beverage",
                        "dinner", "lunch", "breakfast", "coffee", "water"],
    "WiFi":            ["wifi", "internet", "connectivity", "wi-fi",
                        "connection", "streaming", "online", "signal"],
    "Entertainment":   ["entertainment", "screen", "movie", "tv",
                        "headphone", "music", "channel", "monitor"],
    "Ground Service":  ["check_in", "checkin", "baggage", "luggage",
                        "gate", "boarding", "lounge", "counter"],
    "Delays":          ["delay", "delayed", "late", "wait", "hour",
                        "cancel", "cancelled", "schedule", "on_time"],
    "Value":           ["price", "value", "expensive", "cost",
                        "money", "worth", "cheap", "overpriced"],
}
 
 
def extract_absa(text):
    """
    Use spaCy dependency parsing to extract
    (aspect, opinion_word, sentiment) triples.
    """
    doc = nlp(str(text)[:512])   # cap at 512 chars for speed
    found = {}
 
    for token in doc:
        token_lower = token.text.lower()
 
        # Match token to an aspect
        matched_aspect = None
        for aspect, keywords in ASPECTS.items():
            if any(kw in token_lower for kw in keywords):
                matched_aspect = aspect
                break
 
        if matched_aspect:
            # Look for adjectives syntactically linked to this token
            opinions = []
            for child in token.children:
                if child.dep_ in ("amod", "advmod", "acomp", "neg") \
                        and child.pos_ in ("ADJ", "ADV", "PART"):
                    opinions.append(child.text.lower())
 
            # Also check if token itself is modified by adj in the sentence
            if token.head.pos_ in ("ADJ", "VERB"):
                opinions.append(token.head.text.lower())
 
            if opinions:
                opinion_str = ", ".join(opinions)
                scores = [
                    analyzer.polarity_scores(op)["compound"]
                    for op in opinions
                ]
                avg_score = np.mean(scores) if scores else 0
                found[matched_aspect] = {
                    "opinion_words": opinion_str,
                    "sentiment":     round(avg_score, 3),
                }
 
    return found