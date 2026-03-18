import json
import re

with open('/Users/mango/Desktop/proj/soopkomong/assets/locations.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for loc in data['locations']:
    tel = loc.get('tel')
    if tel:
        print(f"ID: {loc['id']}, Tel: '{tel}'")
