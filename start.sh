
jenkins_port=9001

docker stop myjenkins

docker build --no-cache  -t myjenkins .
docker run -p ${jenkins_port}:8080 --name myjenkins myjenkins:latest
# docker run -p 9001:8080 --name myjenkins myjenkins:latest