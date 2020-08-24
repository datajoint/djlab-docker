from traitlets.config import Config
c = Config() if 'c' not in locals() else c

c.InteractiveShellApp.extensions = ['djlab']
