FROM wpengine/gha:v1
ADD entrypoint.sh /entrypoint.sh
ADD exclude.txt /exclude.txt
ENTRYPOINT ["/entrypoint.sh"]
