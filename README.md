Leverages remote host nginx and ssh remote port forwarding to expose localhost port.
Something similar to `ngrok` but self-hosted.  

Ex.

```
user@host:~/callback-tunnel$ ./create-endpoint.sh
-u public url
-p local port
-h user@host
user@host:~/callback-tunnel$ ./create-endpoint.sh -u example.com -p 8080 -h root@10.8.0.1
Mapping public endpoint Sohp97gj8TkIM.example.com to local port 8080
Selectd proxy port is 50986
http://Sohp97gj8TkIM.example.com
Press enter to close the Sohp97gj8TkIM.example.com tunnel to local port 8080
```
