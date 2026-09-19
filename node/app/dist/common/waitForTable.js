import { setTimeout as sleep } from "node:timers/promises";
import { sql } from "./dbConnect.js";
import { logger } from "./logger.js";
async function _waitForTableOnce(schema, table, withData) {
    try {
        const data = await sql.unsafe(`select 1 from ${schema}.${table} limit 1`);
        if (withData) {
            return data.length > 0;
        }
        else {
            return true;
        }
    }
    catch (error) {
        if (error &&
            typeof error === "object" &&
            "code" in error &&
            error.code === "42P01") {
            logger.error(`relation "${schema}.${table}" does not exist`);
        }
        else {
            logger.error(error);
            throw error;
        }
        return false;
    }
}
export async function waitForTable(schema, table, withData = false) {
    while (!(await _waitForTableOnce(schema, table, withData))) {
        await sleep(1000);
    }
}
