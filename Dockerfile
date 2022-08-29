# Build this manually from Dockerfiles/Dockerfile and push to DockerHub to rebuild changes.
# TODO: Automate this process.
FROM wpengine/gha:base-stable

# Add any additional dockerfile commands after the import FROM wpengine/gha:base-stable
ADD entrypoint.sh /entrypoint.sh
ADD exclude.txt /exclude.txt
ENTRYPOINT ["/entrypoint.sh"]
