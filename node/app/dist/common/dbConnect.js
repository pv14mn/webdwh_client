import { default as postgres } from "postgres";
import { registerCleanupCB } from "./cleanupSequence.js";
const maxConnections = Number(process.env.DB_MAX_CONNECTIONS) || 10;
export const sql = postgres(process.env.URL4NODE_LOADER ?? "", {
    max: maxConnections,
});
registerCleanupCB(async () => await sql.end());
