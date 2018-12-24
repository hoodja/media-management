./storeVideo.sh && ./storeImages.sh  && echo root | sshpass ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 root@${STORE_IP:?'no STORE_IP set'} ./indexFiles.sh
