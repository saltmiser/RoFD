#!/usr/bin/python
from os import sys

# Simply open a file for reading
def getInputFile(fileName):
  return open(fileName, 'r')

# Find the position in a file where the 
# data starts
def findDataBeginningInFile(fileHandle):
  for i in range(0, 6): # we so happen to know the first 6 lines is just header
    void = fileHandle.readline()
  return fileHandle

# Parse a line in the file and return a LIST of the values from each line  
def getValuesForQuanta(resultStore, fileHandle):
  lineInFile = fileHandle.readline().split()  
  if(len(lineInFile) == 0):
    return resultStore
  else:
    result = []
    for element in lineInFile:
      result.append(round(float(element), 1))
    resultStore.append(result)
    return getValuesForQuanta(resultStore, fileHandle) 

# Given a data table, an xyIndex (columns) into that table, and a starting 
# row in that table, return a slope measurement over an increasing or 
# decreasing area of the data and return the slope, along with the end
# position of the data (since you know the start!)
def getNextSlope(data, xIndex, yIndex, start):
  startValueX = data[start][xIndex]
  startValueY = data[start][yIndex]
  lastValueX = startValueX
  lastValueY = startValueY
  trendY = 0
  for row in range(start+1, len(data)):
    thisValueX = data[row][xIndex]
    thisValueY = data[row][yIndex]
    changeX = thisValueX - lastValueX
    changeY = thisValueY - lastValueY
    if(trendY == 0):
      trendY = changeY
    else:
      if(trendY < 0 and changeY > 0):
        return row
      elif(trendY > 0 and changeY < 0):
        return row
  return len(data) - 1
        


# Main program beings here
sys.setrecursionlimit(10000)
fileHandle = getInputFile('LHIP 240.txt')
fileHandle = findDataBeginningInFile(fileHandle)
allData = []
getValuesForQuanta(allData, fileHandle)
for d in allData:
  print d

