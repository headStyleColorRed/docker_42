docker stop $(docker ps -aq) && docker rm $(docker ps -aq) ;
docker build . -t $1 ;
docker run -it --rm -d -p 80:80 -p 443:443 --name ft_server  $1 ;