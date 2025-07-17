import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['ENV', 'BUCKET_NAME'])

env = args['ENV']
bucket = args['BUCKET_NAME']