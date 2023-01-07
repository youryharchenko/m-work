
using TextAnalysis, Languages

include("utils.jl")

function proc_doc!(kb, file, author, title; lang=Languages.English())

	# log = open("log.txt", "w")

	sent_lcase, crps = document(file, lang)
		
	v_nothing = insert(kb, :V, ["nothing"])
	v_author1 = insert(kb, :V, [author])
	v_doc1 = insert(kb, :V, [title])

	v_c_doc = insert(kb, :V, ["Document"])
	v_c_author = insert(kb, :V, ["Author"])
	v_c_sentence = insert(kb, :V, ["Sentence"])
	v_c_sentence_inst = insert(kb, :V, ["SentenceInst"])
	v_c_word = insert(kb, :V, ["Word"])
	v_c_word_inst = insert(kb, :V, ["WordInst"])


	v_a_title = insert(kb, :V, ["Title"])
	v_a_name = insert(kb, :V, ["Name"])
	v_a_number = insert(kb, :V, ["Number"])

	v_r_is_author = insert(kb, :V, ["is a author"])
	v_r_has_parts = insert(kb, :V, ["has parts"])
	v_r_inst_of = insert(kb, :V, ["inst of"])

	# select_all(kb, :V)
	
	insert(kb, :C, [v_c_doc])
	insert(kb, :C, [v_c_author])
	insert(kb, :C, [v_c_sentence])
	insert(kb, :C, [v_c_sentence_inst])
	insert(kb, :C, [v_c_word])
	insert(kb, :C, [v_c_word_inst])
	
	# select_all(kb, :C)

	insert(kb, :A, [v_a_title])
	insert(kb, :A, [v_a_name])
	insert(kb, :A, [v_a_number])
	
	# select_all(kb, :A)

	

	insert(kb, :AC, [id(kb, :C, [v_c_author]), id(kb, :A, [v_a_name]), v_nothing])
	insert(kb, :AC, [id(kb, :C, [v_c_doc]), id(kb, :A, [v_a_title]), v_nothing])
	

	# select_all(kb, :AC)

	insert(kb, :R, [v_r_is_author])
	insert(kb, :R, [v_r_has_parts])
	insert(kb, :R, [v_r_inst_of])
		
	# select_all(kb, :R)

	insert(kb, :AR, [id(kb, :R, [v_r_has_parts]), id(kb, :A, [v_a_number]), v_nothing])
	
	# select_all(kb, :AR)

	insert(kb, :RC, [id(kb, :C, [v_c_author]), id(kb, :R, [v_r_is_author]), id(kb, :C, [v_c_doc])])
	
	rc1 = insert(kb, :RC, [id(kb, :C, [v_c_doc]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_sentence_inst])])
	rc2 = insert(kb, :RC, [id(kb, :C, [v_c_sentence]), id(kb, :R, [v_r_has_parts]), id(kb, :C, [v_c_word_inst])])
	rc3 = insert(kb, :RC, [id(kb, :C, [v_c_sentence_inst]), id(kb, :R, [v_r_inst_of]), id(kb, :C, [v_c_sentence])])
	rc4 = insert(kb, :RC, [id(kb, :C, [v_c_word_inst]), id(kb, :R, [v_r_inst_of]), id(kb, :C, [v_c_word])])

	# select_all(kb, :RC)

	insert(kb, :ARC, [rc1, id(kb, :A, [v_a_number]), v_nothing])
	insert(kb, :ARC, [rc2, id(kb, :A, [v_a_number]), v_nothing])
	
	# select_all(kb, :ARC)

	insert(kb, :O, [v_author1])
	insert(kb, :O, [v_doc1])
		
	co1 = insert(kb, :CO, [id(kb, :C, [v_c_author]), id(kb, :O, [v_author1])])
	co2 = insert(kb, :CO, [id(kb, :C, [v_c_doc]), id(kb, :O, [v_doc1])])
		
	# filter(r -> r.c in [id(kb, :C, ["Автор"]), id(kb, :C, ["Документ"])], select_all(kb, :CO))

	insert(kb, :ACO, [co1, id(kb, :A, [v_a_name]), v_author1])
	insert(kb, :ACO, [co2, id(kb, :A, [v_a_title]), v_doc1])

	c = id(kb, :C, [v_c_sentence])
	
	for s in sent_lcase
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	c = id(kb, :C, [v_c_word])
	
	for s in keys(lexicon(crps))
		o = insert(kb, :O, [insert(kb, :V, [s])])
		if o > 0
			insert(kb, :CO, [c, o])	
		end
	end
		
	# filter(r -> r.c == c, select_all(kb, :CO))

	ins_has_parts_inst_of!(
		kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc1, sent_lcase)

	for s in sent_lcase
		v_sent = insert(kb, :V, [s])
		words = TextAnalysis.tokenize(s)
		ins_has_parts_inst_of!(
			kb, v_r_has_parts, v_r_inst_of, v_c_sentence, v_c_word, v_c_word_inst, v_a_number, v_sent, words)
	end
	
	# r = id(kb, :R, [v_r_has_parts])
	# rp = id(kb, :R, [v_r_inst_of])

	# cf = id(kb, :C, [v_c_doc])
	# ct = id(kb, :C, [v_c_sentence_inst])
	# cp = id(kb, :C, [v_c_sentence])

	# rc = id(kb, :RC, [cf, r, ct])
	# rcp = id(kb, :RC, [ct, rp, cp])
	
	# of = id(kb, :O, [v_doc1])

	# a = id(kb, :A, [v_a_number])
		
	# for i in eachindex(sent_lcase)
	# 	v_sent = insert(kb, :V, [sent_lcase[i]])
	# 	ot_p = insert(kb, :O, [v_sent])
	# 	k = count_rco_from(kb, rcp, ot_p)
	# 	v_sent_inst = insert(kb, :V, ["rc$rcp:ot$ot_p:$(k+1)"])
	# 	ot = insert(kb, :O, [v_sent_inst])
	# 	insert(kb, :CO, [ct, ot])
	# 	insert(kb, :RCO, [ot, rcp, ot_p])
		
	# 	rco = insert(kb, :RCO, [of, rc, ot])
	# 	v_i = insert(kb, :V, ["$i"])
	# 	arco = insert(kb, :ARCO, [rco, a, v_i])
	# end
		
	# filter(r -> r.rc == rc, select_all(kb, :RCO))
	# select_all(kb, :ARCO)
	# DuckDB.execute(kb, "EXPORT DATABASE 'semantic.duckdb'")
	#close(log)
	kb
end

function ins_has_parts_inst_of!(
	kb, v_r_has_parts, v_r_inst_of, v_c_doc, v_c_sentence, v_c_sentence_inst, v_a_number, v_doc, sent_lcase)

	r = id(kb, :R, [v_r_has_parts])
	rp = id(kb, :R, [v_r_inst_of])

	cf = id(kb, :C, [v_c_doc])
	ct = id(kb, :C, [v_c_sentence_inst])
	cp = id(kb, :C, [v_c_sentence])

	rc = id(kb, :RC, [cf, r, ct])
	rcp = id(kb, :RC, [ct, rp, cp])
	
	of = id(kb, :O, [v_doc])

	a = id(kb, :A, [v_a_number])

	for i in eachindex(sent_lcase)
		v_sent = insert(kb, :V, [sent_lcase[i]])
		ot_p = insert(kb, :O, [v_sent])
		k = count_rco_from(kb, rcp, ot_p)
		v_sent_inst = insert(kb, :V, ["rc$rcp:ot$ot_p:$(k+1)"])
		ot = insert(kb, :O, [v_sent_inst])
		if isnothing(insert(kb, :CO, [ct, ot])) 
			continue
		end
		insert(kb, :RCO, [ot, rcp, ot_p])
		
		rco = insert(kb, :RCO, [of, rc, ot])
		v_i = insert(kb, :V, ["$i"])
		insert(kb, :ARCO, [rco, a, v_i])


	end
end

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