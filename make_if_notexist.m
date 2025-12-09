function make_if_notexist(myfolder)
%UNTITLED3 Summary of this function goes here
if (~isfolder(myfolder))
    mkdir(myfolder)
end

end