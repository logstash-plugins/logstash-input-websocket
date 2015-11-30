## 3.0.0
 - The "mode" option's "server" value has been removed since server mode
   isn't supported (and never has been). This could potentially affect
   existing users who have had "mode => server" set but in reality have
   been using client mode all along.
 - The "url" option is now mandatory.

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

