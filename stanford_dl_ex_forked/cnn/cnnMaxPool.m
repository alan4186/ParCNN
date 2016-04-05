function pooledFeatures = cnnMaxPool(poolDim, convolvedFeatures)
%cnnPool Pools the given convolved features
%
% Parameters:
%  poolDim - dimension of pooling region
%  convolvedFeatures - convolved features to pool (as given by cnnConvolve)
%                      convolvedFeatures(imageRow, imageCol, featureNum, imageNum)
%
% Returns:
%  pooledFeatures - matrix of pooled features in the form
%                   pooledFeatures(poolRow, poolCol, featureNum, imageNum)
%     

numImages = size(convolvedFeatures, 4);
numFilters = size(convolvedFeatures, 3);
convolvedDim = size(convolvedFeatures, 1);

pooledFeatures = zeros(convolvedDim / poolDim, ...
        convolvedDim / poolDim, numFilters, numImages);

% Instructions:
%   Now pool the convolved features in regions of poolDim x poolDim,
%   to obtain the 
%   (convolvedDim/poolDim) x (convolvedDim/poolDim) x numFeatures x numImages 
%   matrix pooledFeatures, such that
%   pooledFeatures(poolRow, poolCol, featureNum, imageNum) is the 
%   value of the featureNum feature for the imageNum image pooled over the
%   corresponding (poolRow, poolCol) pooling region. 
%   
%   Use mean pooling here.

%%% YOUR CODE HERE %%%
% poolFilter = ones(poolDim, poolDim);
% poolDimSquared = poolDim * poolDim;
% poolIndex = 1 : poolDim : (convolvedDim - max(0, poolDim - 1));
% poolIndex = 2 : poolDim : (convolvedDim - max(0, poolDim - 1));
featureSize = size(convolvedFeatures,1);
% parfor imageNum = 1:numImages
for imageNum = 1:numImages
  for filterNum = 1:numFilters
      feature = convolvedFeatures(:, :, filterNum, imageNum);
      a = 1;
      for ii = 1:poolDim:featureSize
          b = 1;
          for jj = 1:poolDim:featureSize

              pooledFeatures(a,b,numFilters,numImages) = ...
                  max(max(feature(ii:ii+poolDim-1,jj:jj+poolDim-1)));
              b = b +1;
          end
          a = a +1;
      end
%       pooledFeatures(:,:,numFilters,numImages) = feature;
  end
end
% size(pooledFeatures)
end

