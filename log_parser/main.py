import neural_network as nn
import r_log_parser
import log_parser
# xor_network = [[[20, 20, -30], [20, 20, -10]],[[60, 60, -30]]]

# for x in [0,1]:
#     for y in [0,1]:
#         print x, y, nn.feed_forward(xor_network, [x,y])[-1]


entries = r_log_parser.get_commit_entries()
denormalized, headers = r_log_parser.denormalize_commits(entries)
denormalized.insert(0, headers)
log_parser.export_to_csv('output/commit_log.csv', denormalized)
# with open("Output.txt", "w") as text_file:
#     text_file.write(str(entries))

print 'job done!'

# entries, extensions = log_parser.get_change_stats_by_extension()
# log_parser.export_to_csv('entires.txt', entries)
# log_parser.export_to_csv('extensions.txt', [[k,v] for k,v in extensions.iteritems()])

# raw = log_parser.get_raw_entries()

# log_parser.export_to_csv('raw.txt', [(key,e.added, e.removed) for key, values in raw.iteritems() for e in values])

