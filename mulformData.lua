package.path  = '/usr/local/nginx/conf/?.lua;;' .. package.path

local args = {}
local upload = require "resty.upload";
local cjson = require "cjson"
local chunk_size = 4096
local form, err = upload:new(chunk_size)

function split(s, delim)

    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return nil
    end
 
    local start = 1
    local t = {}

    while true do
        local pos = string.find (s, delim, start, true)
        
        if not pos then
            break
        end
 
        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end

    table.insert (t, string.sub (s, start))
 
    return t
end


function post_form_data(form,err)

  if not form then
    ngx.say(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
  end

  form:set_timeout(1000)

  local paramTable = {["s"]=1}
  local tempkey = ""
  while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return {}
    end
    local key = ""
    local value = ""
    if typ == "header" then
    	local key_res = split(res[2],";")
   	key_res = key_res[2]
    	key_res = split(key_res,"=")
    	key = (string.gsub(key_res[2],"\"",""))
    	paramTable[key] = ""
    	tempkey = key
    end	
    if typ == "body" then
    	value = res
    	if paramTable.s ~= nil then paramTable.s = nil end
    	paramTable[tempkey] = value
    end
    if typ == "eof" then
        break
    end
  end
  return paramTable
 end

args = post_form_data(form,err)		

function table2json(t)
        local function serialize(tbl)
                local tmp = {}
                for k, v in pairs(tbl) do
                        local k_type = type(k)
                        local v_type = type(v)
                        local key = (k_type == "string" and "\"" .. k .. "\":")
                            or (k_type == "number" and "")
                        local value = (v_type == "table" and serialize(v))
                            or (v_type == "boolean" and tostring(v))
                            or (v_type == "string" and "\"" .. v .. "\"")
                            or (v_type == "number" and v)
                        tmp[#tmp + 1] = key and value and tostring(key) .. tostring(value) or nil
                end
                if table.maxn(tbl) == 0 then
                        return "{" .. table.concat(tmp, ",") .. "}"
                else
                        return "[" .. table.concat(tmp, ",") .. "]"
                end
        end
        assert(type(t) == "table")
        return serialize(t)
end

ngx.var.request_body_data = table2json(args);
ngx.say('{"code":0,"message":""}');

