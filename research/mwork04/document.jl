
using TextAnalysis, Languages





function document(file, lang)
	l = StringDocument(text(FileDocument(file)))
	TextAnalysis.remove_whitespace!(l)
	sents = TextAnalysis.sentence_tokenize(lang, TextAnalysis.text(l))
	crps = Corpus([StringDocument(String(s)) for s in sents])
	languages!(crps, lang)

	remove_case!(crps)
	prepare!(crps, strip_punctuation | strip_numbers | strip_corrupt_utf8 | strip_non_letters)

	sent_lcase = [TextAnalysis.text(d) for d in crps]

	#remove_words!(crps, ["на","і","що","в","до","не","для"])
	update_lexicon!(crps)
	#lex = lexicon(crps)
	update_inverse_index!(crps)
	inverse_index(crps)
	(sent_lcase, crps)
end