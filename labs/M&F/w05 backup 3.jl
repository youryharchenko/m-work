### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 52782722-488c-11ed-3556-97ef5ad6a103
using CommonMark

# ╔═╡ 203744f1-cdd8-4106-a5fa-c6bc6f2e2427
cm"""
---
<div align="center">

Національний університет біоресурсів і природокористування України

Факультет інформаційних технологій

Кафедра комп'ютерних наук

<br/><br/>

Лабораторна робота 5


Використання метoдa експоненціального згладжування


Варіант 20

</div>

<br/><br/>

<div align="right">

Виконав

Студент групи ІУСТ-22001м

Харченко Юрій

</div>

<br/><br/>

<div align="center">

Київ – 2022

</div>

---
"""

# ╔═╡ 18db02d6-313b-41ed-9893-f990994485db
cm"""

#### В роботі використано мову Julia та її пакети

"""

# ╔═╡ 852a2f8b-50ea-4c23-933e-f114dac469da
using CSV, Dates, DataFrames, StatsPlots, Statistics, ;

# ╔═╡ 9d2e5181-1367-4424-bffe-cfeaa07379a7
csv = CSV.File("data.csv"; select=["year", "total"], types=Dict(:year => Date));

# ╔═╡ c24341bd-a359-448b-b974-e7fdd9e0cdeb
df = csv |> DataFrame

# ╔═╡ 0b72a438-5133-4d9b-aebb-643a526c7abe
s = collect(0.1:0.1:1.0)

# ╔═╡ f535ac28-4148-49cf-8264-68cabf0a5bbc
function rmse(abs_err)
    rmse = sqrt(mean(abs_err .* abs_err))
    return rmse
end

# ╔═╡ 84c0cadc-49ca-4de6-8fe2-ba7119064b6e
res = let
	source = df[!, :total]
	ks = 2:5
	k = []
	for i in ks
		push!(k, ema(source, n=i))
	end
	
	fig = plot(source, label="source", title="Exponential Moving Average")
	j = 1
	for i in ks
		plot!(k[j], label="k=$i")
		j += 1
	end
	
	out = "RMSE:\n"
	j = 1
	for i in ks
		r = rmse(abs.(source[i:end] .- k[j][i:end]))
		out = out * "k = $i : $(round(r, digits=4))\n"
		j += 1
	end
	(fig, out, source, ks, k)
end;

# ╔═╡ 47d70364-d01a-4964-8105-9a3d14f65d42
res[1]

# ╔═╡ 85c8f391-6749-41f3-b9c4-3ea5ada5b7d3
Text(res[2])

# ╔═╡ Cell order:
# ╟─52782722-488c-11ed-3556-97ef5ad6a103
# ╟─203744f1-cdd8-4106-a5fa-c6bc6f2e2427
# ╟─18db02d6-313b-41ed-9893-f990994485db
# ╠═852a2f8b-50ea-4c23-933e-f114dac469da
# ╠═9d2e5181-1367-4424-bffe-cfeaa07379a7
# ╠═c24341bd-a359-448b-b974-e7fdd9e0cdeb
# ╠═84c0cadc-49ca-4de6-8fe2-ba7119064b6e
# ╠═0b72a438-5133-4d9b-aebb-643a526c7abe
# ╠═47d70364-d01a-4964-8105-9a3d14f65d42
# ╠═85c8f391-6749-41f3-b9c4-3ea5ada5b7d3
# ╠═f535ac28-4148-49cf-8264-68cabf0a5bbc
