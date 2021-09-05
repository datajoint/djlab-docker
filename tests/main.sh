#!/bin/bash

assert ()
{
	E_PARAM_ERR=98
	E_ASSERT_FAILED=99

	if [ -z "$3" ]; then
		return $E_PARAM_ERR
	fi

	lineno=$3
	if ! eval "$2"; then
		echo "Assertion failed:  \"$2\""
		echo "File \"$0\", line $lineno"
		exit $E_ASSERT_FAILED
	else
		echo "---------------- TEST[$SHELL_CMD_FLAGS]: $1 ✔️ ----------------" | \
			tr -d '\t'
	fi
}
validate () {
	assert "get djlab default password" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
		python -c 'print(__import__("djlab").get_djlab_config(\
			"djlab.jupyter_server.password"))'
	END
	) == 'datajoint' ]" $LINENO
	SHELL_CMD_FLAGS="-e Djlab_JupyterServer_Password=test"
	SHELL_CMD=$(eval "echo \"$SHELL_CMD_TEMPLATE\"")
	assert "get djlab changed password" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
		python -c 'print(__import__("djlab").get_djlab_config(\
			"djlab.jupyter_server.password"))'
	END
	) == 'test' ]" $LINENO
}
# set image context
REF=$(eval "echo $(cat dist/${DISTRO}/docker-compose.yaml | grep 'image:' | awk '{print $2}')")
TAG=$(echo $REF | awk -F':' '{print $2}')
IMAGE=$(echo $REF | awk -F':' '{print $1}')
SHELL_CMD_TEMPLATE="docker run --rm -i \$SHELL_CMD_FLAGS $REF \
	$([ ${DISTRO} == 'debian' ] && echo bash || echo sh) -c"
# determine reference size
if [ $DISTRO == alpine ] && [ $PY_VER == '3.9' ]; then
	SIZE_LIMIT=623
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.8' ]; then
	SIZE_LIMIT=581  # 657
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.7' ]; then
	SIZE_LIMIT=590  # 648
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.6' ]; then
	SIZE_LIMIT=503  # 648
elif [ $DISTRO == debian ] && [ $PY_VER == '3.9' ]; then
	SIZE_LIMIT=743
elif [ $DISTRO == debian ] && [ $PY_VER == '3.8' ]; then
	SIZE_LIMIT=697  # 890
elif [ $DISTRO == debian ] && [ $PY_VER == '3.7' ]; then
	SIZE_LIMIT=701  # 880
elif [ $DISTRO == debian ] && [ $PY_VER == '3.6' ]; then
	SIZE_LIMIT=614  # 880
fi
SIZE_LIMIT=$(echo "scale=4; $SIZE_LIMIT * 1.03" | bc)
# verify size minimal
SIZE=$(docker images --filter "reference=$REF" --format "{{.Size}}" | awk -F'MB' '{print $1}')
assert "minimal footprint" "(( $(echo "$SIZE <= $SIZE_LIMIT" | bc -l) ))" $LINENO
# run tests
SHELL_CMD=$(eval "echo \"$SHELL_CMD_TEMPLATE\"")
validate
