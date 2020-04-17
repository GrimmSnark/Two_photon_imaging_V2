function linspacedVector = linspaceVector(vectStart, vectEnd, n)
% Function linearly spaces a vector between the start and end vectors while
% keeping the proportions of the vector constant
% Inputs: vectStart- m x 1 vector of start values
%         vectEnd: m x 1 vector of end values
%         n: number of linearly spaced values

linspacedVector = zeros(length(vectStart), n);

for i = 1:length(vectStart)
   linspacedVector(i,:) = linspace(vectStart(i), vectEnd(i), n);
end


end