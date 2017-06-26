from bs4 import BeautifulSoup
from bs4.element import Tag
import requests
from pprint import pprint
import yaml
from time import sleep

BASE_URL_TEMPLATE = 'http://rbnorway.org/{}-t7-frames/'
CHARACTER_NAMES = [
    'Jack7',
    'Shaheen',
]



def _request_character_rows(name):
    resp = requests.get(BASE_URL_TEMPLATE.format(name))
    soup = BeautifulSoup(resp.text, 'html.parser')
    rows = soup.find_all('tr')[1::]
    return rows


def main():

    characters_map = {'characters': {}}
    for name in CHARACTER_NAMES:
        rows = _request_character_rows(name)
        character_map = _build_character_yaml(name, rows)
        characters_map['characters'].update(character_map)
        yaml_file = open('assets/{}.yaml'.format(name), 'w')
        yaml.dump(character_map, yaml_file, default_flow_style=False)
        yaml_file.close()
        sleep(2)
    exit(0)


def _build_character_yaml(name, rows):
    character_map = {name: {'moves': []}}
    for row in rows:
        tds = row.find_all('td')
        move = {
            'command': tds[0].text,
            'hit_level': tds[1].text,
            'damage': tds[2].text,
            'start_up_frames': tds[3].text,
            'block_frame': tds[4].text,
            'hit_frame': tds[5].text,
            'counter_hit_frame': tds[6].text
        }
        character_map[name]['moves'].append({'move': move})

    return character_map


if __name__ == '__main__':
    main()
