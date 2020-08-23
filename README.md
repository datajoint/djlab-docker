# DJLab

A docker image optimized for running a JupyterLab environment with DataJoint.

# Launch locally


`docker-compose -f dist/alpine/docker-compose.yml --env-file config/.env up --build`
OR
`docker-compose -f dist/debian/docker-compose.yml --env-file config/.env up --build`


# Notes

https://hub.docker.com/r/datajoint/djlab