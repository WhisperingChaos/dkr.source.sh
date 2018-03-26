dkr_connect_test(){
	docker version > /dev/null
}
###############################################################################
#	Purpose
#		Apply a regexp pattern to filter output of docker image command
#		that returns locally known image repository name and tag.
###############################################################################
dkr_image_name_filter(){
	local -r imagepattern="$1" # extended regexp supported by grep.  applied to image's '<repository>:<tag>' name.

	local -r imageoutfmt='{{ .Repository }}:{{.Tag}}' 
	docker images --format="$imageoutfmt" | grep -E "$imagepattern" 
}
###############################################################################
#	Purpose
#		Delete local images whose repository:tag match regex pattern.
###############################################################################
dkr_image_destroy(){
	local -r imagepattern="$1" # extended regexp supported by grep. applied to image's '<repository>:<tag>' name.
	local -r deleteForce="$2"  # specify 'f' to force image delete. 

	if [ "$deleteForce" == 'f' ]; then
		local forceOpt='-f'
	fi
	local -r forceOpt
	local -r imageList="$(dkr_image_find "$imagePattern")"
	if [ -n "$imageList" ]; then  
		docker rmi $forceOpt $imageList
	fi
    # destroying something that doesn't exist is same as
	# successfully destroying something that does.
}
###############################################################################
#	Purpose
#		Run an images. A Can act as a declarator.
###############################################################################
dkr_image_run(){
	docker run "${@}"
}
###############################################################################
#	Purpose
#		Build image. Can act as a declarator.
###############################################################################
dkr_image_build(){
	docker build "${@}"
}
