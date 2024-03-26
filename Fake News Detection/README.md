# Fake News Detection

#### The data was ulitmately provided by [Data Flair](https://data-flair.training/). One downgrade about the data, is that its source is unknown. However, for the goal of this project, We'd assume that the data where collected from online resouces via BeautifulSoup, Selenium or requests, etc.

<hr>

## About the dataset

The 1st column identifies the news, the second and the third are the title and the text, and the fourth column has classes dentoting whether the news is ***Real*** or ***Fake***.

<hr>

## Theoretical Knowledge Background

### TFIDF-Vectorizer

**TF(Term Frequency):** The Number of times a word appears in a document is its Term Frequency. A higher value means a term appears more often than others. Accordingly, a good match when the term is part of the search terms.

**IDF (Inverse Document Frequency):** Words that occur many times in a document, but also, occur many times in many others, may be irrelevant. **IDF** is a measure of how significant a term is in the entire corpus.

**-->> TFIDF-Vectorizer** converts a collection of raw documents into a matrix of **TF-IDF** features.
<hr>

### PassiveAggressiveClassifier

Passive Aggressive algorithms are online learning algorithms. Such algorithms remains passive for a correct classification outcome, and turns aggressive in the event of a miscalculation, updating and adjusting. **Unlike most other algorithms, it doesn't converge.** *Its purpose* is to make updates that correct the loss, causing very little change in the norm of the weight vector.

**(>_<) Convergence?**

Convergence is just a term of machine learning algorithms where the algorithm reach its consistent solution(the algorithm's behavior stabilizes over time). Meaning that, going through further iterations and adjustments extraneous. Hence, the adjusments and the iterations, at this point, won't significantly change the outcome or the solution it produces.

<hr>
