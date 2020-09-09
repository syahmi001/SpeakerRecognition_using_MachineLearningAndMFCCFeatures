2.%% Getting the data loaded
dataDir = 'Trainingdata';
ads = audioDatastore(dataDir, 'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames')

[trainDatastore, testDatastore] = splitEachLabel(ads,0.80);

trainDatastore
trainDatastoreCount = countEachLabel(trainDatastore)

testDatastore
testDatastoreCount = countEachLabel(testDatastore)

[sampleTrain, info] = read(trainDatastore);
sound(sampleTrain,info.SampleRate)

reset(trainDatastore)

%% Feature extraction
lenDataTrain = length(trainDatastore.Files);
features = cell(lenDataTrain,1);
for i = 1:lenDataTrain
    [dataTrain, infoTrain] = read(trainDatastore);
    features{i} = ComputePitchAndMFCC(dataTrain,infoTrain);
end
features = vertcat(features{:});
features = rmmissing(features);
head(features)   % Display the first few rows

%% Normalize the data
featureVectors = features{:,2:15};

m = mean(featureVectors);
s = std(featureVectors);
features{:,2:15} = (featureVectors-m)./s;
head(features)   % Display the first few rows

%% Training classifier
inputTable     = features;
predictorNames = features.Properties.VariableNames;
predictors     = inputTable(:, predictorNames(2:15));
response       = inputTable.Label;

trainedClassifier = fitcknn( ...
    predictors, ...
    response, ...
    'Distance','euclidean', ...
    'NumNeighbors',5, ...
    'DistanceWeight','squaredinverse', ...
    'Standardize',false, ...
    'ClassNames',unique(response));

%% Perform cross-validation
k = 5;
group = response;
c = cvpartition(group,'KFold',k); % 5-fold stratified cross validation
partitionedModel = crossval(trainedClassifier,'CVPartition',c);

%Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);

%Visualize the confusion chart
validationPredictions = kfoldPredict(partitionedModel);
figure
cm = confusionchart(features.Label,validationPredictions,'title','Validation Accuracy');
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';



%% Testing the classifier

lenDataTest = length(testDatastore.Files);
featuresTest = cell(lenDataTest,1);
for i = 1:lenDataTest
  [dataTest, infoTest] = read(testDatastore);
  featuresTest{i} = ComputePitchAndMFCC(dataTest,infoTest); 
end
featuresTest = vertcat(featuresTest{:});
featuresTest = rmmissing(featuresTest);
featuresTest{:,2:15} = (featuresTest{:,2:15}-m)./s; 
head(featuresTest)   % Display the first few rows


%% Displaying results
result = KNNClassifier(trainedClassifier, featuresTest)


%% Who is speaking?
%function myspeakerrecog
dataDir2 = 'Testingdata'; 

%the name of people are as below:
%Adli, AsyrafF, AsyrafO, Fathul, Firdaus, Hakim, Meor, Syahmi, Syazani,
%Yasir.

ads2 = audioDatastore(dataDir2, 'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames')

speakerdata = ads2;
lenDataTest2 = length(speakerdata.Files);
whofeature = cell(lenDataTest2,1);

for i = 1:lenDataTest2
  [dataTest2, infoTest2] = read(speakerdata);
  whofeature{i} = ComputePitchAndMFCC(dataTest2,infoTest2); 
end

whofeature = vertcat(whofeature{:});
whofeature = rmmissing(whofeature);
whofeature{:,2:15} = (whofeature{:,2:15}-m)./s;
result1 = KNNClassifier(trainedClassifier, whofeature)

%end