# DJLab

A docker image optimized for running a JupyterLab environment with DataJoint.

# Features

- Add Jupyter Lab environment
- Adds `djlab magic`: a mechanism for configuring and modifying Jupyter features w/o JupyterLab service interruption.
- `djlab magic` can be accessed in notebook via magic e.g. `%djlab [args*]` or programatically.
- To access all config: `%djlab`
- To access specific config: `%djlab [djlab config index]` e.g. `%djlab djlab.jupyter_notebook.save_output`
- To set config: `%djlab [djlab config index] [value]` e.g. `%djlab djlab.jupyter_notebook.save_output TRUE`
- `djlab magic` supports the following configuration:
  - `djlab.jupyter_notebook.display_filepath` - (string, default: `'NULL'`, env: `Djlab_JupyterNotebook_DisplayFilepath`) Absolute filepath of file to show immediately after login
  - `djlab.jupyter_notebook.password` - (string, default: `'datajoint'`, env: `Djlab_JupyterNotebook_Password`) Password to allow JupyterLab login
  - `djlab.jupyter_notebook.save_output` - (string, default: `'FALSE'`, env: `Djlab_JupyterNotebook_SaveOutput`) Determine if output should be saved when saving noteboook
- To access programatically, you call to it as such: `print(__import__('djlab').get_djlab_config('djlab.jupyter_notebook'))`
- Applies image compresssion

# Launch locally

```shell
docker-compose -f dist/alpine/docker-compose.yml --env-file config/.env up --build
```

OR

```shell
docker-compose -f dist/debian/docker-compose.yml --env-file config/.env up --build
```


# Notes

https://hub.docker.com/r/datajoint/djlab