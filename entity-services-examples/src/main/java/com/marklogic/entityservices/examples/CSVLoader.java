package com.marklogic.entityservices.examples;

import com.fasterxml.jackson.databind.MappingIterator;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.marklogic.client.DatabaseClient;
import com.marklogic.client.DatabaseClientFactory;
import com.marklogic.client.document.ServerTransform;
import com.marklogic.client.io.StringHandle;
import com.marklogic.datamovement.DataMovementManager;
import com.marklogic.datamovement.JobReport;
import com.marklogic.datamovement.JobTicket;
import com.marklogic.datamovement.WriteHostBatcher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

/**
 *
 */
public class CSVLoader extends ExamplesBase {


    private static Logger logger = LoggerFactory.getLogger(CSVLoader.class);


    private CsvSchema bootstrapSchema;
    private ObjectMapper csvMapper;

    private CSVLoader() throws IOException {
        super();

        bootstrapSchema = CsvSchema.emptySchema().withHeader();
        csvMapper = new CsvMapper();


    }

    private void go() throws InterruptedException {


        logger.info("job started.");

        File dir = new File("/home/cgreer/third_party/offshore_leaks_csvs-20160513/");
        //File dir = new File("/path/to/CSVs");

        WriteHostBatcher batcher = moveMgr.newWriteHostBatcher()
                .withBatchSize(600)
                .withThreadCount(16)
                .onBatchSuccess( (client, batch) ->  logger.info(getSummaryReport()) )
                .onBatchFailure(
                        (client, batch, throwable) -> {
                            logger.warn("FAILURE on batch:" + batch.toString() + "\n",
                                    throwable);
                            throwable.printStackTrace();
                        }
                );

        ticket=moveMgr.startJob(batcher);

        try( DirectoryStream<Path> stream = Files.newDirectoryStream(dir.toPath(), "*.csv") )
        {
            for (Path entry : stream) {
                logger.info("Adding " + entry.getFileName().toString());

                MappingIterator<ObjectNode> it = csvMapper.readerFor(ObjectNode.class)
                        .with(bootstrapSchema)
                        .readValues(entry.toFile());
                long i=0;
                while (it.hasNext()) {
                    ObjectNode jsonNode = it.next();
                    String jsonString = mapper.writeValueAsString(jsonNode);

                    String uri = entry.getFileName().toString() + "-" + Long.toString(i++) + ".json";
                    batcher.add(uri, new StringHandle(jsonString));
                    if (i % 1000 == 0) logger.info("Inserting JSON document " + uri);
                }
                it.close();
            }
        }

        catch( IOException e )

        {
            e.printStackTrace();
        }

        batcher.flush();
    }

    private String getSummaryReport() {
        JobReport report = moveMgr.getJobReport(ticket);
        if (report == null) {
            // is this a bug or not implemented TODO
            return "Report is null";
        }
        else {
            return "batches: " + report.getSuccessBatchesCount() +
                    ", bytes: " + report.getBytesMoved() +
                    ", failures: " + report.getFailureBatchesCount();
        }
    }

    public static void main(String[] args) throws Exception {

        CSVLoader integrator = new CSVLoader();
        integrator.go();

    }
}
