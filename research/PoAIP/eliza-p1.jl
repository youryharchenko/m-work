### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 70d8957c-7685-4743-8ef8-b39dbef0a41f
function is_variable(pattern)
    """Test if pattern is a single variable."""
    return pattern isa AbstractString && pattern[1] == '?' && 
		length(pattern) > 1 && pattern[2] != '*' && 
		isletter(pattern[2]) &&  !(' ' in pattern)
end

# ╔═╡ d4962a6b-b766-4535-9f97-1af6907ecdd2
all((
	is_variable("?x"),
	is_variable("?subj"),
	!is_variable("is it?"),
	!is_variable("? why?"),
	!is_variable("?"),
	!is_variable(("?x",)),
	!is_variable("?foo bar"),
))

# ╔═╡ 5970f00b-bb2a-4e3d-8c01-ec37903c7513
function is_segment(pattern)
    """Test if pattern begins with a segment variable."""
    return pattern isa Tuple && length(pattern) > 0 && length(pattern[1]) > 2 && 
		pattern[1][1] == '?' && pattern[1][2] == '*' &&
		isletter(pattern[1][3]) && !(' ' in pattern[1])
end


# ╔═╡ f58d463c-d9f3-45a4-b00c-dadb2becf443
all((
	is_segment(("?*foo", "bar")),
	is_segment(("?*x", )),
	!is_segment("?*foo bar"),
	!is_segment(("?*",)),
	!is_segment(("?*foo bar",)),
))

# ╔═╡ e518f6ab-4ba0-4d7f-ab9f-92b649eee689
function contains_tokens(pattern)
    """Test if pattern is a list of subpatterns."""
    return pattern isa Tuple && length(pattern) > 0
end

# ╔═╡ 8a22452e-cec2-499e-8164-9b3ae8aeca6e
all((
	contains_tokens(("foo", "bar")),
	!contains_tokens("foo bar"),
	!contains_tokens(()),
))

# ╔═╡ fa2ece7c-a034-4267-93b9-963bf27adf15
function match_variable(var, replacement, bindings)
    """Bind the input to the variable and update the bindings."""
	
	#println("match_variable :: $var, $replacement, $bindings")
	
    #binding = bindings.get(var)
    if !haskey(bindings, var) #not binding:
        # The variable isn't yet bound.
        bindings[var] = replacement isa Array ? (replacement...,) : replacement	
        bindings
	elseif replacement == bindings[var]
        # The variable is already bound to that input.
        bindings
	else
	    # The variable is already bound, but not to that input--fail.
    	false
	end
end

# ╔═╡ f26a62fa-4cff-4112-9dbd-23c5710c17ce
all((
	match_variable("foo", "bar", Dict("baz" => "quux")) ==
                         Dict("baz" => "quux", "foo" => "bar"),
	match_variable("foo", "bar", Dict("foo" => "bar")) ==
                         Dict("foo" => "bar"),
	!match_variable("foo", "bar", Dict("foo" => "baz"))
))

# ╔═╡ 28b63419-7a06-4191-8e0b-bc3c05c52258
function match_segment(var, pattern, input, bindings, start=1)
    """
    Match the segment variable against the input.

    pattern and input should be lists of tokens.

    Looks for a substring of input that begins at start and is immediately
    followed by the first word in pattern.  If such a substring exists,
    matching continues recursively and the resulting bindings are returned;
    otherwise returns False.
    """
	#println("match_segment :: $var, $pattern, $input, $bindings, $start")
	
    # If there are no words in pattern following var, we can just match var
    # to the remainder of the input.
    if length(pattern) == 0
        return match_variable(var, input, bindings)
	end

    # Get the segment boundary word and look for the first occurrence in
    # the input starting from index start.
    word = pattern[1]
    #try:
        #pos = start + input[start:end].index(word)
	ind = findfirst((x) -> x == word, input[start:end])
	if isnothing(ind) 
		return false
	end
	pos = start + ind - 1
    #except ValueError:
        # When the boundary word doesn't appear in the input, no match.
        #return False

    # Match the located substring to the segment variable and recursively
    # pattern match using the resulting bindings.
    var_match = match_variable(var, input[1:pos-1], copy(bindings))
    match = match_pattern(pattern, input[pos:end], var_match)

    # If pattern matching fails with this substring, try a longer one.
    if match isa Bool && !match 
        return match_segment(var, pattern, input, bindings, start + 1)
	end
    
    return match
end


# ╔═╡ 4a9bca14-2233-11ee-021a-bd5e1a4eecb3
## Pattern matching

function match_pattern(pattern, input, bindings=nothing)
    """
    Determine if the input string matches the given pattern.

    Expects pattern and input to be lists of tokens, where each token is a word
    or a variable.

    Returns a dictionary containing the bindings of variables in the input
    pattern to values in the input string, or False when the input doesn't match
    the pattern.
    """

	#println("match_pattern :: $pattern, $input, $bindings")
	
    # Check to see if matching failed before we got here.
    if bindings isa Bool && !bindings 
        return false
	end
    
    # When the pattern and the input are identical, we have a match, and
    # no more bindings need to be found.
    if pattern == input
        return bindings
	end

    bindings = isnothing(bindings) ? Dict{String, Any}() : bindings

    # Match input and pattern according to their types.
    if is_segment(pattern)
        token = pattern[1] # segment variable is the first token
        var = token[3:end] # segment variable is of the form ?*x
        return match_segment(var, pattern[2:end], input, bindings)
	elseif is_variable(pattern)
        var = pattern[2:end] # single variables are of the form ?foo
        return match_variable(var, [input], bindings)
	elseif contains_tokens(pattern) && contains_tokens(input)
        # Recurse:
        # try to match the first tokens of both pattern and input.  The bindings
        # that result are used to match the remainder of both lists.
        return match_pattern(pattern[2:end],
                             input[2:end],
                             match_pattern(pattern[1], input[1], bindings))
    else
        return false
	end
end


# ╔═╡ bd061ec3-765d-4ad7-8c2b-e0cbcada8403
all((
	Dict{String, Any}("bar" => "baz", "foo" => ("bah", "bla")) ==
            match_segment("foo", (), ("bah", "bla"), Dict{String, Any}("bar" => "baz")),
	Dict{String, Any}("foo" => ("blue",), "x" => ("red",)) ==
            match_segment("foo", ("is", "?x", "today"), ("blue", "is", "red", "today"), Dict{String, Any}()),
	Dict{String, Any}("y" => ("tomorrow",), "x" => ("red", "today", "and"), "foo" => ("blue",)) ==
            match_segment("foo", ("is", "?*x", "today", "is", "?y"), ("blue", "is", "red", "today", "and", "today", "is", "tomorrow"), Dict{String, Any}()),
	!match_segment("foo", ("is", "?y", "now", "?z"), ("red", "is", "blue", "is", "not", "now"), Dict{String, Any}()),
))

# ╔═╡ dd3d4ee5-f626-4e70-a057-3abae47b0f46
all((
	Dict{String, Any}() ==
		match_pattern(("hello", "world"), ("hello", "world"), Dict{String, Any}()),
	!match_pattern(("hello", "world"), ("hello", "bob"), Dict{String, Any}()),
	Dict{String, Any}("x" => ("hello", "bob")) ==
		match_pattern(("?*x", "world"), ("hello", "bob", "world"), Dict{String, Any}()),
	Dict{String, Any}("x" => ("bob",)) ==
		match_pattern("?x", "bob", Dict{String, Any}()),
	Dict{String, Any}("y" => ("bob",), "x" => ("john", "jay")) ==
		match_pattern((split("hello ?y my name is ?*x pleased to meet you")...,), (split("hello bob my name is john jay pleased to meet you")...,), Dict{String, Any}()),
	!match_pattern(("?x", "bob"), (), Dict{String, Any}()),
	!match_pattern((), ("hello", "bob"), Dict{String, Any}()),
))

# ╔═╡ 1bde525b-a1c7-4df0-ba66-51c09465ba66
function switch_viewpoint(words)
    """Swap some common pronouns for interacting with a robot."""
    reps = Dict("i" => "you",
                    "you" => "i",
                    "my" => "your",
                    "your" => "my",
                    "am" => "are",
                    "are" => "am")
    return ([word in keys(reps) ? reps[word] : word for word in words]...,)
end

# ╔═╡ bf93a8a9-5bb6-49b8-ada1-5588944a826b
function respond(rules, input, default_responses)
    """Respond to an input sentence according to the given rules."""

    input = (split(input)...,) # match_pattern expects a list of tokens

    # Look through rules and find input patterns that matches the input.
    matching_rules = []
    for (pattern, transforms) in rules
        pattern = (split(pattern)...,)
        replacements = match_pattern(pattern, input)
        if replacements isa Dict  
            push!(matching_rules, (transforms, replacements))
		end
	end

	println(matching_rules)

    # When rules are found, choose one and one of its responses at random.
    # If no rule applies, we use the default rule.
    if length(matching_rules) > 0
        responses, replacements = rand(matching_rules)
        response = rand(responses)
    else
        replacements = Dict{String, Any}()
        response = rand(default_responses)
	end

    # Replace the variables in the output pattern with the values matched from
    # the input string.
    for (variable, replacement) in replacements
        replacement = join(switch_viewpoint(replacement), " ")
        if length(replacement) > 0
            response = replace(response, "?"*variable => replacement)
		end
	end
    
    return response
end

# ╔═╡ 23cc384f-8d1b-48c6-97bf-e139cdfac167
rules = Dict{String, Array{String}}(
    "?*x hello ?*y" => [
        "How do you do. Please state your problem.",
	],
    "?*x computer ?*y" => [
        "Do computers worry you?",
        "What do you think about machines?",
        "Why do you mention computers?",
        "What do you think machines have to do with your problem?",
	],
    "?*x name ?*y" => [
        "I am not interested in names",
	],
    "?*x sorry ?*y" => [
        "Please don't apologize",
        "Apologies are not necessary",
        "What feelings do you have when you apologize",
        ],
    "?*x I remember ?*y" => [
        "Do you often think of ?y?",
        "Does thinking of ?y bring anything else to mind?",
        "What else do you remember?",
        "Why do you recall ?y right now?",
        "What in the present situation reminds you of ?y?",
        "What is the connection between me and ?y?",
        ],
    "?*x do you remember ?*y" => [
        "Did you think I would forget ?y?",
        "Why do you think I should recall ?y now?",
        "What about ?y?",
        "You mentioned ?y",
        ],
    "?*x I want ?*y" => [
        "What would it mean if you got ?y?",
        "Why do you want ?y?",
        "Suppose you got ?y soon."
        ],
    "?*x if ?*y" => [
        "Do you really think it's likely that ?y?",
        "Do you wish that ?y?",
        "What do you think about ?y?",
        "Really--if ?y?"
        ],
    "?*x I dreamt ?*y" => [
        "How do you feel about ?y in reality?",
        ],
    "?*x dream ?*y" => [
        "What does this dream suggest to you?",
        "Do you dream often?",
        "What persons appear in your dreams?",
        "Don't you believe that dream has to do with your problem?",
        ],
    "?*x my mother ?*y" => [
        "Who else in your family ?y?",
        "Tell me more about your family",
        ],
    "?*x my father ?*y" => [
        "Your father?",
        "Does he influence you strongly?",
        "What else comes to mind when you think of your father?",
        ],
    "?*x I am glad ?*y" => [
        "How have I helped you to be ?y?",
        "What makes you happy just now?",
        "Can you explain why you are suddenly ?y?",
        ],
    "?*x I am sad ?*y" => [
        "I am sorry to hear you are depressed",
        "I'm sure it's not pleasant to be sad",
        ],
    "?*x are like ?*y" => [
        "What resemblence do you see between ?x and ?y?",
        ],
    "?*x is like ?*y" => [
        "In what way is it that ?x is like ?y?",
        "What resemblence do you see?",
        "Could there really be some connection?",
        "How?",
        ],
    "?*x alike ?*y" => [
        "In what way?",
        "What similarities are there?",
        ],
    "?* same ?*y" => [
        "What other connections do you see?",
        ],
    "?*x no ?*y" => [
        "Why not?",
        "You are being a bit negative.",
        "Are you saying 'No' just to be negative?"
        ],
    "?*x I was ?*y" => [
        "Were you really?",
        "Perhaps I already knew you were ?y.",
        "Why do you tell me you were ?y now?"
        ],
    "?*x was I ?*y" => [
        "What if you were ?y?",
        "Do you think you were ?y?",
        "What would it mean if you were ?y?",
        ],
    "?*x I am ?*y" => [
        "In what way are you ?y?",
        "Do you want to be ?y?",
        ],
    "?*x am I ?*y" => [
        "Do you believe you are ?y?",
        "Would you want to be ?y?",
        "You wish I would tell you you are ?y?",
        "What would it mean if you were ?y?",
        ],
    "?*x am ?*y" => [
        "Why do you say 'AM?'",
        "I don't understand that"
        ],
    "?*x are you ?*y" => [
        "Why are you interested in whether I am ?y or not?",
        "Would you prefer if I weren't ?y?",
        "Perhaps I am ?y in your fantasies",
        ],
    "?*x you are ?*y" => [
        "What makes you think I am ?y?",
        ],
    "?*x because ?*y" => [
        "Is that the real reason?",
        "What other reasons might there be?",
        "Does that reason seem to explain anything else?",
        ],
    "?*x were you ?*y" => [
        "Perhaps I was ?y?",
        "What do you think?",
        "What if I had been ?y?",
        ],
    "?*x I can't ?*y" => [
        "Maybe you could ?y now",
        "What if you could ?y?",
        ],
    "?*x I feel ?*y" => [
        "Do you often feel ?y?"
        ],
    "?*x I felt ?*y" => [
        "What other feelings do you have?"
        ],
    "?*x I ?*y you ?*z" => [
        "Perhaps in your fantasy we ?y each other",
        ],
    "?*x why don't you ?*y" => [
        "Should you ?y yourself?",
        "Do you believe I don't ?y?",
        "Perhaps I will ?y in good time",
        ],
    "?*x yes ?*y" => [
        "You seem quite positive",
        "You are sure?",
        "I understand",
        ],
    "?*x someone ?*y" => [
        "Can you be more specific?",
        ],
    "?*x everyone ?*y" => [
        "Surely not everyone",
        "Can you think of anyone in particular?",
        "Who, for example?",
        "You are thinking of a special person",
        ],
    "?*x always ?*y" => [
        "Can you think of a specific example?",
        "When?",
        "What incident are you thinking of?",
        "Really--always?",
        ],
    "?*x what ?*y" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What is it you really want to know?",
        "What do you think?",
        "What comes to your mind when you ask that?",
        ],
    "?*x perhaps ?*y" => [
        "You do not seem quite certain",
        ],
    "?*x are ?*y" => [
        "Did you think they might not be ?y?",
        "Possibly they are ?y",
        ],
	)

# ╔═╡ 50bb77a9-8739-4943-a154-312b5ad27a68
default_responses = [
    "Very interesting",
    "I am not sure I understand you fully",
    "What does that suggest to you?",
    "Please continue",
    "Go on",
    "Do you feel strongly about discussing such things?",
]

# ╔═╡ abd6218f-1981-4dbe-a4c8-4f5f22bc370a
respond(rules, "Good by", default_responses)

# ╔═╡ Cell order:
# ╠═4a9bca14-2233-11ee-021a-bd5e1a4eecb3
# ╠═70d8957c-7685-4743-8ef8-b39dbef0a41f
# ╠═d4962a6b-b766-4535-9f97-1af6907ecdd2
# ╠═5970f00b-bb2a-4e3d-8c01-ec37903c7513
# ╠═f58d463c-d9f3-45a4-b00c-dadb2becf443
# ╠═e518f6ab-4ba0-4d7f-ab9f-92b649eee689
# ╠═8a22452e-cec2-499e-8164-9b3ae8aeca6e
# ╠═fa2ece7c-a034-4267-93b9-963bf27adf15
# ╠═f26a62fa-4cff-4112-9dbd-23c5710c17ce
# ╠═28b63419-7a06-4191-8e0b-bc3c05c52258
# ╠═bd061ec3-765d-4ad7-8c2b-e0cbcada8403
# ╠═dd3d4ee5-f626-4e70-a057-3abae47b0f46
# ╠═bf93a8a9-5bb6-49b8-ada1-5588944a826b
# ╠═1bde525b-a1c7-4df0-ba66-51c09465ba66
# ╠═abd6218f-1981-4dbe-a4c8-4f5f22bc370a
# ╠═23cc384f-8d1b-48c6-97bf-e139cdfac167
# ╠═50bb77a9-8739-4943-a154-312b5ad27a68
