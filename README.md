### ⚠️ `config/wazuh_indexer/internal_users` contains demo credentials. Don't forget to rmeove them before deploying on production. These credentials are publicly accessible !!! ⚠️

Custom logstash image (with opensearch output plugin) isn't yet published on a repo. Don't forget to run `docker build -t wazuh_logstash:custom -f Dockerfile.logstash .` to build the image before running the instance.

TLS certs are not included inside the git repo. Run `docker-compose -f generate-indexer-certs.yml run --rm generator` to get your own certificates 👌

If you plan to update anything, take a look at the [compatibility matrix](https://www.elastic.co/support/matrix) to prevent your setup to stop working 

More developped README comming soon !