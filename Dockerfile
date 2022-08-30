FROM wpengine/gha:v1
ADD entrypoint.sh /entrypoint.sh
ADD exclude.txt /exclude.txt
ENTRYPOINT ["/entrypoint.sh"]

# TODO: Add any additional dockerfiles to the main Dockerfile after the import FROM wpengine/gha:v1
# TEST: another change
