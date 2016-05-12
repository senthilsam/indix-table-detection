# indix-table-detection
Pre Requiste

1. Perl 5.16
2. Python 2.7
  2.1 sklearn
  2.2 pickle
  
Steps for training:
step 1: Generating feature file from trainfile
        perl extractBinaryFeatureTrainset.pl <input train file> <feature file name>
step 2. Train Random Forest model with the help of feature file.
        python trainRandomForest.py
            It will ask for the feature file and modelfile name.

steps for testing:
step 1: Generating feature file from testfile.
        perl extractBinaryFeatureTestset.pl <input train file> <test feature file name>
step 2. Predict the output with the help of model file and test feature file.
        python trainRandomForest.py
            It will ask for the feature file and modelfile name and outfile.
            
