import math
import csv
from bs4 import BeautifulSoup
from datetime import datetime
import re

# 保存したHTMLのpath
path = 'C:/Users/Little_Rubyist/Downloads/wacca_mypage.html'
page = open(path,encoding='utf-8_sig')
soup = BeautifulSoup(page.read())
list = soup.find('ul', 'playdata__score-list__wrap').find_all('li', 'item')
date = datetime.today().strftime('%Y_%m_%d')
csv_name = f"C:/Users/Little_Rubyist/Downloads/wacca_score/{date}.csv"
with open(csv_name, mode='w', encoding='UTF-8', newline="") as f:
    writer = csv.writer(f)
    writer.writerow(['title', 'difficult', 'level', 'score', 'rate', 'achieve'])

def calculate_rate(score):
    if score == 1000000:
        return 'Master'
    elif 990000 <= score <= 999999:
        return 'SSS+'
    elif 980000 <= score <= 989999:
        return 'SSS'
    elif 970000 <= score <= 979999:
        return 'SS+'
    elif 950000 <= score <= 969999:
        return 'SS'
    elif 930000 <= score <= 949999:
        return 'S+'
    elif 900000 <= score <= 929999:
        return 'S'
    elif 850000 <= score <= 899999:
        return 'AAA'
    elif 800000 <= score <= 849999:
        return 'AA'
    elif 700000 <= score <= 799999:
        return 'A'
    elif 300000 <= score <= 699999:
        return 'B'
    elif 1 <= score <= 299999:
        return 'C'

def check_achieve(src):
    if 'achieve4.png' in src:
        return 'All Marvelous'
    elif 'achieve3.png' in src:
        return 'FullConbo'
    elif 'achieve2.png' in src:
        return 'Missless'
    elif 'achieve1.png' in src:
        return 'Clear'

def calculate_level(level):
    if level.is_integer():
        return math.floor(level)
    elif not level.is_integer():
        return f"{math.floor(level)}+"

def find_achieve_src(different):
    return song.find('div', f'score__icon__{different}').find('img', attrs={'alt': 'achieveimage'})['src']

for song in list:
    title = song.find('div', 'playdata__score-list__song-info__name').string
    normal_level = float(song['data-rank_normal_level'])
    hard_level = float(song['data-rank_hard_level'])
    expert_level = float(song['data-rank_expert_level'])
    inferno_level = float(song['data-rank_inferno_level'])
    normal_score = int(song['data-rank_normal_score'])
    hard_score = int(song['data-rank_hard_score'])
    expert_score = int(song['data-rank_expert_score'])
    inferno_score = int(song['data-rank_inferno_score'])
    normal_achieve = find_achieve_src('normal')
    hard_achieve = find_achieve_src('hard')
    expert_achieve = find_achieve_src('expert')
    inferno_achieve = find_achieve_src('inferno')

    with open(csv_name, mode='a', encoding='UTF-8', newline="") as f:
        writer = csv.writer(f, delimiter=",", quotechar='"', quoting=csv.QUOTE_MINIMAL)
        writer.writerow([title, 'Normal', calculate_level(normal_level), normal_score, calculate_rate(normal_score), check_achieve(normal_achieve)])
        writer.writerow([title, 'Hard', calculate_level(hard_level), hard_score, calculate_rate(hard_score), check_achieve(hard_achieve)])
        writer.writerow([title, 'Expert', calculate_level(expert_level), expert_score, calculate_rate(expert_score), check_achieve(expert_achieve)])
        if inferno_level != 0:
            writer.writerow([title, 'Inferno', calculate_level(inferno_level), inferno_score, calculate_rate(inferno_score), check_achieve(inferno_achieve)])