import json
import requests
import sys
import codecs

# Ensure proper encoding for both Python 2 and 3
if sys.version_info[0] < 3:
    # Python 2: Force UTF-8 encoding for stdout
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
else:
    # Python 3: Use UTF-8 encoding
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)

def update_reflector_file(data):
    with codecs.open('reflector_options.txt', 'w', encoding='utf-8') as f:
        for item in data['reflectors']:
            designator = "M17-{}".format(item['designator'])
            sponsor = item['sponsor']
            country = item['country']
            ipv4 = item['ipv4']
            url = item['url']
            
            # Write the reflector details to the file in the desired format
            f.write(u"{} - {} ({}) - Country: {} - URL: {}\n".format(
                designator, sponsor, ipv4, country, url))

def main():
    response = requests.get("https://dvref.com/mrefd/json/?format=json")
    data = response.json()
    
    update_reflector_file(data)
    print(u"Reflectors updated successfully!")

if __name__ == "__main__":
    main()
