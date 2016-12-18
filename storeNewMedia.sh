./storeVideo.sh && ./storeImages.sh  && ssh root@${STORE_IP:?'no STORE_IP set'} ./indexFiles.sh
