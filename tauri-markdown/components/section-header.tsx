import { Button } from "@nextui-org/button";
import { FC } from "react";

interface SectionHeaderInfo {
    title: string | undefined;
}
export const SectionHeader: FC<SectionHeaderInfo> = ({ title }) => {
    return (
        <div className="flex flex-row items-center justify-between px-2 pb-4">
            <p className="text-lg font-bold mt-2">{title}</p>
            <Button variant="faded" size="sm">查看更多</Button>
        </div>
    );
}
