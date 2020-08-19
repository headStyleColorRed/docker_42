docker build . -t $1 ;
docker run  -d -p 80:80 --name ft_server  $1 ;