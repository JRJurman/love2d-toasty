-- Source - https://stackoverflow.com/a/68486276
-- Posted by MHebes, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-01-31, License - CC BY-SA 4.0

function shuffle(t)
    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end
