# set the directory we are using as a root directory so we dont have to access the full path with files etc.
setwd("c:/datparse")

# this gets a list of the files that match the pattern in the working directory set above
files <- list.files(pattern ="*.dat")

# loops through each of the files and puts the name in fname
for (fName in files) { 
      
      # a file connection for reading the file 
      con <- file(fName,open="r")
      
      # put all the lines of the file into a variable can look at a file by pasting say...
      
      # files <- list.files(pattern ="*.dat")
      # con <- file(files[5],open="r")
      # dataChunk<-readLines(con)
      # dataChunk
      
      # into the console that way you can look at file[5] if its formatting is different
      dataChunk<-readLines(con)
      
      # the file is in a variable so we don't need it anymore 
      close(con)
      print(paste("Processing file" , fName))
      
      #output file - keep the name just output in a new dir and use .csv not .dat etc etc
      # ok this just creates the new file name - strsplit splits on the "." of the old file then unlist turns the result from a list
      # to a vector and [1] gets the first part of the vector or the bit before the "." then paste joins this to "csv" with a "."
      newFileName <- paste(unlist(strsplit(fName, "\\."))[1], "csv", sep=".")
      
      # out put to the console so we can see what's happening
      print(newFileName)
      
      # use the filename we created to open a file in the directory - file cant be opened if it is open in windows
      fileConn<-file(paste(c("./Output"), newFileName, sep="/"), open="w")
      
      # set the initial tag name to nothing
      tagName <- NULL
      
      # loop through each of the lines in the file
      for(line in dataChunk) {
            # ignore the LB Lines - next exits the current iteration of the loop and gets the next line
            if (startsWith(line, "LB,")) next
            
            # use TR lines to set the tag name
            if (startsWith(line, "TR,")) {
                  cols = unlist(strsplit(line, ","))
                  # assumed this is always the second column.... if not then cry.
                  tagName = cols[2]
                  print(paste("Values for tag" , tagName))
            }
            # everything else is a value for the last tagname
            else {
                  # if this isn't a TR or LB line split it by "," and put the columns into the timeVal variable
                  timeVal = unlist(strsplit(line, ","))
                  
                  # ignoring the ? marks blah blah - timeVal[2] will be the second column so if it's "?" get the next line in the loop
                  if (timeVal[2] == "?") next
                  
                  # formats are here... https://stat.ethz.ch/R-manual/R-devel/library/base/html/strptime.html
                  # timeVal[1] should be the timestamp - first column of the row.
                  # %Y = 4 digit year ie 2017
                  # %m = 2 digit month ie 01 (January)
                  # %d = 2 digit day ie 07 for seventh day of January
                  # T = the letter T it doesn't have a % so it's just a letter
                  # %H = 24hr time 2 digits ie 01 or 00 or 21
                  # %M = 2 digit minute ie 47
                  # %OS = seconds with milliseconds with three values after the decimal
                  # Z is the letter Z
                  # lessCrazyTimeFmt now holds a dateTime variable
                  lessCrazyTimeFmt = strptime(timeVal[1], format="%Y%m%dT%H%M%OSZ", tz="")
                  
                  # not sure why you havd a ")" in there... I've removed it now
                  # strftime formats the time variable using the same format as before
                  # %d %Y %H %M all work as before
                  # %b is the three letter month format ie Jan
                  # %OS3 is seconds with milliseconds to 3 decimal places ie 23.334 can make this 2 or 4 decimal places by using %OS2 or %OS4 etc
                  # paste joins tagName, the time format and the value (timeVal[2]) into a single string using the "," separator
                  outLine = paste(tagName, strftime(lessCrazyTimeFmt, format="%d-%b-%Y %H:%M:%OS3", tz=""), timeVal[2], sep=",")
                  
                  # write this out to the file we opened earlier.
                  writeLines(outLine, fileConn)
            }
      }
      
      # close the file connection and go back up and do the next file.
      close(fileConn)
}
