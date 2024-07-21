"use client"


import React, { FC } from "react";
import { Card, CardFooter, Image, Button, Link, CardHeader, CardBody } from "@nextui-org/react";
import { ToolsItem } from "@/app/settings/page";
import { motion } from "framer-motion";
import { useRouter } from "next/navigation";


export const WebsiteCard = ({ param }: { param: ToolsItem }) => {
    const router = useRouter();
    return (
        <Card key={param.id} isPressable onClick={()=>{router.push(`/details?toolId=${param.id}`)}} className="w-[280px] h-[280px] col-span-1">
            <CardHeader className="pb-0 pt-2 px-4 flex-col items-start text-left">
                <p className="text-tiny uppercase font-bold truncate w-full">{param.categorys?.join("、")}</p>
                <small className="text-default-500 truncate w-full">{param.description}</small>
                <h4 className="font-bold text-large truncate w-full">{param.title}</h4>
            </CardHeader>
            <CardBody className="py-2">
                <motion.div whileHover={{ scale: 1.05 }} // 鼠标悬停时放大到1.1倍
                    transition={{ type: 'spring', stiffness: 100 }}>
                    <Image
                        alt="Card background"
                        className="w-[270px] object-cover rounded-xl h-[180px]"
                        src={param.cover_image_url}
                    />
                </motion.div>


            </CardBody>

        </Card>

    );
}
