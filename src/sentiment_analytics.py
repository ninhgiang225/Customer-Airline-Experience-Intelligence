import pandas as pd
import numpy as np
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer


analyzer = SentimentIntensityAnalyzer()



def get_sentiment(text):
    scores = analyzer.polarity_scores(str(text))
    compound = scores["compound"]
    if compound >= 0.05:
        label = "Positive"
    elif compound <= -0.05:
        label = "Negative"
    else:
        label = "Neutral"
    return pd.Series({
        "SENTIMENT_SCORE":    round(compound, 4),
        "SENTIMENT_LABEL":    label,
        "SENTIMENT_POS":      scores["pos"],
        "SENTIMENT_NEG":      scores["neg"],
        "SENTIMENT_NEU":      scores["neu"],
    })
