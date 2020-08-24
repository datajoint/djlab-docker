from IPython.core.magic import line_magic, Magics, magics_class
from yq import cli
import io
from contextlib import redirect_stdout
from os import getenv


def get_djlab_config(key):
    f = io.StringIO()
    with redirect_stdout(f):
        try:
            cli(args=['-Y', '.{}'.format(key), getenv('DJLAB_CONFIG')])
        except SystemExit:
            pass
    if f.getvalue().find(': ') > -1:
        return f.getvalue()
    else:
        return f.getvalue().replace('\n', '').replace('\'', '').replace('...', '')


def set_djlab_config(key, value):
    config_file = getenv('DJLAB_CONFIG')
    f = io.StringIO()
    with redirect_stdout(f):
        try:
            cli(args=['-Y', f'. | .{key} = \"{value}\"', config_file])
        except SystemExit:
            pass
    with open(config_file, 'w') as out:
        out.write(f.getvalue())


@magics_class
class DjlabConfig(Magics):
    @line_magic
    def djlab(self, line):
        args = line.split()
        if len(args) == 0:
            print(get_djlab_config(''))
        elif len(args) == 1:
            print(get_djlab_config(args[0]))
        elif len(args) == 2:
            set_djlab_config(args[0], args[1])


def load_ipython_extension(ipython):
    """
    Any module file that define a function named `load_ipython_extension`
    can be loaded via `%load_ext module.path` or be configured to be
    autoloaded by IPython at startup time.
    """
    # You can register the class itself without instantiating it.  IPython will
    # call the default constructor on it.
    ipython.register_magics(DjlabConfig)
