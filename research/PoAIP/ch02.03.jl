### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 9ed9ffb6-18af-11ee-0049-d724212bd16a
simple_grammar = (
	(:sentence, :(->), (:noun_phrase, :verb_phrase)),
    (:noun_phrase, :(->), (:Article, :Noun)),
    (:verb_phrase, :(->), (:Verb, :noun_phrase)),
    (:Article, :(->), :the, :a),
    (:Noun, :(->), :man, :ball, :woman, :table),
    (:Verb, :(->), :hit, :took, :saw, :liked),
)

# ╔═╡ 11e2434d-a9b5-428c-9771-a7385aab3d72
bigger_grammar = (
	(:sentence, :(->), (:noun_phrase, :verb_phrase)),
    (:noun_phrase, :(->), (:Article, :AdjStar, :Noun, :PPStar), (:Name), (:Pronoun)),
    (:verb_phrase, :(->), (:Verb, :noun_phrase, :PPStar)),
	(:PPStar, :(->), (), (:PP, :PPStar)),
    (:AdjStar, :(->), (), (:Adj, :AdjStar)),
	(:PP, :(->), (:Prep, :noun_phrase)),
    (:Prep, :(->), :to, :in, :by, :with, :on),
	(:Adj, :(->), :big, :little, :blue, :green, :adiabatic),
    (:Article, :(->), :the, :a),
	(:Name, :(->), :Pat, :Kim, :Lee, :Terry, :Robin),
    (:Noun, :(->), :man, :ball, :woman, :table),
    (:Verb, :(->), :hit, :took, :saw, :liked),
	(:Pronoun, :(->), :he, :she, :it, :these, :those, :that),
)

# ╔═╡ 296607a2-02ef-4aef-b095-69c08910157a
#grammar = simple_grammar
grammar = bigger_grammar

# ╔═╡ 20a346b7-ad29-4518-928e-048d06cbb6d0
begin
	function rule_lhs(rule::Nothing) 
		nothing
	end
	function rule_lhs(rule) 
		length(rule) > 0 ? rule[1] : nothing
	end
	function rule_rhs(rule::Nothing) 
		nothing
	end
	function rule_rhs(rule) 
		length(rule) > 2 ? rule[3:end] : nothing
	end
	function assoc(key, table) 
		i = findfirst((item) -> item[1] == key, table)
		isnothing(i) ? nothing : table[i]
	end
	function rewrites(category) 
		rule_rhs(assoc(category, grammar))
	end

	function mappend(fn, list)
		(Iterators.flatten(fn(i) for i in list)...,)
	end

	function generate(phrase::Tuple)
		mappend(generate, phrase)
	end
	
	function generate(symb::Symbol)
		r = rewrites(symb)
		isnothing(r) ? (symb,) : generate(rand(r))
	end
end;

# ╔═╡ ec33c28a-8f0d-48f5-89e0-9e4313eec7a2
join(string.(generate(:sentence)), " ")

# ╔═╡ ccd63ba6-a2cf-4af2-9992-73909cb94755
generate(:Noun)

# ╔═╡ eb41e86c-7b7a-464a-86bf-8ec70a917c81
generate(:noun_phrase)

# ╔═╡ 2e9b0526-f90a-44ab-9613-0d218bc023f0
generate(:verb_phrase)

# ╔═╡ Cell order:
# ╠═9ed9ffb6-18af-11ee-0049-d724212bd16a
# ╠═11e2434d-a9b5-428c-9771-a7385aab3d72
# ╠═296607a2-02ef-4aef-b095-69c08910157a
# ╠═20a346b7-ad29-4518-928e-048d06cbb6d0
# ╠═ec33c28a-8f0d-48f5-89e0-9e4313eec7a2
# ╠═ccd63ba6-a2cf-4af2-9992-73909cb94755
# ╠═eb41e86c-7b7a-464a-86bf-8ec70a917c81
# ╠═2e9b0526-f90a-44ab-9613-0d218bc023f0
