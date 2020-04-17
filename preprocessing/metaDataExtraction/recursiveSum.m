function data =recursiveSum(data)
%recursive form of sum, will keep on summing data until it is a single
%number

while numel(data) ~= 1
    data = sum(data);
end

end