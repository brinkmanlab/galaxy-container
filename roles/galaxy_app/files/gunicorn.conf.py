import os
import sys
from ruamel.yaml import YAML

dir_path = os.path.dirname(os.path.realpath(__file__))

with open(os.path.join(dir_path, 'gunicorn.yml')) as f:
    c = YAML(typ='safe').load(f)
#sys.path.append(c['pythonpath'])

from galaxy.web_stack.gunicorn_config import *
globals().update(c)

