import re

print(re.match(r'^\+?[1-9][0-9]{7,14}$', "+79999999999") is None)