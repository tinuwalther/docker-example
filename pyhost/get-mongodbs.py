import sys

def get_dbs(connectionstring):
    '''Connect to MongoDB and print out all databases'''
    import pymongo
    mongo_client = pymongo.MongoClient(connectionstring)
    print(mongo_client.list_database_names())
    mongo_client.close()

if len(sys.argv) == 1:
  mongohost = ''
else:
  mongohost = str(sys.argv[1])

if len(mongohost) == 0 or mongohost == '--help':
  print('Usage: python3 ' + str(sys.argv[0]) + ' <argument>')
  print('  Argument: hostname or ip-address to connect to the mongodb')
  print('  Example:  172.17.0.2')
else:
  connectionstring = "mongodb://"+ mongohost
  print('Trying to connect to: ' + connectionstring + ':27017')
  get_dbs(connectionstring)