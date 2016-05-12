# @author       :Senthilkumar Soundararajan
# @filename     :test_random_foret_v1.0.1.py
# Purpose       :Used to test RF model


import os
import sys
from sklearn.ensemble import RandomForestClassifier
import pickle

if __name__ == "__main__":
    
    testFile = raw_input( "Enter Test Set File: " )
    modelFile = raw_input( "Enter Model file: " )
    outFile = raw_input( "Enter out file: " )
    # Load model
    f = open(modelFile, 'rb')
    classifier = pickle.load(f)
    f.close()
    
    inputdata = []
    OUT = open(outFile,'w')
    # has_table has_neted_table has_no_row_col  has_one_row has_one_col row_count   col_count   head_count  has_title   has_attribs has_links   has_dimensions  has_details has_book_detals has_product_detals  has_electronics answer_label
    if os.path.isfile(testFile):
        with open(testFile) as file:
            for line in file:
                if line[0] == "#":
                    continue
                features = line.split("\t")
                inputdata.append(features)
    # predict
    output = classifier.predict(inputdata)
    # print
    for answer in output:
        if str(answer) == str(1):
            OUT.write(  "yes\n" )
        elif str(answer) == str(0):
            OUT.write(  "no\n" )
    
    OUT.close()
    