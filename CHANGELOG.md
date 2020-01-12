## 4.0.5
  - Fix socket leaks
  - Add configuration for connection retrying with backoff.
  - Add support for plugin shutdown.

## 4.0.4
  - Docs: Set the default_codec doc attribute.

## 4.0.3
  - Update gemspec summary

## 4.0.2
  - Fix some documentation issues

## 4.0.0
 - internal: Upgrade event API dependency to support Logstash 2.4 & 5.x.
 - internal: Bump dependency to ftw library to fix compatibility problem.

## 3.0.2
 - Depend on logstash-core-plugin-api instead of logstash-core,
   removing the need to mass update plugins on major releases of
   logstash

## 3.0.1
 - New dependency requirements for logstash-core for the 5.0 release

## 3.0.0
 - The "mode" option's "server" value has been removed since server mode
   isn't supported (and never has been). This could potentially affect
   existing users who have had "mode => server" set but in reality have
   been using client mode all along.
 - The "url" option is now mandatory.

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly
   allows Logstash to instruct input plugins to terminate gracefully,
   instead of using Thread.raise on the plugins' threads. Ref:
   https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

