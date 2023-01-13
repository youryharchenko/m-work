

expr1 = Expr(:block, 
			Expr(:using, 
				Expr(:(.), 
					:KBs
				)
			),
			Expr(:(=), 
				:kb, 
				Expr(:call, 
					Expr(:(.), 
						:KBs,
						QuoteNode(:KBase)
					)
				)
				
			)
		)


println(expr1)
        
dump(expr1)
        
eval(expr1)
        
println(kb)