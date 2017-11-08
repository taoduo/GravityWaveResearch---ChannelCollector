import sys
import re
for line in sys.stdin:
	m = re.search('(^[0-9]+\\.[0-9]*)*', line)
	print(m.group(0)),