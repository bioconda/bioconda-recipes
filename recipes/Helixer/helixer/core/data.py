import logging
import os
import sys

import requests
import appdirs

import csv


MODEL_PATH = os.path.join(appdirs.user_data_dir('Helixer'), 'models')
MODEL_LIST_URL = 'https://raw.githubusercontent.com/weberlab-hhu/Helixer/main/resources/model_list.csv'
MODEL_LIST = 'model_list.csv'


def fetch_and_organize_models(priority_models):
    """downloads current best models to Helixer's user data directory"""

    # main model directory
    model_path = MODEL_PATH
    if not os.path.exists(model_path):
        os.makedirs(model_path)

    # each model
    for model in priority_models:
        mfile = model['model_file_name']
        lineage = model['lineage']
        url = model['download_link']

        path = os.path.join(model_path, lineage)
        if not os.path.exists(path):
            os.makedirs(path)
        r = requests.get(url, allow_redirects=True)
        with open(os.path.join(model_path, lineage, mfile), 'wb') as f:
            f.write(r.content)

    # additionally save model list to disk (so it can run offline w/ default models)
    r = requests.get(MODEL_LIST_URL, allow_redirects=True)
    with open(os.path.join(model_path, MODEL_LIST), 'wb') as f:
        f.write(r.content)


def prioritized_models(lineage):
    """get priority sorted list of available models for lineage"""
    model_list_url = MODEL_LIST_URL

    try:
        with requests.get(model_list_url) as response:
            ml = response.content
            ml = ml.decode().split('\n')
    except requests.exceptions.RequestException as e:
        existing_list = os.path.join(MODEL_PATH, MODEL_LIST)
        print(f'encountered error: \n{e};\n\ncontinuing with existing list: {existing_list}')
        with open(existing_list) as f:
            ml = f.readlines()
            ml = [x.rstrip() for x in ml]

    cr = csv.reader(ml)
    models = []
    header = None
    for line in cr:
        if not line or line[0].startswith('#'):
            continue
        if header is None:
            header = line
        else:
            new = {key: val for key, val in zip(header, line)}
            new['priority'] = int(new['priority'])
            models.append(new)
    if lineage is not None:
        models = [m for m in models if m['lineage'] == lineage]
    return sorted(models, key=lambda m: m['priority'])


def identify_current(lineage, prioritized):
    """identify which pre-downloaded model has highest priority / should be used"""
    prioritized_dict = {x['model_file_name']: x for x in prioritized}
    current_models = os.listdir(os.path.join(MODEL_PATH, lineage))
    recognized, unrecognized = [], []
    known = set(x['model_file_name'] for x in prioritized)
    for model in current_models:
        if model in known:
            recognized.append(model)
        else:
            unrecognized.append(model)
    print(f'Ignoring the following unexpected models in {MODEL_PATH}:'
          f'{unrecognized}.\nYou can set --model-filepath in Helixer.py if you wish to use these.', file=sys.stderr)
    if recognized:
        recognized = sorted(recognized, key=lambda x: prioritized_dict[x]['priority'])
        return recognized[0]
    else:
        print(f'no models found in {MODEL_PATH}', file=sys.stderr)
        return None


def report_if_current_not_best(prioritized, current):
    if current is None:
        print('Error: Cannot continue without a model, either download models with `fetch_helixer_models.py`'
              'or set --model-filepath in Helixer.py', file=sys.stderr)
        sys.exit(1)
    elif current == prioritized[0]['model_file_name']:
        pass  # all up to date, no action required
    else:
        logging.info(f'newer/better model: {prioritized[0]["model_file_name"]} available than current: {current}'
                     f'for lineage {prioritized[0]["lineage"]}.'
                     f'You can get the latest model(s) with fetch_helixer_models.py, if desired.')

