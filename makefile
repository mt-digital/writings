
iatv_wp:
	pandoc --variable urlcolor=cyan -s --highlight-style kate \
	iatv_corpus_whitepaper.md -o iatv_corpus_whitepaper.pdf && \
	open iatv_corpus_whitepaper.pdf
