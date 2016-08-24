# Cable News Programming and the Mind

## Introduction

The world is full of opposing forces that hold the whole in a state of
perpetual tension. Without that tension the thing would cease to exist. When
the atomic fusion of a star cannot counteract the gravitational force, the
star collapses to a cooler, darker version of itself in the form of a
white dwarf, a neutron star, or most dramatically as a black hole. Such facts
are as old as history, as in the concept of Yin and Yang. In 1929,
no doubt ruminating on the disastrous effects of World War I, Freud described
this tension in his book *Civilization and its Discontents*. He describes the
conflict of love of community and desire for collective safety against
the "death drive" of individualism. In our modern times in the United States of
America, it is all too easiy to recognize this tension. As many thoughtful
people are wondering, I want to know where this animosity, rage, and
uncompromising posturing comes from. I believe there is a better way and I
want to work on solutions to this seemingly intractable problem.

There are plenty
of examples where our ethics and politics fade into the background subconscious
and we are not aware of our neighbors opinions on such matters. Supporting a
common sports team is one example of that. As a first step towards understand
the cognitive basis for our seemingly intractable political problems, I want to
understand one of the most divisive, shared, and ubiquitous sources of
divisive content: cable news.

When I was a child my grandma would talk about watching her "programs" and that
word stuck with me as odd. The idea of a news show (or any media for that
matter) as a "program" took on a new meaning and I became excited about the
understanding how cable news programs us! Writing this I am thinking about how
the whole idea of television is becoming antiquated--I don't watch cable news, I
don't even have cable. All my TV comes through broadband and apps like Netflix,
mlb.tv, YouTube, videos on particular news outlets' websites, and so on. Still,
Fox News, CNN, and others still get exclusive broadcast rights to debates and
they are still a main source of information for people (get some Pew stats on
where people get their news).

More recent work on the psychology of voting and other political behavior has
been collected and reviewed by George Lakoff in his 2008 book *The Political
Mind*, which references another good book with both review and original
material, *The Political Brain*, also written in 2008, by Brian Westen.
Westen focuses on the role of conscious and unconscious emotion in political
decision-making. *The Political Mind* focuses on how political issues are framed
and the dominant metaphors used by republicans and democrats.

The Cable News archive presents a great resource to study the dynamics of
language of cable "programs" across the political spectrum. Westen describes
some political ads and their subconscious "primings" which include speech, other
sounds (such as a barely audible African drum in an attack ad against a
particular African-American candidate), and visual cues (such as Willie Horton).
As a first step I will generate a corpus of the transcripts of all cable news
shows going as far back as the Internet Archive has. Then, I'll bulid a Google
n-gram clone for this corpus to allow for streamlined data exploration. During
that period of "corpus plus" I'd like to expand [foxsay.io](http://foxsay.io)
to provide summaries of cable news from all of the national cable news sources,
not just Fox News as is currently done.

Once the preliminary work is done, I will explore some linguistic analyses,
especially tracking important
phrases, metaphors, and framings over time. I'm curious: which shows on
which channels are the taste makers? In both Lakoff and Westen's book, they
criticize the left as being unable to create and deploy their own metaphors,
phrases, and framings, and fall prey to using language devised by the right,
thus ceding important cognitive ground before the battle even begins. Can we
see this happening in cable news? Does George Bush or do news anchors present a
new metahpor and then that metaphor is taken up by other shows on Fox and then
by other channels like CNN and MSNBC? What are the details of the dynamics,
i.e., how long does it take a typical metahpor to transfer from one station to
another? What is the source of variance in these times? What are the classes
of metaphor and other linguistic features?


## Internet Archive, Corpus Building, and Auto-summarization

At this time, [foxsay.io](http://foxsay.io) is live, updated hourly by the
script [update_foxsay.py](https://github.com/mtpain/foxsay.io/blob/master/update_foxsay.py). There are two relevant GitHub repositories to know about to understand
what software I've written so far and what data the
TV News Archive (TVNA) provides. Those two GitHub repos can be found at
[http://github.com/mtpain/iatv](http://github.com/mtpain/iatv)
and [http://github.com/foxsay.io](http://github.com/foxsay.io). The first is
a Python API for accessing, cleaning, and processing Internet Archive TV News
data. The second is the code for the website that uses pre-downloaded and
-processed transcripts from the TVNA. Before describing the tools I've built in
too much detail, I'm going to review the TVNA itself.

The TVNA is a one-of-a-kind, searchable resource for television shows that have
aired in the past 4+ years. From the site itself, at
[https://archive.org/details/tv#about](https://archive.org/details/tv#about),

> The research library contains more than 1,093,000 news programs collected over 4+ years from national U.S. networks and stations in San Francisco and Washington D.C. The archive is updated with new broadcasts 24 hours after they are aired. Older materials are also being added.

Although the content is excellent, the search interface of the TVNA is not so
great. There are quite a few instances where the UI/UX leaves a lot to be
desired. Also, it's not possible to download entire shows or transcripts. I
believe this is due to copyright issues.

I was hoping to avoid the 60-second limits and download the entire
[SubRip-formatted](https://en.wikipedia.org/wiki/SubRip)
captions could somehow be avoided by using the internet archive API. However,
when, for example, I try downloading the `.srt` from a particular show like so

```python
from internetarchive import download
download('WRC_20160417_100000_News4_Today', glob_pattern='*.srt')
```

I get the following error telling me I don't have permission to download that

```
HTTPError: 403 Client Error: Forbidden for url: https://archive.org/download/WRC_20160417_100000_News4_Today/WRC_20160417_100000_News4_Today.cc5.srt
```

So to overcome this, I inspected the clips on the show's page and found that
one can build URLs that request segments of the `.srt` captions. For example, to
access the first sixty seconds of the News 4 Today show from above, you can
put the following into your browser and see the first 60 seconds of the show:
[https://archive.org/download/WRC_20160417_100000_News4_Today/WRC_20160417_100000_News4_Today.cc5.srt?t=0/60](https://archive.org/download/WRC_20160417_100000_News4_Today/WRC_20160417_100000_News4_Today.cc5.srt?t=0/60)

Using this
as a basis, I built my own Python API for working with this TVNA data. It's
partly based on the official
[`internetarchive` repository](https://github.com/jjjake/internetarchive)
(see also the
[`internetarchive` docs](https://internetarchive.readthedocs.io/en/latest/)).
There is also a repository from Stanford researcher Rebecca Weiss,
[rjweiss/InternetArchive](https://github.com/rjweiss/InternetArchive), but
this seems to assume that the captions have already been downloaded and are
stored in a directory. The functions in there seem to be mainly for analysis.

Here is an example of how to use the API provided by `iatv`, which is actually
the [`update_foxsay.py`](https://github.com/mtpain/foxsay.io/blob/master/update_foxsay.py)
script that's used in a cron job on the server hosting
[`foxsay.io`](http://foxsay.io).

```python
from datetime import datetime, timedelta

from iatv import download_all_transcripts, search_items, summarize_standard_dir

yesterday = datetime.now() - timedelta(days=1)

dstr = yesterday.strftime('%Y%m%d')

# use
items = search_items('I', channel='FOXNEWSW', time=dstr, rows=100000)

shows = [item for item in items if 'commercial' not in items]

download_all_transcripts(shows, base_directory='/home/mt/foxsay.io/data/2016')

summarize_standard_dir('/home/mt/foxsay.io/data/2016/', 10)
```

There are two rather weird things here, one is the need to add 'I' as a
search term. As far as I know, there is no way to simply request all results
from a particular time. Here is an example query that yields the results in
proper JSON format:
[https://archive.org/details/tv?time=20160815-20160823&sort=start+desc&q=brazil&output=json](
https://archive.org/details/tv?time=20160815-20160823&sort=start+desc&q=brazil&output=json)

On the other hand, look at the result when we don't provide any `q` field:
[https://archive.org/details/tv?fc=channel:%22FOXNEWSW%22&output=json](
https://archive.org/details/tv?fc=channel:%22FOXNEWSW%22&output=json)
All we get is a hodgepodge of badly formatted elements.


### Auto-summarization and foxsay.io

When I started thinking about addressing the issues of what cable news is saying
and how it effects cognition, one of the first thoughts that came to mind was
"How will I get a cursory view of cable news? How will I know that any analysis
is right?" In physics you learn to compare numbers, like, if you find that
the distance a projectile will travel is greater than the distance to the sun,
you can guess that your answer was incorrect. In this case, if some analysis
says that Fox News says one thing, and MSNBC says another, how will I gain a
sense of whether or not my algorithms are working properly? Or even before that,
How can I gain enough insight to what is being discussed to begin to formulate
science questions about the content?

To address this I built a simple web app, [foxsay.io](http://foxsay.io), to
summarize each day's shows. For now

In the example above, I used a function that summarizes all previously
un-summarized transcripts within a "standard" directory,
`summarize_standard_dir`. This calls another function, `summarize`, which
uses the `sumy` package (there are no standalone sumy docs, just the README
on the [sumy GitHub repo](https://github.com/miso-belica/sumy)). Here is a
snippet showing how `sumy` is used to create a function that summarizes a
single transcript.

```python
from sumy.parsers.plaintext import PlaintextParser
from sumy.nlp.tokenizers import Tokenizer
from sumy.summarizers.lsa import LsaSummarizer as Summarizer
from sumy.nlp.stemmers import Stemmer
from sumy.utils import get_stop_words

IATV_BASE_URL = 'https://archive.org/details/tv'
DOWNLOAD_BASE_URL = 'https://archive.org/download/'

LANGUAGE = 'english'

SENTENCES_COUNT = 10

def summarize(text, n_sentences, sep='\n'):
    '''
    Args:
        text (str or file): text itself or file in memory of text
        n_sentences (int): number of sentences to include in summary
    Kwargs:
        sep (str): separator to join summary sentences
    Returns:
        (str) n_sentences-long, automatically-produced summary of text
    '''

    if isinstance(text, str):
        parser = PlaintextParser.from_string(text, Tokenizer(LANGUAGE))
    elif isinstance(text, file):
        parser = PlaintextParser.from_file(text, Tokenizer(LANGUAGE))
    else:
        raise TypeError('text must be either str or file')

    stemmer = Stemmer(LANGUAGE)

    summarizer = Summarizer(stemmer)
    summarizer.stop_words = get_stop_words(LANGUAGE)

    return '\n'.join(str(s) for s in summarizer(parser.document, n_sentences))
```

`sumy` provides a number of routines for summarization (see the README on
GitHub for the entire list) and references for each one, which should prove to
be a great reading list. The example above uses a
latent semantic analysis (LSA) summarizer. There are a couple of references
given for this: [http://scholar.google.com/citations?user=0fTuW_YAAAAJ&hl=en](
http://scholar.google.com/citations?user=0fTuW_YAAAAJ&hl=en) and
[http://www.kiv.zcu.cz/~jstein/publikace/isim2004.pdf](
http://www.kiv.zcu.cz/~jstein/publikace/isim2004.pdf).

## Road map

### Short-term ("corpus plus")

[foxsay.io](http://foxsay.io) will serve as a testing ground for corpus
development. I'll use it to make sure the corpus is building properly by
extending the auto-summarization to other channels and their shows. Some other
cursory analysis, meant to bring the corpus to "corpus plus" status as Paul
said, might be n-gram viewing like
[Google Books Ngram Viewer](https://books.google.com/ngrams), or following
the TVNA, have a set of popular topics and show search results/summaries
related to those topics.
It may also be interesting to summarize each news network every day and organize
it similarly to the current `foxsay.io`, but replace shows with networks.

### Medium-term

As for more linguistically sophisticated analyses, beyond "corpus plus", I
plan to analyze the framing of particular issues, such as climate change,
terrorism, gun rights, etc., as well as the metaphors and other devices used
to describe them. More specifically, I'm curious about particular timings:
when did particular phrases first enter the lexicon? After a metaphor or framing
has emerged on one show, how long does it take to move to another show? How
many metaphors go from one network to another? What is the direction of
motion between shows and networks? That is, which shows and which networks
are the tastemakers for phrasing in the cable news ecosystem? Once we've
identified some of these sorts of patterns we can start to dig deeper and
examine the connection between the language of cable news and cognition.

### Long-term

These ideas will surely evolve as time passes, but for now here's where I'm
thinking this project will go in the longer-term. I'd like to take the
transcripts from these cable news programs, train a cognitive model that, say,
plays scrabble, then see if there is predictive power in the analysis. By
"predictive" I mean, can we determine which cable news networks and/or shows
a person watches based on the way they play Scrabble? Later, maybe we can
train cognitive models with the visual and audio inputs as well, and see the
effect this has on pragmatic actions. It may be interesting to try to predict
voting or other political behavior from cable news content.

### At all stages

Another component to all of this is a better understanding of the mix of
media that the average person consumes. There are definitely polls that
can inform us on this. A quick search turned up a set of [Pew Research Polls
dedicated to News Media Trends](
http://www.pewresearch.org/topics/news-media-trends/). At all stages of this,
I need to work to understand how cable news is situated among other news
media.
