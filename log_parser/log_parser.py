from collections import defaultdict
import re
import os.path
import csv

class Author(object):
    name = ""
    email = ""

    def __init__(self, name, email):
        self.name = name
        self.email = email


class FileChangeLog(object):
    fileName = ""
    added = 0
    removed = 0
    author = None

    
    def __init__(self, fileName, added, removed, author):
        self.fileName = fileName
        self.added = int(added)
        self.removed = int(removed)
        self.author = author

def computeStats(fileEntries):
    stats = list()
    
    for k,v in fileEntries.iteritems():
        stat = {'fileName':k, 'added':0, 'removed':0, 'addedTimes':0, 'removedTimes':0, 'commits':len(v)}
        distinctAuthors = set()
        stats.append(stat)
        for entry in v:
            stat['added'] += entry.added
            stat['removed'] += entry.removed
            if entry.added > 0:
                stat['addedTimes'] += 1
            if entry.removed > 0:
                stat['removedTimes'] += 1
            distinctAuthors.add(entry.author)
        stat['authorsCount'] = len(distinctAuthors)
        
    return stats
    
def isCodeFile(fileName):
    lowerName = fileName.lower() 
    return lowerName.endswith('.cs') and not  lowerName.endswith('assemblyinfo.cs') 
        
def printStats(statsList):
    sourceCodeFiles = [f for f  in statsList if isCodeFile(f['fileName'])]
    topModified = sorted(sourceCodeFiles,key=lambda item: item['addedTimes'], reverse=True)[:20]
    for k in topModified:
        print '{fileName} addedTimes : {addedTimes} , removedTimes : {removedTimes}, added : {added}, removed : {removed}, authorsCount : {authorsCount}'.format(**k)
        

def parseFileChangesLine(added, removed, fileName):
    print added + ' _ ' + removed + ' - ' + fileName

def parseLogFile(log_fh):
    fileEntries = defaultdict(list)
    authors = dict()
    currentAuthor = None

    for line in log_fh:
        
        matched = re.match('^(?P<added>\d+)\t(?P<removed>\d+)\t(?P<fileName>[\w|/\.]+)', line)
        if matched:
            entry = FileChangeLog(matched.group('fileName'), matched.group('added'), matched.group('removed'), currentAuthor)
            fileEntries[entry.fileName].append(entry)
        else:
            matched = re.match('Author:\s(?P<name>.*)\s<(?P<email>.*)>', line)
            if matched:
                email = matched.group('email')
                name = matched.group('name')

                if email not in authors:
                    author = Author(name, email)
                    authors[email] = author
                
                currentAuthor = authors[email]
    
    return fileEntries



def get_raw_entries():
    with open('../../docs/log-examples/AutoFixture.log') as file:
        fileEntries = parseLogFile(file)
        return fileEntries

def get_stats():
        fileEntries = get_raw_entries()
        stats = computeStats(fileEntries)
        return stats

def get_change_stats_by_extension():
    fileEntries = get_raw_entries()
    entries = list()
    extensionsCounter = 0
    extensions = defaultdict(int)
    for k,v in fileEntries.iteritems():
        filename, file_extension = os.path.splitext(k)
        if file_extension not in extensions:
            extensionsCounter += 1
            extensions[file_extension] = extensionsCounter;            
        for entry in v:
            entries.append([entry.added, entry.removed, extensions[file_extension]])
    return entries, extensions






