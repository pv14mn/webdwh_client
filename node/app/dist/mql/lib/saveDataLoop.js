import { sql } from "../../common/dbConnect.js";
export async function saveDataLoop(cidRun, bs) {
    bs.forEach(async (obj) => {
        if (obj.dictData.length > 0) {
            await sql `CALL mql.load_dict(${obj.dictData})`;
            obj.dictData.length = 0;
        }
        if (obj.factData.size > 0) {
            const data = obj.factData.values().toArray();
            obj.factData.clear();
            await sql `CALL mql.load_fact(${cidRun}, ${data})`;
        }
    });
}
