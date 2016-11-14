

%[Wc, Wd, bc, bd] = cnnParamsToStack(theta,imageDim,filterDim,numFilters,...
%poolDim,numClasses);

% shift Wc to be integers
intWc = Wc * 2^8;
intWc = round(intWc);
intWc(intWc > 2^8-1) = 2^8-1;
intWc(intWc < -2^8) = -2^8;
dim = size(intWc);
binWc = cellstr(dec2twos(intWc,9));
binWc = reshape(binWc,dim);

for i = 0:size(Wc,3)-1
   csvwrite(['kernel_base2/kernel',num2str(i),'.csv'],binWc(:,:,i+1));
   disp(['writing: kernel_base2/kernel',num2str(i),'.csv']);
end