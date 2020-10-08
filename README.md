# rspamd-bitcoinabuse-plugin
Rspamd plugin to check bitcoin addresses via the bitcoinabuse API

## How to use

Place the bitcoinabuse.lua plugin in /etc/rspamd/plugins.d/ and add the following to the /etc/rspamd/rspamd.conf.local configuration file:
```
bitcoinabuse {
    api_token = "<your bitcoinabuse.com api token>";
}
```

## Authors

* **Jeffry Sleddens** - [jeffrysleddens](https://github.com/jeffrysleddens)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details

## References

* Rspamd: <https://rspamd.com>
* BitcoinAbuse: <https://www.bitcoinabuse.com/>
