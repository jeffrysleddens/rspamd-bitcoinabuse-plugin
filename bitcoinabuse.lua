--[[

  BitcoinAbuse lookup for rspamd
  Version: 1.0
  by Jeffry Sleddens / Rotterdam University of Applied Sciences

--]]
local rspamd_logger = require "rspamd_logger"
local rspamd_http = require "rspamd_http"
local ucl = require "ucl"

local N = 'bitcoinabuse'
local symbol_bitcoinabuse = 'BITCOINABUSE'
local symbol_bitcoinaddr = 'BITCOIN_ADDR'
local score_bitcoinabuse = 15.0
local opts = rspamd_config:get_all_opt(N)

-- Default settings
local api_url = 'https://www.bitcoinabuse.com/api/reports/check'
local api_token = 'no_api_token'

local function check_bitcoinabuse(task)
    local function check_bitcoinabuse_cb(err, code, body, headers)
        if err then
            rspamd_logger.errx('API call to bitcoinabuse.com failed: %s', err)
            return
        end

        rspamd_logger.debugx('bitcoinabuse.com returned: %s', body)

        local ucl_parser = ucl.parser()
        local ok, ucl_err = ucl_parser:parse_string(tostring(body))
        if not ok then
            rspamd_logger.errx('error parsing json response: %s', N, ucl_err)
            return
        end
        local result = ucl_parser:get_object()

        if result['count'] ~= nil and result['count'] > 0 then
          task:insert_result(symbol_bitcoinabuse, 1, result['address'] .. ':count=' .. result['count'])
        end
    end

    if not task:has_symbol(symbol_bitcoinaddr) then
      return false
    end

    local bitcoin_address = task:get_symbol(symbol_bitcoinaddr)[1].options[1]

    rspamd_logger.debugx('querying bitcoinabuse.com for address %s', bitcoin_address)
    rspamd_http.request({
        url = api_url .. '?address=' .. bitcoin_address .. '&api_token=' .. api_token,
        callback = check_bitcoinabuse_cb,
        task = task,
        mime_type = 'text/plain',
    })
end

if opts then
    if opts.api_token then
        api_token = opts.api_token

        local id = rspamd_config:register_symbol({
            name = symbol_bitcoinabuse,
            score = score_bitcoinabuse,
            callback = check_bitcoinabuse
        })
        rspamd_config:register_dependency(symbol_bitcoinabuse, symbol_bitcoinaddr)

        rspamd_logger.infox('%s module is configured and loaded', N)
    else
        rspamd_logger.infox('%s module missing api_token configuration, not loaded', N)
    end

else
    rspamd_logger.infox('%s module not configured', N)
end
