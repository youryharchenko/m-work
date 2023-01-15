using KBs

init_script = quote
    a = 11
    b = 12

    "OK"
end


dump(init_script)

kb = KBs.init(init_script)



KBs.save(kb, "save-06")