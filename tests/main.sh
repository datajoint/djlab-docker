#!/bin/bash

assert ()
{
	E_PARAM_ERR=98
	E_ASSERT_FAILED=99

	if [ -z "$3" ]; then
		return $E_PARAM_ERR
	fi

	lineno=$3
	# echo "$2"
	if ! eval "$2"; then
		echo "Assertion ($1) failed:  \"$2\""
		echo "File \"$0\", line $lineno"
		exit $E_ASSERT_FAILED
	else
		echo "---------------- TEST[$SHELL_CMD_FLAGS]: $1 ✔️ ----------------" | \
			tr -d '\t'
	fi
}
validate () {
	[ "$PY_VER" == "3.6" ] || \
		assert "debugger available" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
			pip list --format=freeze 2>/dev/null | \
				grep ipykernel | \
				grep -qv "ipykernel==5\." && \
			echo done
		END
		) == 'done' ]" $LINENO
	SHELL_CMD_FLAGS="-e Djlab_JupyterServer_DisplayFilepath=/home/anaconda/README.md"
	SHELL_CMD=$(eval "echo \"$SHELL_CMD_TEMPLATE\"")
	assert "check landing page" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
		jupyter lab > /tmp/logs 2>&1 & \
		sleep 5 && \
		cat /tmp/logs | \
			grep -q "http://127.0.0.1:8888/lab/tree/anaconda/README.md" && \
		echo done
	END
	) == 'done' ]" $LINENO
	assert "get djlab default password with magic" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
		ipython -c "%djlab djlab.jupyter_server.password"
	END
	) == 'datajoint' ]" $LINENO
	SHELL_CMD_FLAGS="-e Djlab_JupyterServer_Password=test"
	SHELL_CMD=$(eval "echo \"$SHELL_CMD_TEMPLATE\"")
	assert "get djlab changed password with magic" "[ $($SHELL_CMD 'eval "$(cat)"' <<-END
		ipython -c "%djlab djlab.jupyter_server.password"
	END
	) == 'test' ]" $LINENO
}
# set image context
REF=$(eval \
	"echo $(cat dist/${DISTRO}/docker-compose.yaml | grep 'image:' | awk '{print $2}')")
TAG=$(echo $REF | awk -F':' '{print $2}')
IMAGE=$(echo $REF | awk -F':' '{print $1}')
SHELL_CMD_TEMPLATE="docker run --rm -i \$SHELL_CMD_FLAGS $REF \
	$([ ${DISTRO} == 'debian' ] && echo bash || echo sh) -c"
# determine reference size
if [ $DISTRO == alpine ] && [ $PY_VER == '3.9' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=623
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.8' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=581  # 657
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.7' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=590  # 648
elif [ $DISTRO == alpine ] && [ $PY_VER == '3.6' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=503  # 648
elif [ $DISTRO == debian ] && [ $PY_VER == '3.9' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=743
elif [ $DISTRO == debian ] && [ $PY_VER == '3.8' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=697  # 890
elif [ $DISTRO == debian ] && [ $PY_VER == '3.7' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=701  # 880
elif [ $DISTRO == debian ] && [ $PY_VER == '3.6' ] && [ $PLATFORM == 'linux/amd64' ]; then
	SIZE_LIMIT=614  # 880
fi
SIZE_LIMIT=$(echo "scale=4; $SIZE_LIMIT * 1.05" | bc)
# verify size minimal
SIZE=$(docker images --filter "reference=$REF" --format "{{.Size}}" | awk -F'MB' '{print $1}')
assert "minimal footprint" "(( $(echo "$SIZE <= $SIZE_LIMIT" | bc -l) ))" $LINENO
# run tests
SHELL_CMD=$(eval "echo \"$SHELL_CMD_TEMPLATE\"")
validate
