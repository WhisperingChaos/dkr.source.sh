#!/bin/bash
#!/bin/bash
test_dkr_TEST_NAMESPACE='dkr_test_'
config_executeable(){
	local -r myRoot="$1"
	# include components required to create this executable
	local mod
	for mod in $( "$myRoot/sourcer/sourcer.sh" "$myRoot"); do
		source "$mod"
	done
}


test_dkr_connect(){
	assert_true dkr_connect_test
}

test_dkr_image_name_filter(){
	assert_halt
	# left over test state or potential overlap
	# user must make decision.
	assert_false 'dkr_image_name_filter "$test_dkr_TEST_NAMESPACE.*"'
	assert_continue
	test_dkr_image_create 5
	assert_true 'dkr_image_name_filter "$test_dkr_TEST_NAMESPACE[0-9]:" > /dev/null'
	assert_true test_dkr_images_namespace_clean
}


test_dkr_image_create(){
	local -ri imageCnt=$1

	assert_true '[ $imageCnt -gt -1 ]' 
	for (( i = 0; i < imageCnt; i++)){
		test_dkr_scratch "$i" | docker build -t $test_dkr_TEST_NAMESPACE${i} - >/dev/null
	}
}
test_dkr_scratch(){
	cat <<DOCKERFILE
FROM scratch
ENV INSTANCE=$1
DOCKERFILE
}

test_dkr_images_namespace_clean(){
	test_dkr_images_remove "$(test_dkr_images_namespace_scan)"
}
test_dkr_images_namespace_scan(){
	 docker images --format='{{ .Repository }}:{{.Tag}}' 2>/dev/null  \
		| grep -E "$test_dkr_TEST_NAMESPACE.*"
}
test_dkr_images_remove(){
	local -r imageList="$1"
	if [ -z "$imageList" ]; then
		return
	fi 
	docker rmi $imageList >/dev/null
}


main(){
	config_executeable "$(dirname "${BASH_SOURCE[0]}")"
	assert_halt
	local imageCleanList="$(test_dkr_images_namespace_scan)"
	if [ "$1" == '-c' ] && [ -n "$imageCleanList" ];  then 
		assert_true 'test_dkr_images_remove "$imageCleanList"'
		imageCleanList=""
	fi
	assert_true '[ -z "$imageCleanList" ]'
	assert_continue
	test_dkr_connect
	test_dkr_image_name_filter
	assert_return_code_set
}
main "${@}"


