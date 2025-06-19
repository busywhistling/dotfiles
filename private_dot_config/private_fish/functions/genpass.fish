function genpass
set p1 (xkcdpass -d "_" -C "random" -n 4)
set p2 (math (random)'%10')
echo "$p1@$p2"
end
