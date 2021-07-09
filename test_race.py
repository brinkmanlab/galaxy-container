#!/usr/bin/env python3

import sys
if sys.version_info[0] < 3:
    raise Exception("Must be using Python 3")

from pathlib import Path

try:
    import bioblend
    from bioblend.galaxy.objects import GalaxyInstance
    from bioblend.galaxy.objects.wrappers import History, HistoryDatasetAssociation
except ImportError as e:
    print(e, file=sys.stderr)
    print("\n\033[1m\033[91mBioBlend dependency not found.\033[0m Try 'pip install bioblend'.", file=sys.stderr)
    exit(1)

__version__ = '0.1.0'

#import logging
#logging.basicConfig(level=logging.DEBUG)

upload_history_name = 'Uploaded data'
upload_history_tag = 'user_data'


def get_upload_history(conn) -> History:
    """
    Helper to get or create a history to contain uploads
    :param conn: An instance of GalaxyInstance
    :return: A History instance
    """
    histories = conn.gi.histories.get_histories()
    for history in histories:
        if upload_history_tag in history['tags']:
            return conn.histories.get(history['id'])
    else:
        history = conn.histories.create(name=upload_history_name)
        history.tags.append(upload_history_tag)
        history.update(tags=history.tags)
        return history


def upload(history: History, path: Path, label: str = '', type: str = None) -> HistoryDatasetAssociation:
    """
    Upload datasets
    :param history: History to upload to
    :param path: path to file to upload
    :param label: label to assign to dataset
    :param type: type of dataset as determined by Galaxy
    :return: HDA instance
    """
    if not path.is_file():
        print("Invalid file path specified")

    if not label:
        label = path.name

    if type:
        hda = history.upload_file(str(path.resolve()), file_name=label, file_type=type)
    else:
        hda = history.upload_file(str(path.resolve()), file_name=label)

    return hda


if __name__ == '__main__':
    conn = GalaxyInstance('localhost:8000', '63ade82a83e02581f076f34522d957b7')
    h = get_upload_history(conn)
    i = 0
    while True:
        upload(h, Path('./LICENSE'), 'test', 'txt')
        i += 1
        if i % 100 == 0:
            h.update()
            if 'error' in h.state_details and h.state_details['error'] > 0:
                print('Error detected.')
                exit(1)
