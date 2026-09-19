import { sql } from "./dbConnect.js";
export async function getIdRun() {
    const [row] = await sql `select nextval('webdwh_aux.id_run_seq')`;
    return parseInt(row.nextval, 10);
}
