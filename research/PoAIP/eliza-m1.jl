### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ ae0bce98-1ffe-11ee-33b8-7f8f9ac74aea
using LispSyntax

# ╔═╡ 40672741-a451-415a-aae5-4edc88cca906
lisp"""
(defn variable_p [x]
  ;; Is x a variable (a symbol beginning with "?")?
  (and (symbolp x) (equal (elt (symbol_name x) 0) "?")))
"""

# ╔═╡ 3f9311db-7b9b-41a7-8484-cd63ecc2bbeb
lisp"""
(defn segment_pattern_p [pattern]
  ;; Is this a segment matching pattern: ((?* var) . pat)
  (and (consp pattern)
       (starts_with (first pattern) "?*")))
"""

# ╔═╡ 44f60968-951d-4dc5-a338-acdd4be1a816
lisp"""
(defun segment-match [pattern input bindings start]
  ;; Match the segment pattern ((?* var) . pat) against input.
  (let ((var (second (first pattern)))
        (pat (rest pattern)))
    (if (null pat)
        (match_variable var input bindings)
        ;; We assume that pat starts with a constant
        ;; In other words, a pattern can't have 2 consecutive vars
        (let ((pos (position (first pat) input
                             start start test #'equal)))
          (if (null pos)
              fail
              (let ((b2 (pat_match
                          pat (subseq input pos)
                          (match_variable var (subseq input 0 pos)
                                          bindings))))
                ;; If this match failed, try another longer one
                (if (eq b2 fail)
                    (segment_match pattern input bindings (+ pos 1))
                    b2)))))))
"""

# ╔═╡ f896e9a6-cee2-42da-a4fa-52ab077100d4
lisp"""
(defn pat_match (pattern input bindings)
  ;Match pattern against input in the context of the bindings
  (cond ((eq bindings fail) fail)
        ((variable_p pattern)
         (match_variable pattern input bindings))
        ((eql pattern input) bindings)
        ((segment_pattern_p pattern)                ; ***
         (segment_match pattern input bindings))    ; ***
        ((and (consp pattern) (consp input))
         (pat_match (rest pattern) (rest input)
                    (pat_match (first pattern) (first input)
                               bindings)))
        (t fail)))
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LispSyntax = "51c06dcf-91d3-5c9e-a52e-02df4e7cbcf5"

[compat]
LispSyntax = "~0.2.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "d3288ae7dc1d8267a62fbb67043ac8c492051134"

[[deps.AutoHashEquals]]
git-tree-sha1 = "45bb6705d93be619b81451bb2006b7ee5d4e4453"
uuid = "15f4f7f2-30c1-5605-9d31-71845cf9641f"
version = "0.2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.LispSyntax]]
deps = ["ParserCombinator", "REPL", "ReplMaker"]
git-tree-sha1 = "a6df629a9e5bac55b68df7215ede9bb9b14fdab6"
uuid = "51c06dcf-91d3-5c9e-a52e-02df4e7cbcf5"
version = "0.2.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.ParserCombinator]]
deps = ["AutoHashEquals", "Printf"]
git-tree-sha1 = "3a0e65d9a73e3bb6ed28017760a1664423d7e37c"
uuid = "fae87a5f-d1ad-5cf0-8f61-c941e1580b46"
version = "2.1.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.ReplMaker]]
deps = ["REPL", "Unicode"]
git-tree-sha1 = "f8bb680b97ee232c4c6591e213adc9c1e4ba0349"
uuid = "b873ce64-0db9-51f5-a568-4457d8e49576"
version = "0.2.7"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═ae0bce98-1ffe-11ee-33b8-7f8f9ac74aea
# ╠═40672741-a451-415a-aae5-4edc88cca906
# ╠═3f9311db-7b9b-41a7-8484-cd63ecc2bbeb
# ╠═44f60968-951d-4dc5-a338-acdd4be1a816
# ╠═f896e9a6-cee2-42da-a4fa-52ab077100d4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
