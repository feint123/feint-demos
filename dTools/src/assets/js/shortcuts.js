import { register, isRegistered } from '@tauri-apps/api/globalShortcut';
import { WebviewWindow, LogicalPosition } from '@tauri-apps/api/window';
import {mousePosition} from './tools';
const shortKeys = [{
    key:'CmdOrControl+Shift+V',
    action: async () => {
        const qcb_window = WebviewWindow.getByLabel('qcb');
        const pos = await mousePosition();
        qcb_window.setPosition(new LogicalPosition(pos.x - 170, pos.y - 50));
        qcb_window.show();
        qcb_window.setFocus();
    }}]

export async function shortcuts() {
    shortKeys.forEach(async (row, index, arr)  => {
        const isReg = await isRegistered(row.key);
        if (!isReg) {
            await register(row.key, row.action );
        }
    })
    
}