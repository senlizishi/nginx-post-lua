# nginx-post-form-data
A Lua script that enables Nginx to receive Post requests in form-data format.

### Common form-data data formats
 ```
 POST /users/ HTTP/1.1
Host: localhost:8000
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

------WebKitFormBoundary7MA4YWxkTrZu0gW--,
Content-Disposition: form-data; name="country"

China
------WebKitFormBoundary7MA4YWxkTrZu0gW--
Content-Disposition: form-data; name="city"

GZ
------WebKitFormBoundary7MA4YWxkTrZu0gW--
 ```
 In the header information, **Content-Type: multipart/form-data; boundary=
----WebKitFormBoundary7MA4YWxkTrZu0gW** specifies the format and boundary (split string) respectively, and uses the string specified by the boundary as the split in the body, which can be easily restored to the form of key:value.
### Lua-resty-upload
This uses the [lua-nginx-module](https://github.com/openresty/lua-resty-upload) provided by OpenResty to support Nginx Lua extensions.

### How to use
 ```
 location ~ ^/demo/(\w+) {
            ...
            set $request_body_data '';
            content_by_lua_file conf/lua-script/mulformData.lua;
            ...
        }
 ```
### Article
[Nginx Post(form-data)](https://www.toutiao.com/article/6989804754533040670/)
