# Configuration file for ipython-notebook.
from os import getenv, getuid
from pwd import getpwall
from IPython.lib import passwd
from traitlets.config import Config
from djlab import get_djlab_config

user = [u for u in getpwall() if u.pw_uid == getuid()][0]
c = Config() if 'c' not in locals() else c

# ------------------------------------------------------------------------------
# NotebookApp configuration
# ------------------------------------------------------------------------------

# NotebookApp will inherit config from: BaseIPythonApplication, Application

# The IPython password to use i.e. "datajoint".


c.NotebookApp.password = passwd(get_djlab_config(
    'djlab.jupyter_notebook.password')).encode('utf-8')

# Allow root access.
c.NotebookApp.allow_root = True

# The IP to serve on.
c.NotebookApp.ip = u'0.0.0.0'

# The Port to serve on.
c.NotebookApp.port = 8888

c.NotebookApp.default_url = '/lab'

c.NotebookApp.notebook_dir = user.pw_dir

c.NotebookApp.terminado_settings = { 'shell_command': [user.pw_shell, '-l'] }

c.FileContentsManager.root_dir = '/home'

# you may also use a query param ?file-browser-path= to modify tree navigation on left
c.NotebookApp.default_url = ('/lab' if get_djlab_config(
                                'djlab.jupyter_notebook.display_filepath') == 'NULL'
                             else '/lab/tree{}'.format(
                                get_djlab_config(
                                    'djlab.jupyter_notebook.display_filepath').replace(
                                        c.FileContentsManager.root_dir, '')))


def scrub_output_pre_save(model, **kwargs):
    """scrub output before saving notebooks"""
    if not get_djlab_config('djlab.jupyter_notebook.save_output').upper() == 'TRUE':
        # only run on notebooks
        if model['type'] != 'notebook':
            return
        # only run on nbformat v4
        if model['content']['nbformat'] != 4:
            return

        model['content']['metadata'].pop('signature', None)
        for cell in model['content']['cells']:
            if cell['cell_type'] != 'code':
                continue
            cell['outputs'] = []
            cell['execution_count'] = None
    else:
        return


# add shortcut to move cell up/down
c.FileContentsManager.pre_save_hook = scrub_output_pre_save
