#!/bin/sh

#Set default permission of new files
umask u+rwx,g+rwx,o-rwx

#Fix UID/GID
/startup -user=dja -new_uid=$(id -u) -new_gid=$(id -g)

#Enable conda paths
. /etc/profile.d/shell_intercept.sh

#Install Conda dependencies
if [ -f "$CONDA_REQUIREMENTS" ]; then
    conda install -yc conda-forge --file $CONDA_REQUIREMENTS
fi

#Install Python dependencies
if [ -f "$PIP_REQUIREMENTS" ]; then
    pip install -r $PIP_REQUIREMENTS --upgrade
fi

#Update djlab config based on env vars
CURR_CONFIG=$(yq -Y "." ${DJLAB_CONFIG})
for line in $(env | grep Djlab | sort); do
    KEY="$(echo $line | cut -d'=' -f1)"
    KEY=$(echo "$KEY" | sed -r 's/^([A-Z])/\L\1/g' | sed -r 's/([a-z0-9_])([A-Z])/\1_\L\2/g' | sed -r 's/__/\./g')
    VALUE="$(echo $line | cut -d'=' -f2)"
    CURR_CONFIG=$(echo "${CURR_CONFIG}" | yq -Y ". | .${KEY} = \"${VALUE}\"")
done
echo "${CURR_CONFIG}" > ${DJLAB_CONFIG}

#Run command
"$@"