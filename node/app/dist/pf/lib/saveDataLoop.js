import { sql } from "../../common/dbConnect.js";
export async function saveDataLoop(cidRun, bs) {
    bs.forEach(async (buff) => {
        const evts = [];
        const scode = [];
        const tick = [];
        const icode = [];
        const a = [];
        const b = [];
        const nch = [];
        const lp = [];
        const nchl = [];
        const tickCnt = [];
        const extts = [];
        const sidRun = [];
        buff.values().forEach((o) => {
            evts.push(o.evts);
            scode.push(o.S);
            tick.push(o.TICK);
            icode.push(o.I);
            a.push(o.A ?? null);
            b.push(o.B ?? null);
            nch.push(o.NCH ?? null);
            lp.push(o.LP ?? null);
            nchl.push(o.NCHL ?? null);
            tickCnt.push(o.tickCnt);
            extts.push(o.extts);
            sidRun.push(o.sidRun);
        });
        await sql `CALL pf.load_batch(${cidRun}, ${evts}, ${scode}, ${tick}, ${icode}, ${a}, ${b}, ${nch}, ${lp}, ${nchl}, ${tickCnt}, ${extts}, ${sidRun})`;
        buff.clear();
    });
}
