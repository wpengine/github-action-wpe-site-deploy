# Pull the base image from DockerHub. 
# If you need to make changes to the base image, rebuild it manually from `Dockerfiles/Dockerfile` and push to DockerHub.
# TODO: Automate this process to track stable tags and custom branch tags(based on regex).
FROM wpengine/gha:base-stable

# Add any additional directives after the import FROM wpengine/gha:base-stable
ADD entrypoint.sh /entrypoint.sh
ADD exclude.txt /exclude.txt
ENTRYPOINT ["/entrypoint.sh"]
