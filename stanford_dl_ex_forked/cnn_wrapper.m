% a wrapper script to quickly edit hyper parameters of a cnn
clear; clc; close all;

addpath(genpath('cnn'));
addpath(genpath('common'));

options.epochs = 3;
options.minibatch = 256;
options.alpha = 1e-1;
options.momentum = .95;
options.learning_rate_schedule = 'none'; % 'none', 'adagrad', 'adadec'
options.heuristics_learning_rate_schedule = ''; % {'constant', 'power', 'exponential', 'halfPerEpoch'}

% for plotting training results
options.test_interval_iterations = 100;
options.numFigures = 1;
options.saveDir = 'wrapper_test_results';
options.test_results_save_file = [options.saveDir '/' ...
            options.heuristics_learning_rate_schedule '_' ...
            options.learning_rate_schedule];
        
        

% Configuration
imageDim = 28;
numClasses = 10;  % Number of classes (MNIST images fall into 10 classes)
filterDim = 9;    % Filter size for conv layer
numFilters = 20;   % Number of filters for conv layer
poolDim = 2;      % Pooling dimension, (should divide imageDim-filterDim+1)

cnnTrain;