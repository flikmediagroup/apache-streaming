# Apache-streaming

Based on [cloudposse/apache-streaming](https://github.com/cloudposse/apache-streaming).

Changes to original:
- disable mod cgi
- disable conf db-env

# Changelog

## [1.0.1] - 2019-11-26

### Added
- Output logs to /dev/stdout
- Use RemoteIPHeader and change combined logformat to get real ip from proxy