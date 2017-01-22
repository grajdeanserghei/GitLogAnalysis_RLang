from collections import defaultdict
import re
import os.path
import csv

def parseCommits(log_fh):
    commits = []
    commit = None    
    for line in log_fh:      

        matched = re.match('^commit (?P<id>\w+)', line)
        if(matched):
            if commit != None:
                commits.append(commit)            
            commit = {'id' : matched.group('id'), 'files': []}            
            pass
        
        matched = re.match('Author:\s(?P<name>.*)\s<(?P<email>.*)>', line)
        if matched:
            commit['author'] =  matched.group('name')
            commit['email'] =  matched.group('email')
            pass
        
        matched = re.match('^Date: (?P<date>.*)', line)
        if matched:
            commit['date'] =  matched.group('date')            
            pass            
        
        matched = re.match('^(?P<added>\d+)\t(?P<removed>\d+)\t(?P<fileName>[\w|/\.]+)', line)
        if matched:
            fileEntry = {'fileName': matched.group('fileName'), 'added' :  matched.group('added'), 'removed' : matched.group('removed')}           
            commit['files'].append(fileEntry)
            pass
    
    commits.append(commit)
    return commits

def denormalize_commits(commits):
    results = list()    
    for commit in commits:
        id = commit['id']
        author = commit['author']
        email = commit['email']
        date = commit['date']

        for fileEntry in commit['files']:
            fileName = fileEntry['fileName']
            added = fileEntry['added']
            removed = fileEntry['removed']
            results.append([id, author, email, date, fileName, added, removed])
    
    headers = ['id', 'author', 'email', 'date', 'fileName', 'added', 'removed']
    return results, headers
      

def get_commit_entries(fileName):
    with open(fileName) as file:
        fileEntries = parseCommits(file)
        return fileEntries

def export_to_csv(fileName, entriesList):
    with open(fileName, 'wb') as csvFile:
        wr = csv.writer(csvFile, quoting=csv.QUOTE_MINIMAL)
        wr.writerows(entriesList)