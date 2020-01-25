# FT_SERVER

## Nginx

In the nginx configuration we can find a first part which redirects all HTTP traffic to HTTPS. We can find more information here: 

https://bjornjohansen.no/redirect-to-https-with-nginx

and here

https://www.linode.com/docs/web-servers/nginx/how-to-configure-nginx/

After redirecting to port 443 where we declare the ssl certificates -which we create on the Dockerfile-, establish the root, index, server name y locations.

