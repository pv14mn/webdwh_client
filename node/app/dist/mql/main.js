import { getIdRun } from "../common/getIdRun.js";
import { logger } from "../common/logger.js";
import { getNatsConnection } from "../common/natsConnect.js";
import { waitForTable } from "../common/waitForTable.js";
import { mkBufferStream } from "./lib/BufferStream.js";
import { saveDataLoop } from "./lib/saveDataLoop.js";
await waitForTable("mql", "tickers");
const cidRun = await getIdRun();
logger.info({
    cidRun: cidRun,
    target: "mql",
});
const nc = await getNatsConnection();
const bs = await mkBufferStream(nc);
await saveDataLoop(cidRun, bs);
