# SolrDataImportBatch

CMD DOS/WINDOWS Batch script for request CURL SOLR for long dataimport, and check status / result.

The script requests (CURL) to initiate dataimport from a Solr core, and then check for the results requesting (CURL) status from the dataimport.
The script check for some basic erros do some retries and stores everithing on /log folder - date file.

Feel free to modify the script to other aplications. 
