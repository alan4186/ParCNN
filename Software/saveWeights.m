

[Wc, Wd, bc, bd] = cnnParamsToStack(theta,imageDim,filterDim,numFilters,...
poolDim,numClasses);

for i = 1:size(Wc,3)
    % shift weights to match hardware index
    Wc(:,:,i) = rot90(Wc(:,:,i),2);
end
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


%% write FFN weights
numFilter = 8;
fm_dim = sqrt(size(Wd,2)/numFilter)
for i=1:size(Wd,1)
    ffnw = Wd(i,:);
    ffnw = reshape(ffnw,[fm_dim,fm_dim,numFilter]);
    for f=1:numFilter
        ffnw(:,:,f) = ffnw(:,:,f)';
    end
    ffnw= reshape(ffnw,[],1);
    
    iffnw = ffnw * 2^16;
    iffnw = round(iffnw);
%     iffnw(iffnw > 2^8-1) = 2^8-1;
%     iffnw(iffnw < -2^8) = -2^8;
    dim = size(iffnw);
    binffnw = (dec2twos(iffnw,24));
    dffnw = bin2dec(binffnw);
    hffnw = (dec2hex(dffnw,8));
    
    c = cell(size(Wd,2),2);
    addr = 0:size(Wd,2)-1;
    for q=1:size(addr,2)
        c{q,1} = addr(q);
        c{q,2} = hffnw(q,:);
    end
%     formatSpec = '%d,%s\n';
%     fileID = fopen(['ffn_weight_csvs/ffn_weight',num2str(i-1),'.csv'],'w');
%     [nrows,ncols] = size(c);
%     for row = 1:nrows
%         fprintf(fileID,formatSpec,c{row,:});
%     end
%     fclose(fileID);
    T = cell2table(c,'VariableNames',{'Addr_Base10','Data_Base16'});
    writetable(T,['ffn_weight_csvs/ffn_weight',num2str(i-1),'.csv'])
    disp(['writing: ffn_weight',num2str(i-1),'.csv']);
   
end
    