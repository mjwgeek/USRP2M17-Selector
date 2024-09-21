import json
import requests

def update_reflector_file(data):
    with open('reflector_options.txt', 'w') as f:
        for item in data['reflectors']:
            designator = f"M17-{item['designator']}"
            sponsor = item['sponsor']
            country = item['country']
            ipv4 = item['ipv4']
            url = item['url']
            
            # Write the reflector details to the file in the desired format
            f.write(f"{designator} - {sponsor} ({ipv4}) - Country: {country} - URL: {url}\n")

def main():
    response = requests.get("https://dvref.com/mrefd/json/?format=json")
    data = response.json()
    
    update_reflector_file(data)
    print("Reflectors updated successfully!")

if __name__ == "__main__":
    main()
