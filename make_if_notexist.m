function make_if_notexist(myfolder)
%check if a folder exsits, if not, make one.
if (~isfolder(myfolder))
    mkdir(myfolder)
end

end