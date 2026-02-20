function copy(t)
    local s = {}
    for i = 1, #t do
        s[i] = t[i]
    end
    return s
end
