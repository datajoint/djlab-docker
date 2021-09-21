# Update djlab config based on env vars
CURR_CONFIG=$(yq -Y "." "${DJLAB_CONFIG}")
for line in $(env | grep Djlab | sort); do
	KEY="$(echo $line | cut -d'=' -f1)"
	KEY="$(echo "$KEY" | sed -r 's/^([A-Z])/\L\1/g' | \
		sed -r 's/([a-z0-9_])([A-Z])/\1_\L\2/g' | sed -r 's/__/\./g')"
	VALUE="$(echo $line | cut -d'=' -f2)"
	CURR_CONFIG="$(echo "${CURR_CONFIG}" | yq -Y ". | .${KEY} = \"${VALUE}\"")"
done
echo "${CURR_CONFIG}" > "${DJLAB_CONFIG}"
# Run command
[ "$(pwd)" != "/home/anaconda" ] || cd ~
"$@"