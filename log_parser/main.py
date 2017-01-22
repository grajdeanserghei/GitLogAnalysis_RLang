import r_log_parser

entries = r_log_parser.get_commit_entries('Autofixture.log')
denormalized, headers = r_log_parser.denormalize_commits(entries)
denormalized.insert(0, headers)
r_log_parser.export_to_csv('output/commit_log.csv', denormalized)

print 'Done!'
